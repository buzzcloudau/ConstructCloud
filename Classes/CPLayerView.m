//
//  CPLayerView.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPLayerView.h"
#import <QuartzCore/QuartzCore.h>
#import "ViewControllerForMagazine.h"
#import "defs.h"
#import "CPWebView.h"

@implementation CPLayerView

-(id)initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath pageView:(id)pageView {
	
	self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
	
	_pageView = pageView;
	_contentPath = contentPath;
	_xmlPacket = xmlData;
	_scrollPage = 0;
	_actions = [[NSMutableArray alloc] init];
	_images = [[NSMutableArray alloc] init];
	_imagesViews = [[NSMutableArray alloc] init];
	_scrollPosX = 0;
	_scrollPosY = 0;
	_scrollPage = 0;
	_panGesture = nil;
	_reanimateOnRotate = FALSE;
	_isAnimating = FALSE;
	_controlTimer = nil;
	_naturalFlow = YES;
	
	_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	_postmaster = [[CPPostmaster alloc] init];
	_contentCache = [_appDelegate contentCache];
	
	[self setDelegate:self];

	[self setAlpha:0.0];
	
	[self setAutoresizesSubviews:YES];

	if (self) {

		[[NSNotificationCenter defaultCenter] removeObserver:self];

		_hasPortrait	= [_xmlPacket childNamed:@"psrc"] || [_xmlPacket childNamed:@"src"] ? TRUE : FALSE;
		_hasLandscape	= [_xmlPacket childNamed:@"lsrc"] || [_xmlPacket childNamed:@"src"] ? TRUE : FALSE;
		_xmlID			= [_xmlPacket attributeNamed:@"id"];

		[self resetLayout:[UIApplication sharedApplication].statusBarOrientation];

		[self.layer setZPosition:[[_xmlPacket attributeNamed:@"zindex"] floatValue]];
		
		if (_animationAutoPlay) {
			[self performAnimations];
		}
	}
	
	return self;
}

- (void)progressimage:(id)sender {

	if (!_isAnimating) {

		_scrollPage++;

		if (!_controlAutoLoop && _scrollPage >= ([_images count] - 1)) {

			[self stopTimer];

		} else {

			if (_scrollPage >= [_images count]) {
				_scrollPage = 0;
			}
			
			[self setpanimage];
			
		}

	}
}

- (void)panimages:(UIPanGestureRecognizer *)recognizer {

	if (UIGestureRecognizerStateBegan == recognizer.state) {
		_scrollPosX = 0;
	}

	if (([_panGesture translationInView:self].x - _controlPanSize) > _scrollPosX) {

		_scrollPosX = [_panGesture translationInView:self].x + _controlPanSize;

		if (!_controlAutoLoop && _scrollPage == 0) {

			return;

		} else {

			if (_scrollPage <= 0) {
				_scrollPage = [_images count];
			}

			_scrollPage--;
			[self setpanimage];

		}


	} else if (([_panGesture translationInView:self].x + _controlPanSize) < _scrollPosX) {

		_scrollPosX = [_panGesture translationInView:self].x - _controlPanSize;

		_scrollPage++;

		if (!_controlAutoLoop && _scrollPage >= ([_images count] - 1)) {

			_scrollPage--;
			return;

		} else {

			if (_scrollPage >= [_images count]) {
				_scrollPage = 0;
			}

			[self setpanimage];
			
		}

	}
}

