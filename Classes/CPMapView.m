//
//  CPMapView.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPMapView.h"
#import "CPMapPin.h"
#import <QuartzCore/QuartzCore.h>
#import "defs.h"

@implementation CPMapView

@synthesize hasPortrait = _hasPortrait;
@synthesize hasLandscape = _hasLandscape;
@synthesize landscapeIsPortrait = _landscapeIsPortrait;
@synthesize xmlID = _xmlID;
@synthesize xmlPacket = _xmlPacket;
@synthesize mapView = _mapView;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize mustRender = _mustRender;
@synthesize locationArray = _locationArray;

@synthesize positionLeft = _positionLeft;
@synthesize positionTop = _positionTop;
@synthesize positionWidth = _positionWidth;
@synthesize positionHeight = _positionHeight;
@synthesize positionContentWidth = _positionContentWidth;
@synthesize positionContentHeight = _positionContentHeight;
@synthesize positionVisible = _positionVisible;
@synthesize positionVisibleAnimate = _positionVisibleAnimate;

@synthesize controlPanSize = _controlPanSize;
@synthesize controlPaging = _controlPaging;
@synthesize controlBounce = _controlBounce;
@synthesize controlAutoPlay = _controlAutoPlay;
@synthesize controlAutoLoop = _controlAutoLoop;
@synthesize controlDisableTouch = _controlDisableTouch;
@synthesize controlTransition = _controlTransition;
@synthesize controlMinZoom = _controlMinZoom;
@synthesize controlMaxZoom = _controlMaxZoom;
@synthesize controlInitZoom = _controlInitZoom;

@synthesize borderRadius = _borderRadius;
@synthesize borderWidth = _borderWidth;
@synthesize borderColor = _borderColor;
@synthesize borderImage = _borderImage;

@synthesize shadowColorSet = _shadowColor;
@synthesize shadowOffsetXSet = _shadowOffsetX;
@synthesize shadowOffsetYSet = _shadowOffsetY;
@synthesize shadowOpacitySet = _shadowOpacity;
@synthesize shadowRadiusSet = _shadowRadius;

@synthesize actions = _actions;
@synthesize actionOnTap = _actionOnTap;
@synthesize actionID = _actionID;
@synthesize actionURL = _actionURL;
@synthesize actionIndex = _actionIndex;

@synthesize animationDelay = _animationDelay;
@synthesize animationDuration = _animationDuration;

@synthesize pageView = _pageView;

-(id)initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath pageView:(id)pageView {

	self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
	
	_xmlPacket = xmlData;
	_contentPath = contentPath;
	_actions = [[NSMutableArray alloc] init];
	_pageView = pageView;
	
	if (self) {
		
		[self setDelegate:self];
		
		_hasPortrait	= [_xmlPacket childNamed:@"psrc"] || [_xmlPacket childNamed:@"src"] ? TRUE : FALSE;
		_hasLandscape	= [_xmlPacket childNamed:@"lsrc"] || [_xmlPacket childNamed:@"src"] ? TRUE : FALSE;
		_xmlID			= [_xmlPacket attributeNamed:@"id"];
		
		[self resetLayout:[UIApplication sharedApplication].statusBarOrientation];
		
		[self.layer setZPosition:[[_xmlPacket attributeNamed:@"zindex"] floatValue]];
		
		[self performAnimations];
		
	}
	
	// LOCATIONS
	
	SMXMLElement *tmpLocations	= [_xmlPacket childNamed:@"locations"];
	_locationArray = [[NSMutableArray alloc] initWithCapacity:[tmpLocations childrenNamed:@"location"].count];

	for (SMXMLElement *location in [tmpLocations childrenNamed:@"location"]) {

		float latitude = [[location valueWithPath:@"latitude"] floatValue];
		float longitude = [[location valueWithPath:@"longitude"] floatValue];
		NSString *locationTitle = [location valueWithPath:@"title"];
		NSString *locationDescription = [location valueWithPath:@"description"];
			
		CLLocationCoordinate2D locationCoords = CLLocationCoordinate2DMake(latitude,longitude);
			
		CPMapPin *pin = [[CPMapPin alloc] initWithCoordinates:locationCoords placeName:locationTitle description:locationDescription pageView:_pageView contentPath:_contentPath];
		
		if ([location childNamed:@"actions"]) {
			[pin setTouchActions:[location childNamed:@"actions"]];
		}
		
		if ([location valueWithPath:@"leftimage"] != nil) {
			[pin setLeftImage:[location valueWithPath:@"leftimage"]];
		} else if ([location valueWithPath:@"leftbutton"] != nil) {
			[pin setLeftButton:[self typeForString:[location valueWithPath:@"leftbutton"]]];
		}
		
		if ([location valueWithPath:@"rightimage"] != nil) {
			[pin setRightImage:[location valueWithPath:@"rightimage"]];
		} else if ([location valueWithPath:@"rightbutton"] != nil) {
			[pin setRightButton:[self typeForString:[location valueWithPath:@"rightbutton"]]];
		}
		
		[self addAnnotation:pin];

	}
	
	return self;
}

