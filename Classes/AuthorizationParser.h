//
//  AuthorizationParser.h
//  Tracker Core Data
//
//  Created by Evan Light on 6/16/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved.
//




@interface AuthorizationParser : NSXMLParser {
	NSString *guid;
	BOOL foundGuid;
}

@property (nonatomic,retain) NSString *guid;
@property (nonatomic) BOOL foundGuid;


- (id) initWithXML: (NSString*) xml;

@end
