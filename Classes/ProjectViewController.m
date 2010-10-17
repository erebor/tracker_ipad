    //
//  StoryViewController.m
//  Tracker Core Data
//
//  Created by Evan Light on 8/5/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import "Tracker.h"
#import "Project.h"
#import "StoryTableViewController.h"
#import "ProjectViewController.h"

@implementation ProjectViewController

@synthesize project, detailView, titleLabel, tabBar, tabBarView, storyTableDelegate, detailViewController,
			projectTrackerId, detailViewControllers, uiBarTitles;

- (id) initWithProject:(Project *)p {
	self = [super init];
	self.project = p;
	self.projectTrackerId = p.trackerId;
	return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view = [[UIView alloc] init];
	self.view.backgroundColor = [UIColor clearColor];
	
	self.titleLabel = [[UILabel alloc] init];
	titleLabel.text = self.project.name;
	titleLabel.font = [UIFont fontWithName:@"Helvetica" size:28];
	titleLabel.frame = CGRectMake(20, 10, 698, 30);
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:titleLabel];
	
	self.tabBarView = [[UIView alloc] init];
	[self.view addSubview:tabBarView];
	self.tabBarView.backgroundColor = [UIColor grayColor];
	self.tabBar = [[UITabBar alloc] init];
	self.tabBar.delegate = self;
	[self.tabBarView addSubview:self.tabBar];

	NSArray *uiBarImageNames = [[NSArray alloc] initWithObjects:@"current-unselected.png", @"done-unselected.png", @"backlog-unselected.png", @"icebox-unselected.png", nil];
	self.detailViewControllers = [[NSMutableArray alloc] init];
	[self.detailViewControllers addObject:[self storyTableViewControllerWithIterationsRelativeToCurrent:@"="]];
	[self.detailViewControllers addObject:[self storyTableViewControllerWithIterationsRelativeToCurrent:@"<"]];
	[self.detailViewControllers addObject:[self storyTableViewControllerWithIterationsRelativeToCurrent:@">"]];
	[self.detailViewControllers addObject:[self storyTableViewControllerWithIterationsRelativeToCurrent:nil]];

	self.uiBarTitles = [[[NSArray alloc] initWithObjects:@"Current", @"Done", @"Backlog", @"Icebox", nil] autorelease];	
	[self createUiBarItemsGivenTitles:uiBarTitles andImageNames:uiBarImageNames];
	[uiBarImageNames release];
	
	[self.tabBarView addSubview:((UIViewController*)[self.detailViewControllers objectAtIndex:0]).view];
	self.tabBar.selectedItem = (UITabBarItem*)[self.tabBar.items objectAtIndex:0];
}

- (StoryTableViewController*) storyTableViewControllerWithIterationsRelativeToCurrent:(NSString*)operand {
	NSPredicate *predicate = nil;
	if (operand) {
		NSString *predStr = [NSString stringWithFormat:@"project.trackerId = %d and iterationNumber %@ %d", 
							 [self.project.trackerId intValue], 
							 operand,
							 [self.project currentIterationNumber]
							 ];
		predicate = [NSPredicate predicateWithFormat:predStr];
	}
	NSLog(@"Predicate: %@", [predicate predicateFormat]);
	return [[StoryTableViewController alloc] initWithProject:self.project andIterationsPredicate:predicate]; 
}

- (void) createUiBarItemsGivenTitles:(NSArray*)uiBarTitles andImageNames:(NSArray*)uiBarFileNames {
	if ([self.uiBarTitles count] != [uiBarFileNames count]) {
		NSLog(@"ERROR: uiBarTitles length not the same as uiBarImageNames");
		return;
	}
	NSString *title, *fileName;
	UITabBarItem *item;
	UIImage *image;
	NSMutableArray *items = [[NSMutableArray alloc] init];
	for(NSUInteger i = 0; i < [self.uiBarTitles count]; i++) {
		title = [self.uiBarTitles objectAtIndex:i];
		fileName = [uiBarFileNames objectAtIndex:i];
		image = (fileName != nil && ![fileName isEqualToString:@""]) ? 
			[UIImage imageNamed:fileName] : 
			nil;
		item = [[UITabBarItem alloc] initWithTitle:title image:image tag:i];
		[items addObject:item];
	}
	[self.tabBar setItems:items];
	for (item in items) {
		[item release];
	}
	[items release];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self adjustViewsForOrientation:self.interfaceOrientation];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self adjustViewsForOrientation:toInterfaceOrientation];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
		self.view.frame = CGRectMake(0, 0, 718, 1004);
		self.tabBarView.frame = CGRectMake(0, 50, 718, 954);
		self.tabBar.frame = CGRectMake(0, 904, 718, 50);
	} else {
		self.view.frame = CGRectMake(0, 0, 974, 738);
		self.tabBarView.frame = CGRectMake(0, 50, 974, 698);
		self.tabBar.frame = CGRectMake(0, 648, 974, 50);		
	}
	for (UIViewController *controller in self.detailViewControllers) {
		[controller adjustViewsForOrientation:orientation];
	}
}

- (void) refresh {
	for (UIViewController *controller in self.detailViewControllers) {
		[controller refresh];
	}
	self.project = [[Tracker getInstance] findProjectWithID:[self.projectTrackerId integerValue]];
}


#pragma mark -
#pragma mark UITabBarDelegate

- (void)beginCustomizingItems:(NSArray *)items {
}

- (BOOL)endCustomizingAnimated:(BOOL)animated {
	return true;
}

- (BOOL)isCustomizing {
	return false;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
//	NSLog(@"Selected tab is %@", item.title);
	for (UIViewController *controller in self.detailViewControllers) {
		[controller.view removeFromSuperview];
	}
	for (NSInteger selectionIndex = 0; selectionIndex < [self.uiBarTitles count]; selectionIndex++) {
		NSString *titleAtIndex = (NSString*)[self.uiBarTitles objectAtIndex:selectionIndex];
		if ([titleAtIndex isEqualToString:item.title]) {
			UIViewController *controller = [self.detailViewControllers objectAtIndex:selectionIndex];
			[self.tabBarView addSubview:controller.view];
			break;
		}
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[self.titleLabel release];
	[self.detailViewController release];
	[self.uiBarTitles release];
}


@end
