//
//  CPWebView.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPMagazineWebView.h"

@implementation CPMagazineWebView

@synthesize mustRender = _mustRender;
@synthesize internalFrame = _internalFrame;
@synthesize hasBackgroundImage = _hasBackgroundImage;
@synthesize page = _page;
@synthesize currentPage = _currentPage;
@synthesize tagCount = _tagCount;
@synthesize contentPath = _contentPath;
@synthesize isLoaded = _isLoaded;
@synthesize mainView = _mainView;
@synthesize webView = _webView;
@synthesize viewTapGestureRecogniser = _viewTapGestureRecogniser;
@synthesize followingLink = _followingLink;
@synthesize xmlID = _xmlID;
@synthesize pageIndexInSet = _pageIndexInSet;
@synthesize pageSetCount = _pageSetCount;

- (id)initWithFrame:(CGRect)frame
   mustRenderOnLoad:(BOOL)mustRenderOnLoad
		contentPath:(NSString *)contentPath
{
    [[NSBundle mainBundle] loadNibNamed:@"CPMagazineWebView" owner:self options:nil];

	self = [super initWithFrame:frame];
	[_webView setFrame:frame];

	if (self) {

		_contentPath = contentPath;
        _internalFrame = frame;
		_isLoaded = FALSE;
		_followingLink = TRUE;
		
        _tagCount = 0;
        
        self.frame = frame;
        self.bounds = frame;

		[self setClipsToBounds:TRUE];
		[_webView.scrollView setBounces:FALSE];
		[_webView setDelegate:self];

		[self setBackgroundColor:[UIColor blackColor]];
		[self.mainView setBackgroundColor:[UIColor blackColor]];
		[_webView setBackgroundColor:[UIColor blackColor]];
		[_webView.scrollView setBackgroundColor:[UIColor blackColor]];

		[self setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
		[self.mainView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
		[_webView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];

		[self setAutoresizesSubviews:TRUE];
		[self setOpaque:TRUE];
		[self setUserInteractionEnabled:TRUE];

		_hasBackgroundImage = FALSE;

		[self addSubview:self.mainView];
		[self addSubview:_webView];

		[self initBG];
    }

    return self;
	
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
	return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches  withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches  withEvent:event];
}

- (void)resetLayout {

	//NSString *currentURL = [self.request.URL absoluteString];

	NSString *indexFile = [[_page childNamed:@"src"] valueWithPath:@"index"];

	if (_currentPage && !_isLoaded) {

		NSString *urlPath = [NSString stringWithFormat:@"%@/%@",_contentPath,indexFile];
		
		[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:urlPath isDirectory:NO]]];

		_isLoaded = TRUE;
		
	} else if (!_currentPage) {

		[_webView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
		_isLoaded = FALSE;
	}

}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

	NSURL *requestURL = [request URL];

	_followingLink = TRUE;
	
    if ( [[requestURL scheme] isEqualToString:@"file"]) {

		_followingLink = FALSE;
		return TRUE;

	} else if ( [[requestURL scheme] isEqualToString:@"http"] || [[requestURL scheme] isEqualToString:@"https"]) {
        //return ![[UIApplication sharedApplication ] openURL:requestURL];

		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:requestURL forKey:@"url"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPNavigateWebNavigator" object:nil userInfo:userInfo];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPShowWebNavigator" object:self];

		 _followingLink = FALSE;
		return FALSE;

    } else {

		_followingLink = FALSE;
		return ![[UIApplication sharedApplication] openURL:requestURL];

	}

	return TRUE;
}

- (void)clearLayout {

}

- (void)initBG {

}

- (void)setRenderedView {
	
}

- (void)setPageFromElement:(SMXMLElement *)xmlPage {
	_page = xmlPage;

	NSString *tmpStr = [_page attributeNamed:@"id"];

	if (tmpStr != NULL && tmpStr != nil) {
		_xmlID = tmpStr;
	} else {
		_xmlID = @"undefined";
	}
}

- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation {
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {

		[_webView setFrame:CGRectMake(0, 0, 1024, 768)];
		[_webView.scrollView setFrame:CGRectMake(0, 0, 1024, 768)];

	} else {

		[_webView setFrame:CGRectMake(0, 0, 768, 1024)];
		[_webView.scrollView setFrame:CGRectMake(0, 0, 768, 1024)];

	}
}

- (void)setIsLoaded:(BOOL)isLoaded {
	_isLoaded = isLoaded;
}

- (void)setMustRender:(BOOL)mustRender {
	_mustRender = mustRender;
}

- (void)setCurrentPage:(BOOL)currentPage {
	_currentPage = currentPage;
}

- (IBAction)tGRecogniser:(id)sender {

	//[[NSNotificationCenter defaultCenter] postNotificationName:@"CPHandleContentsOverlay" object:self];

	[self performSelector:@selector(processSingleTap) withObject:nil afterDelay:0.3];

}

- (void)processSingleTap {

	if (_followingLink) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPHandleSingleTap" object:nil userInfo:nil];
	} else {
		_followingLink = TRUE;
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
