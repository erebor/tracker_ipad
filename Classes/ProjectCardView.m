//
//  ContainerView.m
//  Tracker Core Data
//
//  Created by Evan Light on 8/2/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved.
//

#import "ProjectCardView.h"


@implementation ProjectCardView

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event {
	NSLog(@"Sending notification with value %d", self.tag);
	[[NSNotificationCenter defaultCenter] postNotificationName:@"open project" object:[NSNumber numberWithInteger:self.tag]];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	float colorValues[] = {0, 0, 0, .7};
	CGColorRef shadowColor = CGColorCreate(colorSpace, colorValues);
	CGSize shadowOffset = CGSizeMake(2, 2);
	CGContextSetShadowWithColor (context, shadowOffset, 4 /* blur */, shadowColor);
	[super drawRect:rect];
	
	CGColorRelease(shadowColor);
	CGColorSpaceRelease(colorSpace);
	CGContextRestoreGState(context);	
}

@end
