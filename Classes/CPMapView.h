//
//  CPMapView.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <MapKit/MapKit.h>
#import "SMXMLDocument.h"

@interface CPMapView : MKMapView <MKMapViewDelegate>

- (id) initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath pageView:(id)pageView;
- (void) setMustRender:(BOOL)mustRender;
- (void) setCurrentPage:(id)currentPage;
- (void) resetLayout:(UIInterfaceOrientation)toInterfaceOrientation;
- (void) preRotate:(UIInterfaceOrientation)toInterfaceOrientation;
- (void) setMapLocation:(float)latitude longitude:(float)longitude;
- (float) longitude;
- (float) latitude;
- (void) removeFromSuperview;
- (void) setHasBackgroundImage:(BOOL)hasBackgroundImage;

@property (nonatomic) id pageView;

@property (nonatomic) BOOL hasLandscape;
@property (nonatomic) BOOL hasPortrait;
@property (nonatomic) BOOL landscapeIsPortrait;
@property (nonatomic) BOOL mustRender;
@property (nonatomic) NSString *xmlID;
@property (nonatomic) SMXMLElement *xmlPacket;

@property (nonatomic) MKMapView *mapView;
@property (nonatomic) float longitude;
@property (nonatomic) float latitude;

@property (nonatomic) NSMutableArray *locationArray;

@property (nonatomic) float controlPanSize;
@property (nonatomic) BOOL controlPaging;
@property (nonatomic) BOOL controlBounce;
@property (nonatomic) BOOL controlAutoPlay;
@property (nonatomic) BOOL controlAutoLoop;
@property (nonatomic) BOOL controlDisableTouch;
@property (nonatomic) NSString *controlTransition;
@property (nonatomic) NSTimer *controlTimer;
@property (nonatomic) float controlMinZoom;
@property (nonatomic) float controlMaxZoom;
@property (nonatomic) float controlInitZoom;

@property (nonatomic) float positionLeft;
@property (nonatomic) float positionTop;
@property (nonatomic) float positionWidth;
@property (nonatomic) float positionHeight;
@property (nonatomic) float positionContentWidth;
@property (nonatomic) float positionContentHeight;
@property (nonatomic) BOOL positionVisible;
@property (nonatomic) BOOL positionVisibleAnimate;

@property (nonatomic) float borderRadius;
@property (nonatomic) float borderWidth;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) NSString *borderImage;
@property (nonatomic) NSString *contentPath;

@property (nonatomic) UIColor *shadowColorSet;
@property (nonatomic) float shadowOffsetXSet;
@property (nonatomic) float shadowOffsetYSet;
@property (nonatomic) float shadowRadiusSet;
@property (nonatomic) float shadowOpacitySet;

@property (nonatomic) NSMutableArray *actions;
@property (nonatomic) NSString *actionOnTap;
@property (nonatomic) NSString *actionID;
@property (nonatomic) NSString *actionURL;
@property (nonatomic) int actionIndex;

@property (nonatomic) NSTimeInterval animationDelay;
@property (nonatomic) NSTimeInterval animationDuration;

@end
