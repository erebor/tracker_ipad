//
//  MasterViewController.m
//  Tracker Core Data
//
//  Created by Evan Light on 7/23/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import "MasterViewController.h"
#import "MenuViewController.h"
#import "Tracker.h"
#import "Project.h"
#import "Iteration.h"
#import "Credentials.h"
#import "ProjectCardView.h"
#import "ProjectViewController.h"
#import "RefreshController.h"

#import "CKSparkline.h"

@implementation MasterViewController

@synthesize menuViewController, projectViewController, projectViews, scrollView,
			detailView, refreshController;

#define NUM_COLS_PORTRAIT	2
#define NUM_COLS_LANDSCAPE	3
#define PROJECT_CARD_HEIGHT 220
#define PROJECT_CARD_WIDTH	295
#define PROJECT_ROW_MARGIN  20
#define PROJECT_COL_MARGIN	20
#define PROJECT_COL_MARGIN_PORTRAIT		40
#define PROJECT_METRIC_CARD_LEFT_MARGIN 5
#define PROJECT_METRIC_CARD_TOP_MARGIN	5
#define PROJECT_NAME_LABEL_HEIGHT		30
#define PROJECT_METRIC_CARD_WIDTH ( PROJECT_CARD_WIDTH - 2 * PROJECT_METRIC_CARD_LEFT_MARGIN )
#define METRIC_TITLE_FONT_SIZE			12
#define METRIC_SUBTITLE_FONT_SIZE		9
#define METRIC_FONT_SIZE				24

#pragma mark -
#pragma mark View Lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectsFetched:) name:@"projectsFetched" object:nil];		
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectFetchFailed:) name:@"projectFetchFailed" object:nil];			
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationSucceeded:) name:@"authenticated" object:nil];				
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationFailed:) name:@"failedAuthentication" object:nil];				
	
	self.projectViews = [[NSMutableArray alloc] init];
	self.view = [[UIView alloc] init];

 	self.menuViewController = [[MenuViewController alloc] initWithMasterViewController:self];
	[self.view addSubview:menuViewController.view];	
	
	self.detailView = [[UIView alloc] init];
	[self.view addSubview:self.detailView];
	self.detailView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"cloth.png"]];
	
	self.scrollView = [[UIScrollView alloc] init];
	self.scrollView.backgroundColor = [UIColor clearColor]; 
	self.scrollView.bounces = YES; 
	self.scrollView.showsHorizontalScrollIndicator = NO;	
	self.scrollView.showsVerticalScrollIndicator = YES;
	self.scrollView.clipsToBounds = YES;
	[self.detailView addSubview:self.scrollView];
	
	UIInterfaceOrientation orientation = self.interfaceOrientation;
	[self adjustViewForOrientation:orientation];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	Tracker *tracker = [Tracker getInstance];
	if ([tracker hasCredentials]) {
		[tracker authenticate];
	} else {
		NSLog(@"showSettings");
		[self.menuViewController showSettings];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self adjustViewsForOrientation:toInterfaceOrientation];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void) adjustViewForOrientation:(UIInterfaceOrientation)orientation {
	if (orientation == UIInterfaceOrientationPortrait) {
		self.view.frame = CGRectMake(0.0, 20.0, 768.0, 1004.0);
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		self.view.frame = CGRectMake(0.0, 0.0, 768.0, 1004.0);		
	} else if (orientation == UIInterfaceOrientationLandscapeLeft) {
		self.view.frame = CGRectMake(20.0, 0.0, 748.0, 1024.0);				
	} else {
		self.view.frame = CGRectMake(00.0, 0.0, 748.0, 1024.0);				
	}
	if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
		self.detailView.frame = CGRectMake(50.0, 0.0, 718.0, 1004.0);
		self.scrollView.frame = CGRectMake(0.0, 0.0, 718.0, 1004.0);
	} else {
		self.detailView.frame = CGRectMake(50.0, 0.0, 974.0, 748.0);
		self.scrollView.frame = CGRectMake(0.0, 0.0, 974.0, 748.0);	
	}	
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	NSLog(@"view frame x:%f y:%f w:%f h:%f",
		  self.view.frame.origin.x,
		  self.view.frame.origin.y,
		  self.view.frame.size.width,
		  self.view.frame.size.height);
}

