//
//  CPUINavigationViewController.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import "CPSettingsData.h"

@interface CPUINavigationViewController : UINavigationController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL) shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;

@property (nonatomic) CPSettingsData *settings;

@end
