//
//  XPathHelper.m
//  Tracker Core Data
//
//  Created by Evan Light on 6/29/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import "XPathHelper.h"
#import "TouchXML.h"

static XPathHelper *instance = NULL;

@implementation XPathHelper

@synthesize instance;

+ (id) getInstance {
	if (instance == NULL) {
		instance = [[XPathHelper alloc] init];
	}
	return instance;
}

- (NSString*) findStringForElement:(NSString*)element inNode:(CXMLNode*)node {
	NSArray *nodes = [node nodesForXPath:element error:nil];
	if ([nodes count] == 0) {
		return nil;
	}
	NSString *retval = [[nodes objectAtIndex:0] stringValue];
//	NSLog(@"%@: %@", element, retval);
	return retval;
}

@end
