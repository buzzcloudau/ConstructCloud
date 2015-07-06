//
//  CPOpenGLView.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "SMXMLDocument.h"
#import "CPMagazinePageView.h"
#import "CPMovieController.h"
#import "defs.h"
#import "OpenGLWaveFrontObject.h"

@interface CPOpenGLView : UIView {
	OpenGLWaveFrontObject *wfObj;
}

- (id)initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath pageView:(id)pageView;
- (void)setAlpha:(CGFloat)alpha;
- (void)setMustRender:(BOOL)mustRender;
- (void)setCurrentPage:(id)currentPage;
- (void)resetLayout:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)removeFromSuperview;
- (id)getObjectByID:(NSString *)objID;

@property (nonatomic) id pageView;

@property (nonatomic) BOOL isAnimating;

@property (nonatomic) BOOL hasLandscape;
@property (nonatomic) BOOL hasPortrait;
@property (nonatomic) BOOL mustRender;
@property (nonatomic) NSString *xmlID;
@property (nonatomic) SMXMLElement *xmlPacket;

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

@property (nonatomic) UIColor *backgroundColorSet;
@property (nonatomic) float backgroundOpacity;
@property (nonatomic) NSString *backgroundImage;
@property (nonatomic) NSString *backgroundPosition; //tile, centre, stretch

@property (nonatomic) NSString *objFile;
@property (nonatomic) NSString *mltFile;

@property (nonatomic) CAEAGLLayer* eaglLayer;
@property (nonatomic) EAGLContext* context;
@property (nonatomic) GLuint colorRenderBuffer;



@end