- (void) adjustViewsForOrientation:(UIInterfaceOrientation)orientation {
	[self deallocProjectViews];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProject:) name:@"open project" object:nil];		
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectsFetched:) name:@"projectsFetched" object:nil];		
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(projectFetchFailed:) name:@"projectFetchFailed" object:nil];			
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationSucceeded:) name:@"authenticated" object:nil];				
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationFailed:) name:@"failedAuthentication" object:nil];				

	[self renderProjectCardsFor:orientation];
	
	[self adjustViewForOrientation:orientation];	
	[self.menuViewController adjustViewsForOrientation:orientation];
	[self.projectViewController adjustViewsForOrientation:orientation];	
}

- (void) displaySplash {
	[self.menuViewController showRefreshAnimation];
}

- (void) hideSplash {
	[self.menuViewController hideRefreshAnimation];
}

#pragma mark -
#pragma mark Create UI

- (void) renderProjectCardsFor: (UIInterfaceOrientation)orientation {
	NSInteger numCols = 0;
	CGFloat contentWidth = 0;
	CGFloat colMargin = 0;
	
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
		contentWidth = 974;
		numCols = NUM_COLS_LANDSCAPE;
		colMargin = PROJECT_COL_MARGIN;
    } else if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
		contentWidth = 718;
		numCols = NUM_COLS_PORTRAIT;
		colMargin = PROJECT_COL_MARGIN_PORTRAIT;
    }	
	
	Tracker *tracker = [Tracker getInstance];
	
	// Draws Project Cards
	NSUInteger projectNum = 0;
	NSUInteger rowNum;
	CGFloat x, y;
	Project *project;
	for(rowNum = 0; projectNum < [tracker.projects count]; rowNum++) {
		for(NSUInteger colNum = 0; colNum < numCols; colNum++) {
			if (projectNum >= [tracker.projects count]) {
				break;
			}
			project = [tracker.projects objectAtIndex:projectNum];
//			NSLog(@"Got project %@", project.name);
			
			x = (colNum+1) * colMargin + colNum * PROJECT_CARD_WIDTH;
			y = (rowNum+1) * PROJECT_ROW_MARGIN + rowNum * PROJECT_CARD_HEIGHT;
			[self createProjectCardAtX:x y:y forProject:project];
			
			projectNum++;			
		}
	}
	
	CGFloat contentHeight = (rowNum+1) * PROJECT_ROW_MARGIN + rowNum * PROJECT_CARD_HEIGHT;
	self.scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
}

- (void) createProjectCardAtX:(CGFloat)x y:(CGFloat)y forProject:(Project*)project {
	ProjectCardView *projectView = [[ProjectCardView alloc] init];
	projectView.tag = [project.trackerId integerValue];
	UIColor *projectCardGray = [[UIColor alloc] initWithRed:221.0/255 green:221.0/255 blue:221.0/255 alpha:1];	
	projectView.backgroundColor = projectCardGray;
	projectView.frame = CGRectMake(x, y, PROJECT_CARD_WIDTH, PROJECT_CARD_HEIGHT);
	[scrollView addSubview:projectView];

	UILabel *label = [[UILabel alloc] init];
	label.text = [NSString stringWithFormat: project.name];
	label.frame = CGRectMake(0, 0, PROJECT_CARD_WIDTH, PROJECT_NAME_LABEL_HEIGHT);
	label.backgroundColor = projectCardGray;
	label.textAlignment = UITextAlignmentCenter;
	label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	label.font = [UIFont fontWithName:@"Verdana" size: 24];
	[projectView addSubview:label];

	[self createProjectMetricsViewInView:projectView forProject:project];
	[self.projectViews addObject:projectView];	
	
	[label release];
	[projectCardGray release];	
}

