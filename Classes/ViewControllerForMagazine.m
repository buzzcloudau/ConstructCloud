//
//  ViewControllerForMagazine.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "ViewControllerForMagazine.h"
#import "CPMagazinePageView.h"
#import "CPMagazineWebView.h"
#import "SMXMLDocument.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "defs.h"
#import "CPPageControl.h"

@implementation ViewControllerForMagazine
@synthesize ExpNavView = _ExpNavView;
@synthesize buttonSocial = _buttonSocial;

@synthesize scrollView = _scrollView;

@synthesize articlePages = _articlePages;
@synthesize prevIndex = _prevIndex;
@synthesize currIndex = _currIndex;
@synthesize nextIndex = _nextIndex;
@synthesize currentOffset = _currentOffset;
@synthesize docVersion = _docVersion;
@synthesize pageCount = _pageCount;
@synthesize xmlDoc = _xmlDoc;
@synthesize contentPath = _contentPath;
@synthesize disableRotations = _disableRotations;
@synthesize contentsView = _contentsView;
@synthesize webNavView = _webNavView;
@synthesize contentsBGView = _contentsBGView;
@synthesize navigationPages = _navigationPages;
@synthesize setupComplete = _setupComplete;
@synthesize settings = _settings;
@synthesize player = _player;
@synthesize articlePager = _articlePager;

@synthesize button1;
@synthesize button2;
@synthesize button3;
@synthesize button4;
@synthesize button5;
@synthesize main;
@synthesize navigation;

// @synthesize contentsScrollContent = _contentsScrollContent;

- (void)viewDidLoad {

    [super viewDidLoad];

	_settings = [CPSettingsData getInstance];

    if (![_settings.device isEqualToString:@"iPhone"]) {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
	}
    
    [self setViewSize];
    
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        self.view.frame = CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f);
	} else {
        self.view.frame = CGRectMake(0.0f, 0.0f, 768.0f, 1024.0f);
	}

	_articlePager = [[CPPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 20, self.view.frame.size.width, 20)];
	
	_articlePager.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
									  UIViewContentModeBottom |
									  UIViewAutoresizingFlexibleLeftMargin |
									  UIViewAutoresizingFlexibleRightMargin |
									  UIViewAutoresizingFlexibleWidth);
	
	_articlePager.numberOfPages = 1;
	_articlePager.currentPage = 1;
	//_articlePager.delegate = self.view;
	[self.view addSubview:_articlePager];

	[_ExpNavView.layer setZPosition:_articlePager.layer.zPosition + 1];
	[_buttonSocial.layer setZPosition:_ExpNavView.layer.zPosition + 1];
	
	// initialize ExpandableNavigation object with an array of buttons.
    NSArray* buttons = [NSArray arrayWithObjects:button1, button2, button3, button4, button5, nil];

    self.navigation = [[ExpandableNavigation alloc] initWithMenuItems:buttons mainButton:self.main radius:120.0];
    
    [_scrollView setPagingEnabled:TRUE];
    [_scrollView setScrollsToTop:TRUE];
    [_scrollView setShowsHorizontalScrollIndicator:TRUE];
    [_scrollView setBounces:TRUE];
	[_scrollView setCanCancelContentTouches:FALSE];
	[_scrollView setBackgroundColor:[UIColor blackColor]];
	
    _pageCount = 0;
    _prevIndex = -1;
    _currIndex = 0;
    _nextIndex = 1;

	_navAnimating = false;
	
    
    _articlePages = [[NSMutableArray alloc] init]; // stores the references to the page objects
	_navigationPages = [[NSMutableArray alloc] init]; // stores the page id's
    
	//UIImage *patternImage = [UIImage imageNamed:@"backgroundTile2.png"];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:patternImage];
	self.view.backgroundColor = [UIColor darkGrayColor];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    // LOAD THE XML FILE
	NSData *data = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/issue.xml",_contentPath]];

    NSError *error;
	_xmlDoc = [SMXMLDocument documentWithData:data error:&error];

    // check for errors
    if (error) {
		/* 
		 UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Error while parsing the document"
														  message:[error description]
														 delegate:nil
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
		*/
		
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@""
														  message:[NSString stringWithFormat:@"There was an error loading %@",_settings.publicationName]
														 delegate:self
												cancelButtonTitle:@"Back"
												otherButtonTitles:@"Retry",nil];
		
		DLog(@"Parse Error : %@",error);
		
		[message show];
		
        return;
   }
    
    // Load everything
    _docVersion = [[_xmlDoc.root childNamed:@"settings"] valueWithPath:@"version"];

	// THIS IS HOW YOU SEARCH
    // SMXMLElement *xx = [document.root childWithAttribute:@"id" value:@"shenyun"];
    // //// DLog(@"xxx var = %@",[xx valueWithPath:@"title"]);

	if (_setupComplete != TRUE) {

		if ([_docVersion isEqualToString:@"1.0"]) {
			[self runSetupv1];
		} else {
			//// DLog(@"cant find the document version. Found: %@",_docVersion);
		}

		[self setSetupComplete:TRUE];
	}

	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		_webNavView = [[CPWebNavigatorView alloc] initWithFrame:CGRectMake(0, (0-self.view.frame.size.height), self.view.frame.size.width, self.view.frame.size.height)];
		_contentsView = [[CPContentsView alloc] initWithFrame:CGRectMake(-320, 0, 300, (self.view.frame.size.height)) xmlDoc:_xmlDoc contentPath:_contentPath navBar:self.navigationController parentController:self];
		_contentsBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	} else {
		_webNavView = [[CPWebNavigatorView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.width*2), self.view.frame.size.height, self.view.frame.size.width)];
		_contentsView = [[CPContentsView alloc] initWithFrame:CGRectMake(-320, 0, 300, (self.view.frame.size.width)) xmlDoc:_xmlDoc contentPath:_contentPath navBar:self.navigationController parentController:self];
		_contentsBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
	}

    // Add the touch actions
