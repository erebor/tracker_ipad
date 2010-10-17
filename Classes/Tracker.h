//
//  Tracker.h
//  Tracker Core Data
//
//  Created by Evan Light on 6/29/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Credentials;
@class ASIHTTPRequest;
@class CXMLNode;
@class Tracker;
@class Project;

@interface Tracker : NSObject {
	Credentials *credentials;
	NSMutableArray *projects;
	NSManagedObjectContext *managedObjectContext;
	BOOL offline;
}

@property (nonatomic,retain) Credentials *credentials;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSMutableArray *projects;
@property (nonatomic) BOOL offline;

+ (id) getInstance;
+ (void) setManagedObjectContext:(NSManagedObjectContext *)newMoc;

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)newManagedObjectContext;

- (void) fetchProjects;
- (Project*) findProjectWithID:(NSInteger)id;
- (void) deleteProjects;
- (void) updateProjectsFromXML:(NSString *)xml;
- (void) loadOrCreateCredentials;
- (BOOL) hasCredentials;
- (void) identifyMyNameFromProjectXML:(NSString*)xml;
- (void) authenticate;
- (BOOL) hasAuthenticated;
- (NSNumber*) numIterationsInVelocityFrom:(NSString*)scheme;
- (void) loadProjectsFromDB;
- (NSArray*) loadEntitiesOfType: (NSString*) entityType;
- (ASIHTTPRequest*) performAsynchronousGetToURL: (NSString*) urlStr 
							 	    withHeaders: (NSDictionary*) headers
									  onSuccess: (SEL) success
										 onFail: (SEL) fail;
- (ASIHTTPRequest*) performSynchronousGetToURL: (NSString*) urlStr 
								   withHeaders: (NSDictionary*) headers;


- (void) projectFetchFailed:(ASIHTTPRequest*)request;
- (void) projectsFetched:(ASIHTTPRequest*)request;

- (void) authenticatedSuccessfully:(ASIHTTPRequest*)request;
- (void) failedToAuthenticate:(ASIHTTPRequest *)request;

- (NSString*) getUsername;
- (NSString*) getPassword;
- (NSString*) getGuid;
- (NSString*) getFullname;

- (void) setUsername:(NSString*)newUsername;
- (void) setPassword:(NSString*)newPassword;
- (void) setGuid:(NSString*)newGuid;


@end
