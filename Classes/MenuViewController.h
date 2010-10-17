//
//  MenuViewController.h
//  Tracker Core Data
//
//  Created by Evan Light on 7/23/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <UIKit/UIKit.h>

@class PreferencesController;
@class MasterViewController;

@interface MenuViewController : UIViewController {
	PreferencesController *preferencesController;
	MasterViewController *masterViewController;
	UIButton *settingsButton;
	UIButton *refreshButton;
	UIButton *backButton;
	UIImageView *refreshAnimationView;
}

@property (nonatomic, retain) PreferencesController *preferencesController;
@property (nonatomic, retain) MasterViewController *masterViewController;
@property (nonatomic, retain) UIButton *settingsButton;
@property (nonatomic, retain) UIButton *refreshButton;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIImageView *refreshAnimationView;

- (id) initWithMasterViewController:(MasterViewController*)master;
- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation;
- (void) setButton:(UIButton*)button withImageFileName:(NSString*)fileName andExtension:(NSString*)extension forState:(UIControlState)state;
- (void) showBackButton;
- (void) hideBackButton;
- (void) showSettings;
- (void) showRefreshAnimation;
- (void) hideRefreshAnimation;
	
@end