//	UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleContentsOverlay:)];
//    doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
//    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
//    [_scrollView addGestureRecognizer:doubleTapGestureRecognizer];

	UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleContentsOverlay:)];
    singleTapGestureRecognizer.numberOfTouchesRequired = 1;
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
	[_contentsBGView addGestureRecognizer:singleTapGestureRecognizer];

	UITapGestureRecognizer *singleTapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleExpNav:)];
    singleTapGestureRecognizer2.numberOfTouchesRequired = 1;
    singleTapGestureRecognizer2.numberOfTapsRequired = 1;
	[_contentsBGView addGestureRecognizer:singleTapGestureRecognizer2];
	[_scrollView addGestureRecognizer:singleTapGestureRecognizer2];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(expNavAnimationCollapseView)
                                                 name:@"CPHandleExpNavCollapse"
                                               object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(expNavAnimationExpandView)
                                                 name:@"CPHandleExpNavExpand"
                                               object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleExpNav:)
                                                 name:@"CPHandleSingleTap"
                                               object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleContentsOverlayFromNotification:)
                                                 name:@"CPHandleContentsOverlay"
                                               object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performContentsOverlayActionOpen)
                                                 name:@"CPHandleContentsOverlayOpen"
                                               object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performContentsOverlayActionClose)
                                                 name:@"CPHandleContentsOverlayClose"
                                               object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webViewOpenHandler:)
                                                 name:@"CPShowWebNavigator"
                                               object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webViewCloseHandler:)
                                                 name:@"CPHideWebNavigator"
                                               object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webViewNavigateHandler:)
                                                 name:@"CPNavigateWebNavigator"
                                               object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resetLayout:)
												 name:@"CPInterfaceOrientationChange"
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resetLayout:)
												 name:MPMoviePlayerWillExitFullscreenNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(movieEventFullscreenHandler:)
												 name:MPMoviePlayerDidExitFullscreenNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(movieEventEnterFullscreenHandler:)
												 name:MPMoviePlayerWillEnterFullscreenNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(navigateToPage:)
												 name:@"CPNavigateToPage"
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(processAfterScroll)
												 name:@"CPProcessAfterScroll"
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playFullScreenVideo:)
												 name:@"CPPlayFullScreenVideo"
											   object:nil];


//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(movieEventFullscreenHandler:)
//												 name:UIDeviceOrientationDidChangeNotification
//											   object:nil];
//	
	[_contentsBGView setBackgroundColor:[UIColor blackColor]];
	[_contentsBGView.layer setZPosition:1];
	[_contentsBGView setAlpha:0];

	[_contentsView.layer setZPosition:2];
	[_contentsView setAlpha:0];

//	[_contentsView.layer setShadowColor:[UIColor blackColor].CGColor];
//	[_contentsView.layer setShadowOpacity:0.5f];
//	[_contentsView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
//	[_contentsView.layer setShadowRadius:3.0];

	[self.view addSubview:_contentsBGView];
	[self.view addSubview:_contentsView];
	[self.view addSubview:_webNavView];
}

- (void) playFullScreenVideo:(id)sender {

	NSURL *movieURL = [[sender userInfo] valueForKey:@"movieurl"];

	_player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
	[_scrollView addSubview:_player.view];
	// DEPRECIATED [_player setUseApplicationAudioSession:FALSE];
	[_player setMovieSourceType:MPMovieSourceTypeFile];

	[_player prepareToPlay];
	[_player setFullscreen:TRUE animated:FALSE];
	[_player play];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	
    if([title isEqualToString:@"Retry"])
    {
		[self performSelector:@selector(viewDidLoad) withObject:nil afterDelay:0.5];
    }
	
	if([title isEqualToString:@"Back"])
    {
		[self.navigationController setNavigationBarHidden:FALSE animated:FALSE];
		//[self.navigationController setToolbarHidden:FALSE animated:FALSE];

		if (![_settings.device isEqualToString:@"iPhone"]) {
			[[UIApplication sharedApplication] setStatusBarHidden:FALSE withAnimation:FALSE];
		}

		[self.navigationController popViewControllerAnimated:FALSE];
    }
}

- (IBAction) touchMenuItem:(id)sender {

//    // if the menu is expanded, then collapse it when an menu item is touched.
//    UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil
//													  message:[(UIButton *)sender currentTitle]
//													 delegate:nil
//											cancelButtonTitle:@"OK"
//											otherButtonTitles:nil];
//    [message show];

	if (sender == button1) {
		
		[self.navigationController setNavigationBarHidden:FALSE animated:FALSE];
		//[self.navigationController setToolbarHidden:YES animated:FALSE];

		if (![_settings.device isEqualToString:@"iPhone"]) {
			[[UIApplication sharedApplication] setStatusBarHidden:FALSE withAnimation:FALSE];
		}

		[self.navigationController popViewControllerAnimated:FALSE];
		//[_navBar popToRootViewControllerAnimated:TRUE];

	} else if (sender == button2) {

		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPHandleContentsOverlay" object:self];

	} else {

		NSString *urlStr = nil;

		if (sender == button3) {

			urlStr = _settings.facebookURL;

		} else if (sender == button4) {

			urlStr = _settings.twitterURL;

		} else if (sender == button5) {

			urlStr = _settings.youtubeURL;

		}

		NSURL *requestURL = [[NSURL alloc] initWithString:urlStr];

		if ( [[requestURL scheme] isEqualToString:@"http"]
			|| [[requestURL scheme] isEqualToString:@"https"]
			) {
			//return ![[UIApplication sharedApplication ] openURL:requestURL];

			NSDictionary *userInfo = [NSDictionary dictionaryWithObject:requestURL forKey:@"url"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"CPNavigateWebNavigator" object:nil userInfo:userInfo];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"CPShowWebNavigator" object:self];

		} else {

			[[UIApplication sharedApplication] openURL:requestURL];
			
		}

	}