- (void) createProjectMetricsViewInView:(UIView*)projectView forProject:(Project*)project {
	UIView *projectMetricsView = [[UIView alloc] init];
	CGFloat projectMetricY = PROJECT_NAME_LABEL_HEIGHT + PROJECT_METRIC_CARD_TOP_MARGIN;
	CGFloat projectMetricHeight = PROJECT_CARD_HEIGHT - PROJECT_NAME_LABEL_HEIGHT - PROJECT_METRIC_CARD_TOP_MARGIN* 2;
	projectMetricsView.frame = CGRectMake(PROJECT_METRIC_CARD_LEFT_MARGIN, projectMetricY, PROJECT_METRIC_CARD_WIDTH, projectMetricHeight);
	projectMetricsView.backgroundColor = [UIColor whiteColor];
	
	UIFont *metricTitleFont = [UIFont fontWithName:@"Verdana" size: METRIC_TITLE_FONT_SIZE];
	UIFont *metricSubtitleFont = [UIFont fontWithName:@"Verdana" size: METRIC_SUBTITLE_FONT_SIZE];
	UIFont *metricFont = [UIFont fontWithName:@"Helvetica" size: METRIC_FONT_SIZE];
	UIColor *color = [[UIColor alloc] initWithRed:130.0/255 green:130.0/255. blue:130.0/255 alpha:1];
	
	CGFloat titleWidth = (PROJECT_METRIC_CARD_WIDTH - 20) / 2;
	CGFloat subtitleWidth = (PROJECT_METRIC_CARD_WIDTH - 20) / 4;

	Iteration *priorIteration = [project iterationForNumber:[project currentIterationNumber] - 1];
	Iteration *currentIteration = [project currentIteration];
	
    [self createLabelWithString:@"overall velocity" usingFont:metricTitleFont color:color inRect:CGRectMake(5, 15, titleWidth, METRIC_TITLE_FONT_SIZE + 6) inView:projectMetricsView];	
	[self createLabelWithString:[NSString stringWithFormat:@"%d", [project.currentVelocity intValue]] usingFont:metricFont color:color inRect:CGRectMake(5, 45, subtitleWidth, METRIC_FONT_SIZE) inView:projectMetricsView];
	[self createLabelWithString:@"current" usingFont:metricSubtitleFont color:color inRect:CGRectMake(5, 75, subtitleWidth, METRIC_SUBTITLE_FONT_SIZE) inView:projectMetricsView];	
	
	NSArray *iterationsUpToPresent = [project iterationsUpToPresent];
	CKSparkline *projectSparkline = [[CKSparkline alloc] initWithFrame:CGRectMake(5 + subtitleWidth, 45, subtitleWidth, METRIC_FONT_SIZE)];
	NSMutableArray *velocities = [[NSMutableArray alloc] init];
	for (Iteration *iteration in iterationsUpToPresent) {
//		NSLog(@"%@ iteration %d velocity %d", project.name, [iteration.iterationNumber intValue], [iteration.projectVelocity intValue]);
		[velocities addObject:iteration.projectVelocity];
	}
	projectSparkline.data = velocities;
	projectSparkline.lineColor = [UIColor blueColor];
	projectSparkline.highlightedLineColor = [UIColor yellowColor];
	[projectMetricsView addSubview:projectSparkline];
	
	NSString *avgPoints = [NSString stringWithFormat:@"avg %.2f", [project.average floatValue]];
    [self createLabelWithString:avgPoints usingFont:metricSubtitleFont color:color inRect:CGRectMake(5 + subtitleWidth, 75, subtitleWidth, METRIC_SUBTITLE_FONT_SIZE) inView:projectMetricsView];	
	
	[self createLabelWithString:@"overall progress" usingFont:metricTitleFont color:color inRect:CGRectMake(5, 105, titleWidth, METRIC_TITLE_FONT_SIZE + 6) inView:projectMetricsView];	
	NSString *percentComplete = [NSString stringWithFormat:@"%d%%", [project percentComplete]];
//	NSLog(@"percent complete: %d", [project percentComplete]);
	[self createLabelWithString:percentComplete usingFont:metricFont color:color inRect:CGRectMake(5, 135, subtitleWidth, METRIC_FONT_SIZE) inView:projectMetricsView];
	[self createLabelWithString:@"complete" usingFont:metricSubtitleFont color:color inRect:CGRectMake(5, 165, subtitleWidth, METRIC_SUBTITLE_FONT_SIZE) inView:projectMetricsView];	
	int pointsStartedInCurrentIteration = [[project currentIteration] pointsStarted];
	NSString *pointsStarted = [NSString stringWithFormat:@"%d", pointsStartedInCurrentIteration];
	[self createLabelWithString:pointsStarted usingFont:metricFont color:color inRect:CGRectMake(5 + subtitleWidth, 135, subtitleWidth, METRIC_FONT_SIZE) inView:projectMetricsView];
    [self createLabelWithString:@"in progress" usingFont:metricSubtitleFont color:color inRect:CGRectMake(5 + subtitleWidth, 165, subtitleWidth, METRIC_SUBTITLE_FONT_SIZE) inView:projectMetricsView];	

    [self createLabelWithString:@"my velocity" usingFont:metricTitleFont color:color inRect:CGRectMake(15 + titleWidth, 15, titleWidth, METRIC_TITLE_FONT_SIZE + 6) inView:projectMetricsView];	
	[self createLabelWithString:[NSString stringWithFormat:@"%d", [priorIteration.myVelocity intValue]] usingFont:metricFont color:color inRect:CGRectMake(15 + titleWidth, 45, subtitleWidth, METRIC_FONT_SIZE) inView:projectMetricsView];
	[self createLabelWithString:@"current" usingFont:metricSubtitleFont color:color inRect:CGRectMake(15 + titleWidth, 75, subtitleWidth, METRIC_SUBTITLE_FONT_SIZE) inView:projectMetricsView];	
	CKSparkline *mySparkline = [[CKSparkline alloc] initWithFrame:CGRectMake(5 + titleWidth + subtitleWidth, 45, subtitleWidth, METRIC_FONT_SIZE)];
	[velocities removeAllObjects];
	for (Iteration *iteration in iterationsUpToPresent) {
		[velocities addObject:iteration.myVelocity];
	}
	mySparkline.data = velocities;
	mySparkline.lineColor = [UIColor blueColor];
	mySparkline.highlightedLineColor = [UIColor yellowColor];
	[projectMetricsView addSubview:mySparkline];
	NSString *myAvgPoints = [NSString stringWithFormat:@"avg %.2f", [project.myAverage floatValue]];
    [self createLabelWithString:myAvgPoints usingFont:metricSubtitleFont color:color inRect:CGRectMake(15 + titleWidth * 3 / 2, 75, subtitleWidth, METRIC_SUBTITLE_FONT_SIZE) inView:projectMetricsView];	
    
	[self createLabelWithString:@"my progress" usingFont:metricTitleFont color:color inRect:CGRectMake(15 + titleWidth, 105, titleWidth, METRIC_TITLE_FONT_SIZE + 6) inView:projectMetricsView];	
	NSString *pointsComplete = [NSString stringWithFormat:@"%d", [currentIteration myPointsComplete]];
	[self createLabelWithString:pointsComplete usingFont:metricFont color:color inRect:CGRectMake(15 + titleWidth, 135, subtitleWidth, METRIC_FONT_SIZE) inView:projectMetricsView];
	[self createLabelWithString:@"complete" usingFont:metricSubtitleFont color:color inRect:CGRectMake(15 + titleWidth, 165, subtitleWidth, METRIC_SUBTITLE_FONT_SIZE) inView:projectMetricsView];	
	pointsStartedInCurrentIteration = [[project currentIteration] myPointsStarted];
	pointsStarted = [NSString stringWithFormat:@"%d", pointsStartedInCurrentIteration];
	[self createLabelWithString:pointsStarted usingFont:metricFont color:color inRect:CGRectMake(15 + titleWidth + subtitleWidth, 135, subtitleWidth, METRIC_FONT_SIZE) inView:projectMetricsView];
    [self createLabelWithString:@"in progress" usingFont:metricSubtitleFont color:color inRect:CGRectMake(15 + titleWidth + subtitleWidth, 165, subtitleWidth, METRIC_SUBTITLE_FONT_SIZE) inView:projectMetricsView];	

	[projectView addSubview:projectMetricsView];		
	
	[metricTitleFont release];
	[metricFont release];
	[projectMetricsView release];
	[projectSparkline release];	
	[mySparkline release];		
	[velocities release];
}

