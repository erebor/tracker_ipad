//
//  StoryTableDelegate.m
//  Tracker Core Data
//
//  Created by Evan Light on 8/8/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import "Tracker.h"
#import "Project.h"
#import "Iteration.h"
#import "Story.h"
#import "StoryTableViewController.h"
#import "StoryDetailsTableCell.h"

#import <QuartzCore/QuartzCore.h>

#define NUMBER_TAG			8
#define TITLE_TAG			1
#define OWNER_TAG			2
#define SCORE_TAG			4
#define POINTS_LABEL_TAG	16
#define OWNER_LABEL_TAG		32
#define STORY_LABEL_TAG		64

#define PORTRAIT_TABLE_WIDTH	718
#define LANDSCAPE_TABLE_WIDTH	974

@implementation StoryTableViewController

@synthesize project, iterations, releaseColor, doneFeatureColor, currentFeatureColor, 
			predicate, projectTrackerId, iceboxStories, selectedRow, selectedSection, detailsCell,
			origSelectedRow, orientation;

static NSString *FeatureCellIdentifier = @"FeatureCell";
static NSString *ReleaseCellIdentifier = @"ReleaseCell";
static NSString *BugCellIdentifier = @"BugCell";
static NSString	*ChoreCellIdentifier = @"ChoreCell";

static NSString *DoneFeatureCellIdentifier = @"DoneFeatureCell";
static NSString	*DoneChoreCellIdentifier = @"DoneChoreCell";
static NSString *DoneBugCellIdentifier = @"DoneBugCell";

static NSString *InWorkFeatureCellIdentifier = @"InWorkFeatureCell";
static NSString	*InWorkChoreCellIdentifier = @"InWorkChoreCell";
static NSString *InWorkBugCellIdentifier = @"InWorkBugCell";


static NSString *CellNib = @"StoryTableViewCell";
static NSString *ReleaseCellNib = @"ReleaseTableViewCell";
static NSString *BugCellNib = @"BugTableViewCell";
static NSString	*ChoreCellNib = @"ChoreTableViewCell";

static NSString *DoneCellNib = @"DoneTableViewCell";
static NSString *DoneBugCellNib = @"DoneBugTableViewCell";
static NSString	*DoneChoreCellNib = @"DoneChoreTableViewCell";

static NSString *InWorkCellNib = @"InWorkTableViewCell";
static NSString *InWorkBugCellNib = @"InWorkBugTableViewCell";
static NSString	*InWorkChoreCellNib = @"InWorkChoreTableViewCell";

- (id) initWithProject:(Project*)p andIterationsPredicate:(NSPredicate*)pred {
	self = [super init];
	self.predicate = pred;
	self.project = p;
	self.projectTrackerId = p.trackerId;
	self.selectedSection = -1;
	self.selectedRow = -1;
	self.detailsCell = nil;
	if (pred == nil) {
		self.iceboxStories = [p iceBoxStoriesAscending];
	} else {
		self.iterations = [p iterationsMatchingPredicate:pred];
	}
	self.releaseColor = [[UIColor alloc] initWithRed:223.0/255 green:240.0/255 blue:250.0/255 alpha:1.0];
	self.doneFeatureColor = [[UIColor alloc] initWithRed:208.0/255 green:234.0/255 blue:196.0/255 alpha:1.0];
	self.currentFeatureColor = [[UIColor alloc] initWithRed:1 green:246.0/255 blue:211.0/255 alpha:1.0];
	UIColor *borderColor = [[[UIColor alloc] initWithRed:221.0/255 green:221.0/255 blue:221.0/255 alpha:1] autorelease];
	[self.view.layer setBorderColor: [borderColor CGColor]];
	[self.view.layer setBorderWidth: 1.0];	
	return self;
}	

- (BOOL) isIcebox {
	return self.predicate == nil ? YES : NO;
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)o {
	self.orientation = o;
    if (self.orientation == UIInterfaceOrientationPortrait || self.orientation == UIInterfaceOrientationPortraitUpsideDown) {
		self.view.frame = CGRectMake(0, 0, PORTRAIT_TABLE_WIDTH, 904);
	} else {
		self.view.frame = CGRectMake(0, 0, LANDSCAPE_TABLE_WIDTH, 648);
	}	
}

- (void) refresh {
	self.project = [[Tracker getInstance] findProjectWithID:[self.projectTrackerId integerValue]];
	if ([self isIcebox]) {
		self.iceboxStories = [self.project iceBoxStoriesAscending];
	} else {
		self.iterations = [self.project iterationsMatchingPredicate:self.predicate];
	}
	[(UITableView*)self.view reloadData];
}