//	if( self.navigation.expanded ) {
//		[self.navigation collapse];
//	}
}

- (IBAction)socialButtonTouch:(id)sender forEvent:(UIEvent *)event {
}


- (void)navigateToPage:(id)sender {

	NSString *pageid = [[sender userInfo] valueForKey:@"pageid"];
	int pageNum = [_navigationPages indexOfObject:pageid]; // returns max int (?) if object not found.

	if ([_settings internetActive]) {
		@try {

			// TRACK THE LAUNCH
			id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
			[tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"uiPage"
																   action:@"navigatetopage"
																	label:[NSString stringWithFormat:@"/app/mag/%@/%@/navto/%@",[_settings publication],[_settings currentIssue],pageid]
																	value:[NSNumber numberWithInt:1]] set:@"start" forKey:kGAISessionControl] build]];
			
		} @catch (NSException *e) {

			DLog(@"error trying to log google analytics...");

		}
	}

	if (pageNum < ([_navigationPages count] + 1)) {
		DLog(@"*********** handleExpNav - navigate");
		[self handleExpNav:nil];
		// [navigation collapse];
		//[self expNavAnimationCollapseView];

		if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
			[_scrollView scrollRectToVisible:CGRectMake(([UIScreen mainScreen].bounds.size.height * pageNum), 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width) animated:NO];
		} else {
			[_scrollView scrollRectToVisible:CGRectMake(([UIScreen mainScreen].bounds.size.width * pageNum), 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) animated:NO];
		}

		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPProcessAfterScroll" object:nil userInfo:nil];

		[_articlePager setAlpha:1];

		[UIView animateWithDuration:0.5f
							  delay:3.0f
							options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
						 animations:^{

							 [_articlePager setAlpha:0];

						 }
						 completion:^(BOOL finished){
							 
						 }];
		
	} else {
		DLog(@"page not found -- %@",pageid);
	}

}

- (void)resetLayout:(id)sender {

	[self willAnimateRotationToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:0];
	
}

- (void)movieEventFullscreenHandler:(id)sender {

	[_settings setIsFullScreen:NO];
  
	[self didRotateFromInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];

}

- (void)movieEventEnterFullscreenHandler:(id)sender {
	[_settings setIsFullScreen:YES];
	
}

- (void)webViewOpenHandler:(id)sender {

	[UIView animateWithDuration:0.6f
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
					 animations:^{

						 [_webNavView setFrame:CGRectMake(0, 0, _webNavView.frame.size.width, _webNavView.frame.size.height)];

					 }
					 completion:^(BOOL finished){

						 if (finished) {

						 }
						 
					 }];
	
}

- (void)webViewCloseHandler:(id)sender {

	[UIView animateWithDuration:0.6f
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
					 animations:^{

						 [_webNavView setFrame:CGRectMake(0, (_webNavView.frame.size.height*2), _webNavView.frame.size.width, _webNavView.frame.size.height)];

					 }
					 completion:^(BOOL finished){

						 if (finished) {
							 [_webNavView.webNavigatorWebView loadHTMLString:@"<html><head></head><body></body></html>" baseURL:nil];
						 }
						 
					 }];
	
}

- (void)webViewNavigateHandler:(NSNotification *)notification {

	NSDictionary	*userInfo	= notification.userInfo;
    NSURL			*url		= [userInfo objectForKey:@"url"];
	NSURLRequest	*request	= [NSURLRequest requestWithURL:url];
	
	if ([_settings internetActive]) {
		
		// TRACK THE LAUNCH
		id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
		[tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"uiWebNavigator"
															   action:@"urlload"
																label:[NSString stringWithFormat:@"/app/mag/%@/%@/url/%@",[_settings publication],[_settings currentIssue],url]
																value:[NSNumber numberWithInt:1]] set:@"start" forKey:kGAISessionControl] build]];
		
	}
	
	[self performContentsOverlayActionClose];
	[_webNavView.webNavigatorLabel setText:@"Loading..."];
	[_webNavView.webNavigatorWebView loadRequest:request];
	[self expNavAnimationCollapseView];
	
}


///*************************************************************///
///*************************************************************///
///                                                             ///
///                                                             ///
///    VERSION 1.0                                              ///
///                                                             ///
///                                                             ///
///*************************************************************///
///*************************************************************///


