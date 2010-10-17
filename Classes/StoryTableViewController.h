//
//  StoryTableViewController.h
//  Tracker Core Data
//
//  Created by Evan Light on 8/8/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Project;
@class Story;
@class StoryDetailsTableCell;

@interface StoryTableViewController : UITableViewController {
	Project *project;
	NSArray *iterations;
	UIColor *releaseColor;
	UIColor *doneFeatureColor;
	UIColor *currentFeatureColor;	
	NSPredicate *predicate;
	NSNumber *projectTrackerId;
	NSMutableArray *iceboxStories;
	NSInteger selectedRow;
	NSInteger selectedSection;
	NSInteger origSelectedRow;
	StoryDetailsTableCell *detailsCell;
	UIInterfaceOrientation orientation;
}

@property (nonatomic,retain) Project *project;
@property (nonatomic,retain) NSArray *iterations;
@property (nonatomic,retain) UIColor *releaseColor;
@property (nonatomic,retain) UIColor *doneFeatureColor;
@property (nonatomic,retain) UIColor *currentFeatureColor;	
@property (nonatomic,retain) NSPredicate *predicate;
@property (nonatomic,retain) NSNumber *projectTrackerId;
@property (nonatomic,retain) NSArray *iceboxStories;
@property (nonatomic) NSInteger selectedRow;
@property (nonatomic) NSInteger selectedSection;
@property (nonatomic) NSInteger origSelectedRow;
@property (nonatomic,retain) StoryDetailsTableCell *detailsCell;
@property (nonatomic) UIInterfaceOrientation orientation;

- (id) initWithProject:(Project*)p andIterationsPredicate:(NSPredicate*)predicate;
- (Story*) storyForDetailsAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL) shouldDisplayStoryDetailsAtIndexPath:(NSIndexPath*)indexPath;
- (void) populateDetailsCell:(UITableViewCell*)cell forStory:(Story*)story;
- (UITableViewCell*) getOrCreateDetailsCellForIndexPath:(NSIndexPath*)indexPath;
	
- (UITableViewCell*) getOrCreateCellWithIdentifier:(NSString*)identifier andNibName:(NSString*)nibName;
- (UITableViewCell*) getOrCreateFeatureCellForTableView:(UITableView*)view andStory:(Story*)story;
- (UITableViewCell*) getOrCreateBugCellForTableView:(UITableView*)view andStory:(Story*)story;
- (UITableViewCell*) getOrCreateChoreCellForTableView:(UITableView*)view andStory:(Story*)story;
- (UITableViewCell*) getOrCreateReleaseCellForTableView:(UITableView*)view andStory:(Story*)story;
- (void) refresh;
- (BOOL) isIcebox;
- (BOOL) hasSelectedRowInSection:(NSInteger)section;
- (BOOL) hasSelectedRow;
- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation;
- (CGFloat) heightForStoryTitleLabelWithText:(NSString*)text;
@end
