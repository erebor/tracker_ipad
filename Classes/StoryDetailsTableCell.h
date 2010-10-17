//
//  StoryDetailsTableCell.h
//  Tracker Core Data
//
//  Created by Evan Light on 8/21/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Story;

@interface StoryDetailsTableCell : UITableViewCell {
	UILabel *descLabel;
	UILabel *createdByLabel;
	UILabel *createdAtLabel;
}

@property (nonatomic,retain) UILabel *descLabel;
@property (nonatomic,retain) UILabel *createdByLabel;
@property (nonatomic,retain) UILabel *createdAtLabel;

- (void) displayStory:(Story*)story;
- (CGFloat) heightForDescWithOrientation:(UIInterfaceOrientation)orientation;
- (CGFloat) heightForCellWithOrientation:(UIInterfaceOrientation)orientation;
@end