- (void)runSetupv1 {
    
    SMXMLElement *article = [_xmlDoc.root childNamed:@"article"];

	int pageSetCount = 0;
	int pageSetIndex = 0;

	for (article in [_xmlDoc.root childrenNamed:@"article"]) {

		pageSetCount = [[article childrenNamed:@"page"] count];
		pageSetIndex = -1;

        for (SMXMLElement *page in [article childrenNamed:@"page"]) {

			[_navigationPages addObject:[page attributeNamed:@"id"]];

            BOOL doRenderOnLoad = FALSE;
            
            if ((_pageCount + 1) == _prevIndex || (_pageCount + 1) == _currIndex || (_pageCount + 1) == _nextIndex) {
                doRenderOnLoad = TRUE;
            }

			pageSetIndex++;

			if ([[page attributeNamed:@"type"] isEqualToString:@"webview"]) {


				CPMagazineWebView *pageDoc = [[CPMagazineWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)
																	 mustRenderOnLoad:doRenderOnLoad
																		  contentPath:_contentPath];

				[pageDoc setPageSetCount:pageSetCount];
				[pageDoc setPageIndexInSet:pageSetIndex];

				pageDoc.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
											UIViewAutoresizingFlexibleRightMargin |
											UIViewAutoresizingFlexibleBottomMargin |
											UIViewAutoresizingFlexibleLeftMargin);
				
				pageDoc.center = CGPointMake(screenWidth/2, screenHeight/2);
				
				[_articlePages addObject:pageDoc];
				_pageCount = [_articlePages count];
				
				pageDoc.tag = _pageCount;
				[pageDoc setPageFromElement:page];
				
				if (_pageCount == 1) {
					pageDoc.mustRender = TRUE;
					pageDoc.currentPage = TRUE;
				} else if (_pageCount == 2) {
					pageDoc.mustRender = TRUE;
					pageDoc.currentPage = FALSE;
				} else {
					pageDoc.mustRender = FALSE;
					pageDoc.currentPage = FALSE;
				}
				
				[_scrollView addSubview:pageDoc];
				
			} else {
				
				float lpageWidth;
				float lpageHeight;
				float ppageWidth;
				float ppageHeight;
				
				CGRect pageFrame;
				CGPoint pageCenter;
				
				
				if ([page attributeNamed:@"lwidth"] != nil && [page attributeNamed:@"lheight"] != nil) {
					
					lpageHeight = [[page attributeNamed:@"lheight"] floatValue];
					lpageWidth = [[page attributeNamed:@"lwidth"] floatValue];
					
				} else {
					
					if ([page attributeNamed:@"height"] != nil) {
					
						lpageWidth = [[page attributeNamed:@"height"] floatValue];
						
					} else {
						
						if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
							lpageWidth = screenWidth;
						} else {
							lpageWidth = screenHeight;
						}
						
					}
					
					if ([page attributeNamed:@"width"] != nil) {
						
						lpageHeight = [[page attributeNamed:@"width"] floatValue];
						
					} else {
						
						if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
							lpageHeight = screenHeight;
						} else {
							lpageHeight = screenWidth;
						}
						
					}
					
				}
				
				if ([page attributeNamed:@"pwidth"] != nil && [page attributeNamed:@"pheight"] != nil) {
					
					ppageHeight = [[page attributeNamed:@"pheight"] floatValue];
					ppageWidth = [[page attributeNamed:@"pwidth"] floatValue];
					
				} else {
					
					if ([page attributeNamed:@"height"] != nil) {
						
						ppageWidth = [[page attributeNamed:@"height"] floatValue];
						
					} else {
						
						if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
							ppageWidth = screenHeight;
						} else {
							ppageWidth = screenWidth;
						}
						
					}
					
					if ([page attributeNamed:@"width"] != nil) {
						
						ppageHeight = [[page attributeNamed:@"height"] floatValue];
						
					} else {
						
						if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
							ppageHeight = screenWidth;
						} else {
							ppageHeight = screenHeight;
						}
						
					}
					
				}
				
				if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
				
					pageFrame = CGRectMake(0, 0, lpageWidth , lpageHeight);
					pageCenter = CGPointMake(lpageWidth/2, lpageHeight/2);
					
				} else {
				
					pageFrame = CGRectMake(0, 0, ppageWidth , ppageHeight);
					pageCenter = CGPointMake(ppageWidth/2, ppageHeight/2);
					
				}
				
				CPMagazinePageView *pageDoc = [[CPMagazinePageView alloc] initWithFrame:pageFrame
																	   mustRenderOnLoad:doRenderOnLoad
																			contentPath:_contentPath
																			 lpageWidth:lpageWidth
																			lpageHeight:lpageHeight
																			 ppageWidth:ppageWidth
																			ppageHeight:ppageHeight];


				[pageDoc setPageSetCount:pageSetCount];
				[pageDoc setPageIndexInSet:pageSetIndex];

				pageDoc.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
											UIViewAutoresizingFlexibleRightMargin |
											UIViewAutoresizingFlexibleBottomMargin |
											UIViewAutoresizingFlexibleLeftMargin);
				
				pageDoc.center = pageCenter;
				
				[_articlePages addObject:pageDoc];
				_pageCount = [_articlePages count];
				
				pageDoc.tag = _pageCount;
				[pageDoc setPageFromElement:page];
				
				if (_pageCount == 1) {
					pageDoc.mustRender = TRUE;
					pageDoc.currentPage = TRUE;
				} else if (_pageCount == 2) {
					pageDoc.mustRender = TRUE;
					pageDoc.currentPage = FALSE;
				} else {
					pageDoc.mustRender = FALSE;
					pageDoc.currentPage = FALSE;
				}
				
				[_scrollView addSubview:pageDoc];

			}
        }
    }
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)sender {
    
    _disableRotations = TRUE;

	[_articlePager setAlpha:1.0f];

}