-(UIButtonType)typeForString:(NSString *)buttonType {
	
	if ([buttonType isEqualToString:@"detail"]) {
		return UIButtonTypeDetailDisclosure;
	} else if ([buttonType isEqualToString:@"add"]) {
		return UIButtonTypeContactAdd;
	} else if ([buttonType isEqualToString:@"infodark"]) {
		return UIButtonTypeInfoDark;
	} else if ([buttonType isEqualToString:@"infolight"]) {
		return UIButtonTypeInfoLight;
	}
	
	return 0;
	
}

-(void)performAnimations {
	
	// WE DONT REALLY WANT TO ANIMATE SIZE OR POSITION.. YET..
	
	[self setFrame:CGRectMake(_positionLeft, _positionTop, _positionWidth, _positionHeight)];
	
	// PERFORM ANIMATIONS
	
	if (!_positionVisible || (_positionVisible && _positionVisibleAnimate)) {
		[self setAlpha:0.0];
	} else if (_positionVisible) {
		[self setAlpha:1.0];
	}
	
	if (_positionVisible && _positionVisibleAnimate) {
		[UIView animateWithDuration:(NSTimeInterval)_animationDuration
							  delay:(NSTimeInterval)(_animationDelay < 1 ? 1 : _animationDelay)
							options:UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 if (_positionVisible) {
								 [self setAlpha:1.0];
							 }
						 }
						 completion:^(BOOL finished) {
						 }];
	}
}

-(void)setCurrentPage:(id)currentPage {

}