- (void) createLabelWithString:(NSString*)labelStr usingFont:(UIFont*)font color:(UIColor*)color inRect:(CGRect)rect inView:(UIView*)view {
	UILabel *label = [[UILabel alloc] init];
	label.text = labelStr;
	label.textColor = color;
	label.font = font;
	label.backgroundColor = view.backgroundColor;
	label.frame = rect;
	label.textAlignment = UITextAlignmentCenter;	
	[view addSubview:label];
	[label release];
}

#pragma mark -
#pragma mark Actions

- (void) refresh {
	[self displaySplash];
	[[Tracker getInstance] fetchProjects];
}

- (void) showProjectCards {
//	NSLog(@"showProjectCards");
	[self.menuViewController hideBackButton];
	[self.projectViewController.view removeFromSuperview];
	[self.detailView addSubview:self.scrollView];
}

#pragma mark -
#pragma mark Notifications

- (void) showProject:(NSNotification*)notification {
	Project *project = [[Tracker getInstance] findProjectWithID:[notification.object integerValue]];
//	NSLog(@"showProject: clicked on project %@", project.name);

	self.projectViewController = [[ProjectViewController alloc] initWithProject:project];
	[self.menuViewController showBackButton];
	[self.scrollView removeFromSuperview];
	[self.detailView addSubview:self.projectViewController.view];
}

