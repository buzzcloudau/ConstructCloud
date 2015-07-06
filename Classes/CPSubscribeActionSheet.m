//
//  CPSubscribeActionSheet.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPSubscribeActionSheet.h"
#import "RootViewController.h"
#import "defs.h"

@implementation CPSubscribeActionSheet

@synthesize navigationController = _navigationController;

- (id)initWithNavController:(UINavigationController *)navController {

	self = [super
				initWithTitle:@"Subscriptions"
				delegate:self
				cancelButtonTitle:@"Cancel"
				destructiveButtonTitle:nil
				otherButtonTitles:@"Subscribe Now",@"Restore Purchases",nil];

	_navigationController = navController;

	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) showSheet:(UIEvent*)event {

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {

		UIView *tView = nil;

		for( UITouch* touch in [event allTouches] ) {
			if( [touch phase] == UITouchPhaseEnded ) {
				tView = [touch view];
			}
		}

		[self showFromRect:CGRectMake(0, 0, tView.frame.size.width, tView.frame.size.height) inView:tView animated:YES];

	} else {

		[self showInView:_navigationController.navigationBar];
		
	}

}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	RootViewController *tmpRootView = (RootViewController *)self.navigationController.topViewController;

	if (buttonIndex == 0) {

		[tmpRootView actionSubscribe:self];

	} else if (buttonIndex == 1) {

		[tmpRootView actionRestore:self];

	}
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
