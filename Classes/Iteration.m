// 
//  Iteration.m
//  Tracker Core Data
//
//  Created by Evan Light on 8/3/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import "Iteration.h"

#import "Project.h"
#import "Story.h"
#import "Tracker.h"
#import "Credentials.h"

@implementation Iteration 

@dynamic startDate;
@dynamic endDate;
@dynamic iterationNumber;
@dynamic myVelocity;
@dynamic projectVelocity;
@dynamic stories;
@dynamic project;
@dynamic points;
@dynamic myPoints;

@synthesize cachedStories;

- (int) pointsStarted {
	int retval = 0;
	for (Story *story in self.stories) {
		if ([story.currentState isEqualToString:@"started"]) {
			retval += [story.score intValue];
		}
	}
	return retval;
}

- (int) myPointsComplete {
	int retval = 0;
	NSString *myName = [[[Tracker getInstance] credentials] fullname];
	for (Story *story in self.stories) {
		if ([story.currentState isEqualToString:@"accepted"] &&
			[story.ownedBy isEqualToString:myName]) {
			retval += [story.score intValue];
		}
	}
	return retval;
}

- (int) myPointsStarted {
	int retval = 0;
	NSString *myName = [[[Tracker getInstance] credentials] fullname];
	for (Story *story in self.stories) {
		if ([story.currentState isEqualToString:@"started"] &&
			[story.ownedBy isEqualToString:myName]) {
			retval += [story.score intValue];
		}
	}
	return retval;
}

- (int) pointsComplete {
	int retval = 0;
	for (Story *story in self.stories) {
		if ([story.currentState isEqualToString:@"accepted"]) {
			retval += [story.score intValue];
		}
	}
	return retval;
}

- (NSArray*) storiesbySortOrderAscending {
	NSArray *retval = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];   
	[request setSortDescriptors:sortDescriptors];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iteration.project.trackerId = %d and iteration.iterationNumber = %d",
							  [self.project.trackerId intValue],
							  [self.iterationNumber intValue]
							  ];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	retval = [self.managedObjectContext executeFetchRequest:request error:&error];    
	if (error) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	
	
	[sortDescriptors release];
	[sortDescriptor release];
	[request release];
	
	return retval;
}

- (Story*) storyAtIndex:(NSUInteger)storyIdx {
//	NSLog(@"Story at index %d", storyIdx);
	if (!self.cachedStories) {
		self.cachedStories = [self storiesbySortOrderAscending];
	}
//	NSLog(@"%@", stories);
	Story *retval = [self.cachedStories objectAtIndex:storyIdx];
//	NSLog(@"STORY: %@", retval);
	return retval;
}

@end