-(void)setpanimage {

	if (!_isAnimating && [_imagesViews count] > 0) {

		UIImageView *prevImgView = [_imagesViews objectAtIndex:0];
	
		SMXMLElement *img = (SMXMLElement *)[_images objectAtIndex:_scrollPage];
		BOOL isAbsolute = [[img attributeNamed:@"absolute"] boolValue];
		
		if (!isAbsolute) {
			
			UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",_contentPath,[img value]]];
			
			UIImageView *tmpImgView = [[UIImageView alloc] initWithImage:tmpImg];
			[tmpImgView setFrame:CGRectMake(0
											, 0
											, [[img attributeNamed:@"width"] intValue] ? [[img attributeNamed:@"width"] intValue] : _positionWidth
											, [[img attributeNamed:@"height"] intValue] ? [[img attributeNamed:@"height"] intValue] : _positionHeight
											)];
			
			if ([_controlTransition isEqualToString:@"fade"] || [_controlTransition isEqualToString:@"crossfade"]) {
				
				_isAnimating = TRUE;
				
				[tmpImgView setAlpha:0];
				[self addSubview:tmpImgView];
				[_imagesViews addObject:tmpImgView];
				
				[UIView animateWithDuration:_animationDuration
									  delay:_animationDelay
									options:UIViewAnimationOptionBeginFromCurrentState
								 animations:^{
									 
									 if ([_controlTransition isEqualToString:@"crossfade"]) {
										 [prevImgView setAlpha:0];
									 }
									 
									 [tmpImgView setAlpha:1.0];
									 
								 }
								 completion:^(BOOL finished) {
									 
									 
									 [prevImgView removeFromSuperview];
									 [_imagesViews removeObject:prevImgView];
									 
									 _isAnimating = FALSE;
									 
								 }];
				
			} else {
				
				[self addSubview:tmpImgView];
				[_imagesViews addObject:tmpImgView];
				
				[prevImgView removeFromSuperview];
				[_imagesViews removeObject:prevImgView];
				
			}
			
		} else {
			
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
			
			dispatch_async(queue, ^{
				
				NSData *imageData = [_postmaster getAndReceive:[NSURL URLWithString:[img value]] packageData:nil cachable:YES];
				
				UIImage *bgImage = [UIImage imageWithData:imageData];
				
				dispatch_sync(dispatch_get_main_queue(), ^{
					
					UIImageView *tmpImgView = [[UIImageView alloc] initWithImage:bgImage];
					
					[tmpImgView setFrame:CGRectMake(0
													, 0
													, [[img attributeNamed:@"width"] intValue] ? [[img attributeNamed:@"width"] intValue] : _positionWidth
													, [[img attributeNamed:@"height"] intValue] ? [[img attributeNamed:@"height"] intValue] : _positionHeight
													)];
					
					if ([_controlTransition isEqualToString:@"fade"] || [_controlTransition isEqualToString:@"crossfade"]) {
						
						_isAnimating = TRUE;
						
						[tmpImgView setAlpha:0];
						[self addSubview:tmpImgView];
						[_imagesViews addObject:tmpImgView];
						
						[UIView animateWithDuration:_animationDuration
											  delay:_animationDelay
											options:UIViewAnimationOptionBeginFromCurrentState
										 animations:^{
											 
											 if ([_controlTransition isEqualToString:@"crossfade"]) {
												 [prevImgView setAlpha:0];
											 }
											 
											 [tmpImgView setAlpha:1.0];
											 
										 }
										 completion:^(BOOL finished) {
											 
											 
											 [prevImgView removeFromSuperview];
											 [_imagesViews removeObject:prevImgView];
											 
											 _isAnimating = FALSE;
											 
										 }];
						
					} else {
						
						[self addSubview:tmpImgView];
						[_imagesViews addObject:tmpImgView];
						
						[prevImgView removeFromSuperview];
						[_imagesViews removeObject:prevImgView];
						
					}
					
				});
				
			});
			
		}
	}
}

- (void)viewDidLoad {

}

- (void) scrollViewWillBeginDragging:(UIScrollView *)sender {

}

- (void)scrollViewDidScroll:(UIScrollView *)sender {

}

-(void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
}

/*
-(void)setMustRender:(BOOL)mustRender {
    _mustRender = mustRender;
}

-(BOOL)mustRender {
	return _mustRender;
}
*/

- (void)removeFromSuperview {
	[super removeFromSuperview];
}

-(void)setCurrentPage:(id)currentPage {
    
}

