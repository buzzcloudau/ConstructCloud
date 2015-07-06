//
//  CPOpenGLView.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPOpenGLView.h"

@implementation CPOpenGLView

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
@synthesize positionContentWidth = _positionContentWidth;
@synthesize positionContentHeight = _positionContentHeight;
@synthesize positionVisible = _positionVisible;
@synthesize positionVisibleAnimate = _positionVisibleAnimate;

@synthesize borderRadius = _borderRadius;
@synthesize borderWidth = _borderWidth;
@synthesize borderColor = _borderColor;
@synthesize borderImage = _borderImage;

@synthesize mustRender = _mustRender;
@synthesize contentPath = _contentPath;

@synthesize backgroundColorSet = _backgroundColor;
@synthesize backgroundOpacity = _backgroundOpacity;
@synthesize backgroundPosition = _backgroundPosition;
@synthesize backgroundImage = _backgroundImage;

@synthesize mltFile = _mltFile;
@synthesize objFile = _objFile;

@synthesize eaglLayer = _eaglLayer;
@synthesize context = _context;
@synthesize colorRenderBuffer = _colorRenderBuffer;


-(id)initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath pageView:(id)pageView {
	
	_pageView = pageView;
	_contentPath = contentPath;
	_xmlPacket = xmlData;
	_isAnimating = FALSE;
	
	self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
	
//	[self setAlpha:0.0];
	
	if (self) {
		
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		
		_hasPortrait	= [_xmlPacket childNamed:@"psrc"] || [_xmlPacket childNamed:@"src"] ? TRUE : FALSE;
		_hasLandscape	= [_xmlPacket childNamed:@"lsrc"] || [_xmlPacket childNamed:@"src"] ? TRUE : FALSE;
		_xmlID			= [_xmlPacket attributeNamed:@"id"];
		
		// FILES
		
		_objFile = [NSString stringWithFormat:@"%@/%@",_contentPath,[[_xmlPacket childNamed:@"files"] valueWithPath:@"obj"]];
		_mltFile = [NSString stringWithFormat:@"%@/%@",_contentPath,[[_xmlPacket childNamed:@"files"] valueWithPath:@"mlt"]];

		DLog(@"_objFile : %d",[[NSFileManager defaultManager] fileExistsAtPath:_objFile]);
		DLog(@"_mltFile : %d",[[NSFileManager defaultManager] fileExistsAtPath:_mltFile]);
		
		//wfObj = [[OpenGLWaveFrontObject alloc] initWithPath:_objFile];
		
		[self resetLayout:[UIApplication sharedApplication].statusBarOrientation];
		
		[self.layer setZPosition:500.0f];
		
		[self setupLayer];
		[self setupContext];
		[self setupRenderBuffer];
		[self setupFrameBuffer];
		[self render];
		
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
	
	DLog(@"setupLayer");
	
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext {
	
	DLog(@"setupContext");
	
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
	
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
	
	//[wfObj drawSelf];
}

- (void)setupRenderBuffer {
	
	DLog(@"setupRenderBuffer");
	
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
	
	DLog(@"setupFrameBuffer");
	
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
							  GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)render {
	
	DLog(@"render");
	
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

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

-(void)resetLayout:(UIInterfaceOrientation)toInterfaceOrientation {
	
	SMXMLElement *defSrc = [_xmlPacket childNamed:@"src"];
//	SMXMLElement *defCon = [defSrc childNamed:@"control"];
	SMXMLElement *defPos = [defSrc childNamed:@"position"];
	SMXMLElement *defBdr = [defSrc childNamed:@"border"];
	SMXMLElement *defBck = [defSrc childNamed:@"background"];
//	SMXMLElement *defAct = [defSrc childNamed:@"actions"];
//	SMXMLElement *defAni = [defSrc childNamed:@"animation"];
//	SMXMLElement *defShd = [defSrc childNamed:@"shadow"];
//	SMXMLElement *defImg = [defSrc childNamed:@"images"];
	
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
	

	
// RUN SETUP
	
//	[self.layer setBackgroundColor:[[UIColor redColor] CGColor]];
//	
//	[self.layer setBorderWidth:10.0f];
//	[self.layer setCornerRadius:15.0f];
//	[self.layer setBorderColor:[[UIColor whiteColor] CGColor]];
	
	[self setFrame:CGRectMake(_positionLeft, _positionTop, _positionWidth, _positionHeight)];
	[self setBounds:CGRectMake(_positionLeft, _positionTop, _positionWidth, _positionHeight)];
	
	DLog(@"%f %f %f %f",_positionLeft,_positionTop,_positionWidth,_positionHeight);
	
}

- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation {
	
	[self resetLayout:toInterfaceOrientation];
	
}

- (id)getObjectByID:(NSString *)objID {
	return [(CPMagazinePageView *)_pageView getObjectByID:objID];
}

@end
