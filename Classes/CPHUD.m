//
//  CPHUD.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPHUD.h"
#import "defs.h"

@implementation CPHUD

@synthesize parentView = _parentView;
@synthesize activityView = _activityView;

- (id) initWithView:(UIView *)parentView {

	self = [super init];
	
	_parentView = parentView;
	_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	
	_activityView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
									  UIViewAutoresizingFlexibleRightMargin |
									  UIViewAutoresizingFlexibleBottomMargin |
									  UIViewAutoresizingFlexibleLeftMargin);
	
	return self;
}

- (void) show:(BOOL)display {
	
	if (display && (_activityView.superview == nil || _activityView.alpha != 1.00f)) {
		
		_activityView.center=_parentView.center;
		
		[_activityView setAlpha:1.00f];
		
		[_activityView startAnimating];
		
		[_parentView addSubview:_activityView];
		
		[_parentView bringSubviewToFront:_activityView];
		
	} else if (!display) {
		
		[UIView animateWithDuration:0.50f animations:^(void) {
			
			[_activityView setAlpha:0.00f];
			
		} completion:^(BOOL finished) {
			
			[_activityView removeFromSuperview];
			
		}];
		
	}
	
}

@end
