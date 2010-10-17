//
//  XPathHelper.h
//  Tracker Core Data
//
//  Created by Evan Light on 6/29/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved under Creative Commons Attribution-NonCommercial-ShareAlike 3.0..
//

#import <Foundation/Foundation.h>

@class CXMLNode;

@interface XPathHelper : NSObject {
	XPathHelper *instance;
}

@property (nonatomic,retain) XPathHelper *instance;

+ (id) getInstance;
- (NSString*) findStringForElement:(NSString*)element inNode:(CXMLNode*)node;

@end