-(void)resetLayout:(UIInterfaceOrientation)toInterfaceOrientation {
	
	SMXMLElement *defSrc = [_xmlPacket childNamed:@"src"];
	SMXMLElement *defCon = [defSrc childNamed:@"control"];
	SMXMLElement *defPos = [defSrc childNamed:@"position"];
	SMXMLElement *defBdr = [defSrc childNamed:@"border"];
	SMXMLElement *defShd = [defSrc childNamed:@"shadow"];
	SMXMLElement *defLoc = [defSrc childNamed:@"location"];
	SMXMLElement *defAct = [defSrc childNamed:@"actions"];
	SMXMLElement *defAni = [defSrc childNamed:@"animation"];
	SMXMLElement *altSrc = nil;
	
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		altSrc = [_xmlPacket childNamed:@"lsrc"];
	} else {
		altSrc = [_xmlPacket childNamed:@"psrc"];
	}
	
	// Do we have a src??
	// If not, clean up.
	
	if (!defSrc && !altSrc) {
		
		[self setAlpha:0.0];
		
		return;
	
	}
	
	// DEFAULT MAP LOCATION
	
	SMXMLElement *altLoc = [altSrc childNamed:@"location"];
	
	_longitude			= [[altLoc valueWithPath:@"longitude"] floatValue];
	_latitude			= [[altLoc valueWithPath:@"latitude"] floatValue];
	
	if (!_latitude) {
		_latitude		= [[defLoc valueWithPath:@"latitude"] floatValue];
	}
	
	if (!_longitude) {
		_longitude		= [[defLoc valueWithPath:@"longitude"] floatValue];
	}
	
	// CONTROL
	
	SMXMLElement *altCon = [altSrc childNamed:@"control"];
	
	_controlPanSize			 = [[altCon valueWithPath:@"pansize"] intValue];
	_controlAutoLoop		 = [[altCon valueWithPath:@"autoloop"] boolValue];
	_controlAutoPlay		 = [[altCon valueWithPath:@"autoplay"] boolValue];
	_controlBounce			 = [[altCon valueWithPath:@"bounce"] boolValue];
	_controlPaging			 = [[altCon valueWithPath:@"paging"] boolValue];
	_controlDisableTouch	 = [[altCon valueWithPath:@"disabletouch"] boolValue];
	_controlTransition		 = [altCon valueWithPath:@"transition"];
	_controlMinZoom			 = [[altCon valueWithPath:@"minzoom"] floatValue];
	_controlMaxZoom			 = [[altCon valueWithPath:@"maxzoom"] floatValue];
	_controlInitZoom		 = [[altCon valueWithPath:@"zoom"] floatValue];
	
	if (!_controlPanSize) {
		_controlPanSize   = [[defCon valueWithPath:@"pansize"] intValue];
	}
	
	if (!_controlPanSize) {
		_controlPanSize   = 1;
	}
	
	if (!_controlMinZoom) {
		_controlMinZoom   = [[defCon valueWithPath:@"minzoom"] floatValue];
	}
	
	if (!_controlMinZoom) {
		_controlMinZoom   = 1;
	}
	
	if (!_controlMaxZoom) {
		_controlMaxZoom   = [[defCon valueWithPath:@"zoom"] floatValue];
	}
	
	if (!_controlMaxZoom) {
		_controlMaxZoom   = 1;
	}
	
	if (!_controlInitZoom) {
		_controlInitZoom   = [[defCon valueWithPath:@"maxzoom"] floatValue];
	}
	
	if (!_controlInitZoom) {
		_controlInitZoom   = 1;
	}
	
	if (!_controlAutoLoop) {
		_controlAutoLoop  = [[defCon valueWithPath:@"autoloop"] boolValue];
	}
	
	if (!_controlAutoLoop) {
		_controlAutoLoop  = FALSE;
	}
	
	if (!_controlAutoPlay) {
		_controlAutoPlay  = [[defCon valueWithPath:@"autoplay"] boolValue];
	}
	
	if (!_controlAutoPlay) {
		_controlAutoPlay  = FALSE;
	}
	
	if (!_controlBounce) {
		_controlBounce  = [[defCon valueWithPath:@"bounce"] boolValue];
	}
	
	if (!_controlBounce) {
		_controlBounce  = FALSE;
	}
	
	if (!_controlPaging) {
		_controlPaging  = [[defCon valueWithPath:@"paging"] boolValue];
	}
	
	if (!_controlPaging) {
		_controlPaging  = FALSE;
	}
	
	if (!_controlDisableTouch) {
		_controlDisableTouch  = [[defCon valueWithPath:@"disabletouch"] boolValue];
	}
	
	if (!_controlDisableTouch) {
		_controlDisableTouch  = FALSE;
	}
	
	if (!_controlTransition) {
		_controlTransition  = [defCon valueWithPath:@"transition"];
	}
	
	// POSITION
	
	SMXMLElement *altPos = [altSrc childNamed:@"position"];
	
	_positionWidth			 = [[altPos valueWithPath:@"width"] intValue];
	_positionHeight			 = [[altPos valueWithPath:@"height"] intValue];
	_positionContentWidth	 = [[altPos valueWithPath:@"contentWidth"] intValue];
	_positionContentHeight	 = [[altPos valueWithPath:@"contentHeight"] intValue];
	_positionLeft			 = [[altPos valueWithPath:@"left"] intValue];
	_positionTop			 = [[altPos valueWithPath:@"top"] intValue];
	_positionVisible		 = [[altPos valueWithPath:@"visible"] boolValue];
	_positionVisibleAnimate  = [[[altPos childNamed:@"visible"] attributeNamed:@"animate"] boolValue];
	
	if (!_positionWidth) {
		_positionWidth    = [[defPos valueWithPath:@"width"] intValue];
	}
	
	if (!_positionHeight) {
		_positionHeight   = [[defPos valueWithPath:@"height"] intValue];
	}
	
	if (!_positionContentWidth) {
		_positionContentWidth    = [[defPos valueWithPath:@"contentWidth"] intValue];
	}
	
	if (!_positionContentWidth) {
		_positionContentWidth    = 0;
	}
	
	if (!_positionContentHeight) {
		_positionContentHeight   = [[defPos valueWithPath:@"contentHeight"] intValue];
	}
	
	if (!_positionContentHeight) {
		_positionContentHeight   = 0;
	}
	
	if (!_positionLeft) {
		_positionLeft     = [[defPos valueWithPath:@"left"] intValue];
	}
	
	if (!_positionTop) {
		_positionTop      = [[defPos valueWithPath:@"top"] intValue];
	}
	
	if (!_positionVisible) {
		_positionVisible  = [[defPos valueWithPath:@"visible"] boolValue];
	}
	
	if (!_positionVisibleAnimate) {
		_positionVisibleAnimate  = [[[defPos childNamed:@"visible"] attributeNamed:@"animate"] boolValue];
	}
	
	// BORDER
	
	SMXMLElement *altBdr = [altSrc childNamed:@"border"];
	
	_borderRadius		= [[altBdr valueWithPath:@"radius"] floatValue];
	_borderWidth		= [[altBdr valueWithPath:@"width"] floatValue];
	_borderImage		= [altBdr valueWithPath:@"image"];
	
	if (!_borderRadius) {
		_borderRadius	= [[defBdr valueWithPath:@"radius"] floatValue];
	}
	
	if (!_borderWidth) {
		_borderWidth	= [[defBdr valueWithPath:@"width"] floatValue];
	}
	
	if (!_borderImage) {
		_borderImage	= [defBdr valueWithPath:@"image"];
	}
		
	// BORDER COLOR
		
	NSString *tmpBorderColor	= [altBdr valueWithPath:@"color"];
	
	if (!tmpBorderColor) {
		tmpBorderColor	= [defBdr valueWithPath:@"color"];
	}
	
	SEL borderColorSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",tmpBorderColor]);
	_borderColor = [UIColor clearColor];
	
	if ([UIColor respondsToSelector:borderColorSelector]) {
		_borderColor = [UIColor performSelector:borderColorSelector];
	}
		
	// SHADOW
		
	SMXMLElement *altShd = [altSrc childNamed:@"shadow"];
	
	_shadowRadius		= [[altShd valueWithPath:@"radius"] floatValue];
	_shadowOffsetX		= [[altShd valueWithPath:@"offsetx"] floatValue];
	_shadowOffsetY		= [[altShd valueWithPath:@"offsety"] floatValue];
	_shadowOpacity		= [[altShd valueWithPath:@"opacity"] floatValue];
	
	if (!_shadowRadius) {
		_shadowRadius	= [[defShd valueWithPath:@"radius"] floatValue];
	}
	
	if (!_shadowOffsetX) {
		_shadowOffsetX	= [[defShd valueWithPath:@"offsetx"] floatValue];
	}
	
	if (!_shadowOffsetY) {
		_shadowOffsetY	= [[defShd valueWithPath:@"offsety"] floatValue];
	}
	
	if (!_shadowOpacity) {
		_shadowOpacity	= [[defShd valueWithPath:@"opacity"] floatValue];
	}
		
	// SHADOW COLOR
		
	NSString *tmpShadowColor	= [altShd valueWithPath:@"color"];
	
	if (!tmpShadowColor) {
		tmpShadowColor	= [defShd valueWithPath:@"color"];
	}
	
	SEL shadowColorSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",tmpShadowColor]);
	_shadowColor = [UIColor clearColor];
	
	if ([UIColor respondsToSelector:shadowColorSelector]) {
		_shadowColor = [UIColor performSelector:shadowColorSelector];
	}
	
	[self.layer setBorderWidth:_borderWidth];
	[self.layer setCornerRadius:_borderRadius];
	[self.layer setBorderColor:_borderColor.CGColor];
	
	if (![_borderImage isEqualToString:@""]) {
		[self.layer setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:_borderImage]] CGColor]];
	}
	
	if (_shadowOpacity) {
		[self.layer setShadowColor:_shadowColor.CGColor];
		[self.layer setShadowOffset:CGSizeMake(_shadowOffsetX, _shadowOffsetY)];
		[self.layer setShadowOpacity:_shadowOpacity];
		[self.layer setShadowRadius:_shadowRadius];
		[self.layer setMasksToBounds:FALSE];
	}
		
	
	// ACTIONS
	
	SMXMLElement *altAct = [altSrc childNamed:@"actions"];
	SMXMLElement *tmpAct = nil;
	
	if (altAct != nil) {
		tmpAct = altAct;
	} else if (defAct != nil) {
		tmpAct = defAct;
	}
	
	if (tmpAct != nil) {
		
		[_actions removeAllObjects];
		
		for (SMXMLElement *act in [tmpAct childrenNamed:@"ontap"]) {
			
			[_actions addObject:act];
			
		}
		
	}
	
	
	// ANIMATIONS
	
	SMXMLElement *altAni = [altSrc childNamed:@"animation"];
	
	_animationDelay		= [[altAni valueWithPath:@"delay"] floatValue];
	_animationDuration	= [[altAni valueWithPath:@"duration"] floatValue];
	
	if (!_animationDelay) {
		_animationDelay = [[defAni valueWithPath:@"delay"] floatValue];
	}
	
	if (!_animationDelay) { // still no delay ??
		_animationDelay = 0;
	}
	
	if (!_animationDuration) {
		_animationDuration = [[defAni valueWithPath:@"duration"] floatValue];
	}
	
	if (!_animationDuration) { // still no duration ??
		_animationDuration = 0;
	}
	
	// RUN SETUP
	
	[self setFrame:CGRectMake(_positionLeft, _positionTop, _positionWidth, _positionHeight)];
	[self setClipsToBounds:TRUE];
	
	if (_controlDisableTouch) {
		
		[self setUserInteractionEnabled:FALSE];
		
	} else {
		
		[self setUserInteractionEnabled:TRUE];
		
	}
	
	if (_longitude != 0 && _latitude != 0) {
		[self setMapLocation:_latitude longitude:_longitude];
	}
	
