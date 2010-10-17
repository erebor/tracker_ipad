//
//  Project.h
//  Tracker Core Data
//
//  Created by Evan Light on 6/19/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <CoreData/CoreData.h>

@class Iteration;
@class IceboxStory;
@class CXMLNode;
@class ASIHTTPRequest;

@interface Project :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * currentVelocity;
@property (nonatomic, retain) NSNumber * initialVelocity;
@property (nonatomic, retain) NSNumber * trackerId;
@property (nonatomic, retain) NSNumber * worked;
@property (nonatomic, retain) NSNumber * average;
@property (nonatomic, retain) NSNumber * myAverage;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSNumber * myTotal;
@property (nonatomic, retain) NSNumber * numIterationsForVelocity;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* iterations;
@property (nonatomic, retain) NSSet* iceboxStories;

- (void) fetchStories;
- (void) createIterationsFromXML:(NSString*)xml;
- (void) createIceboxStoriesFromXML:(NSString*)xml;
- (NSUInteger) computePointsForStoriesMatchingPredicate:(NSPredicate*)predicate;
- (Iteration*) currentIteration;
- (int) velocityForIteration:(int)iterationNum usingPoints:(SEL)points;
- (int) currentIterationNumber;
- (Iteration*) iterationForNumber:(int)number;
- (int) percentComplete;
- (NSArray*) iterationsUpToPresent;
- (NSArray*) iterationsMatchingPredicate:(NSPredicate*)predicate;
- (NSArray*) iceBoxStoriesAscending;
@end


@interface Project (CoreDataGeneratedAccessors)
- (void)addIterationsObject:(Iteration *)value;
- (void)removeIterationsObject:(Iteration *)value;
- (void)addIterations:(NSSet *)value;
- (void)removeIterations:(NSSet *)value;
- (void)addIceboxStoriesObject:(IceboxStory*)value;
- (void)remoteIceboxStoriesObject:(IceboxStory*)value;
@end

