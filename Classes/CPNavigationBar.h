//
//  CPNavigationBar.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CPNavigationBar : UINavigationBar {}

- (void)drawRect:(CGRect)rect;

@property (nonatomic) UIImage *backgroundImage;

@end
