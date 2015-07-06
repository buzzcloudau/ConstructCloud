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
#import "CPMagazinePageView.h"
#import "CPSettingsData.h"

@interface CPWebView : UIWebView <UIWebViewDelegate>

- (id)initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath pageView:(id)pageView;
- (void)setAlpha:(CGFloat)alpha;
- (void)setMustRender:(BOOL)mustRender;
- (void)setCurrentPage:(id)currentPage;
- (void)resetLayout:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)removeFromSuperview;
- (void)handleSingleTap:(UITapGestureRecognizer*)recognizer;
- (id)getObjectByID:(NSString *)objID;
- (void)stopTimer;
- (void)gotoURL:(NSString *)url;

@property (nonatomic) id pageView;

@property (nonatomic) BOOL isAnimating;

@property (nonatomic) BOOL hasLandscape;
@property (nonatomic) BOOL hasPortrait;
@property (nonatomic) BOOL mustRender;
@property (nonatomic) NSString *xmlID;
@property (nonatomic) SMXMLElement *xmlPacket;

@property (nonatomic) float positionLeft;
@property (nonatomic) float positionTop;
@property (nonatomic) float positionWidth;
@property (nonatomic) float positionHeight;
@property (nonatomic) BOOL positionVisible;
@property (nonatomic) BOOL positionVisibleAnimate;

@property (nonatomic) BOOL controlBounce;
@property (nonatomic) BOOL controlAutoPlay;
@property (nonatomic) BOOL controlDisableTouch;
@property (nonatomic) NSTimer *controlTimer;
@property (nonatomic) NSString *controlSrc;
@property (nonatomic) NSString *controlSrcLoaded;

@property (nonatomic) float borderRadius;
@property (nonatomic) float borderWidth;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) NSString *borderImage;
@property (nonatomic) NSString *contentPath;

@property (nonatomic) NSString *actionOnTap;
@property (nonatomic) NSString *actionID;
@property (nonatomic) NSString *actionURL;
@property (nonatomic) int actionIndex;

@property (nonatomic) NSTimeInterval animationDelay;
@property (nonatomic) NSTimeInterval animationDuration;

@property (nonatomic) UIColor *backgroundColorSet;
@property (nonatomic) float backgroundOpacity;
@property (nonatomic) NSString *backgroundImage;
@property (nonatomic) NSString *backgroundPosition; //tile, centre, stretch

@property (nonatomic) UIColor *shadowColorSet;
@property (nonatomic) float shadowOffsetXSet;
@property (nonatomic) float shadowOffsetYSet;
@property (nonatomic) float shadowRadiusSet;
@property (nonatomic) float shadowOpacitySet;
@property (nonatomic) UIInterfaceOrientation preStatusBarOrientation;

@property (nonatomic) BOOL reanimateOnRotate;

@property (nonatomic) UIPanGestureRecognizer *panGesture;

@property (nonatomic) NSMutableArray *actions;

@property (nonatomic) CPSettingsData *settings;

@end
