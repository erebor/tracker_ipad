//
//  Tracker_Core_DataAppDelegate.h
//  Tracker Core Data
//
//  Created by Evan Light on 6/15/10.
//  Copyright Triple Dog Dare 2010. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@class MasterViewController;

@interface Tracker_Core_DataAppDelegate : NSObject <UIApplicationDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
	
    UIWindow *window;

	UISplitViewController *splitViewController;

	MasterViewController *rootViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) MasterViewController *rootViewController;

//@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
//@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
//@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
