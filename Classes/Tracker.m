//
//  Tracker.m
//  Tracker Core Data
//
//  Created by Evan Light on 6/29/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import "Tracker.h"
#import "ASIHTTPRequest.h"
#import "TouchXML.h"
#import "Project.h"
#import "Credentials.h"
#import "XPathHelper.h"
#import "AuthorizationParser.h"

@implementation Tracker

static Tracker *instance;
static NSManagedObjectContext *managedObjectContext;

@synthesize credentials, managedObjectContext, projects, offline;

+ (void) setManagedObjectContext: (NSManagedObjectContext*) newMoc {
	managedObjectContext = newMoc;
}

+ (id) getInstance {
	if (instance == NULL) {
		instance = [[Tracker alloc] initWithManagedObjectContext:(NSManagedObjectContext *) managedObjectContext];
		instance.offline = YES;
	}
	return instance;
}

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)newManagedObjectContext {
	self = [super init];
	self.managedObjectContext = newManagedObjectContext;
	self.projects = [[NSMutableArray alloc] init];
	[self loadOrCreateCredentials];
	return self;
}

- (void) fetchProjects {
	NSLog(@"fetchProjects");
	if (![self hasAuthenticated]) {
		NSLog(@"haven't auth'd yet");
		return;
	}
	NSDictionary *headers = [NSDictionary dictionaryWithObject: self.credentials.guid 
														forKey: @"X-TrackerToken"];
	[self performAsynchronousGetToURL:@"https://www.pivotaltracker.com/services/v3/projects"
						  withHeaders:headers
							onSuccess:@selector(projectsFetched:)
							   onFail:@selector(projectFetchFailed:)
	];
}

- (void) projectsFetched:(ASIHTTPRequest*)request {
	offline = NO;
	[self deleteProjects];		
	[self updateProjectsFromXML: [request responseString]];
	[self identifyMyNameFromProjectXML: [request responseString]];
	
	for (Project *project in self.projects) {
		//		NSLog(@"Project %@ has ID %d", project.name, [project.trackerId integerValue]);
		[project fetchStories];
	}	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"projectsFetched" object:nil];
}	

- (void) projectFetchFailed:(ASIHTTPRequest*)request {
	offline = YES;
	[self loadProjectsFromDB];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"projectFetchFailed" object:nil];		
}

- (void) loadProjectsFromDB {
	// Create the request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	// Set the entity type to 'Project' and use our NSManagedObojectContext
	NSEntityDescription *entity = 
		[NSEntityDescription entityForName:@"Project" 
					inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];

	// Set the sort key and order
	NSSortDescriptor *sortDescriptor = 
		[[NSSortDescriptor alloc] initWithKey:@"trackerId" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];   
	[request setSortDescriptors:sortDescriptors];
	
	// Now perform the query	
	NSError *error = nil;
	NSArray *immutableProjects = 
		[self.managedObjectContext executeFetchRequest:request error:&error];
	if (error) {
		NSLog(@"Unresolved error %@", error);
		abort();
	}	
	
	self.projects = [[NSMutableArray alloc] initWithArray:immutableProjects];	
}

- (Project*) findProjectWithID:(NSInteger)id {
	Project *retval = nil;
//	NSLog(@"Searching for project id %d", id);
	for (Project *project in self.projects) {
//		NSLog(@"Comparing to %d", [project.trackerId integerValue]);
		if([project.trackerId integerValue] == id) {
			retval = project;
			break;
		}
	}
	return retval;
}

- (void) deleteProjects {
	NSArray * result = [self loadEntitiesOfType: @"Project"];
	for (id project in result) {
		[managedObjectContext deleteObject: project];
	}
	[self.projects removeAllObjects];
}

- (BOOL) hasCredentials {
	BOOL retval = NO;
	if (self.credentials) {
		if (self.credentials.username && self.credentials.password) {
			retval = YES;
		} else {
			retval = NO;
		}
	} else {
		[self loadOrCreateCredentials];
		retval = NO;
	}
	return retval;
}

/* Load or create Credenitals through Core Data */
- (void)loadOrCreateCredentials {
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Credentials" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
	NSError *error = nil;
	NSArray *array = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error != nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
	}
	
	if (array != nil && [array count] != 0) {
		self.credentials = [array objectAtIndex:0];
	} else {
		self.credentials = [NSEntityDescription insertNewObjectForEntityForName:@"Credentials" inManagedObjectContext: managedObjectContext];
		[managedObjectContext save:&error];
		if (error) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}	
	}
	
    [fetchRequest release];
} 

