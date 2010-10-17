//
//  AuthorizationParser.m
//  Tracker Core Data
//
//  Created by Evan Light on 6/16/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved.
//

#import "AuthorizationParser.h"


@implementation AuthorizationParser

@synthesize guid, foundGuid;

#pragma mark -
#pragma mark Initializer

- (id) initWithXML: (NSString*) xml {
	self = [super initWithData: [xml dataUsingEncoding:NSUTF8StringEncoding]];
	[self setDelegate:self];
	return self;
}

#pragma mark -
#pragma mark XML Parser Delegate Methods

- (void)parser: (NSXMLParser*) xmlParser
didStartElement: (NSString*) element
  namespaceURI: (NSString*) uri
 qualifiedName: (NSString*) name
	attributes: (NSDictionary*) attributeDict {
	if ([element isEqualToString: @"guid"]) {
		self.foundGuid = YES;
	}
}

- (void)parser: (NSXMLParser*) xmlParser
foundCharacters: (NSString*) chars {
	if (self.foundGuid == YES) {
		self.guid = chars;
	}
}

- (void)parser:  (NSXMLParser*) xmlParser
 didEndElement: (NSString*) element
  namespaceURI: (NSString*) uri
 qualifiedName: (NSString*) name {
	if (self.foundGuid == YES) {
		self.foundGuid = NO;
	}
}

@end
