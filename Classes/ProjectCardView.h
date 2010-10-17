//
//  ContainerView.h
//  Tracker Core Data
//
//  Created by Evan Light on 8/2/10.
//  Copyright 2010 Triple Dog Dare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ProjectCardView : UIView {

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)drawRect:(CGRect)rect;
@end
