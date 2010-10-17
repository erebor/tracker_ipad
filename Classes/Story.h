//
//  Story.h
//  Tracker Core Data
//
//  Created by Evan Light on 8/3/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <CoreData/CoreData.h>

@class Comment;
@class Iteration;
@class Task;

@interface Story :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * trackerId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * storyType;
@property (nonatomic, retain) NSString * requestedBy;
@property (nonatomic, retain) NSString * ownedBy;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * currentState;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) NSSet* comments;
@property (nonatomic, retain) NSSet* tasks;
@property (nonatomic, retain) Iteration * iteration;

- (BOOL) isDone;
- (BOOL) isInWork;

@end


@interface Story (CoreDataGeneratedAccessors)
- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)value;
- (void)removeComments:(NSSet *)value;

- (void)addTasksObject:(Task *)value;
- (void)removeTasksObject:(Task *)value;
- (void)addTasks:(NSSet *)value;
- (void)removeTasks:(NSSet *)value;

@end

