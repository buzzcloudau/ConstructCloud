//
//  CPMapPin.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SMXMLDocument.h"

@interface CPMapPin : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
	NSString *leftImage;
	NSString *rightImage;
}

@property (nonatomic) id pageView;
@property (nonatomic) NSString *contentPath;

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic) NSString *actionOnTap;
@property (nonatomic) NSString *actionID;
@property (nonatomic) NSString *actionURL;
@property (nonatomic) NSString *leftImage;
@property (nonatomic) NSString *rightImage;
@property (nonatomic) int actionIndex;
@property (nonatomic) NSMutableArray *actions;
@property (nonatomic) NSMutableArray *actionsLeft;
@property (nonatomic) NSMutableArray *actionsRight;
@property (nonatomic) UIButtonType leftButton;
@property (nonatomic) UIButtonType rightButton;

@property (nonatomic) BOOL canShowCallout;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description pageView:(id)pageView contentPath:(NSString *)contentPath;
- (void) setTouchActions:(SMXMLElement *)actions;

- (NSString *)leftImage;
- (NSString *)rightImage;
- (UIButtonType)leftButton;
- (UIButtonType)rightButton;

- (void) pinTap;
- (void) rightTap;
- (void) leftTap;

@end