- (void) projectsFetched:(NSNotification *)notification {
	[self.projectViewController refresh];	
	//	NSLog(@"refresh orientation: %d", self.interfaceOrientation);
	[self adjustViewsForOrientation:self.interfaceOrientation];	
	[self hideSplash];	
}

- (void) projectFetchFailed:(NSNotification *)notification {
	[self hideSplash];	
	if ([[Tracker getInstance] offline]) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Pivotal Tracker Inaccessible" 
														 message:@"Sorry, but we canot reach Pivotal Tracker at this time"
														delegate:self 
											   cancelButtonTitle:@"Ok" 
											   otherButtonTitles:nil]
							  autorelease];
		[alert show];		
	}
}

- (void) authenticationSucceeded:(NSNotification*)notification {
	[self refresh];
}

- (void) authenticationFailed:(NSNotification*)notification {
	[self hideSplash];	
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Failed to Authenticate" 
													 message:@"Tracker may be offline or your credentials may be incorrect"
													delegate:self 
										   cancelButtonTitle:@"Ok" 
										   otherButtonTitles:nil]
						  autorelease];
	[alert show];	
}


#pragma mark -
#pragma mark Application lifecycle

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

- (void)deallocProjectViews {
	UIView *view;
	NSEnumerator *projectEnum = [self.projectViews objectEnumerator];
	while(view = [projectEnum nextObject]) {
		[view removeFromSuperview];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.projectViews removeAllObjects];
}

- (void)dealloc {
    [super dealloc];
	[self.scrollView release];
	[self.detailView release];
}


@end