//	[self setMaximumZoomScale:_controlMaxZoom];
//	[self setMinimumZoomScale:_controlMinZoom];
//	[self setZoomScale:_controlInitZoom];
	
}

- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation {
	
	SMXMLElement *defSrc = [_xmlPacket childNamed:@"src"];
	SMXMLElement *altSrc = nil;
	
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		altSrc = [_xmlPacket childNamed:@"lsrc"];
	} else {
		altSrc = [_xmlPacket childNamed:@"psrc"];
	}
	
	NSString *reqSysVer = @"6.0";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	
	if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending || (!defSrc && !altSrc)) {
		
		[self setAlpha:0.0];
		
	}
	
}

- (void)setMapLocation:(float)latitude longitude:(float)longitude {
	
	[self setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(latitude,longitude), MKCoordinateSpanMake(0.2, 0.2)) animated:YES];
	[self regionThatFits:MKCoordinateRegionMake(CLLocationCoordinate2DMake(latitude,longitude), MKCoordinateSpanMake(0.2, 0.2))];

}

-(void)setMustRender:(BOOL)mustRender {
	_mustRender = mustRender;
}

-(void)setHasBackgroundImage:(BOOL)hasBackgroundImage {
	// _hasBackgroundImage = hasBackgroundImage;
}

