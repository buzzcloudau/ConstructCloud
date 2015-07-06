//
//  CPMapControllerView.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import "CPMapView.h"
#import "SMXMLDocument.h"

@interface CPMapControllerView : UIScrollView <UIScrollViewDelegate>

- (id) initWithXML:(SMXMLElement *)xmlData mapView:(CPMapView *)mapView contentPath:(NSString *)contentPath;
- (void) setMustRender:(BOOL)mustRender;
- (void) setCurrentPage:(id)currentPage;
- (void) resetLayout;
- (void) preRotate:(UIInterfaceOrientation)toInterfaceOrientation;
- (void) removeFromSuperview;

@property (nonatomic) BOOL hasLandscape;
@property (nonatomic) BOOL hasPortrait;
@property (nonatomic) BOOL landscapeIsPortrait;
@property (nonatomic) BOOL mustRender;
@property (nonatomic) NSString *xmlID;
@property (nonatomic) SMXMLElement *xmlPacket;
@property (nonatomic) MKMapView *mapView;
@property (nonatomic) UIView *scrollContentView;

@end