-(void)performAnimations {
	
	if (_animationDuration > 0.0) {
		[UIView animateWithDuration:(NSTimeInterval)_animationDuration
							  delay:(NSTimeInterval)(_animationDelay < 1 ? 1 : _animationDelay)
							options:UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 
							 if (!_animationAutoReverse || (_animationAutoReverse && _naturalFlow)) {
								 
								 [self setAlpha:_animationOpacity];
								 [self setFrame:CGRectMake(_animationLeft, _animationTop, _animationWidth, _animationHeight)];
							 
								 if (_positionWidth != _animationWidth || _positionHeight !=_animationHeight ) {
									 for (UIImageView *iv in _imagesViews) {
										 [iv setFrame:CGRectMake(0, 0, _animationWidth, _animationHeight)];
									 }
								 }
							 
							 } else {
								 
								 [self setAlpha:_positionOpacity];
								 [self setFrame:CGRectMake(_positionLeft, _positionTop, _positionWidth, _positionHeight)];
								 
								 if (_positionWidth != _animationWidth || _positionHeight !=_animationHeight ) {
									 for (UIImageView *iv in _imagesViews) {
										 [iv setFrame:CGRectMake(0, 0, _positionWidth, _positionHeight)];
									 }
								 }
								 
							 }
							 
						 }
						 completion:^(BOOL finished) {
							 
							 if (_animationAutoReverse) {
								 _naturalFlow = !_naturalFlow;
							 }
							 
							 if (_animationAutoRepeat || (_animationAutoReverse && _naturalFlow)) {
								 dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^(void) {
									 [self performAnimations];
								 });
							 }
							 
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
	SMXMLElement *defImg = [defSrc childNamed:@"images"];
	
	SMXMLElement *altSrc = nil;
	
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		altSrc = [_xmlPacket childNamed:@"lsrc"];
	} else {
		altSrc = [_xmlPacket childNamed:@"psrc"];
	}

// Do we have a src??
// If not, clean up.

	if (!defSrc && !altSrc) {
		
		for (UIImageView *iv in _imagesViews) {
			[iv removeFromSuperview];
		}

		[_imagesViews removeAllObjects];

		[_images removeAllObjects];
		[_actions removeAllObjects];

		[self setAlpha:0.0];

		[self setReanimateOnRotate:TRUE];

		return;
	}

// CONTROL

	SMXMLElement *altCon = [altSrc childNamed:@"control"];
	
	_controlPanSize			 = [[altCon valueWithPath:@"pansize"] intValue];
	_controlAutoLoop		 = [[altCon valueWithPath:@"autoloop"] boolValue];
	_controlAutoPlay		 = [[altCon valueWithPath:@"autoplay"] boolValue];
	_controlBounce			 = [[altCon valueWithPath:@"bounce"] boolValue];
	_controlPaging			 = [[altCon valueWithPath:@"paging"] boolValue];
	_controlDisableScrollIndicators	 = [[altCon valueWithPath:@"disableScrollIndicators"] boolValue];
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
		_controlAutoLoop  = NO;
	}

	if (!_controlAutoPlay) {
		_controlAutoPlay  = [[defCon valueWithPath:@"autoplay"] boolValue];
	}

	if (!_controlAutoPlay) {
		_controlAutoPlay  = NO;
	}

	if (!_controlBounce) {
		_controlBounce  = [[defCon valueWithPath:@"bounce"] boolValue];
	}

	if (!_controlBounce) {
		_controlBounce  = NO;
	}

	if (!_controlPaging) {
		_controlPaging  = [[defCon valueWithPath:@"paging"] boolValue];
	}

	if (!_controlPaging) {
		_controlPaging  = NO;
	}

	if (!_controlDisableTouch) {
		_controlDisableTouch  = [[defCon valueWithPath:@"disabletouch"] boolValue];
	}

	if (!_controlDisableTouch) {
		_controlDisableTouch  = NO;
	}
	
	if (!_controlDisableScrollIndicators) {
		_controlDisableScrollIndicators  = [[defCon valueWithPath:@"disableScrollIndicators"] boolValue];
	}
	
	if (!_controlDisableScrollIndicators) {
		_controlDisableScrollIndicators  = NO;
	}

	if (!_controlTransition) {
		_controlTransition  = [defCon valueWithPath:@"transition"];
	}

