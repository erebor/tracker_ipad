    //
//  MenuViewController.m
//  Tracker Core Data
//
//  Created by Evan Light on 7/23/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import "MenuViewController.h"
#import "PreferencesController.h"

@implementation MenuViewController

@synthesize preferencesController, masterViewController, settingsButton,
			refreshButton, backButton, refreshAnimationView;

- (id) initWithMasterViewController:(MasterViewController*)master {
	self = [super init];
	self.masterViewController = master;
	return self;
}

- (void) setButton:(UIButton*)button withImageFileName:(NSString*)fileName andExtension:(NSString*)extension forState:(UIControlState)state {
	NSString *pathToSettingsButtingImage = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
	UIImage *settingsButtonImage = [UIImage imageWithContentsOfFile:pathToSettingsButtingImage];
	[button setImage:settingsButtonImage forState:state];	
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_gradiant.png"]];
//	UIColor *lightGray = [[UIColor alloc] initWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1];
//	self.view.backgroundColor = lightGray;

	self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.view addSubview:self.settingsButton];
	[self setButton:self.settingsButton withImageFileName:@"settings-unselected" andExtension:@"png" forState:UIControlStateNormal];	
	[self setButton:self.settingsButton withImageFileName:@"settings-selected" andExtension:@"png" forState:UIControlStateHighlighted];		
	[self.settingsButton addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
	
	self.refreshButton = [[UIButton alloc] init];
	[self setButton:self.refreshButton withImageFileName:@"refresh-unselected" andExtension:@"png" forState:UIControlStateNormal];	
	[self setButton:self.refreshButton withImageFileName:@"refresh-selected" andExtension:@"png" forState:UIControlStateHighlighted];		
	[self.view addSubview:self.refreshButton];		
	[self.refreshButton addTarget:masterViewController action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];

	NSArray *myImages = [NSArray arrayWithObjects:
						 [UIImage imageNamed:@"refresh-180.png"],
						 [UIImage imageNamed:@"refresh-20.png"],
						 [UIImage imageNamed:@"refresh-40.png"],						 
						 [UIImage imageNamed:@"refresh-60.png"],
						 [UIImage imageNamed:@"refresh-80.png"],						 
						 [UIImage imageNamed:@"refresh-100.png"],
						 [UIImage imageNamed:@"refresh-120.png"],						 
						 [UIImage imageNamed:@"refresh-140.png"],						 
						 [UIImage imageNamed:@"refresh-160.png"],
						 [UIImage imageNamed:@"refresh-180.png"],						 
						 nil];	
	self.refreshAnimationView = [[UIImageView alloc] init];
	self.refreshAnimationView.animationImages = myImages;
	self.refreshAnimationView.animationDuration = 0.42; // seconds
	self.refreshAnimationView.animationRepeatCount = 0; // 0 = loops forever
	self.refreshAnimationView.tag = 42;	
	
	self.preferencesController = [[PreferencesController alloc] initWithMasterViewController:self.masterViewController];
	
	[self adjustViewsForOrientation: self.interfaceOrientation];
	
	self.backButton = [[UIButton alloc] init];
	[self setButton:self.backButton withImageFileName:@"back-unselected" andExtension:@"png" forState:UIControlStateNormal];	
	[self setButton:self.backButton withImageFileName:@"back-selected" andExtension:@"png" forState:UIControlStateHighlighted];		
	[self.backButton addTarget:masterViewController action:@selector(showProjectCards) forControlEvents:UIControlEventTouchUpInside];			
	
//	[lightGray release];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self adjustViewsForOrientation:toInterfaceOrientation];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		self.view.frame = CGRectMake(0, 0, 50, 748);
		self.refreshButton.frame = CGRectMake(5, 648, 40, 40);
		self.refreshAnimationView.frame = CGRectMake(-4, 648, 55, 40);
		self.settingsButton.frame = CGRectMake(5, 698, 40, 40);		
    } else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
		self.view.frame = CGRectMake(0, 0, 50, 1004);
		self.refreshButton.frame = CGRectMake(5, 904, 40, 40);
		self.refreshAnimationView.frame = CGRectMake(-4, 904, 55, 40);
		self.settingsButton.frame = CGRectMake(5, 954, 40, 40);
    }
	self.backButton.frame = CGRectMake(5, 10, 40, 40);
}

- (void) showBackButton {
	[self.view addSubview:self.backButton];	
}

- (void) hideBackButton {
	[self.backButton removeFromSuperview];
}

- (void) showRefreshAnimation {
	[self.refreshButton removeFromSuperview];
	[self.view addSubview:self.refreshAnimationView];
	[self.refreshAnimationView startAnimating];
}

- (void) hideRefreshAnimation {
	[self.refreshAnimationView removeFromSuperview];	
	[self.view addSubview:self.refreshButton];	
}

#pragma mark -
#pragma mark Actions

- (void) showSettings {
	[self.masterViewController presentModalViewController:self.preferencesController animated:YES];
}

#pragma mark -
#pragma mark Memory

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
}


@end
