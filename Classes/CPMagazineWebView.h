//
//  CPWebView.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import "SMXMLDocument.h"

@interface CPMagazineWebView : UIView <UIWebViewDelegate , UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *viewTapGestureRecogniser;


//- (id)initWithFrame:(CGRect)frame backgroundImage:(NSString *)backgroundImage;
- (id)initWithFrame:(CGRect)frame 
   mustRenderOnLoad:(BOOL)mustRenderOnLoad
		contentPath:(NSString *)contentPath;

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)resetLayout;
- (void)clearLayout;
- (void)initBG;
- (void)setRenderedView;
- (void)setPageFromElement:(SMXMLElement *)xmlPage;
- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)setIsLoaded:(BOOL)isLoaded;
- (void)setMustRender:(BOOL)mustRender;
- (void)setCurrentPage:(BOOL)currentPage;

- (IBAction)tGRecogniser:(id)sender;

@property (nonatomic) CGRect internalFrame;
@property (nonatomic) NSInteger tagCount;
@property (nonatomic) BOOL mustRender;
@property (nonatomic) BOOL currentPage;
@property (nonatomic) BOOL hasBackgroundImage;
@property (nonatomic) BOOL isLoaded;

@property (nonatomic) NSArray *lLoader;
@property (nonatomic) NSArray *pLoader;

@property (nonatomic) SMXMLElement* page;
@property (nonatomic) NSString *contentPath;

@property (nonatomic) BOOL followingLink;

@property (nonatomic) NSString *xmlID;

@property (nonatomic) int pageSetCount;
@property (nonatomic) int pageIndexInSet;

@end
