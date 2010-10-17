//
//  DetailViewController.h
//  Tracker Core Data
//
//  Created by Evan Light on 6/15/10.
//  Copyright Triple Dog Dare 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class RootViewController;

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    
    NSManagedObject *detailItem;

    UILabel *nameLabel;
	UILabel *typeLabel;
	UILabel *estimateLabel;
	UILabel *descriptionLabel;
	UILabel *createdOnLabel;
	UILabel *updatedAtLabel;
	UILabel *createdByLabel;

    RootViewController *rootViewController;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) NSManagedObject *detailItem;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel *estimateLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *createdOnLabel;
@property (nonatomic, retain) IBOutlet UILabel *updatedAtLabel;
@property (nonatomic, retain) IBOutlet UILabel *createdByLabel;

@property (nonatomic, assign) IBOutlet RootViewController *rootViewController;

- (IBAction)insertNewObject:(id)sender;

@end
