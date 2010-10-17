//
//  IceboxStory.h
//  Tracker Core Data
//
//  Created by Evan Light on 8/12/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <CoreData/CoreData.h>
#import "Story.h"

@class Project;

@interface IceboxStory :  Story  
{
}

@property (nonatomic, retain) Project * project;

@end