-(BOOL)mustRender {
	return _mustRender;
}

- (float)longitude {
	return _longitude;
}

- (float)latitude {
	return _latitude;
}

- (void)removeFromSuperview {
	[super removeFromSuperview];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *annotationIdentifier = @"annotationIdentifier";
	
	MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
	
	if (pinView == nil)
	{
		MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
		
		CPMapPin *pinAnnotation = (CPMapPin *) annotation;
		
		// customPinView.pinColor = MKPinAnnotationColorPurple;
		customPinView.animatesDrop = YES;
		
		if ([pinAnnotation canShowCallout]) {
			customPinView.canShowCallout = YES;
		} else {
			customPinView.canShowCallout = NO;
		}
		
		if ([pinAnnotation leftImage] != nil) {
			UIImageView *lefImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",_contentPath,pinAnnotation.leftImage]]];
			customPinView.leftCalloutAccessoryView = lefImageView;
		} else if ([pinAnnotation leftButton] > 0) {
			UIButton* leftButton = [UIButton buttonWithType:[pinAnnotation leftButton]];
			customPinView.leftCalloutAccessoryView = leftButton;
		}
		
		if ([pinAnnotation rightImage] != nil) {
			UIImageView *righImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",_contentPath,pinAnnotation.rightImage]]];
			customPinView.rightCalloutAccessoryView = righImageView;
		} else if ([pinAnnotation rightButton] > 0) {
			UIButton* rightButton = [UIButton buttonWithType:[pinAnnotation rightButton]];
			customPinView.rightCalloutAccessoryView = rightButton;
		}
		
		return customPinView;
	}
	else
	{
		pinView.annotation = annotation;
	}
	return pinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	DLog(@"mapView Clicked");
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	
	[(CPMapPin *)view.annotation pinTap];
	
}

- (void)showDetails:(id)sender {
	DLog(@"ShowDetails");
}


@end