- (void)willResume {   
    
    [self setViewSize];
	[self alignSubviews];
	
	_currIndex = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    _nextIndex = _currIndex + 1;
	_prevIndex = _currIndex - 1;
	
	for (int i = 0; i < _pageCount; i++) {
		
		if ([_docVersion isEqualToString:@"1.0"]) {

			if ([[_articlePages objectAtIndex:i] isKindOfClass:[CPMagazinePageView class]]) {

				CPMagazinePageView * tmp = (CPMagazinePageView *)[_articlePages objectAtIndex:i];
				
				if (tmp.tag > 0) {
					if (i == _currIndex) {
						tmp.mustRender = TRUE;
						tmp.currentPage = TRUE;
					} else if (i == _prevIndex || i == _nextIndex) {
						tmp.mustRender = TRUE;
						tmp.currentPage = FALSE;
					} else {
						tmp.mustRender = FALSE;
						tmp.currentPage = FALSE;
					}
					
					tmp.hasBackgroundImage = FALSE;
					if (tmp.mustRender) {
						DLog(@"preRotate willResume : %@",tmp.xmlID);
					}
					[tmp preRotate:[UIApplication sharedApplication].statusBarOrientation];
					[tmp resetLayout];
				}
				
			} else if ([[_articlePages objectAtIndex:i] isKindOfClass:[CPMagazineWebView class]]) {

				CPMagazineWebView * tmp = (CPMagazineWebView *)[_articlePages objectAtIndex:i];
				
				if (tmp.tag > 0) {
					if (i == _currIndex) {
						tmp.mustRender = TRUE;
						tmp.currentPage = TRUE;
					} else if (i == _prevIndex || i == _nextIndex) {
						tmp.mustRender = TRUE;
						tmp.currentPage = FALSE;
					} else {
						tmp.mustRender = FALSE;
						tmp.currentPage = FALSE;
					}
					
					tmp.hasBackgroundImage = FALSE;
					[tmp preRotate:[UIApplication sharedApplication].statusBarOrientation];
					[tmp resetLayout];
				}
				
			} else {
				DLog(@"Strange Class ----- %@",[[_articlePages objectAtIndex:i] class]);
			}
		}
	}
	
	[_scrollView flashScrollIndicators];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
	[self processAfterScroll];
}

-(void)processAfterScroll {
    
    NSInteger prev_currIndex = _currIndex;
    
    _currIndex = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    
    if (prev_currIndex != _currIndex) {
        
        _nextIndex = _currIndex + 1;
        _prevIndex = _currIndex - 1;
        
        for (int i = 0; i < _pageCount; i++) {
            
            if ([_docVersion isEqualToString:@"1.0"]) {
                
                if ([[_articlePages objectAtIndex:i] isKindOfClass:[CPMagazinePageView class]]) {

					CPMagazinePageView * tmp = (CPMagazinePageView *)[_articlePages objectAtIndex:i];

					if (tmp.tag > 0) {
						if (i == _currIndex) {
							if ([tmp respondsToSelector:@selector(setMustRender:)]) {
								[tmp setMustRender:TRUE];
								[tmp setCurrentPage:TRUE];

								[_articlePager setNumberOfPages:[tmp pageSetCount]];
								[_articlePager setCurrentPage:[tmp pageIndexInSet]];
								
							} else if ([[tmp superview] respondsToSelector:@selector(setMustRender:)]) {
								[(CPMagazinePageView *)tmp.superview setMustRender:TRUE];
								[(CPMagazinePageView *)tmp.superview setCurrentPage:TRUE];
							}

							// TRACK THE LAUNCH
							id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
							[tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"uiMagazineView"
																				   action:@"pageviewload"
																					label:[NSString stringWithFormat:@"/app/mag/%@/%@/pageview/%@",[_settings publication],[_settings currentIssue],[tmp xmlID]]
																					value:[NSNumber numberWithInt:1]] set:@"start" forKey:kGAISessionControl] build]];
							
						} else if (i == _prevIndex || i == _nextIndex) {

							if ([tmp respondsToSelector:@selector(setMustRender:)]) {
								[tmp setMustRender:TRUE];
								[tmp setCurrentPage:FALSE];
							} else if ([[tmp superview] respondsToSelector:@selector(setMustRender:)]) {
								[(CPMagazinePageView *)tmp.superview setMustRender:TRUE];
								[(CPMagazinePageView *)tmp.superview setCurrentPage:FALSE];
							} else {
								DLog(@"Did not process view setMustRender");
							}

						} else {
							if ([tmp respondsToSelector:@selector(setMustRender:)]) {
								[tmp setMustRender:FALSE];
								[tmp setCurrentPage:FALSE];
							} else if ([[tmp superview] respondsToSelector:@selector(setMustRender:)]) {
								[(CPMagazinePageView *)tmp.superview setMustRender:FALSE];
								[(CPMagazinePageView *)tmp.superview setCurrentPage:FALSE];
							} else {
								DLog(@"Did not process view setMustRender2");
							}
						}

						if ([tmp respondsToSelector:@selector(setMustRender:)]) {
							if (tmp.mustRender) {
								DLog(@"preRotate processAfterScroll : %@",tmp.xmlID);
							}
							[tmp preRotate:[UIApplication sharedApplication].statusBarOrientation];
							[tmp resetLayout];
						} else if ([[tmp superview] respondsToSelector:@selector(setMustRender:)]) {
							[(CPMagazinePageView *)tmp.superview preRotate:[UIApplication sharedApplication].statusBarOrientation];
							[(CPMagazinePageView *)tmp.superview resetLayout];
						} else {
							DLog(@"Did not process view resetLayout");
						}
					}
					
				} else if ([[_articlePages objectAtIndex:i] isKindOfClass:[CPMagazineWebView class]]) {

					CPMagazineWebView * tmp = (CPMagazineWebView *)[_articlePages objectAtIndex:i];

					if (tmp.tag > 0) {
						if (i == _currIndex) {
							if ([tmp respondsToSelector:@selector(setMustRender:)]) {
								[tmp setMustRender:TRUE];
								[tmp setCurrentPage:TRUE];

								[_articlePager setNumberOfPages:[tmp pageSetCount]];
								[_articlePager setCurrentPage:[tmp pageIndexInSet]];

							} else if ([[tmp superview] respondsToSelector:@selector(setMustRender:)]) {
								[(CPMagazineWebView *)tmp.superview setMustRender:TRUE];
								[(CPMagazineWebView *)tmp.superview setCurrentPage:TRUE];
							}

							// TRACK THE LAUNCH
							id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
							[tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"uiMagazineView"
																				   action:@"webviewload"
																					label:[NSString stringWithFormat:@"/app/mag/%@/%@/pageview/%@",[_settings publication],[_settings currentIssue],[tmp xmlID]]
																					value:[NSNumber numberWithInt:1]] set:@"start" forKey:kGAISessionControl] build]];
							
						} else if (i == _prevIndex || i == _nextIndex) {
							
							if ([tmp respondsToSelector:@selector(setMustRender:)]) {
								[tmp setMustRender:TRUE];
								[tmp setCurrentPage:FALSE];
							} else if ([[tmp superview] respondsToSelector:@selector(setMustRender:)]) {
								[(CPMagazineWebView *)tmp.superview setMustRender:TRUE];
								[(CPMagazineWebView *)tmp.superview setCurrentPage:FALSE];
							} else {
								DLog(@"Did not process view setMustRender");
							}
							
						} else {
							if ([tmp respondsToSelector:@selector(setMustRender:)]) {
								[tmp setMustRender:FALSE];
								[tmp setCurrentPage:FALSE];
							} else if ([[tmp superview] respondsToSelector:@selector(setMustRender:)]) {
								[(CPMagazineWebView *)tmp.superview setMustRender:FALSE];
								[(CPMagazineWebView *)tmp.superview setCurrentPage:FALSE];
							} else {
								DLog(@"Did not process view setMustRender2");
							}
						}
						
						if ([tmp respondsToSelector:@selector(setMustRender:)]) {
							[tmp preRotate:[UIApplication sharedApplication].statusBarOrientation];
							[tmp resetLayout];
						} else if ([[tmp superview] respondsToSelector:@selector(setMustRender:)]) {
							[(CPMagazineWebView *)tmp.superview preRotate:[UIApplication sharedApplication].statusBarOrientation];
							[(CPMagazineWebView *)tmp.superview resetLayout];
						} else {
							DLog(@"Did not process view resetLayout");
						}
					}
					
				}
			}
        }
    }

	[self performSelector:@selector(performContentsOverlayActionClose) withObject:nil afterDelay:0.2];

	[UIView animateWithDuration:0.5f
						  delay:3.0f
						options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
					 animations:^{

						 [_articlePager setAlpha:0];

					 }
					 completion:^(BOOL finished){

					 }];

	_disableRotations = FALSE;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[self processAfterScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	_disableRotations = FALSE;
}

