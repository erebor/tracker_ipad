    //
//  RefreshController.m
//  Tracker Core Data
//
//  Created by Evan Light on 8/21/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import "RefreshController.h"


@implementation RefreshController

- (RefreshController*) init {
	self = [super init];
	self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"Refresh.xib" owner:self options:nil];
	self.view = [nibViews objectAtIndex:1];		
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

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self adjustOrientation:self.interfaceOrientation];
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
	NSLog(@"OHAI");
	[self adjustOrientation:toInterfaceOrientation];
}

- (void) adjustOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	NSLog(@"WTF!");
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
		self.view.frame = CGRectMake(0.0, 20.0, 768.0, 1004.0);
	} else if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		self.view.frame = CGRectMake(0.0, 0.0, 768.0, 1004.0);		
	} else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		self.view.frame = CGRectMake(20.0, 0.0, 748.0, 1024.0);				
	} else {
		self.view.frame = CGRectMake(00.0, 0.0, 748.0, 1024.0);				
	}
}


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
