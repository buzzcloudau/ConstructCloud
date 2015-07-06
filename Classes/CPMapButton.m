//
//  CPMapButton.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPMapButton.h"

@implementation CPMapButton

@synthesize xmlPacket = _xmlPacket;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize zoomLevel = _zoomLevel;
@synthesize mapView = _mapView;

- (id)initWithXML:(SMXMLElement *)xmlData buttonSetup:(SMXMLElement *)buttonSetup position:(int)position parentWidth:(int)parentWidth mapView:(CPMapView *)mapView contentPath:(NSString *)contentPath
{

	_xmlPacket = xmlData;
	_mapView = mapView;

	SMXMLElement *xmlTitle = [buttonSetup childNamed:@"title"];
	SMXMLElement *xmlDescription = [buttonSetup childNamed:@"description"];
	SMXMLElement *xmlBackground = [buttonSetup childNamed:@"background"];
	SMXMLElement *xmlPosition = [buttonSetup childNamed:@"position"];
	SMXMLElement *xmlImage = [buttonSetup childNamed:@"image"];

	SEL selector;
	UIColor *tmpColor;
	UILabel *txtLabel;
	NSString *textAlignment;

	float posLeft		= 0;
	float posTop		= 0;
	float btnWidth		= [[xmlPosition valueWithPath:@"width"] floatValue];
	float btnHeight		= [[xmlPosition valueWithPath:@"height"] floatValue];


	int cols			= (parentWidth / btnWidth);
	
	posLeft = ceil(position % cols) * btnWidth;
	posTop	= (position / cols) * btnHeight;

	CGRect frame = CGRectMake(posLeft, posTop, btnWidth, btnHeight);

	self = [super initWithFrame:frame];
    if (self) {

		_latitude	= [[_xmlPacket valueWithPath:@"latitude"] floatValue];
		_longitude	= [[_xmlPacket valueWithPath:@"longitude"] floatValue];
		_zoomLevel	= [[_xmlPacket valueWithPath:@"zoom"] floatValue];

		UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processTap:)];
		[self addGestureRecognizer:tgr];

		if (xmlImage != nil) {

			UIImageView *tmpImgView = [[UIImageView alloc] initWithFrame:CGRectMake([[xmlImage valueWithPath:@"left"] floatValue]
																					, [[xmlImage valueWithPath:@"top"] floatValue]
																					, [[xmlImage valueWithPath:@"width"] floatValue]
																					, [[xmlImage valueWithPath:@"height"] floatValue])];

			UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",contentPath,[xmlData valueWithPath:@"image"]]];

			[tmpImgView setImage:tmpImg];

			[self addSubview:tmpImgView];

		}

		if (xmlTitle != nil) {

			selector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",[xmlTitle valueWithPath:@"color"]]);

			tmpColor = [UIColor blackColor];
			if ([UIColor respondsToSelector:selector]) {
				tmpColor = [UIColor performSelector:selector];
			}

			txtLabel = [[UILabel alloc] initWithFrame:CGRectMake([[xmlTitle valueWithPath:@"left"] floatValue]
																 , [[xmlTitle valueWithPath:@"top"] floatValue]
																 , [[xmlTitle valueWithPath:@"width"] floatValue]
																 , [[xmlTitle valueWithPath:@"height"] floatValue])];

			[txtLabel setText:[_xmlPacket valueWithPath:@"title"]];
			[txtLabel setBackgroundColor:[UIColor clearColor]];
			[txtLabel setTextColor:tmpColor];

			textAlignment = [xmlTitle valueWithPath:@"alignment"];
			
			if ([textAlignment isEqualToString:@"center"]) {
				[txtLabel setTextAlignment:NSTextAlignmentCenter];
			} else if ([textAlignment isEqualToString:@"right"]) {
				[txtLabel setTextAlignment:NSTextAlignmentRight];
			} else {
				[txtLabel setTextAlignment:NSTextAlignmentLeft];
			}
			
			[self addSubview:txtLabel];

		}

		if (xmlDescription != nil) {

			// selector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",[xmlDescription valueWithPath:@"color"]]);
			
			txtLabel = [[UILabel alloc] initWithFrame:CGRectMake([[xmlDescription valueWithPath:@"left"] floatValue]
																 , [[xmlDescription valueWithPath:@"top"] floatValue]
																 , [[xmlDescription valueWithPath:@"width"] floatValue]
																 , [[xmlDescription valueWithPath:@"height"] floatValue])];
			
			[txtLabel setText:[_xmlPacket valueWithPath:@"description"]];
			[txtLabel setBackgroundColor:[UIColor clearColor]];
			[txtLabel setTextColor:tmpColor];

			textAlignment = [xmlDescription valueWithPath:@"alignment"];
			
			if ([textAlignment isEqualToString:@"center"]) {
				[txtLabel setTextAlignment:NSTextAlignmentCenter];
			} else if ([textAlignment isEqualToString:@"right"]) {
				[txtLabel setTextAlignment:NSTextAlignmentRight];
			} else {
				[txtLabel setTextAlignment:NSTextAlignmentLeft];
			}

			[self addSubview:txtLabel];

		}
		
		selector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",[xmlBackground valueWithPath:@"color"]]);
		
		tmpColor = [UIColor clearColor];
		if ([UIColor respondsToSelector:selector]) {
			tmpColor = [UIColor performSelector:selector];
		}
		
		[self setBackgroundColor:tmpColor];

    }
    return self;
}


- (void)processTap:(UITapGestureRecognizer *)sender
{
	[_mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(_latitude,_longitude), MKCoordinateSpanMake(_zoomLevel, _zoomLevel)) animated:YES];
	[_mapView regionThatFits:MKCoordinateRegionMake(CLLocationCoordinate2DMake(_latitude,_longitude), MKCoordinateSpanMake(_zoomLevel, _zoomLevel))];
}

- (float)longitude {
	return _longitude;
}

- (float)latitude {
	return _latitude;
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