// POSITION
	
	SMXMLElement *altPos = [altSrc childNamed:@"position"];
	
	_positionWidth			 = [[altPos valueWithPath:@"width"] floatValue];
	_positionHeight			 = [[altPos valueWithPath:@"height"] floatValue];
	_positionContentLeft	 = [[altPos valueWithPath:@"contentLeft"] floatValue];
	_positionContentTop		 = [[altPos valueWithPath:@"contentTop"] floatValue];
	_positionContentWidth	 = [[altPos valueWithPath:@"contentWidth"] floatValue];
	_positionContentHeight	 = [[altPos valueWithPath:@"contentHeight"] floatValue];
	_positionLeft			 = [[altPos valueWithPath:@"left"] floatValue];
	_positionTop			 = [[altPos valueWithPath:@"top"] floatValue];
	_positionVisible		 = [[altPos valueWithPath:@"visible"] boolValue];
	_positionVisibleAnimate  = [[[altPos childNamed:@"visible"] attributeNamed:@"animate"] boolValue];

	if (!_positionWidth) {
		_positionWidth    = [[defPos valueWithPath:@"width"] floatValue];
	}
	
	if (!_positionWidth) {
		_positionWidth    = 0;
	}
	
	if (!_positionHeight) {
		_positionHeight   = [[defPos valueWithPath:@"height"] floatValue];
	}
	
	if (!_positionHeight) {
		_positionHeight   = 0;
	}

	if (!_positionContentLeft) {
		_positionContentLeft    = [[defPos valueWithPath:@"contentLeft"] floatValue];
	}
	
	if (!_positionContentLeft) {
		_positionContentLeft    = 0;
	}

	if (!_positionContentTop) {
		_positionContentTop   = [[defPos valueWithPath:@"contentTop"] floatValue];
	}
	
	if (!_positionContentTop) {
		_positionContentTop   = 0;
	}
	
	if (!_positionContentWidth) {
		_positionContentWidth    = [[defPos valueWithPath:@"contentWidth"] floatValue];
	}
	
	if (!_positionContentWidth) {
		_positionContentWidth    = _positionWidth;
	}
	
	if (!_positionContentHeight) {
		_positionContentHeight   = [[defPos valueWithPath:@"contentHeight"] floatValue];
	}
	
	if (!_positionContentHeight) {
		_positionContentHeight   = _positionHeight;
	}

	if (!_positionLeft) {
		_positionLeft     = [[defPos valueWithPath:@"left"] floatValue];
	}
	
	if (!_positionLeft) {
		_positionLeft     = 0;
	}
	
	if (!_positionTop) {
		_positionTop      = [[defPos valueWithPath:@"top"] floatValue];
	}
	
	if (!_positionTop) {
		_positionTop      = 0;
	}
	
	if (!_positionVisibleAnimate) {
		_positionVisibleAnimate  = [[[defPos childNamed:@"visible"] attributeNamed:@"animate"] boolValue];
	}
	
	if (!_positionVisibleAnimate) {
		_positionVisibleAnimate  = NO;
	}
	
	if (!_positionVisible) {
		_positionVisible  = [[defPos valueWithPath:@"visible"] boolValue];
	}
	
	if ([altPos valueWithPath:@"opacity"] != nil) {
		_positionOpacity = [[altPos valueWithPath:@"opacity"] floatValue];
	} else if ([altPos valueWithPath:@"opacity"] != nil) {
		_positionOpacity = [[defPos valueWithPath:@"opacity"] floatValue];
	} else if (!_positionVisible || (_positionVisible && _positionVisibleAnimate)) {
		_positionOpacity = 0;
	} else if (_positionVisible) {
		_positionOpacity = 1;
	} else {
		_positionOpacity = 1;
	}
	
//	if (!_positionVisible) {
//		_positionVisible  = YES;
//	}


