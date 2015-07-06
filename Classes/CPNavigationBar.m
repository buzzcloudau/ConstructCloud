//
//  CPNavigationBar.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPNavigationBar.h"

@implementation CPNavigationBar

@synthesize backgroundImage = _backgroundImage;

- (void)drawRect:(CGRect)rect {
    _backgroundImage = [UIImage imageNamed:@"navbar-bg.png"];
    [_backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
