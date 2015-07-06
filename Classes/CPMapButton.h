//
//  CPMapButton.h
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
#import "CPMapView.h"

@interface CPMapButton : UIView

- (id) initWithXML:(SMXMLElement *)xmlData buttonSetup:(SMXMLElement *)buttonSetup position:(int)position parentWidth:(int)parentWidth mapView:(CPMapView *)mapView contentPath:(NSString *)contentPath;
- (float) longitude;
- (float) latitude;

@property (nonatomic) SMXMLElement *xmlPacket;
@property (nonatomic) float longitude;
@property (nonatomic) float latitude;
@property (nonatomic) float zoomLevel;
@property (nonatomic) MKMapView *mapView;

@end
