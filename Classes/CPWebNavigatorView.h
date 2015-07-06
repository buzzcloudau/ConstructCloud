//
//  CPWebNavigatorView.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@interface CPWebNavigatorView : UIView <UIWebViewDelegate , UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIView *webNavigatorView;
@property (weak, nonatomic) IBOutlet UIWebView *webNavigatorWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *webNavigatorNavigateDone;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *webNavigatorNavigateRefresh;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *webNavigatorNavigateAction;
@property (weak, nonatomic) IBOutlet UILabel *webNavigatorLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *webNavigatorNavigateBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *webNavigatorNavigateForward;

- (IBAction)doneBtnTap:(id)sender;

@end
