// 
//  Story.m
//  Tracker Core Data
//
//  Created by Evan Light on 8/3/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import "Story.h"

#import "Comment.h"
#import "Iteration.h"
#import "Task.h"

@implementation Story 

@dynamic desc;
@dynamic updatedAt;
@dynamic trackerId;
@dynamic name;
@dynamic sortOrder;
@dynamic storyType;
@dynamic requestedBy;
@dynamic ownedBy;
@dynamic createdAt;
@dynamic currentState;
@dynamic score;
@dynamic comments;
@dynamic tasks;
@dynamic iteration;

- (BOOL) isDone {
	return [self.currentState isEqualToString:@"accepted"] ||	
		   [self.currentState isEqualToString:@"finished"];
}

- (BOOL) isInWork {
	return [self.currentState isEqualToString:@"started"];
}

@end
