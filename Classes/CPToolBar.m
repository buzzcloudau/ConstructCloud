//
//  CPToolBar.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPToolBar.h"

@implementation CPToolBar

@synthesize backgroundImage = _backgroundImage;

- (void)drawRect:(CGRect)rect {

    _backgroundImage = [UIImage imageNamed:@"toolbar-bg.png"];
    [_backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	
}

@end
