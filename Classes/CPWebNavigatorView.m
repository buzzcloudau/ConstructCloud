//
//  CPWebNavigatorView.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPWebNavigatorView.h"

@implementation CPWebNavigatorView
@synthesize webNavigatorView;
@synthesize webNavigatorWebView;
@synthesize webNavigatorNavigateDone;
@synthesize webNavigatorNavigateRefresh;
@synthesize webNavigatorNavigateAction;
@synthesize webNavigatorLabel;
@synthesize webNavigatorNavigateBack;
@synthesize webNavigatorNavigateForward;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"CPWebNavigator" owner:self options:nil];
        [self addSubview:self.webNavigatorView];
		[self setFrame:frame];
		[self setBounds:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[self setClipsToBounds:TRUE];
		[self.webNavigatorView setBackgroundColor:[UIColor darkGrayColor]];
		[self.webNavigatorWebView.scrollView setBackgroundColor:[UIColor darkGrayColor]];
		[self.webNavigatorWebView setDelegate:(id)self];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)webViewDidFinishLoad:(UIWebView *)webView {

	webNavigatorNavigateBack.enabled = self.webNavigatorWebView.canGoBack;
	webNavigatorNavigateForward.enabled = self.webNavigatorWebView.canGoForward;

	[self.webNavigatorLabel setText:[webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	webNavigatorNavigateBack.enabled = self.webNavigatorWebView.canGoBack;
	webNavigatorNavigateForward.enabled = self.webNavigatorWebView.canGoForward;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

}

- (IBAction)doneBtnTap:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CPHideWebNavigator" object:self];
}

@end
