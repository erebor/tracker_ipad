//
//  Iteration.h
//  Tracker Core Data
//
//  Created by Evan Light on 8/3/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <CoreData/CoreData.h>

@class Project;
@class Story;

@interface Iteration :  NSManagedObject  
{
	NSArray *cachedStories;
}

@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * iterationNumber;
@property (nonatomic, retain) NSNumber * myVelocity;
@property (nonatomic, retain) NSNumber * projectVelocity;
@property (nonatomic, retain) NSNumber * points;
@property (nonatomic, retain) NSNumber * myPoints;
@property (nonatomic, retain) NSSet* stories;
@property (nonatomic, retain) Project * project;

@property (nonatomic, retain) NSArray *cachedStories;

- (int) pointsStarted;
- (int) myPointsComplete;
- (int) myPointsStarted;
- (int) pointsComplete;
- (NSArray*) storiesbySortOrderAscending;
- (Story*) storyAtIndex:(NSUInteger)storyIdx;
@end


@interface Iteration (CoreDataGeneratedAccessors)
- (void)addStoriesObject:(Story *)value;
- (void)removeStoriesObject:(Story *)value;
- (void)addStories:(NSSet *)value;
- (void)removeStories:(NSSet *)value;

@end