#pragma mark -
#pragma mark UIView

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	if ([self isIcebox]) {
		return 1;
	} else {
		return [self.iterations count];
	}
}

- (NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
//	NSLog(@"numberOfRowsInSection");
	NSInteger retval = 0;
	if ([self isIcebox] ) {
		retval = [self.iceboxStories count];
	} else {
		retval = [[[self.iterations objectAtIndex:section] stories] count];
	}
	if ([self hasSelectedRowInSection:section]) {
		retval++;
	}
//	NSLog(@"Number of rows in section: %d", retval);
	return retval;
}

- (BOOL) hasSelectedRowInSection:(NSInteger)section {
	return self.selectedSection == section && self.selectedRow >= 0;
}

- (BOOL) hasSelectedRow {
	return self.selectedSection >= 0 && self.selectedRow >= 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	//NSLog(@"tableView:titleForHeaderInSection:");
	if ([self isIcebox]) {
		return @"Icebox";
	} else {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMM dd"];
		Iteration *iteration = [self.iterations objectAtIndex:section];
		NSString *retval = [NSString stringWithFormat:@"%@ - %@, %d points, %d complete", 
							[dateFormatter stringFromDate:iteration.startDate],
							[dateFormatter stringFromDate:iteration.endDate],
							[iteration.points intValue],
							[iteration pointsComplete]						
							];
		[dateFormatter release];
		//NSLog(@"section header: %@", retval);
		return retval;
	}
}

- (BOOL) shouldDisplayStoryDetailsAtIndexPath:(NSIndexPath*)indexPath {
	return self.selectedSection == indexPath.section && self.selectedRow+1 == indexPath.row;
}

- (void) populateDetailsCell:(UITableViewCell*)cell forStory:(Story*)story{

}

- (Story*) storyForDetailsAtIndexPath:(NSIndexPath*)indexPath {
	Story *story = nil;
	if ([self isIcebox]) {
		story = [self.iceboxStories objectAtIndex:indexPath.row-1];
	} else {
		Iteration *iteration = [self.iterations objectAtIndex:indexPath.section];
		story = [iteration storyAtIndex:indexPath.row-1];
	}
	return story;
}

- (UITableViewCell*) getOrCreateDetailsCellForIndexPath:(NSIndexPath*)indexPath {
//	NSLog(@"getOrCreateDetailsCellForIndexPath %d %d", indexPath.section, indexPath.row);
	Story *story = [self storyForDetailsAtIndexPath:indexPath];
//	NSLog(@"Story details for %@", story);
	
	if (self.detailsCell == nil) {
		self.detailsCell = [[StoryDetailsTableCell alloc] init];
		self.detailsCell.selectionStyle = UITableViewCellSelectionStyleNone;	
	}

	[self.detailsCell displayStory:story];
	
	return self.detailsCell;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;	
	Story *story = nil;
//	NSLog(@"cellForRowAtIndexPath %d %d", indexPath.section, indexPath.row);
	if ([self shouldDisplayStoryDetailsAtIndexPath:indexPath]) {
//		NSLog(@"Getting or creating details cell");
		cell = [self getOrCreateDetailsCellForIndexPath:indexPath];
//		NSLog(@"Got cell %@", cell);
	} else {
//		NSLog(@"Getting or creating normal cell");
		if ([self hasSelectedRow] && indexPath.row > self.selectedRow+1) {
			// KLUGE to account for the additional cell for the details
			indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
//			NSLog(@"We're now using the row decremet kluge %d %d", indexPath.section, indexPath.row);			
		}
		if ([self isIcebox]) {
			story = [self.iceboxStories objectAtIndex:indexPath.row];
		} else {
			Iteration *iteration = [self.iterations objectAtIndex:indexPath.section];
			story = [iteration storyAtIndex:indexPath.row];
		}

		if ([story.storyType isEqualToString:@"release"]) {
			cell = [self getOrCreateReleaseCellForTableView:(UITableView*)self.view andStory:story];
		} else if([story.storyType isEqualToString:@"chore"]) { 
			cell = [self getOrCreateChoreCellForTableView:(UITableView*)self.view andStory:story];
		} else if([story.storyType isEqualToString:@"bug"]) { 		
			cell = [self getOrCreateBugCellForTableView:(UITableView*)self.view andStory:story];
		} else {
			cell = [self getOrCreateFeatureCellForTableView:(UITableView*)self.view andStory:story];
		}
		if (cell) {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			UILabel *titleLabel = (UILabel*)[cell viewWithTag:TITLE_TAG];
			titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;	
			titleLabel.numberOfLines = 0;
			CGRect frame = titleLabel.frame;
			titleLabel.frame = CGRectMake(frame.origin.x, 
										  frame.origin.y, 
										  frame.size.width, 
										  [self heightForStoryTitleLabelWithText:titleLabel.text]);
		}
	}
    return cell;
}

