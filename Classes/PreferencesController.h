//
//  PreferencesController.h
//  Tracker Core Data
//
//  Created by Evan Light on 6/15/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <UIKit/UIKit.h>


@class MasterViewController;
@class Tracker;

@interface PreferencesController : UIViewController <UITextFieldDelegate> {
	UITextField *usernameField;
	UITextField *passwordField;
	MasterViewController *masterViewController;
	Tracker *tracker;
}

@property (nonatomic,retain) Tracker *tracker;
@property (nonatomic,retain) IBOutlet UITextField *usernameField;
@property (nonatomic,retain) IBOutlet UITextField *passwordField;
@property (nonatomic,retain) IBOutlet MasterViewController *masterViewController;


- (id) initWithMasterViewController:(MasterViewController*)master;
- (IBAction) done;

@end
