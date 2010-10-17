//
//  Comment.h
//  Tracker Core Data
//
//  Created by Evan Light on 6/15/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <CoreData/CoreData.h>


@interface Comment :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * commenter;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * text;

@end



