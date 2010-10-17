    //
//  PreferencesController.m
//  Tracker Core Data
//
//  Created by Evan Light on 6/15/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import "PreferencesController.h"
#import "Tracker.h"


@implementation PreferencesController

@synthesize usernameField, passwordField, masterViewController, tracker;

- (id) initWithMasterViewController:(MasterViewController*)master {
	self = [super init];
	self.masterViewController = master;	
	return self;
	NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"Preferences" owner:self options:nil];
	self.view = [nibViews objectAtIndex:1];	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField { 
	[textField resignFirstResponder]; 
	[[Tracker getInstance] setUsername:self.usernameField.text];
	[[Tracker getInstance] setPassword:self.passwordField.text];
	[self done];
	return YES;
}

- (void)viewWillAppear:(BOOL)animated {
//	UIColor *transparent = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0];
//	self.view.backgroundColor = transparent;
	self.usernameField.text = [[Tracker getInstance] getUsername];
	self.passwordField.text = [[Tracker getInstance] getPassword];
//	[transparent release];
}

- (void) done {	
	[[Tracker getInstance] setUsername:self.usernameField.text];
	[[Tracker getInstance] setPassword:self.passwordField.text];

	[self.masterViewController dismissModalViewControllerAnimated:YES];
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
