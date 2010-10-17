//
//  StoryViewController.h
//  Tracker Core Data
//
//  Created by Evan Light on 8/5/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <UIKit/UIKit.h>

@class Project;
@class MasterViewController;
@class StoryTableViewController;

@interface ProjectViewController : UIViewController <UITabBarDelegate> {
	Project *project;
	UIView  *detailView;
	UILabel *titleLabel;
	UITabBar *tabBar;
	UIView *tabBarView;
	NSMutableArray *detailViewControllers;
	StoryTableViewController *storyTableDelegate;
	NSNumber *projectTrackerId;
	NSArray *uiBarTitles;
}

@property (nonatomic,retain) Project *project;
@property (nonatomic,retain) UIView *detailView;
@property (nonatomic,retain) UILabel *titleLabel;
@property (nonatomic,retain) UITabBar *tabBar;
@property (nonatomic,retain) UIView *tabBarView;
@property (nonatomic,retain) StoryTableViewController *storyTableDelegate;
@property (nonatomic,retain) UIViewController *detailViewController;
@property (nonatomic,retain) NSNumber *projectTrackerId;
@property (nonatomic,retain) NSMutableArray *detailViewControllers;
@property (nonatomic,retain) NSArray *uiBarTitles;

- (id) initWithProject:(Project*)project;
- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation;
- (void) createUiBarItemsGivenTitles:(NSArray*)uiBarTitles andImageNames:(NSArray*)uiBarFileNames;
- (void) refresh;
- (StoryTableViewController*) storyTableViewControllerWithIterationsRelativeToCurrent:(NSString*)operand;
@end
