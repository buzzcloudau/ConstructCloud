//
//  CPHUD.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CPHUD : NSObject

- (id) initWithView:(UIView *)parentView;
- (void) show:(BOOL)show;

@property (strong, nonatomic) UIView *parentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;

@end
