//
//  CPWebView.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPWebView.h"
#import <QuartzCore/QuartzCore.h>
#import "ViewControllerForMagazine.h"
#import "defs.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation CPWebView

@synthesize isAnimating = _isAnimating;

@synthesize pageView = _pageView;

@synthesize hasPortrait = _hasPortrait;
@synthesize hasLandscape = _hasLandscape;
@synthesize xmlID = _xmlID;
@synthesize xmlPacket = _xmlPacket;

@synthesize positionLeft = _positionLeft;
@synthesize positionTop = _positionTop;
@synthesize positionWidth = _positionWidth;
@synthesize positionHeight = _positionHeight;
@synthesize positionVisible = _positionVisible;
@synthesize positionVisibleAnimate = _positionVisibleAnimate;

@synthesize controlBounce = _controlBounce;
@synthesize controlAutoPlay = _controlAutoPlay;
@synthesize controlDisableTouch = _controlDisableTouch;
@synthesize controlSrc = _controlSrc;
@synthesize controlSrcLoaded = _controlSrcLoaded;

@synthesize borderRadius = _borderRadius;
@synthesize borderWidth = _borderWidth;
@synthesize borderColor = _borderColor;
@synthesize borderImage = _borderImage;

@synthesize actionOnTap = _actionOnTap;
@synthesize actionID = _actionID;
@synthesize actionURL = _actionURL;
@synthesize actionIndex = _actionIndex;

@synthesize animationDelay = _animationDelay;
@synthesize animationDuration = _animationDuration;

@synthesize mustRender = _mustRender;
@synthesize contentPath = _contentPath;

@synthesize backgroundColorSet = _backgroundColor;
@synthesize backgroundOpacity = _backgroundOpacity;
@synthesize backgroundPosition = _backgroundPosition;
@synthesize backgroundImage = _backgroundImage;

@synthesize shadowColorSet = _shadowColor;
@synthesize shadowOffsetXSet = _shadowOffsetX;
@synthesize shadowOffsetYSet = _shadowOffsetY;
@synthesize shadowOpacitySet = _shadowOpacity;
@synthesize shadowRadiusSet = _shadowRadius;

@synthesize preStatusBarOrientation = _preStatusBarOrientation;

@synthesize panGesture = _panGesture;

@synthesize reanimateOnRotate = _reanimateOnRotate;

@synthesize actions = _actions;
@synthesize settings = _settings;

-(id)initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath pageView:(id)pageView {
	
	self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
	
	[self setDelegate:self];
	
	_pageView = pageView;
	_contentPath = contentPath;
	_xmlPacket = xmlData;
	_actions = [[NSMutableArray alloc] init];
	_reanimateOnRotate = FALSE;
	_isAnimating = FALSE;
	_controlTimer = nil;
	_controlSrcLoaded = @"";
	
	_settings = [CPSettingsData getInstance];
	
	[self setAlpha:0.0];

	if (self) {

		[[NSNotificationCenter defaultCenter] removeObserver:self];

		_hasPortrait	= [_xmlPacket childNamed:@"psrc"] || [_xmlPacket childNamed:@"src"] ? TRUE : FALSE;
		_hasLandscape	= [_xmlPacket childNamed:@"lsrc"] || [_xmlPacket childNamed:@"src"] ? TRUE : FALSE;
		_xmlID			= [_xmlPacket attributeNamed:@"id"];

		[self resetLayout:[UIApplication sharedApplication].statusBarOrientation];

		[self.layer setZPosition:[[_xmlPacket attributeNamed:@"zindex"] floatValue]];

		[self performAnimations];
	}

	return self;
}

- (void)viewDidLoad {

}

