//
//  CPLayerView.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import "SMXMLDocument.h"
#import "CPMagazinePageView.h"
#import "CPMovieController.h"
#import "CPPostmaster.h"
#import "AppDelegate.h"

@interface CPLayerView : UIScrollView <UIScrollViewDelegate>

- (id)initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath pageView:(id)pageView;
- (void)setAlpha:(CGFloat)alpha;
- (void)setCurrentPage:(id)currentPage;
- (void)resetLayout:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)removeFromSuperview;
- (void)handleSingleTap:(UITapGestureRecognizer*)recognizer;
- (id)getObjectByID:(NSString *)objID;
- (void)setScrollPage:(int)pageNum;
- (void)stopTimer;
- (void)setpanimage;

@property (nonatomic) id pageView;

@property (nonatomic) BOOL isAnimating;

@property (nonatomic) BOOL hasLandscape;
@property (nonatomic) BOOL hasPortrait;
@property (nonatomic) BOOL mustRender;
@property (nonatomic) NSString *xmlID;
@property (nonatomic) SMXMLElement *xmlPacket;
@property (nonatomic) UIInterfaceOrientation preStatusBarOrientation;
@property (nonatomic) NSString *contentPath;

@property (nonatomic) NSMutableArray *actions;
@property (nonatomic) NSString *actionOnTap;
@property (nonatomic) NSString *actionID;
@property (nonatomic) NSString *actionURL;
@property (nonatomic) int actionIndex;

@property (nonatomic) NSMutableArray *images;
@property (nonatomic) NSMutableArray *imagesViews;

@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) BOOL reanimateOnRotate;
@property (nonatomic) float positionLeft;
@property (nonatomic) float positionTop;
@property (nonatomic) float positionWidth;
@property (nonatomic) float positionHeight;
@property (nonatomic) float positionContentLeft;
@property (nonatomic) float positionContentTop;
@property (nonatomic) float positionContentWidth;
@property (nonatomic) float positionContentHeight;
@property (nonatomic) float positionOpacity;
@property (nonatomic) BOOL positionVisible;
@property (nonatomic) BOOL positionVisibleAnimate;

@property (nonatomic) float controlPanSize;
@property (nonatomic) BOOL controlPaging;
@property (nonatomic) BOOL controlBounce;
@property (nonatomic) BOOL controlAutoPlay;
@property (nonatomic) BOOL controlAutoLoop;
@property (nonatomic) BOOL controlDisableTouch;
@property (nonatomic) BOOL controlDisableScrollIndicators;
@property (nonatomic) NSString *controlTransition;
@property (nonatomic) NSTimer *controlTimer;
@property (nonatomic) float controlMinZoom;
@property (nonatomic) float controlMaxZoom;
@property (nonatomic) float controlInitZoom;

@property (nonatomic) float borderRadius;
@property (nonatomic) float borderWidth;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) NSString *borderImage;
@property (nonatomic) bool borderImageAbsolute;

@property (nonatomic) NSTimeInterval animationDelay;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) float animationOpacity;
@property (nonatomic) float animationTop;
@property (nonatomic) float animationLeft;
@property (nonatomic) float animationWidth;
@property (nonatomic) float animationHeight;
@property (nonatomic) BOOL animationAutoRepeat;
@property (nonatomic) BOOL animationAutoReverse;
@property (nonatomic) BOOL animationAutoPlay;

@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) float backgroundOpacity;
@property (nonatomic) NSString *backgroundImage;
@property (nonatomic) NSString *backgroundPosition; //tile, centre, stretch

@property (nonatomic) UIColor *shadowColor;
@property (nonatomic) float shadowOffsetX;
@property (nonatomic) float shadowOffsetY;
@property (nonatomic) float shadowRadius;
@property (nonatomic) float shadowOpacity;

@property (nonatomic) int scrollPage;
@property (nonatomic) float scrollPosX;
@property (nonatomic) float scrollPosY;

@property (nonatomic) BOOL naturalFlow;

@property (nonatomic) AppDelegate *appDelegate;
@property (nonatomic) CPPostmaster *postmaster;
@property (nonatomic) NSCache *contentCache;

@end