- (void)scrollViewWillEndDecelerating:(UIScrollView *)scrollView {
	_disableRotations = FALSE;
}


- (void)setViewSize {
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
	
	int offset = 0;

	if (application.statusBarHidden == NO)
    {
		//	offset = offset - 20;
    }
	
	if (self.navigationController.navigationBarHidden == NO) {
		offset = offset - 44;
	}

	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		screenWidth = size.height;
		screenHeight = size.width;
    } else {
        screenWidth = size.width;    
		screenHeight = size.height;
    }
	
    screenRect = CGRectMake(0,offset,size.width,size.height);
	
	[_scrollView setFrame:CGRectMake(0 , offset, screenWidth, screenHeight)];
	[_contentsView setFrame:CGRectMake(_contentsView.frame.origin.x , 0, 320, screenHeight)];
	[_contentsBGView setFrame:CGRectMake(0 , 0, screenWidth, screenHeight)];

	if (_webNavView.frame.origin.y == 0) {
		[_webNavView setFrame:CGRectMake(0 , 0, screenWidth, screenHeight)];
	} else {
		[_webNavView setFrame:CGRectMake(0 , (screenHeight*2), screenWidth, screenHeight)];
	}
}

- (void)alignSubviews {
    
	// Position all the content views at their respective page positions
    
    _scrollView.contentSize = CGSizeMake(_pageCount*_scrollView.bounds.size.width , _scrollView.bounds.size.height);

	NSUInteger i = 0;
	float pageTop = 0;
	float pageLeft = 0;
	
	for (CPMagazinePageView *v in _articlePages) {
		
		if([v isKindOfClass:[CPMagazinePageView class]]) {
			
			
			if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
			
				
				if (_scrollView.bounds.size.height != [v lpageHeight] && [v lpageHeight] <= _scrollView.bounds.size.height) {
					pageTop = ((_scrollView.bounds.size.height - [v lpageHeight]) / 2);
				} else {
					pageTop = 0;
				}
				
				if (_scrollView.bounds.size.width != [v lpageWidth] && [v lpageWidth] <= _scrollView.bounds.size.width) {
					pageLeft = ((_scrollView.bounds.size.width - [v lpageWidth]) / 2);
				} else {
					pageLeft = 0;
				}
			
				[v setFrame:CGRectMake(((i * _scrollView.bounds.size.width) + pageLeft), pageTop, [v lpageWidth], [v lpageHeight])];
		
			} else {
			
				if (_scrollView.bounds.size.height != [v ppageHeight] && [v ppageHeight] <= _scrollView.bounds.size.height) {
					pageTop = ((_scrollView.bounds.size.height - [v ppageHeight]) / 2);
				} else {
					pageTop = 0;
				}
				
				if (_scrollView.bounds.size.width != [v ppageWidth] && [v ppageWidth] <= _scrollView.bounds.size.width) {
					pageLeft = ((_scrollView.bounds.size.width - [v ppageWidth]) / 2);
				} else {
					pageLeft = 0;
				}
				
				[v setFrame:CGRectMake(((i * _scrollView.bounds.size.width) + pageLeft), pageTop,[v ppageWidth], [v ppageHeight])];
			
			}
			
		} else {
			
			[v setFrame:CGRectMake((i * _scrollView.bounds.size.width), 0,_scrollView.bounds.size.width, _scrollView.bounds.size.height)];
			
		}
		
		i++;
	}

	[_scrollView setContentOffset:CGPointMake((_currIndex * _scrollView.bounds.size.width), 0)];
}

- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);

    CGContextRef context = UIGraphicsGetCurrentContext();

    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);

            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];

            // Restore the context
            CGContextRestoreGState(context);
        }
    }

    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration {
    
    [_articlePager setAlpha:0];
	
	if ([_docVersion isEqualToString:@"1.0"]) {
		
		if ([[_articlePages objectAtIndex:_currIndex] isKindOfClass:[CPMagazinePageView class]]) {
			
			CPMagazinePageView * tmp = (CPMagazinePageView *)[_articlePages objectAtIndex:_currIndex];
			
			tmp.mustRender = TRUE;
			tmp.currentPage = TRUE;
			
			if (tmp.mustRender) {
				DLog(@"preRotate willRotateToInterfaceOrientation : %@",tmp.xmlID);
			}
			[tmp preRotate:toInterfaceOrientation];
			
		} else if ([[_articlePages objectAtIndex:_currIndex] isKindOfClass:[CPMagazineWebView class]]) {
			
			CPMagazineWebView * tmp = (CPMagazineWebView *)[_articlePages objectAtIndex:_currIndex];
			
			tmp.mustRender = TRUE;
			tmp.currentPage = TRUE;
			
			if (tmp.mustRender) {
				DLog(@"preRotate willRotateToInterfaceOrientation : %@",tmp.xmlID);
			}
			[tmp preRotate:toInterfaceOrientation];
			
		}
    }

}

- (void)processRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	_currIndex = _scrollView.contentOffset.x / _scrollView.bounds.size.width;


	main.transform = CGAffineTransformMakeRotation( 0 );
    [main setFrame:CGRectMake(3, (_scrollView.bounds.size.height - 41), 38, 38)];

	[_ExpNavView setFrame:CGRectMake(0, (_scrollView.frame.size.height - 150), 150, 150)];
	[main setFrame:CGRectMake(0, 110, 38, 38)];

	[navigation collapse];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
										 duration:(NSTimeInterval)duration {
	
	[self setViewSize];
    [self alignSubviews];
	
	if (_webNavView.frame.origin.y == 0) {
		[_webNavView setFrame:CGRectMake(0 , 0, screenWidth, screenHeight)];
	} else {
		[_webNavView setFrame:CGRectMake(0 , (screenHeight*2), screenWidth, screenHeight)];
	}

	[_contentsBGView setFrame:CGRectMake(0 , 0, screenWidth, screenHeight)];
	[_contentsView setFrame:CGRectMake(_contentsView.frame.origin.x , 0, 320, screenHeight)];
	[_contentsView setBounds:CGRectMake(0, 0, _contentsView.frame.size.width, _contentsView.frame.size.height)];

	_scrollView.contentOffset = CGPointMake(_currIndex * _scrollView.bounds.size.width, 0);

	[self processRotateToInterfaceOrientation:interfaceOrientation];

}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    
    //// DLog(@"deviceOrientationDidChange");
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if ([_docVersion isEqualToString:@"1.0"]) {

		for (int i = 0; i < _pageCount; i++) {
			
			if ([[_articlePages objectAtIndex:i] isKindOfClass:[CPMagazinePageView class]]) {
			
				CPMagazinePageView *tmp = (CPMagazinePageView *)[_articlePages objectAtIndex:i];

				if (tmp.tag > 0 && i != _currIndex) {
					if (i == _prevIndex || i == _nextIndex) {
						tmp.mustRender = TRUE;
						tmp.currentPage = FALSE;
					} else {
						tmp.mustRender = FALSE;
						tmp.currentPage = FALSE;
					}
					if (tmp.mustRender) {
						DLog(@"preRotate didRotateFromInterfaceOrientation : %@",tmp.xmlID);
					}
					[tmp preRotate:[UIApplication sharedApplication].statusBarOrientation];
				} else {
					[_articlePager setNumberOfPages:[tmp pageSetCount]];
					[_articlePager setCurrentPage:[tmp pageIndexInSet]];
				}
				[tmp resetLayout];

			} else if ([[_articlePages objectAtIndex:i] isKindOfClass:[CPMagazineWebView class]]) {

				CPMagazineWebView *tmp = (CPMagazineWebView *)[_articlePages objectAtIndex:i];
				
				if (tmp.tag > 0 && i != _currIndex) {
					if (i == _prevIndex || i == _nextIndex) {
						tmp.mustRender = TRUE;
						tmp.currentPage = FALSE;
					} else {
						tmp.mustRender = FALSE;
						tmp.currentPage = FALSE;
					}
					[tmp preRotate:[UIApplication sharedApplication].statusBarOrientation];
				} else {
					[_articlePager setNumberOfPages:[tmp pageSetCount]];
					[_articlePager setCurrentPage:[tmp pageIndexInSet]];
				}
				[tmp resetLayout];
				
			} else {
				DLog(@"Strange Page Class %@",[[_articlePages objectAtIndex:i] class]);
			}
        }

		[UIView animateWithDuration:0.5f
							  delay:0.3f
							options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
						 animations:^{

							 [_articlePager setAlpha:1];

						 }
						 completion:^(BOOL finished){

							 [UIView animateWithDuration:0.5f
												   delay:1.0f
												 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
											  animations:^{

												 // [_articlePager setAlpha:0];
												  [self performContentsOverlayActionClose];

											  }
											  completion:^(BOOL finished){
												  
											  }];
					 
						 }];

	}
}

-(void)handleContentsOverlay:(UITapGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPHandleContentsOverlay" object:self];
    }
}

