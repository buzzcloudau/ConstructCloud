//
//  CPMagazinePageView.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import "CPImageView.h"
#import "CPMapView.h"
#import "CPMapControllerView.h"
#import "CPLayerView.h"
#import "CPWebView.h"
#import "CPOpenGLView.h"
#import "SMXMLDocument.h"
#import "CPMovieController.h"
#import "CPHUD.h"
#import "CPPostmaster.h"
#import "AppDelegate.h"

@interface CPMagazinePageView : UIView

//- (id)initWithFrame:(CGRect)frame backgroundImage:(NSString *)backgroundImage;
- (id)initWithFrame:(CGRect)frame
   mustRenderOnLoad:(BOOL)mustRenderOnLoad
		contentPath:(NSString *)contentPath
		  lpageWidth:(float)lpageWidth
		 lpageHeight:(float)lpageHeight
		 ppageWidth:(float)ppageWidth
		ppageHeight:(float)ppageHeight;

- (void)resetLayout;
- (void)clearLayout;
- (void)initBG;
- (void)setRenderedView;
- (void)addImages;
- (void)addVideos;
- (void)resetVideos;
- (void)addMaps;
- (void)resetMaps;
- (void)addLayers;
- (void)resetLayers;
- (void)addWebs;
- (void)resetWebs;
- (void)addOpenGL;
- (void)resetOpenGL;
- (void)setBackgroundImageForOrientation:(UIInterfaceOrientation)bgInterfaceOrientation;
- (void)setPageFromElement:(SMXMLElement *)xmlPage;
- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)setMustRender:(BOOL)mustRender;
- (void)setCurrentPage:(BOOL)currentPage;
- (id)getObjectByID:(NSString *)objID;

@property (nonatomic) CGRect internalFrame;
@property (nonatomic) NSInteger tagCount;
@property (nonatomic) BOOL mustRender;
@property (nonatomic) BOOL currentPage;
@property (nonatomic) BOOL hasBackgroundImage;
@property (nonatomic) UIInterfaceOrientation renderedOrientation;

@property (nonatomic) NSMutableArray *movieList;
@property (nonatomic) NSMutableArray *imageList;
@property (nonatomic) NSMutableArray *buttonList;
@property (nonatomic) NSMutableArray *mapList;
@property (nonatomic) NSMutableArray *mapControllerList;
@property (nonatomic) NSMutableArray *layerList;
@property (nonatomic) NSMutableArray *webList;
@property (nonatomic) NSMutableArray *openGLList;

@property (nonatomic) NSMutableArray *objectList;

@property (nonatomic) SMXMLElement* page;
@property (nonatomic) UIImageView *bgImageView;
@property (nonatomic) NSString *contentPath;

@property (nonatomic) CPMovieController *tmpMovie;

@property (nonatomic) NSString *xmlID;

@property (nonatomic) int pageSetCount;
@property (nonatomic) int pageIndexInSet;

@property (nonatomic) float lpageWidth;
@property (nonatomic) float lpageHeight;

@property (nonatomic) float ppageWidth;
@property (nonatomic) float ppageHeight;

@property (nonatomic) CPHUD *hud;

@property (nonatomic) AppDelegate *appDelegate;
@property (nonatomic) CPPostmaster *postmaster;
@property (nonatomic) NSCache *contentCache;


@end
