// 
//  Project.m
//  Tracker Core Data
//
//  Created by Evan Light on 6/19/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import "Project.h"
#import "Tracker.h"
#import "Story.h"
#import "IceboxStory.h"
#import "Iteration.h"
#import "Credentials.h"

#import "TouchXML.h"
#import "XPathHelper.h"
#import "ASIHTTPRequest.h"

@implementation Project 

@dynamic currentVelocity;
@dynamic initialVelocity;
@dynamic trackerId;
@dynamic worked;
@dynamic total;
@dynamic myTotal;
@dynamic name;
@dynamic iterations;
@dynamic iceboxStories;
@dynamic average;
@dynamic myAverage;
@dynamic numIterationsForVelocity;

- (void) fetchStories {
	NSString *projectStoriesUrlStr = [NSString stringWithFormat: @"https://www.pivotaltracker.com/services/v3/projects/%@/iterations", self.trackerId];
	NSDictionary *headers = [NSDictionary dictionaryWithObject: [[Tracker getInstance] getGuid]
														forKey: @"X-TrackerToken"];
	ASIHTTPRequest *completedRequest = [[Tracker getInstance] performSynchronousGetToURL: projectStoriesUrlStr
															withHeaders: headers];
	[self createIterationsFromXML: [completedRequest responseString]];	
	
	NSString *iceboxStoriesStr = [NSString stringWithFormat: @"https://www.pivotaltracker.com/services/v3/projects/%@/stories?filter=state:unscheduled", self.trackerId];
	completedRequest = [[Tracker getInstance] performSynchronousGetToURL:iceboxStoriesStr withHeaders:headers];
	[self createIceboxStoriesFromXML: [completedRequest responseString]]; 
}