-(void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
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

-(void)setCurrentPage:(id)currentPage {
    
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

-(void)resetLayout:(UIInterfaceOrientation)toInterfaceOrientation {

	[self stopTimer];

    SMXMLElement *defSrc = [_xmlPacket childNamed:@"src"];
	SMXMLElement *defCon = [defSrc childNamed:@"control"];
	SMXMLElement *defPos = [defSrc childNamed:@"position"];
	SMXMLElement *defBdr = [defSrc childNamed:@"border"];
	SMXMLElement *defBck = [defSrc childNamed:@"background"];
	SMXMLElement *defAct = [defSrc childNamed:@"actions"];
	SMXMLElement *defAni = [defSrc childNamed:@"animation"];
	SMXMLElement *defShd = [defSrc childNamed:@"shadow"];
	
	SMXMLElement *altSrc = nil;
	
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		altSrc = [_xmlPacket childNamed:@"lsrc"];
	} else {
		altSrc = [_xmlPacket childNamed:@"psrc"];
	}

// Do we have a src??
// If not, clean up.

	if (!defSrc && !altSrc) {

		[_actions removeAllObjects];

		[self setAlpha:0.0];

		[self setReanimateOnRotate:TRUE];

		return;
	}

// CONTROL

	SMXMLElement *altCon = [altSrc childNamed:@"control"];
	
	_controlBounce			= [[altCon valueWithPath:@"bounce"] boolValue];
	_controlDisableTouch	= [[altCon valueWithPath:@"disabletouch"] boolValue];
	_controlAutoPlay		= [[altCon valueWithPath:@"autoplay"] boolValue];
	_controlSrc				= [altCon valueWithPath:@"url"];
	
	if (!_controlBounce) {
		_controlBounce  = [[defCon valueWithPath:@"bounce"] boolValue];
	}
	
	if (!_controlBounce) {
		_controlBounce  = FALSE;
	}
	
	if (!_controlAutoPlay) {
		_controlAutoPlay  = [[defCon valueWithPath:@"autoplay"] boolValue];
	}
	
	if (!_controlAutoPlay) {
		_controlAutoPlay  = FALSE;
	}
	
	if (!_controlDisableTouch) {
		_controlDisableTouch  = [[defCon valueWithPath:@"disabletouch"] boolValue];
	}

	if (!_controlDisableTouch) {
		_controlDisableTouch  = FALSE;
	}
	
	if (!_controlSrc) {
		_controlSrc  = [defCon valueWithPath:@"url"];
	}
	
	if (!_controlSrc) {
		_controlSrc  = @"";
	}

// POSITION
	
	SMXMLElement *altPos = [altSrc childNamed:@"position"];
	
	_positionWidth			 = [[altPos valueWithPath:@"width"] intValue];
	_positionHeight			 = [[altPos valueWithPath:@"height"] intValue];
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

// BACKGROUND

	SMXMLElement *altBck = [altSrc childNamed:@"background"];

	_backgroundOpacity	= [[altBck valueWithPath:@"opacity"] floatValue];
	_backgroundImage	= [altBck valueWithPath:@"image"];
	_backgroundPosition	= [altBck valueWithPath:@"position"];
	
	if (!_backgroundOpacity) {
		_backgroundOpacity	= [[defBck valueWithPath:@"opacity"] floatValue];
	}

	if (!_backgroundOpacity) { // still no opacity ?
		_backgroundOpacity = 1.0;
	}

	if (!_backgroundImage) {
		_backgroundImage	= [defBck valueWithPath:@"image"];
	}

	if (!_backgroundPosition) {
		_backgroundPosition	= [defBck valueWithPath:@"position"];
	}

// BACKGROUND COLOR

	NSString *tmpBackgroundColor	= [altBck valueWithPath:@"color"];

	if (!tmpBackgroundColor) {
		tmpBackgroundColor	= [defBck valueWithPath:@"color"];
	}

	if (!tmpBackgroundColor) { // still no color ?
		tmpBackgroundColor	= @"clear";
	}

	if ([tmpBackgroundColor isEqualToString:@"clear"]) { // iOS is setting clear with zero opacity to black. WTF!?!
		_backgroundOpacity = 0;
	}

	SEL backgroundColorSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",tmpBackgroundColor]);
	_backgroundColor = [UIColor clearColor];

	if ([UIColor respondsToSelector:backgroundColorSelector]) {
		_backgroundColor = [UIColor performSelector:backgroundColorSelector];
	}

	_backgroundColor = [_backgroundColor colorWithAlphaComponent:_backgroundOpacity];

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

// RUN SETUP

	for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
		if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
			recognizer.enabled = NO;
			[self removeGestureRecognizer:recognizer];
		}
	}

	if ([_actions count] > 0) {
		// Add the touch actions
		UITapGestureRecognizer *sngTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
		sngTap.numberOfTouchesRequired = 1;
		sngTap.numberOfTapsRequired = 1;

		[self addGestureRecognizer:sngTap];
	}

	[self setFrame:CGRectMake(_positionLeft, _positionTop, _positionWidth, _positionHeight)];
	[self setClipsToBounds:TRUE];
	[self.scrollView setBounces:_controlBounce];
	
	if (_controlDisableTouch) {

		[self setUserInteractionEnabled:FALSE];

	} else {

		[self setUserInteractionEnabled:TRUE];

	}

	[self.layer setBackgroundColor:_backgroundColor.CGColor];
	
	[self.layer setBorderWidth:_borderWidth];
	[self.layer setCornerRadius:_borderRadius];
	[self.layer setBorderColor:_borderColor.CGColor];

	if (_backgroundImage) {
		UIImage *bgImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",_contentPath,_backgroundImage]];
		[self setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
	}
	
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

	if (_reanimateOnRotate) {
		[self performAnimations];
		[self setReanimateOnRotate:FALSE];
	}

	if (_controlAutoPlay) {

		_controlTimer = nil;
		_controlTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(_animationDelay + _animationDuration + 0.01)
														 target:self
													   //selector:@selector(progressimage:)
														selector:nil
													   userInfo:nil
														repeats:YES];
	} else {

		[self stopTimer];

	}
	
	if (![_controlSrc isEqualToString:_controlSrcLoaded]) {
		
		[self gotoURL:_controlSrc];
		
	}

}

-(void) setReanimateOnRotate:(BOOL)reanimateOnRotate {
	_reanimateOnRotate = reanimateOnRotate;
}

-(void)handleSingleTap:(UITapGestureRecognizer*)recognizer {

	// Noting here yet.
	
}

-(void)gotoURL:(NSString *)url
{
    
	[self setControlSrc:url];
	
	if ([_settings internetActive]) {
		
		// TRACK THE LAUNCH
		id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
		[tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"uiWebLayer"
															   action:@"urlload"
																label:[NSString stringWithFormat:@"/app/mag/%@/%@/url/%@",[_settings publication],[_settings currentIssue],url]
																value:[NSNumber numberWithInt:1]] set:@"start" forKey:kGAISessionControl] build]];
	}
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	
	[self loadRequest:request];
	
}

- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation {

	[self stopTimer];

	_controlAutoPlay = FALSE;
	[self resetLayout:toInterfaceOrientation];
}

- (void)stopTimer {
	if (_controlTimer != nil) {
		[_controlTimer invalidate];
	}
}

- (id)getObjectByID:(NSString *)objID {
	return [(CPMagazinePageView *)_pageView getObjectByID:objID];
}

@end