// BORDER
	
	SMXMLElement *altBdr = [altSrc childNamed:@"border"];
	
	_borderRadius		= [[altBdr valueWithPath:@"radius"] floatValue];
	_borderWidth		= [[altBdr valueWithPath:@"width"] floatValue];
	_borderImage		= [altBdr valueWithPath:@"image"];
	_borderImageAbsolute = [[altBdr attributeNamed:@"absolute"] boolValue];

	if (!_borderRadius) {
		_borderRadius	= [[defBdr valueWithPath:@"radius"] floatValue];
	}
	
	if (!_borderWidth) {
		_borderWidth	= [[defBdr valueWithPath:@"width"] floatValue];
	}
	
	if (!_borderImage) {
		_borderImage	= [defBdr valueWithPath:@"image"];
		_borderImageAbsolute = [[defBdr attributeNamed:@"absolute"] boolValue];
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
	
	_animationDelay			= [[altAni valueWithPath:@"delay"] floatValue];
	_animationDuration		= [[altAni valueWithPath:@"duration"] floatValue];
	_animationOpacity		= [[altAni valueWithPath:@"opacity"] floatValue];
	_animationAutoRepeat	= [[altAni valueWithPath:@"autorepeat"] boolValue];
	_animationAutoReverse	= [[altAni valueWithPath:@"autoreverse"] boolValue];

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
	
	if (!_animationOpacity) {
		_animationOpacity = [[defAni valueWithPath:@"opacity"] floatValue];
	}
	
	if (!_animationOpacity && (_positionVisibleAnimate || _positionVisible)) { // still no opacity ??
		_animationOpacity = 1;
	}
	
	if ([altAni valueWithPath:@"top"] != nil) {
		_animationTop = [[altAni valueWithPath:@"top"] floatValue];
	} else if ([defAni valueWithPath:@"top"] != nil) {
		_animationTop = [[defAni valueWithPath:@"top"] floatValue];
	} else {
		_animationTop = _positionTop;
	}
	
	if ([altAni valueWithPath:@"left"] != nil) {
		_animationLeft = [[altAni valueWithPath:@"left"] floatValue];
	} else if ([defAni valueWithPath:@"left"] != nil) {
		_animationLeft = [[defAni valueWithPath:@"left"] floatValue];
	} else {
		_animationLeft = _positionLeft;
	}
	
	if ([altAni valueWithPath:@"width"] != nil) {
		_animationWidth = [[altAni valueWithPath:@"width"] floatValue];
	} else if ([defAni valueWithPath:@"width"] != nil) {
		_animationWidth = [[defAni valueWithPath:@"width"] floatValue];
	} else {
		_animationWidth = _positionWidth;
	}
	
	if ([altAni valueWithPath:@"height"] != nil) {
		_animationHeight = [[altAni valueWithPath:@"height"] floatValue];
	} else if ([defAni valueWithPath:@"height"] != nil) {
		_animationHeight = [[defAni valueWithPath:@"height"] floatValue];
	} else {
		_animationHeight = _positionHeight;
	}
	
	if (!_animationAutoRepeat) {
		_animationAutoRepeat = [[defAni valueWithPath:@"autorepeat"] boolValue];
	}
	
	if (!_animationAutoRepeat) {
		_animationAutoRepeat = NO;
	}
	
	if (!_animationAutoReverse) {
		_animationAutoReverse = [[defAni valueWithPath:@"autoreverse"] boolValue];
	}
	
	if (!_animationAutoReverse) {
		_animationAutoReverse = NO;
	}
	
	if ([altAni valueWithPath:@"autoplay"] != nil) {
		_animationAutoPlay = [[altAni valueWithPath:@"autoplay"] boolValue];
	} else if ([defAni valueWithPath:@"autoplay"] != nil) {
		_animationAutoPlay = [[defAni valueWithPath:@"autoplay"] boolValue];
	} else if (_positionVisible && _positionVisibleAnimate) { // Carry over from v1.
		_animationAutoPlay = YES;
	} else {
		_animationAutoPlay = NO;
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

// IMAGES

	SMXMLElement *altImg = [altSrc childNamed:@"images"];
	SMXMLElement *tmpImgs = nil;

	if ([_imagesViews count] > 0) {
		for (UIImageView *tmpImageView in _imagesViews) {
			[tmpImageView removeFromSuperview];
		}
		[_images removeAllObjects];
		[_imagesViews removeAllObjects];
	}

	if (altImg != NULL) {

		tmpImgs = altImg;

	} else if (defImg != NULL) {

		tmpImgs = defImg;
		
	}

	NSString *scrollLayout = [tmpImgs attributeNamed:@"layout"];
	__block int scrollOffsetLeft = 0;
	__block int scrollOffsetTop = 0;

	if (tmpImgs != nil) {

		for (SMXMLElement *img in [tmpImgs childrenNamed:@"image"]) {

			[_images addObject:img];

		}
	}

// RUN SETUP

	for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
		if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
			recognizer.enabled = NO;
			[self removeGestureRecognizer:recognizer];
		}
	}
	
	if (_animationOpacity != self.alpha || _reanimateOnRotate) {
		[self setAlpha:_positionOpacity];
	}

