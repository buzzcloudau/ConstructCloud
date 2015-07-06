//
//  CPSubscribeActionSheet.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@interface CPSubscribeActionSheet : UIActionSheet <UIActionSheetDelegate> {
	UINavigationController *navigationController;
}

@property (nonatomic, retain) UINavigationController *navigationController;

- (void) showSheet:(UIEvent*)event;
- (id)initWithNavController:(UINavigationController *)navController;

@end