-(void)handleExpNav:(UITapGestureRecognizer*)recognizer{

	DLog(@"*********** handleExpNav");
	
	if (!navigation.transition && !_navAnimating) {

		[self setNavAnimating:TRUE];

		[UIView animateWithDuration:0.3f
							  delay:0.0f
							options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
						 animations:^{

							 if (!navigation.expanded && _ExpNavView.alpha == 0) {

								 //[navigation expand];
								 [_ExpNavView setAlpha:1];
								 [_ExpNavView setUserInteractionEnabled:TRUE];
								 
								 /*
								 [_buttonSocial setAlpha:1];
								 [_buttonSocial setUserInteractionEnabled:TRUE];
								*/
								 
							 } else {

								 [navigation collapse];
								 [_ExpNavView setAlpha:0];
								 [_ExpNavView setUserInteractionEnabled:FALSE];
								 /*
								 [_buttonSocial setAlpha:0];
								 [_buttonSocial setUserInteractionEnabled:FALSE];
								 */
							 }

						 }
						 completion:^(BOOL finished){

							 if (finished) {
								 [self setNavAnimating:FALSE];
								 //
							 }
							 
						 }];
	}

}

-(void)expNavAnimationCollapseView {

	[_ExpNavView setFrame:CGRectMake(0, (screenHeight - 40), 40, 40)];

}

-(void)expNavAnimationExpandView {

	[_ExpNavView setFrame:CGRectMake(0, (screenHeight - 160), 160, 160)];
	
}

-(void)handleContentsOverlayFromNotification:(id)sender{
	if (_contentsView.frame.origin.x != 0) {
		[self performContentsOverlayActionOpen];
	} else {
		[self performContentsOverlayActionClose];
	}
}

-(void)performContentsOverlayActionOpen {

	//[self setViewSize];
	
	[UIView animateWithDuration:0.3f
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
					 animations:^{
						 
						 [_contentsView setAlpha:1];
						 [_contentsView setFrame:CGRectMake(0, 0, _contentsView.frame.size.width, _contentsView.frame.size.height)];
						 [_contentsBGView setAlpha:0.5f];

						 [_contentsView.layer setShadowColor:[UIColor blackColor].CGColor];
						 [_contentsView.layer setShadowOpacity:0.5f];
						 [_contentsView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
						 [_contentsView.layer setShadowRadius:3.0];

					 }
					 completion:^(BOOL finished){
						 
						 if (finished) {

						 }

					 }];

}

-(void)performContentsOverlayActionClose {
	
	//[_contentsView setAlpha:1];
	//[self setViewSize];
	if (navigation.expanded) {
		DLog(@"*********** handleExpNav - expanded");
		[self handleExpNav:nil];
	}
	
	[UIView animateWithDuration:0.3f
						  delay:0.0f
						options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
					 animations:^{
						 
						 [_contentsView setFrame:CGRectMake(-120, 0, _contentsView.frame.size.width, _contentsView.frame.size.height)];
						 [_contentsBGView setAlpha:0];
						 [_contentsView setAlpha:0];

						 [_contentsView.layer setShadowOpacity:0.0f];
						 [_contentsView.layer setShadowOffset:CGSizeMake(0, 0)];
						 [_contentsView.layer setShadowRadius:0];
						 
					 }
					 completion:^(BOOL finished){
//						 
//						 if (finished) {
//							 [_contentsView setAlpha:0];
//						 }

					 }];
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    for (int i = 0; i < _pageCount; i++) {
        
        if ([_docVersion isEqualToString:@"1.0"]) {

			if ([[_articlePages objectAtIndex:i] isKindOfClass:[CPMagazinePageView class]]) {

				CPMagazinePageView * tmp = (CPMagazinePageView *)[_articlePages objectAtIndex:i];
        
				if (tmp.tag > 0 && i != _currIndex) {
					tmp.mustRender = FALSE;
					tmp.currentPage = FALSE;
					[tmp resetLayout];
				}

			} else if ([[_articlePages objectAtIndex:i] isKindOfClass:[CPMagazineWebView class]]) {

				CPMagazineWebView * tmp = (CPMagazineWebView *)[_articlePages objectAtIndex:i];
				
				if (tmp.tag > 0 && i != _currIndex) {
					tmp.mustRender = FALSE;
					tmp.currentPage = FALSE;
					[tmp resetLayout];
				}
				
			}
        }
    }
}

- (void)viewDidUnload {
    
    //// DLog(@"%s","did unload");
    
	[self setExpNavView:nil];
	[self setArticlePager:nil];
    [self setButtonSocial:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (_disableRotations) {
		return NO;
	} else {
		return _settings.shouldAllowRotate;
	}
}


- (BOOL) shouldAutorotate
{
    if (_disableRotations) {
		return NO;
	} else {
		return _settings.shouldAllowRotate;
	}
}

-(NSUInteger)supportedInterfaceOrientations
{
    return _settings.supportedOrientation;
}

-(void) viewDidAppear:(BOOL)animated {

	[self willResume];
	[super viewDidAppear:animated];
    
}

-(void) viewWillDisappear:(BOOL)animated {

	if (!_settings.isFullScreen) {

		if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
			// back button was pressed.  We know this is true because self is no longer
			// in the navigation stack.
		}

		if ([_docVersion isEqualToString:@"1.0"]) {

			if ([[_articlePages objectAtIndex:_currIndex] isKindOfClass:[CPMagazinePageView class]]) {

				CPMagazinePageView * tmp = (CPMagazinePageView *)[_articlePages objectAtIndex:_currIndex];

				[tmp setCurrentPage:FALSE];
				[tmp setMustRender:FALSE];

				[tmp resetLayout];

			} else if ([[_articlePages objectAtIndex:_currIndex] isKindOfClass:[CPMagazineWebView class]]) {

				// NOTHING TO DO HERE... YET...

			}
		}

		[super viewWillDisappear:animated];

	}
}

-(void)setNavAnimating:(BOOL)navAnimating {
	_navAnimating = navAnimating;
}

-(void) viewWillAppear:(BOOL)animated {
	
	if (![_settings.device isEqualToString:@"iPhone"]) {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
	}

	[_scrollView setAlpha:1.0];
	[super viewWillAppear:animated];
	
}

@end