//	while (self.gestureRecognizers.count) {
//		[self removeGestureRecognizer:[self.gestureRecognizers objectAtIndex:0]];
//	}

	if ([_actions count] > 0) {
		// Add the touch actions
		UITapGestureRecognizer *sngTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
		sngTap.numberOfTouchesRequired = 1;
		sngTap.numberOfTapsRequired = 1;

		[self addGestureRecognizer:sngTap];
	}

	[self setFrame:CGRectMake(_positionLeft, _positionTop, _positionWidth, _positionHeight)];
	[self setContentSize:CGSizeMake(_positionContentWidth, _positionContentHeight)];
	[self setContentOffset:CGPointMake(_positionContentLeft, _positionContentTop)];
	[self setBounces:_controlBounce];
	[self setClipsToBounds:TRUE];
	
	if (_controlDisableScrollIndicators) {
	
		[self setShowsHorizontalScrollIndicator:NO];
		[self setShowsVerticalScrollIndicator:NO];
	
	} else if (_positionWidth != _positionContentWidth || _positionHeight != _positionContentHeight) {
		
		[self flashScrollIndicators];
		
	}
	
	if (_controlDisableTouch) {

		[self setUserInteractionEnabled:FALSE];

	} else {

		[self setUserInteractionEnabled:TRUE];

	}

	[self setMaximumZoomScale:_controlMaxZoom];
	[self setMinimumZoomScale:_controlMinZoom];
	[self setZoomScale:_controlInitZoom];

	if (_controlPaging) {
		[self setPagingEnabled:TRUE];
	} else {
		[self setPagingEnabled:FALSE];
	}

	//[self.layer setBackgroundColor:_backgroundColor.CGColor];
	
	[self.layer setBorderWidth:_borderWidth];
	[self.layer setCornerRadius:_borderRadius];
	[self.layer setBorderColor:_borderColor.CGColor];

	[self setBackgroundImage];
	
	if (![_borderImage isEqualToString:@""]) {
		
		if (_borderImageAbsolute) {
		
			[self.layer setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:_borderImage]] CGColor]];
		
		} else {
		
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
			
			dispatch_async(queue, ^{
				
				NSData *imageBdrData = [_postmaster getAndReceive:[NSURL URLWithString:_borderImage] packageData:nil cachable:YES];
				
				UIImage *tmpBdrImg = [UIImage imageWithData:imageBdrData];
				
				dispatch_sync(dispatch_get_main_queue(), ^{
					
					[self.layer setBorderColor:[[UIColor colorWithPatternImage:tmpBdrImg] CGColor]];
					
				});
				
			});
			
		}
	}

	if (_shadowOpacity) {
		[self.layer setShadowColor:_shadowColor.CGColor];
		[self.layer setShadowOffset:CGSizeMake(_shadowOffsetX, _shadowOffsetY)];
		[self.layer setShadowOpacity:_shadowOpacity];
		[self.layer setShadowRadius:_shadowRadius];
		[self.layer setMasksToBounds:FALSE];
	}

	if ([_images count] > 0) {

		if ([scrollLayout isEqualToString:@"slideshow"]) {

			SMXMLElement *img = (SMXMLElement *)[_images objectAtIndex:_scrollPage];

			BOOL isAbsolute = [[img attributeNamed:@"absolute"] boolValue];
			
			if (!isAbsolute) {
				
				UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",_contentPath,[img value]]];
				UIImageView *tmpImgView = [[UIImageView alloc] initWithImage:tmpImg];
				[tmpImgView setFrame:CGRectMake(0
												, 0
												, [[img attributeNamed:@"width"] intValue] ? [[img attributeNamed:@"width"] intValue] : _positionWidth
												, [[img attributeNamed:@"height"] intValue] ? [[img attributeNamed:@"height"] intValue] : _positionHeight
												)];
				
				[_imagesViews addObject:tmpImgView];
				
				[self addSubview:tmpImgView];
				
				if (!_controlDisableTouch) {
					_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panimages:)];
					[self addGestureRecognizer:_panGesture];
				}
				
			} else {
				
				dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
				
				dispatch_async(queue, ^{
					
					NSData *imageData = [_postmaster getAndReceive:[NSURL URLWithString:[img value]] packageData:nil cachable:YES];
					
					UIImage *tmpImg = [UIImage imageWithData:imageData];
					
					dispatch_sync(dispatch_get_main_queue(), ^{
						
						UIImageView *tmpImgView = [[UIImageView alloc] initWithImage:tmpImg];
						
						[_imagesViews addObject:tmpImgView];
						
						[self addSubview:tmpImgView];
						
						if (!_controlDisableTouch) {
							_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panimages:)];
							[self addGestureRecognizer:_panGesture];
						}
						
					});
					
				});
				
			}

		} else {

			for (SMXMLElement *img in _images) {
				
				BOOL isAbsolute = [[img attributeNamed:@"absolute"] boolValue];

				if (!isAbsolute) {
					
					UIImage *tmpImg = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",_contentPath,[img value]]];
					UIImageView *tmpImgView = [[UIImageView alloc] initWithImage:tmpImg];
					[tmpImgView setFrame:CGRectMake(scrollOffsetLeft
													, scrollOffsetTop
													, [[img attributeNamed:@"width"] intValue] ? [[img attributeNamed:@"width"] intValue] : _positionWidth
													, [[img attributeNamed:@"height"] intValue] ? [[img attributeNamed:@"height"] intValue] : _positionHeight
													)];

					[_imagesViews addObject:tmpImgView];

					if ([scrollLayout isEqualToString:@"landscape"]) {
						scrollOffsetLeft += [[img attributeNamed:@"width"] intValue] ? [[img attributeNamed:@"width"] intValue] : _positionWidth;
					} else if ([scrollLayout isEqualToString:@"portrait"]) {
						scrollOffsetTop += [[img attributeNamed:@"height"] intValue] ? [[img attributeNamed:@"height"] intValue] : _positionHeight;
					}

					[self addSubview:tmpImgView];
					
				} else {
					
					dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
					
					dispatch_async(queue, ^{
						
						NSData *imageData = [_postmaster getAndReceive:[NSURL URLWithString:[img value]] packageData:nil cachable:YES];
						
						UIImage *tmpImg = [UIImage imageWithData:imageData];
						
						dispatch_sync(dispatch_get_main_queue(), ^{
							
							UIImageView *tmpImgView = [[UIImageView alloc] initWithImage:tmpImg];
							[tmpImgView setFrame:CGRectMake(scrollOffsetLeft
															, scrollOffsetTop
															, [[img attributeNamed:@"width"] intValue] ? [[img attributeNamed:@"width"] intValue] : _positionWidth
															, [[img attributeNamed:@"height"] intValue] ? [[img attributeNamed:@"height"] intValue] : _positionHeight
															)];
							
							[_imagesViews addObject:tmpImgView];
							
							if ([scrollLayout isEqualToString:@"landscape"]) {
								scrollOffsetLeft += [[img attributeNamed:@"width"] intValue] ? [[img attributeNamed:@"width"] intValue] : _positionWidth;
							} else if ([scrollLayout isEqualToString:@"portrait"]) {
								scrollOffsetTop += [[img attributeNamed:@"height"] intValue] ? [[img attributeNamed:@"height"] intValue] : _positionHeight;
							}
							
							[self addSubview:tmpImgView];
							
						});
						
					});
					
				}
			}
		}
	}

	if (_reanimateOnRotate) {
		[self performAnimations];
		[self setReanimateOnRotate:FALSE];
	}

	if (_controlAutoPlay) {

		_controlTimer = nil;
		_controlTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)(_animationDelay + _animationDuration + 0.01)
														 target:self
													   selector:@selector(progressimage:)
													   userInfo:nil
														repeats:YES];
	} else {

		[self stopTimer];

	}
	
}