- (void) identifyMyNameFromProjectXML:(NSString*)xml {
	//NSLog(@"%@", xml);
	if(self.credentials.fullname) {
		NSLog(@"My full name is %@", self.credentials.fullname);
		return;
	}
	
	CXMLDocument *doc = [[CXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
	NSArray *memberships = [doc nodesForXPath: @"//membership" error: nil];

	if ([memberships count] != 0) {

		NSEnumerator *membershipEnum = [memberships objectEnumerator];
		CXMLNode *membership;
		while (membership = [membershipEnum nextObject]) {
			NSString *emailForMembership = [[[membership nodesForXPath:@".//email" error:nil] objectAtIndex:0] stringValue];
			if([emailForMembership isEqualToString:[self.credentials.username lowercaseString]]) {
				self.credentials.fullname = [[[membership nodesForXPath:@".//name" error:nil] objectAtIndex:0] stringValue];
			}
		}	
		NSLog(@"My full name is %@", self.credentials.fullname);
		[self.managedObjectContext save:nil];
	}
	[doc release];
}

/* Authenticates the user, given Credentials, to Tracker, parses the XML for the GUID 
 for the user, and stores the GUID in the user's Credentials. */
- (void) authenticate {
	NSLog(@"authenticateToTracker");
	if (self.credentials.username == @"") {
		NSLog(@"No creds, dude");
	}
	[self performAsynchronousGetToURL:@"https://www.pivotaltracker.com/services/v3/tokens/active"
						  withHeaders:nil
							onSuccess:@selector(authenticatedSuccessfully:)
							   onFail:@selector(failedToAuthenticate:)
	];
} 

- (BOOL) hasAuthenticated {
	return credentials.guid != nil;
}

- (void) authenticatedSuccessfully:(ASIHTTPRequest*)request {
	NSString *responseXML = [request responseString];
	AuthorizationParser *parser = [[AuthorizationParser alloc] initWithXML:responseXML];
	[parser parse];
	self.credentials.guid = parser.guid;
	[self.managedObjectContext save:nil];		
	
	[parser release];
	NSLog(@"auth success");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"authenticated" object:nil];
}

- (void) failedToAuthenticate:(ASIHTTPRequest*)request {
	offline = YES;
	NSLog(@"auth failed: %@", request.error);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"failedAuthentication" object:nil];	
}

#pragma mark  -
#pragma mark  XML Parsing

- (void) updateProjectsFromXML:(NSString *)xml {
//	NSLog(@"%@", xml);
	CXMLDocument *doc = [[CXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
	NSArray *projectNodesArray = [doc nodesForXPath: @"//project" error: nil];
	Project *project;
	for (id projectNode in projectNodesArray) {
		project = [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext: managedObjectContext];
		project.name = [[XPathHelper getInstance] findStringForElement:@"name" inNode:projectNode];

		NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];		
		
		NSString *idStr = [[XPathHelper getInstance] findStringForElement:@"id" inNode:projectNode];
		project.trackerId = [f numberFromString: idStr];
		
		NSString *velocityStr = [[XPathHelper getInstance] findStringForElement:@"current_velocity" inNode:projectNode];
		project.currentVelocity = [f numberFromString: velocityStr];
		
		NSString *velocitySchemeStr = [[XPathHelper getInstance] findStringForElement:@"velocity_scheme" inNode:projectNode];
		project.numIterationsForVelocity = [self numIterationsInVelocityFrom:velocitySchemeStr];
		
		[self.projects addObject:project];
		[f release];
	}
	[managedObjectContext save: nil];
	[doc release];
	NSLog(@"DONE CREATING PROJECTS");
}

- (NSNumber*) numIterationsInVelocityFrom:(NSString *)schemeStr {
	NSRange schemeRange;
	schemeRange.location = 11;
	schemeRange.length = 1;
	NSString *numIterationsStr = [schemeStr substringWithRange:schemeRange];
//	NSLog(@"scheme %@", numIterationsStr);

	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSNumber *retval = [f numberFromString:numIterationsStr];
	[f release];

	return retval;
}


#pragma mark -
#pragma mark Utilities that should probably exist in Singletons

- (NSArray*) loadEntitiesOfType: (NSString*) entityType {
	NSFetchRequest * fetch = [[[NSFetchRequest alloc] init] autorelease];
	[fetch setEntity:[NSEntityDescription entityForName:entityType inManagedObjectContext:managedObjectContext]];
	return [managedObjectContext executeFetchRequest:fetch error:nil];
}

- (ASIHTTPRequest*) performSynchronousGetToURL: (NSString*) urlStr 
								   withHeaders: (NSDictionary*) headers {
	NSURL *url = [NSURL URLWithString: urlStr];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	request.timeOutSeconds = 20;
	[request setUsername: self.credentials.username];
	[request setPassword: self.credentials.password];
	if (headers) {
		NSEnumerator *keys = [headers keyEnumerator];
		NSString *key;
		while (key = [keys nextObject]) {
			[request addRequestHeader:key value: [headers objectForKey: key]];
		}
	}
	[request startSynchronous];
	return request;
}

- (ASIHTTPRequest*) performAsynchronousGetToURL: (NSString*) urlStr 
							 	    withHeaders: (NSDictionary*) headers
									  onSuccess: (SEL) success
										 onFail: (SEL) fail {
	NSURL *url = [NSURL URLWithString: urlStr];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	request.timeOutSeconds = 20;
	[request setUsername: self.credentials.username];
	[request setPassword: self.credentials.password];
	[request setDidFailSelector:fail];
	[request setDidFinishSelector:success];
	request.delegate = self;
	if (headers) {
		NSEnumerator *keys = [headers keyEnumerator];
		NSString *key;
		while (key = [keys nextObject]) {
			[request addRequestHeader:key value: [headers objectForKey: key]];
		}
	}
	[request startAsynchronous];
	return request;
}

#pragma mark -
#pragma mark Accessors

- (NSString*) getUsername { return self.credentials.username; }
- (NSString*) getPassword { return self.credentials.password; }
- (NSString*) getGuid { return self.credentials.guid; }
- (NSString*) getFullname { return self.credentials.fullname; }

- (void) setUsername:(NSString*)newUsername { self.credentials.username = newUsername; }
- (void) setPassword:(NSString*)newPassword { self.credentials.password = newPassword; }
- (void) setGuid:(NSString*)newGuid { self.credentials.guid = newGuid; }

#pragma mark -
#pragma mark Dealloc

- (void) dealloc {
	[credentials release];
	[managedObjectContext release];
	for (Project *project in projects) {
		[project release];
	}
	[projects release];
	
	[super dealloc];
}

@end