- (void) createIterationsFromXML: (NSString*) xml {
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSDateFormatter *d = [[NSDateFormatter alloc] init];
	[d setDateFormat:@"yyyy/MM/dd HH:mm:ss zzz"];	
	
	NSLog(@"========================");
	NSLog(@"PROJECT: %@", self.name);
//	NSLog(@"%@",xml);
	CXMLDocument *doc = [[CXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
	NSArray *iterationsArray = [doc nodesForXPath: @"//iteration" error: nil];
	Iteration *iteration;	
	NSUInteger totalPoints = 0, myTotalPoints = 0, workedPoints = 0;
	for (CXMLNode *iterationNode in iterationsArray) {
		iteration = [NSEntityDescription insertNewObjectForEntityForName:@"Iteration" inManagedObjectContext:self.managedObjectContext];
	
		NSString *numberStr = [[XPathHelper getInstance] findStringForElement:@"number" inNode:iterationNode];
		iteration.iterationNumber= [f numberFromString:numberStr];
		iteration.startDate = [d dateFromString: [[XPathHelper getInstance] findStringForElement:@"start" inNode:iterationNode]];
		iteration.endDate = [d dateFromString: [[XPathHelper getInstance] findStringForElement:@"finish" inNode:iterationNode]];
	
		iteration.project = self;
		[self addIterationsObject:iteration];
		
		NSArray *storyNodesArray = [iterationNode nodesForXPath: @".//story" error: nil];
		Story *story;
		NSUInteger sortOrderIdx = 0;
		NSUInteger iterationPoints = 0, myPoints = 0;
		for (id storyNode in storyNodesArray) {
			story = [NSEntityDescription insertNewObjectForEntityForName:@"Story" inManagedObjectContext:self.managedObjectContext];
			story.sortOrder = [NSNumber numberWithInteger: sortOrderIdx];
			sortOrderIdx += 1;
			story.name = [[XPathHelper getInstance] findStringForElement:@"name" inNode:storyNode];
			story.desc = [[XPathHelper getInstance] findStringForElement:@"description" inNode:storyNode];
			story.storyType = [[XPathHelper getInstance] findStringForElement:@"story_type" inNode:storyNode];
			story.currentState = [[XPathHelper getInstance] findStringForElement:@"current_state" inNode:storyNode];
			story.requestedBy = [[XPathHelper getInstance] findStringForElement:@"requested_by" inNode:storyNode];
			story.ownedBy = [[XPathHelper getInstance] findStringForElement:@"owned_by" inNode:storyNode];	
			story.trackerId = [f numberFromString: [[XPathHelper getInstance] findStringForElement:@"id" inNode:storyNode]];
			NSString *estimateStr = [[XPathHelper getInstance] findStringForElement:@"estimate" inNode:storyNode];
			story.createdAt = [d dateFromString: [[XPathHelper getInstance] findStringForElement:@"created_at" inNode:storyNode]];
			story.updatedAt = [d dateFromString: [[XPathHelper getInstance] findStringForElement:@"updated_at" inNode:storyNode]];
			if (estimateStr != nil) {
				story.score = [f numberFromString: estimateStr];
				iterationPoints += [story.score intValue];
				totalPoints += [story.score intValue];
				if ([story.ownedBy isEqualToString:[[[Tracker getInstance] credentials] fullname]]) {
					myPoints += [story.score intValue];
					myTotalPoints += [story.score intValue];
				}
				if ([story.currentState isEqualToString:@"accepted"]) {
					workedPoints += [story.score intValue];
				}
			} else {
				story.score = 0;
			}
			story.iteration = iteration;
			[iteration addStoriesObject:story];
//			NSLog(@"iteration: %d, state: %@ || ownedby: %@ || story: %@", [story.iteration.iterationNumber integerValue], story.currentState, story.ownedBy, story.name);			
		}
		iteration.points = [NSNumber numberWithUnsignedInteger:iterationPoints];
		iteration.myPoints = [NSNumber numberWithUnsignedInteger:myPoints];
		iteration.projectVelocity = [NSNumber numberWithInt:
									 [self velocityForIteration:[iteration.iterationNumber intValue] usingPoints:@selector(points)]];
		iteration.myVelocity = [NSNumber numberWithInt:
								 [self velocityForIteration:[iteration.iterationNumber intValue] usingPoints:@selector(myPoints)]];

//		NSLog(@"Iteration %d || Project velocity: %d || My velocity: %d", [story.iteration.iterationNumber intValue], [iteration.projectVelocity integerValue], [iteration.myVelocity intValue]);
	}
	self.worked= [NSNumber numberWithUnsignedInteger:workedPoints];
	self.total = [NSNumber numberWithUnsignedInteger:totalPoints];
	self.myTotal = [NSNumber numberWithUnsignedInteger:myTotalPoints];

	int velocitiesToPresent = 0, myVelocitiesToPresent = 0;
	for (iteration in self.iterations) {
		if ([iteration.iterationNumber intValue] < [self currentIterationNumber]) {
			velocitiesToPresent += [iteration.projectVelocity intValue];
			myVelocitiesToPresent += [iteration.myVelocity intValue];
		}
	}

	int numIterationsToPresent = [self currentIterationNumber];
	self.average = [NSNumber numberWithFloat:(velocitiesToPresent * 1.0 / numIterationsToPresent)];
	self.myAverage = [NSNumber numberWithFloat:(myVelocitiesToPresent * 1.0 / numIterationsToPresent)];

	NSError *error;
	if (![self.managedObjectContext save: &error]) {
		NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
		NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
		if(detailedErrors != nil && [detailedErrors count] > 0) {
			for(NSError* detailedError in detailedErrors) {
				NSLog(@"  DetailedError: %@", [detailedError userInfo]);
			}
		}
		else {
			NSLog(@"  %@", [error userInfo]);
		}
		abort();
	}
	
	[f release];
	[d release];
	[doc release];
	//NSLog(@"DONE CREATING %@ STORIES FOR PROJECT '%@'", [project.currentStories count] + [project.iceboxedStories count], project.name);
}

- (void) createIceboxStoriesFromXML:(NSString *)xml {
//	NSLog(@"createIceboxStoriesFromXML: for %@", xml);
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSDateFormatter *d = [[NSDateFormatter alloc] init];
	[d setDateFormat:@"yyyy/MM/dd HH:mm:ss zzz"];	
	
	CXMLDocument *doc = [[CXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
	
	NSArray *storyNodesArray = [doc nodesForXPath: @"//story" error: nil];
	IceboxStory *story;
	NSUInteger sortOrderIdx = 0;
	NSError *error = nil;
	for (id storyNode in storyNodesArray) {
		story = [NSEntityDescription insertNewObjectForEntityForName:@"IceboxStory" inManagedObjectContext:self.managedObjectContext];
		story.sortOrder = [NSNumber numberWithInteger: sortOrderIdx];
		sortOrderIdx += 1;
		story.name = [[XPathHelper getInstance] findStringForElement:@"name" inNode:storyNode];
		story.desc = [[XPathHelper getInstance] findStringForElement:@"description" inNode:storyNode];
		story.storyType = [[XPathHelper getInstance] findStringForElement:@"story_type" inNode:storyNode];
		story.currentState = @"unscheduled";
		story.requestedBy = [[XPathHelper getInstance] findStringForElement:@"requested_by" inNode:storyNode];
		story.ownedBy = [[XPathHelper getInstance] findStringForElement:@"owned_by" inNode:storyNode];	
		story.trackerId = [f numberFromString: [[XPathHelper getInstance] findStringForElement:@"id" inNode:storyNode]];
		story.createdAt = [d dateFromString: [[XPathHelper getInstance] findStringForElement:@"created_at" inNode:storyNode]];
		story.updatedAt = [d dateFromString: [[XPathHelper getInstance] findStringForElement:@"updated_at" inNode:storyNode]];
		[self addIceboxStoriesObject:story];
		story.project = self;
//		[self.managedObjectContext save:&error];
//		if (error) {
//			NSLog(@"oops");
//			NSLog(@"Unresolved error %@", error);
//			abort();
//		}			
//		NSLog(@"After successful save");
		//		NSLog(@"state: %@ || ownedby: %@ || story: %@", story.currentState, story.ownedBy, story.name);					
	}
	[self.managedObjectContext save:&error];
	if (error) {
		NSLog(@"Unresolved error %@", error);
		abort();
	}
//	NSLog(@"Created icebox stories");
	[f release];
	[d release];
	[doc release];
//	NSLog(@"releasing stuff");
}

- (NSUInteger) computePointsForStoriesMatchingPredicate:(NSPredicate*)predicate {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
	[fetchRequest setPredicate:predicate];
	NSError *error = nil;
	NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error != nil) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
	}
	
	NSUInteger pts = 0;
	Story *story;
	int storyScore;
	for(NSUInteger i = 0; i < [array count]; i++ ) {
		story = [array objectAtIndex:i];
		if(story.score != nil) {
			storyScore = [story.score integerValue];
			if(storyScore > 0) {
				pts += storyScore;
			}
		}
	}
	[fetchRequest release];
	return pts;
}

- (int) percentComplete {
	float percent = 100 * [self.worked intValue] * 1.0 / [self.total intValue];
	return (int) [[NSNumber numberWithFloat:percent] intValue];
}

- (int) totalPoints {
	int retval = 0;
	for(Iteration *iteration in self.iterations) {
		for(Story *story in iteration.stories) {
			retval += [story.score intValue];
		}
	}
	return retval;
}

#pragma mark -
#pragma mark Iteration-specific code

- (Iteration*) currentIteration {
	Iteration *retval = nil;
	NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
	//	NSLog(@"Current date is %@", currentDate);
	for (Iteration *iteration in self.iterations) {
		//		NSLog(@"Comparing against iteration %d, start %@, end %@", [iteration.iterationNumber integerValue], iteration.startDate, iteration.endDate);
		if ([iteration.startDate laterDate:currentDate] == currentDate &&
			[iteration.endDate earlierDate:currentDate] == currentDate) {
			retval = iteration;
			break;
		}
	}
	return retval;
}

- (int) currentIterationNumber {
	NSEnumerator *iterationsEnum = [self.iterations objectEnumerator];
	Iteration *iteration;
	NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
	while (iteration = [iterationsEnum nextObject]) {
		if ([iteration.startDate laterDate:currentDate] == currentDate &&
			[iteration.endDate earlierDate:currentDate] == currentDate) {
			break;
		}
	}
	return [iteration.iterationNumber intValue];
		
}

- (int) velocityForIteration:(int)iterationNum usingPoints:(SEL)pointsSelector{
	int numIterations = [self.numIterationsForVelocity intValue];
	int firstIterationNum = iterationNum - (numIterations - 1);
	NSString *format = [NSString stringWithFormat:@"iterationNumber >= %d and iterationNumber <= %d", 
						firstIterationNum, 
						iterationNum];
	NSSet *iterationsForVelocity = [self.iterations filteredSetUsingPredicate:
									[NSPredicate predicateWithFormat:format]
									];
	int totalPoints = 0;
	NSEnumerator *iterationsEnum = [iterationsForVelocity objectEnumerator];
	Iteration *iteration;
	while (iteration = [iterationsEnum nextObject]) {
//		NSLog(@"Iteration %d: iteration points: %d", [[iteration iterationNumber] intValue], [[iteration points] intValue]);
		totalPoints += [[iteration performSelector:pointsSelector] intValue];
	}
	return totalPoints / numIterations;
}

- (Iteration*) iterationForNumber:(int)number {
	for (Iteration *iteration in self.iterations) {
		if ([iteration.iterationNumber intValue] == number) {
			return iteration;
		}
	}
	return nil;
}

- (NSArray*) iterationsUpToPresent {
	int iterationNumber = [self currentIterationNumber];
	int projectTrackerId = [self.trackerId intValue];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"iterationNumber < %d and project.trackerId == %d", 
						iterationNumber, projectTrackerId];
//	NSLog(@"%@", [pred predicateFormat]);
	return [self iterationsMatchingPredicate:pred];
}

- (NSArray*) iterationsMatchingPredicate:(NSPredicate *)predicate {
	NSArray *retval = nil;

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Iteration" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"iterationNumber" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];   
	[request setSortDescriptors:sortDescriptors];
	
	[request setPredicate:predicate];
	
	NSError *error = nil;
	retval = [self.managedObjectContext executeFetchRequest:request error:&error];
	if (error) {
		NSLog(@"Unresolved error %@", error);
		NSLog(@"got retvl %@", retval);
		abort();
	}	
//	NSLog(@"iterationsMatchingPredicate returning %d iterations for predicate %@", [retval count], [predicate predicateFormat]);
	
	[sortDescriptors release];
	[sortDescriptor release];
	[request release];
	
	return retval;
}

- (NSArray*) iceBoxStoriesAscending {
	NSArray *retval = nil;

	// Create the request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	// Tell the request that we want IceboxStory records
	NSEntityDescription *entity = 
		[NSEntityDescription entityForName:@"IceboxStory" 
					inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	// Tell the request to sort results based on the 'sortOrder' field in 
	// ascending order
	NSSortDescriptor *sortDescriptor = 
		[[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];   
	[request setSortDescriptors:sortDescriptors];

	// Query only for IceboxStories associated with this Project's trackerId
	NSPredicate *predicate = 
		[NSPredicate predicateWithFormat:@"project.trackerId = %d", [self.trackerId intValue]];
	[request setPredicate:predicate];

	// Perform the query
	NSError *error = nil;
	retval = [self.managedObjectContext executeFetchRequest:request error:&error];    
	if (error) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
	
	// Clean up after yo' funky self
	[sortDescriptors release];
	[sortDescriptor release];
	[request release];
	
	return retval;
}

@end