- (UITableViewCell*) getOrCreateCellWithIdentifier:(NSString*)identifier andNibName:(NSString*)nibName {
	UITableViewCell *cell = (UITableViewCell *)[(UITableView*)self.view dequeueReusableCellWithIdentifier:identifier];		
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
		cell = (UITableViewCell *)[nib objectAtIndex:0];
		((UILabel*)[cell viewWithTag:TITLE_TAG]).numberOfLines = 0;
	}	
	return cell;
}


- (UITableViewCell*) getOrCreateReleaseCellForTableView:(UITableView*)tableView andStory:(Story*)story {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReleaseCellIdentifier];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:ReleaseCellNib owner:self options:nil];
		cell = (UITableViewCell *)[nib objectAtIndex:0];
	}	
	cell.contentView.backgroundColor = self.releaseColor;
	UILabel *titleLabel = (UILabel*)[cell viewWithTag:TITLE_TAG];
	[titleLabel setText:story.name];
	CGRect frame = titleLabel.frame;	
	titleLabel.frame = CGRectMake(frame.origin.x, 
								  0, 
								  frame.size.width, 
								  [self heightForStoryTitleLabelWithText:titleLabel.text]);	
	return cell;
}	

- (UITableViewCell*) getOrCreateBugCellForTableView:(UITableView*)tableView andStory:(Story*)story {
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:BugCellIdentifier];		
	if ([story isDone]) {
		cell = [self getOrCreateCellWithIdentifier:DoneBugCellIdentifier andNibName:DoneBugCellNib];
		cell.contentView.backgroundColor = self.doneFeatureColor;		
	} else if ([story isInWork]) {
		cell = [self getOrCreateCellWithIdentifier:InWorkBugCellIdentifier andNibName:InWorkBugCellNib];
		cell.contentView.backgroundColor = self.currentFeatureColor;		
	} else {
		cell = [self getOrCreateCellWithIdentifier:BugCellIdentifier andNibName:BugCellNib];
	}
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setFormatterBehavior:NSNumberFormatterDecimalStyle];
	
	[(UILabel*)[cell viewWithTag:NUMBER_TAG] setText:[formatter stringFromNumber:story.trackerId]];
	[(UILabel*)[cell viewWithTag:OWNER_TAG] setText:story.ownedBy];
	UILabel *titleLabel = (UILabel*)[cell viewWithTag:TITLE_TAG];
	[titleLabel setText:story.name];
	titleLabel.autoresizingMask   = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;	
	[formatter release];
	return cell;
}

- (UITableViewCell*) getOrCreateChoreCellForTableView:(UITableView*)tableView andStory:(Story*)story {
	UITableViewCell *cell = nil;
	if ([story isDone]) {
		cell = [self getOrCreateCellWithIdentifier:DoneChoreCellIdentifier andNibName:DoneChoreCellNib];
		cell.contentView.backgroundColor = self.doneFeatureColor;	
	} else if ([story isInWork]) {
		cell = [self getOrCreateCellWithIdentifier:InWorkChoreCellIdentifier andNibName:InWorkChoreCellNib];
		cell.contentView.backgroundColor = self.currentFeatureColor;	
	} else {
		cell = [self getOrCreateCellWithIdentifier:ChoreCellIdentifier andNibName:ChoreCellNib];
	}
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setFormatterBehavior:NSNumberFormatterDecimalStyle];
	
	[(UILabel*)[cell viewWithTag:NUMBER_TAG] setText:[formatter stringFromNumber:story.trackerId]];
	[(UILabel*)[cell viewWithTag:OWNER_TAG] setText:story.ownedBy];
	UILabel *titleLabel = (UILabel*)[cell viewWithTag:TITLE_TAG];
	[titleLabel setText:story.name];
	titleLabel.autoresizingMask   = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;	
	[formatter release];
	return cell;
}

