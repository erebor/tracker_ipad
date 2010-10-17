//
//  Credentials.h
//  Tracker Core Data
//
//  Created by Evan Light on 7/28/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <CoreData/CoreData.h>


@interface Credentials :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSString * guid;

@end



