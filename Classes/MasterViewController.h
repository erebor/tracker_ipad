//
//  MasterViewController.h
//  Tracker Core Data
//
//  Created by Evan Light on 7/23/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <UIKit/UIKit.h>

@class MenuViewController;
@class ProjectViewController;
@class Project;
@class RefreshController;

@interface MasterViewController : UIViewController {
	MenuViewController *menuViewController;
	NSMutableArray *projectViews;
	UIScrollView *scrollView;
	UIView *detailView;
	ProjectViewController *projectViewController;
	RefreshController *refreshController;
}

@property (nonatomic, retain) MenuViewController *menuViewController;
@property (nonatomic, retain) ProjectViewController *projectViewController;
@property (nonatomic, retain) NSMutableArray *projectViews;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *detailView;
@property (nonatomic, retain) RefreshController *refreshController;

- (void) adjustViewForOrientation:(UIInterfaceOrientation)orientation;
- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation;
- (void) renderProjectCardsFor:(UIInterfaceOrientation)orientation;
- (void) createProjectCardAtX:(CGFloat)x y:(CGFloat)y forProject:(Project*)project;
- (void) createProjectMetricsViewInView:(UIView*)projectView forProject:(Project*)project;
- (void) createLabelWithString:(NSString*)labelStr usingFont:(UIFont*)font color:(UIColor*)color inRect:(CGRect)rect inView:(UIView*)view;
- (void) deallocProjectViews;

- (void) displaySplash;
- (void) hideSplash;

// ACTION
- (void) refresh;
- (void) showProjectCards;

// NOTIFICATION HANDLERS
- (void) showProject:(NSNotification*)notification;
- (void) projectsFetched:(NSNotification*)notification;
- (void) projectFetchFailed:(NSNotification*)notification;
- (void) authenticationSucceeded:(NSNotification*)notification;
- (void) authenticationFailed:(NSNotification*)notification;
@end