- (UITableViewCell*) getOrCreateFeatureCellForTableView:(UITableView*)tableView andStory:(Story *)story {
	UITableViewCell *cell;
	if ([story isDone]) {
		cell = [self getOrCreateCellWithIdentifier:DoneFeatureCellIdentifier andNibName:DoneCellNib];
		cell.contentView.backgroundColor = self.doneFeatureColor;
	} else if ([story isInWork]) {
		cell = [self getOrCreateCellWithIdentifier:InWorkFeatureCellIdentifier andNibName:InWorkCellNib];
		cell.contentView.backgroundColor = self.currentFeatureColor;			
	} else{
		cell = [self getOrCreateCellWithIdentifier:FeatureCellIdentifier andNibName:CellNib];		
	}
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setFormatterBehavior:NSNumberFormatterDecimalStyle];

	UILabel *titleLabel = (UILabel*)[cell viewWithTag:TITLE_TAG];
	[titleLabel setText:story.name];	
	[(UILabel*)[cell viewWithTag:NUMBER_TAG] setText:[formatter stringFromNumber:story.trackerId]];
	NSString *score = ([story.score intValue] == -1) ? @"X" : [formatter stringFromNumber:story.score];
	[(UILabel*)[cell viewWithTag:SCORE_TAG] setText:score];
	[(UILabel*)[cell viewWithTag:OWNER_TAG] setText:story.ownedBy];	
	
	[formatter release];
	return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int padding = 2;
	Story *story = nil;
//	NSLog(@"heightForRowAtIndexPath %d %d", indexPath.section, indexPath.row);
	if ([self shouldDisplayStoryDetailsAtIndexPath:indexPath]) {
		Story *story = [self storyForDetailsAtIndexPath:indexPath];
		self.detailsCell = [self getOrCreateDetailsCellForIndexPath:indexPath];
		self.detailsCell.descLabel.text = story.desc ? story.desc : @"None";
//		NSLog(@"cell DETAIL height: %f", [self.detailsCell heightForCellWithOrientation:self.orientation]);
		return [self.detailsCell heightForCellWithOrientation:self.orientation];
	}
	if ([self hasSelectedRow] && indexPath.row > self.selectedRow+1) {
		// KLUGE to account for the additional cell for the details
		indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
//		NSLog(@"We're now using the row decrement kluge %d %d", indexPath.section, indexPath.row);			
	}
	if ([self isIcebox]) {
		story = [self.iceboxStories objectAtIndex:indexPath.row];
	} else {
		Iteration *iteration = [self.iterations objectAtIndex:indexPath.section];
		story = [iteration storyAtIndex:indexPath.row];
	}
	if (![story.storyType isEqualToString:@"release"]) {
		padding = 40;
	}

//	NSLog(@"cell height: %f", [self heightForStoryTitleLabelWithText:story.name] + padding);
	return [self heightForStoryTitleLabelWithText:story.name] + padding;
}

- (CGFloat) heightForStoryTitleLabelWithText:(NSString*)text {
    UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
	CGSize constraintSize;
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		constraintSize = CGSizeMake(PORTRAIT_TABLE_WIDTH - 170, MAXFLOAT);
	} else {
		constraintSize = CGSizeMake(LANDSCAPE_TABLE_WIDTH - 170, MAXFLOAT);		
	}
	return [text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap].height;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"willSelectRowAtIndexPath");
	NSArray *paths = nil;
	self.origSelectedRow = self.selectedRow;
	if ([self hasSelectedRow]) {
		if ([self shouldDisplayStoryDetailsAtIndexPath:indexPath]) {
//			NSLog(@"Dude, you clicked on the cell details WTF?");
			return nil;
		} else if (self.selectedSection == indexPath.section && self.selectedRow == indexPath.row) {
			return nil;
		} else {
//			NSLog(@"Remove existing selection");
			NSIndexPath *removeLocation = [NSIndexPath indexPathForRow:self.selectedRow+1 inSection:self.selectedSection];		
			paths = [NSArray arrayWithObject:removeLocation];		
			self.selectedSection = -1;
			self.selectedRow = -1;					
			[(UITableView*)self.view deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationNone];
		}
	}
	self.selectedSection = indexPath.section;
	self.selectedRow = indexPath.row;		
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	NSLog(@"Row selected %d %d", self.selectedSection, self.selectedRow);

	NSArray *paths = nil;
	if ([self hasSelectedRow]) {
		if ([self shouldDisplayStoryDetailsAtIndexPath:indexPath]) {
//			NSLog(@"Dude, you clicked on the cell details WTF?");
			return;
		}
	}
	
	if (self.origSelectedRow != -1 && self.origSelectedRow < self.selectedRow) {
		// Remember that the detail row is, in fact a row and effects the indices
		self.selectedRow--;
	}
	NSIndexPath *insertLocation = [NSIndexPath indexPathForRow:self.selectedRow+1 inSection:self.selectedSection];
	paths = [NSArray arrayWithObject:insertLocation];
//	NSLog(@"Attempting to insert row at %d %d", insertLocation.section, insertLocation.row);
	[(UITableView*)self.view insertRowsAtIndexPaths:(NSArray *)paths withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark -
#pragma mark Memory management


- (void) dealloc {
	[super dealloc];
	[self.releaseColor release];
	[self.doneFeatureColor release];
	[self.detailsCell release];
}

@end
