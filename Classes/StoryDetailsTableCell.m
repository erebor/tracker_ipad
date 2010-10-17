//
//  StoryDetailsTableCell.m
//  Tracker Core Data
//
//  Created by Evan Light on 8/21/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import "StoryDetailsTableCell.h"
#import "Story.h"


@implementation StoryDetailsTableCell

@synthesize descLabel, createdByLabel, createdAtLabel;

- (StoryDetailsTableCell*) init {
	self = [super init];
	self.contentView.backgroundColor = [[[UIColor alloc] initWithRed:213.0/255 
															   green:213.0/255 
																blue:213.0/255 
																alpha:1] autorelease];
	UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 50, 20)];
	desc.text = @"Desc:";
	desc.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
	desc.backgroundColor = self.contentView.backgroundColor;		
	[self.contentView addSubview:desc];
	[desc release];
	
	UILabel *createdBy = [[UILabel alloc] initWithFrame:CGRectMake(450, 5, 100, 20)];
	createdBy.text = @"Created by:";
	createdBy.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
	createdBy.backgroundColor = self.contentView.backgroundColor;	
	[self.contentView addSubview:createdBy];

	UILabel *createdAt = [[UILabel alloc] initWithFrame:CGRectMake(450, 30, 100, 20)];
	createdAt.text = @"Created at:";
	createdAt.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
	createdAt.backgroundColor = self.contentView.backgroundColor;		
	[self.contentView addSubview:createdAt];	
	
	self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, 350, 40)];
	self.descLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
	self.descLabel.backgroundColor = self.contentView.backgroundColor;
	self.descLabel.numberOfLines = 0;
//	self.descLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
	[self.contentView addSubview:self.descLabel];
	[self.descLabel release];

	self.createdByLabel = [[UILabel alloc] initWithFrame:CGRectMake(550, 5, 150, 20)];
	self.createdByLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
	self.createdByLabel.backgroundColor = self.contentView.backgroundColor;
	self.createdByLabel.numberOfLines = 0;
	[self.contentView addSubview:self.createdByLabel];
	[self.createdByLabel release];
	
	self.createdAtLabel = [[UILabel alloc] initWithFrame:CGRectMake(550, 30, 150, 20)];
	self.createdAtLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
	self.createdAtLabel.backgroundColor = self.contentView.backgroundColor;
	self.createdAtLabel.numberOfLines = 0;
	[self.contentView addSubview:self.createdAtLabel];
	[self.createdAtLabel release];

	return self;
}

- (void) displayStory:(Story*)story {
	self.createdByLabel.text = story.requestedBy;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMM dd"];
	self.createdAtLabel.text = [dateFormatter stringFromDate:story.createdAt];
	[dateFormatter release];
}

- (CGFloat) heightForDescWithOrientation:(UIInterfaceOrientation)orientation {
	UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
	CGSize constraintSize;
	if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
		constraintSize = CGSizeMake(350, MAXFLOAT);
	} else {
		constraintSize = CGSizeMake(550, MAXFLOAT);		
	}
	return [self.descLabel.text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap].height;
}

- (CGFloat) heightForCellWithOrientation:(UIInterfaceOrientation)orientation {
//	NSLog(@"heightForCellWithOrientation");
	CGFloat height = 10;
	CGFloat descLabelHeight = [self heightForDescWithOrientation:orientation];
//	NSLog(@"Height of %f for \"%@\"", descLabelHeight, self.descLabel.text);
	CGRect rect = self.descLabel.frame;
	self.descLabel.frame = CGRectMake(rect.origin.x,
									  rect.origin.y,
									  rect.size.width,
									  descLabelHeight);
	height += descLabelHeight;
	return height < 60 ? 60 : height;
}

@end