- (void)setBackgroundImage {
	
	if (_backgroundImage) {
		NSString *tmpBGImg = [NSString stringWithFormat:@"%@/%@",_contentPath,_backgroundImage];
		UIImage *bgImage = [UIImage imageWithContentsOfFile:tmpBGImg];
	
		[self.layer setContents:(id)bgImage.CGImage];
	}
	
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	if(_imagesViews != nil && [_imagesViews count]) {
		return [_imagesViews objectAtIndex:0];
	} else {
		return nil;
	}
}

-(void) setReanimateOnRotate:(BOOL)reanimateOnRotate {
	_reanimateOnRotate = reanimateOnRotate;
}

-(void)handleSingleTap:(UITapGestureRecognizer*)recognizer {

	int actionCount = [_actions count];

	if (recognizer.state == UIGestureRecognizerStateEnded)
    {
		for (int actionPos = 0; actionPos < actionCount; actionPos++) {

			SMXMLElement *echAction = [_actions objectAtIndex:actionPos];

			_actionOnTap		= [echAction attributeNamed:@"action"];
			_actionID			= [echAction attributeNamed:@"target"];
			_actionURL			= [echAction attributeNamed:@"url"];
			_actionIndex		= [[echAction attributeNamed:@"index"] intValue];
			//NSString *forState	= [echAction attributeNamed:@"forstate"];

			id tmpLayerView = nil;
			
			if ([_actionOnTap isEqualToString:@"geturl"]) {
				tmpLayerView = (CPWebView *)[self getObjectByID:_actionID];
			} else {
				tmpLayerView = (CPLayerView *)[self getObjectByID:_actionID];
			}
			
			
			DLog(@"Handle Single Tap. - %@ - %@ - %u",_actionOnTap,_actionID,_actionIndex);
			
			if ([_actionOnTap isEqualToString:@"setstate"]){

				CPLayerView *tmpLayerView = (CPLayerView *)[self getObjectByID:_actionID];

				[tmpLayerView setScrollPage:_actionIndex];
				[tmpLayerView setpanimage];

			} else if ([_actionOnTap isEqualToString:@"geturl"] && tmpLayerView) {
			
				[(CPWebView *)tmpLayerView gotoURL:_actionURL];
				
			} else if (tmpLayerView) {
				
				//if (([forState isEqualToString:@"visible"] && [tmpLayerView alpha] == 1) || ([forState isEqualToString:@"hidden"] && [tmpLayerView alpha] == 0)) {
					
					[UIView animateWithDuration:(NSTimeInterval)_animationDuration
										  delay:(NSTimeInterval)_animationDelay
										options:UIViewAnimationOptionBeginFromCurrentState
									 animations:^{
										 
										 [[tmpLayerView superview] bringSubviewToFront:tmpLayerView];
										 
										 if ([_actionOnTap isEqualToString:@"show"]){
											 [tmpLayerView setAlpha:1];
										 } else if ([_actionOnTap isEqualToString:@"hide"]){
											 [tmpLayerView setAlpha:0];
										 }
										 
									 }
									 completion:^(BOOL finished) {
										 
									 }];

				//}
				
			} else if ([_actionOnTap isEqualToString:@"geturl"]){

				[self gotoURL];

			} else if ([_actionOnTap isEqualToString:@"playvideo"]){

				NSURL *movieURL = nil;
				NSString *fooFile = [NSString stringWithFormat:@"%@/%@",_contentPath,_actionURL];

				if ([[NSFileManager defaultManager] fileExistsAtPath:fooFile]) {
					movieURL = [NSURL fileURLWithPath:fooFile];
				} else {
					movieURL = [NSURL URLWithString:_actionURL];
				}

				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:movieURL forKey:@"movieurl"];

				[[NSNotificationCenter defaultCenter] postNotificationName:@"CPPlayFullScreenVideo" object:nil userInfo:userInfo];

			} else if ([_actionOnTap isEqualToString:@"goto"]){

				NSString *actionPage = _actionID;
				NSDictionary *userInfo = [NSDictionary dictionaryWithObject:actionPage forKey:@"pageid"];

				[[NSNotificationCenter defaultCenter] postNotificationName:@"CPNavigateToPage" object:nil userInfo:userInfo];

			} else {

				// Nothing else assigned. So lets fire off the single tap event
				[[NSNotificationCenter defaultCenter] postNotificationName:@"CPHandleSingleTap" object:nil userInfo:nil];
			}

		}

	} else {

		// Nothing else assigned. So lets fire off the single tap event
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPHandleSingleTap" object:nil userInfo:nil];

	}
}

- (void)setScrollPage:(int)pageNum {
	_scrollPage = pageNum;
}

-(void)gotoURL
{
    NSURL *requestURL = [[NSURL alloc] initWithString:_actionURL];
	
	DLog(@"%@",requestURL);

    if ( [[requestURL scheme] isEqualToString:@"http"]
		|| [[requestURL scheme] isEqualToString:@"https"]
		) {
        //return ![[UIApplication sharedApplication ] openURL:requestURL];

		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:requestURL forKey:@"url"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPNavigateWebNavigator" object:nil userInfo:userInfo];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPShowWebNavigator" object:self];

	} else {

		[[UIApplication sharedApplication] openURL:requestURL];
		
	}
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
