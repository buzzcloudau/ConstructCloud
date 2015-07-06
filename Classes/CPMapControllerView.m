//
//  CPMapControllerView.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPMapControllerView.h"
#import "CPMapPin.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CPMapButton.h"
#import "defs.h"

@implementation CPMapControllerView

@synthesize hasPortrait = _hasPortrait;
@synthesize hasLandscape = _hasLandscape;
@synthesize landscapeIsPortrait = _landscapeIsPortrait;
@synthesize xmlID = _xmlID;
@synthesize xmlPacket = _xmlPacket;
@synthesize mapView = _mapView;
@synthesize mustRender = _mustRender;
@synthesize scrollContentView = _scrollContentView;


- (id) initWithXML:(SMXMLElement *)xmlData mapView:(CPMapView *)mapView contentPath:(NSString *)contentPath {

	_xmlPacket = xmlData;
	_mapView = mapView;

	NSInteger tmpWidth		= 0;
	NSInteger tmpHeight		= 0;
	NSInteger tmpLeft		= 0;
	NSInteger tmpTop		= 0;
	NSString *tmpID			= [_xmlPacket attributeNamed:@"id"];

	NSString *bgColor		= @"";
	// NSString *bgImage		= @"";
	NSString *borderColor	= @"";
	NSString *borderImage	= @"";
	
	float borderRadius		= 0;
	float borderWidth		= 0;
	
	// LOCATIONS

	SMXMLElement *tmpLocations	= [_xmlPacket childNamed:@"locations"];
	//NSObject *tmpObj = [[NSObject alloc] init];
	
	// SETUP

	SMXMLElement *tmpSrcL		= [_xmlPacket childNamed:@"lsrc"];
	SMXMLElement *tmpSrcP		= [_xmlPacket childNamed:@"psrc"];

	SMXMLElement *buttonSetup;
	
	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		
		SMXMLElement *tmpPosL	= [tmpSrcL childNamed:@"position"];
		
		tmpWidth    = [[tmpPosL valueWithPath:@"width"] intValue];
		tmpHeight   = [[tmpPosL valueWithPath:@"height"] intValue];
		tmpLeft     = [[tmpPosL valueWithPath:@"left"] intValue];
		tmpTop      = [[tmpPosL valueWithPath:@"top"] intValue];

		SMXMLElement *tmpBorder	= [tmpSrcL childNamed:@"border"];
		
		borderRadius	= [[tmpBorder valueWithPath:@"radius"] floatValue];
		borderWidth		= [[tmpBorder valueWithPath:@"width"] floatValue];
		borderImage		= [tmpBorder valueWithPath:@"image"];
		borderColor		= [[tmpBorder valueWithPath:@"color"] stringByAppendingString:@"Color"];

		buttonSetup		= [tmpSrcL childNamed:@"buttons"];
		bgColor			= [[tmpSrcL childNamed:@"background"] valueWithPath:@"color"];
		// bgImage			= [[tmpSrcL childNamed:@"background"] valueWithPath:@"image"];

	} else {
		
		SMXMLElement *tmpPosP	= [tmpSrcP childNamed:@"position"];

		tmpWidth    = [[tmpPosP valueWithPath:@"width"] intValue];
		tmpHeight   = [[tmpPosP valueWithPath:@"height"] intValue];
		tmpLeft     = [[tmpPosP valueWithPath:@"left"] intValue];
		tmpTop      = [[tmpPosP valueWithPath:@"top"] intValue];

		SMXMLElement *tmpBorder	= [tmpSrcP childNamed:@"border"];
		
		borderRadius	= [[tmpBorder valueWithPath:@"radius"] floatValue];
		borderWidth		= [[tmpBorder valueWithPath:@"width"] floatValue];
		borderImage		= [tmpBorder valueWithPath:@"image"];
		borderColor		= [[tmpBorder valueWithPath:@"color"] stringByAppendingString:@"Color"];

		buttonSetup		= [tmpSrcP childNamed:@"buttons"];
		bgColor			= [[tmpSrcP childNamed:@"background"] valueWithPath:@"color"];
		// bgImage			= [[tmpSrcP childNamed:@"background"] valueWithPath:@"image"];
		
	}

	int cols = (tmpWidth / [[[buttonSetup childNamed:@"position"] valueWithPath:@"width"] intValue]);
	int btns = [tmpLocations childrenNamed:@"location"].count;
	int contentHeight = ceil(btns / cols) * [[[buttonSetup childNamed:@"position"] valueWithPath:@"height"] intValue];
	
	CGRect controllerFrame = CGRectMake(tmpLeft, tmpTop, tmpWidth, tmpHeight);
	CGRect contentFrame = CGRectMake(0, 0, tmpWidth, contentHeight);
	
	self = [super initWithFrame:controllerFrame];

	if (self) {

		[self setDelegate:self];
		[self setExclusiveTouch:TRUE];
		
		self.xmlID = tmpID;
		self.hasLandscape = TRUE; //![[tmpSrcL valueWithPath:@"file"] isEqualToString:@""] || ![[tmpSrc valueWithPath:@"file"] isEqualToString:@""] ? TRUE : FALSE;
		self.hasPortrait = TRUE; //![[tmpSrcP valueWithPath:@"file"] isEqualToString:@""] || ![[tmpSrc valueWithPath:@"file"] isEqualToString:@""] ? TRUE : FALSE;
		self.landscapeIsPortrait = FALSE; //[[tmpSrcL valueWithPath:@"file"] isEqualToString:[tmpSrcP valueWithPath:@"file"]] ? TRUE : FALSE;
		
		/*
		 [mapView.layer setShadowColor:[UIColor blackColor].CGColor];
		 [mapView.layer setShadowOpacity:0.8];
		 [mapView.layer setShadowRadius:3.0];
		 [mapView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
		 */
		
		self.contentSize = CGSizeMake(contentFrame.size.width,contentFrame.size.height);
		
		_scrollContentView = [[UIView alloc] initWithFrame:contentFrame];

		SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",bgColor]);

		UIColor *tmpBackgroundColor = [UIColor clearColor];
		if ([UIColor respondsToSelector:selector]) {
			tmpBackgroundColor = [UIColor performSelector:selector];
		}

		[_scrollContentView setBackgroundColor:tmpBackgroundColor];

		int btnCount = 0;

		for (SMXMLElement *location in [tmpLocations childrenNamed:@"location"]) {
			
			CPMapButton *btn = [[CPMapButton alloc] initWithXML:location buttonSetup:buttonSetup position:btnCount parentWidth:tmpWidth mapView:(CPMapView *)_mapView contentPath:contentPath];
			[_scrollContentView addSubview:btn];

			btnCount++;
		}
		
		[self addSubview:_scrollContentView];
		
		if (borderRadius != 0) {
			[self.layer setCornerRadius:borderRadius];
		}
		
		if (borderWidth != 0) {
			[self.layer setBorderWidth:borderWidth];
		}
		
		if (![borderColor isEqualToString:@""]) {
			
			SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",borderColor]);
			UIColor *tmpMapBorderColor = [UIColor clearColor];
			if ([UIColor respondsToSelector:selector]) {
				tmpMapBorderColor = [UIColor performSelector:selector];
			}
			
			[self.layer setBorderColor:tmpMapBorderColor.CGColor];
		}
		
		if (![borderImage isEqualToString:@""]) {
			[self.layer setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:borderImage]] CGColor]];
		}
		
		[self flashScrollIndicators];

	}

	return self;
}

-(void)setHasBackgroundImage:(BOOL)hasBackgroundImage {
	// This is being called from CPMapView for some reason
	// _hasBackgroundImage = hasBackgroundImage;
}

-(void)setCurrentPage:(id)currentPage {

}

-(void)resetLayout {
    // WE SHOULD BE RECREATING THESE
	// NOTHING TO RESET
	DLog(@"Incorrectly resetting CPMapControllerView : %d",self.tag);
}

- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation {
	
}

-(void)setMustRender:(BOOL)mustRender {
    _mustRender = mustRender;
}

-(BOOL)mustRender {
	return _mustRender;
}

- (void)removeFromSuperview {
	[super removeFromSuperview];
}

@end
