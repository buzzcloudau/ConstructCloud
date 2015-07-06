//
//  CPMagazinePageView.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPMagazinePageView.h"
#import "CPMapControllerView.h"
#import "defs.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation CPMagazinePageView

- (id)initWithFrame:(CGRect)frame
   mustRenderOnLoad:(BOOL)mustRenderOnLoad
		contentPath:(NSString *)contentPath
		 lpageWidth:(float)lpageWidth
		lpageHeight:(float)lpageHeight
		 ppageWidth:(float)ppageWidth
		ppageHeight:(float)ppageHeight
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

		_contentPath = contentPath;
        _internalFrame = frame;
		_hud = nil;
		
		_tagCount = 0;
        
        self.frame = frame;
        self.bounds = frame;

        _imageList = [[NSMutableArray alloc] init];
        _movieList = [[NSMutableArray alloc] init];
        _buttonList = [[NSMutableArray alloc] init];
		_mapList = [[NSMutableArray alloc] init];
		_mapControllerList = [[NSMutableArray alloc] init];
        _layerList = [[NSMutableArray alloc] init];
		_webList = [[NSMutableArray alloc] init];
		_openGLList = [[NSMutableArray alloc] init];
		_objectList = [[NSMutableArray alloc] init];
		
		_lpageWidth = lpageWidth;
		_lpageHeight = lpageHeight;
		_ppageWidth = ppageWidth;
		_ppageHeight = ppageHeight;
		
		[_objectList insertObject:@"" atIndex:0];

        _hasBackgroundImage = FALSE;
		// _renderedOrientation = NULL;
		
		_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
		_postmaster = [[CPPostmaster alloc] init];
		_contentCache = [_appDelegate contentCache];

		[self initBG];
    }
    return self;
}

- (void)initBG {
    
    if (!_hasBackgroundImage) {

        _bgImageView = [[UIImageView alloc] initWithFrame:_internalFrame];
        
		if (_hud == nil) {
			_hud = [[CPHUD alloc] initWithView:_bgImageView];
		}
		
        [_bgImageView setAnimationDuration:1.1];
        [_bgImageView setAnimationRepeatCount:999999999];    
        
        _bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_bgImageView setBounds:CGRectMake(0, 0, _internalFrame.size.width, _internalFrame.size.height)];
        [_bgImageView setFrame:CGRectMake(0, 0, _internalFrame.size.width, _internalFrame.size.height)];
        //[_bgImageView setCenter:CGPointMake(_internalFrame.size.width/2, _internalFrame.size.height/2)];
        
        [self addSubview:_bgImageView];
        
        _hasBackgroundImage = TRUE;
    }
}

- (void)resetLayout {

	if (_mustRender) {
		DLog(@"resetLayout : %@",_xmlID);
	}
	
    if (!_currentPage) {

        for (int i = (_movieList.count - 1); i >= 0 ; i--) {
            CPMovieController *tmpMovie = [_movieList objectAtIndex:i];
			[[NSNotificationCenter defaultCenter] removeObserver:tmpMovie];
            [tmpMovie stop];
            [tmpMovie.view removeFromSuperview];
			
			//[_objectList replaceObjectAtIndex:tmpMovie.view.tag withObject:@""];

			// Dont remove. the reference is recycled internally
			// Removing the object will cause a crash.

			[_movieList removeObjectAtIndex:i];
        }

		for (int n = (_imageList.count - 1); n >= 0 ; n--) {
            CPImageView *tmpImage = (id)[_imageList objectAtIndex:n];
			[_objectList replaceObjectAtIndex:tmpImage.tag withObject:@""];
            [tmpImage removeFromSuperview];
            [_imageList removeObjectAtIndex:n];
        }
		
		for (int p = (_mapList.count - 1); p >= 0 ; p--) {
            CPMapView *tmpMap = [_mapList objectAtIndex:p];
			[_objectList replaceObjectAtIndex:tmpMap.tag withObject:@""];
            [tmpMap removeFromSuperview];
            [_mapList removeObjectAtIndex:p];
        }

		for (int q = (_mapControllerList.count - 1); q >= 0 ; q--) {
            CPMapControllerView *tmpMapControlelr = [_mapControllerList objectAtIndex:q];
			[_objectList replaceObjectAtIndex:tmpMapControlelr.tag withObject:@""];
            [tmpMapControlelr removeFromSuperview];
            [_mapControllerList removeObjectAtIndex:q];
        }

		for (int r = (_layerList.count - 1); r >= 0; r--) {
			CPLayerView *tmpLayer = [_layerList objectAtIndex:r];
			[tmpLayer stopTimer]; // kill the internal timer
			[_objectList replaceObjectAtIndex:tmpLayer.tag withObject:@""];
			[tmpLayer removeFromSuperview];
            [_layerList removeObjectAtIndex:r];
        }
		
		for (int q = (_webList.count - 1); q >= 0; q--) {
			CPWebView *tmpWeb = [_webList objectAtIndex:q];
			[tmpWeb stopTimer]; // kill the internal timer
			[_objectList replaceObjectAtIndex:tmpWeb.tag withObject:@""];
            [tmpWeb removeFromSuperview];
            [_webList removeObjectAtIndex:q];
        }
		
		for (int z = (_openGLList.count - 1); z >= 0; z--) {
			CPOpenGLView *tmpOpenGL = [_openGLList objectAtIndex:z];
			[_objectList replaceObjectAtIndex:tmpOpenGL.tag withObject:@""];
            [tmpOpenGL removeFromSuperview];
            [_openGLList removeObjectAtIndex:z];
        }
        
    } else {
        [self setRenderedView];
    }
}

- (void)clearLayout {
    
    while([[self subviews] count]) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    [_movieList removeAllObjects];
    [_imageList removeAllObjects];
    [_buttonList removeAllObjects];
	[_mapList removeAllObjects];
	[_mapControllerList removeAllObjects];
	[_layerList removeAllObjects];
	[_webList removeAllObjects];
	[_openGLList removeAllObjects];
}

- (void)setPageFromElement:(SMXMLElement *)xmlPage {
    
    _page = xmlPage;

	NSString *tmpStr = [_page attributeNamed:@"id"];

	if (tmpStr != NULL && tmpStr != nil) {
		_xmlID = tmpStr;
	} else {
		_xmlID = @"undefined";
	}
}

- (void)setBackgroundImageForOrientation:(UIInterfaceOrientation)bgInterfaceOrientation {
	
	SMXMLElement *bgimg = [_page childNamed:@"background"];
	SMXMLElement *tmpBg = nil;
	
	if (bgInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || bgInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		
		tmpBg = [bgimg childNamed:@"lsrc"];
		
	} else {
		
		tmpBg = [bgimg childNamed:@"psrc"];
		
	}
	
	if (tmpBg == nil) {
		
		tmpBg = [bgimg childNamed:@"src"];
		
	}
	
	if (!_mustRender || _renderedOrientation != bgInterfaceOrientation) {
		[_bgImageView setAnimationImages:nil];
	}
	
	if (_hud == nil) {
		_hud = [[CPHUD alloc] initWithView:_bgImageView];
	}
	
	// BACKGROUND COLOR
	NSString *tmpColor	= [tmpBg valueWithPath:@"color"];
	
	if (tmpColor) {
		SEL backgroundColorSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",tmpColor]);
		if ([UIColor respondsToSelector:backgroundColorSelector]) {
			[self setBackgroundColor:[UIColor performSelector:backgroundColorSelector]];
		}
	}
	
	if ([tmpBg valueWithPath:@"image"] != NULL) {
		
		BOOL isAbsolute = [[[tmpBg childNamed:@"image"] attributeNamed:@"absolute"] boolValue];
		
		if (!isAbsolute) {
			NSString *imgName = [NSString stringWithFormat:@"%@/%@"
								 ,_contentPath
								 ,[tmpBg valueWithPath:@"image"]];
			
			UIImage *bgImage = [UIImage imageWithContentsOfFile:imgName];
			
			NSArray *bgImageAry = [[NSArray alloc] initWithObjects:bgImage, nil];
			
			[_bgImageView setAnimationImages:bgImageAry];
			[_bgImageView startAnimating];
			[self setRenderedOrientation:bgInterfaceOrientation];
			
		} else {
			
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
			
			dispatch_async(queue, ^{
				
				NSData *imageData = [_postmaster getAndReceive:[NSURL URLWithString:[tmpBg valueWithPath:@"image"]] packageData:nil cachable:YES];
				
				UIImage *bgImage = [UIImage imageWithData:imageData];
				
				NSArray *bgImageAry = [[NSArray alloc] initWithObjects: bgImage, nil];
				
				dispatch_sync(dispatch_get_main_queue(), ^{
					
					[_bgImageView setAnimationImages:bgImageAry];
					[_bgImageView startAnimating];
					[self setRenderedOrientation:bgInterfaceOrientation];
					
				});
				
			});
			
		}
		
	}
	
}

- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation {
    
	if (_mustRender) {
		
		[self setBackgroundImageForOrientation:toInterfaceOrientation];
        
    } else {
        
		[_hud show:YES];
		[_bgImageView setAnimationImages:nil];
		return;
    }
    
	if (!_bgImageView.isAnimating) {
	
		[_bgImageView startAnimating];
	
	}

	for (int z = 0; z < _layerList.count; z++) {
		CPLayerView *tmpLayer = [_layerList objectAtIndex:z];
		[tmpLayer preRotate:toInterfaceOrientation];
	}
	
	for (int q = 0; q < _webList.count; q++) {
		CPWebView *tmpWeb = [_webList objectAtIndex:q];
		[tmpWeb preRotate:toInterfaceOrientation];
	}
	
	for (int i = 0; i < _mapList.count; i++) {
        CPMapView *mapView = [_mapList objectAtIndex:i];
		[mapView preRotate:toInterfaceOrientation];
    }

	if (_currentPage) {
        
        for (int i = 0; i < _movieList.count; i++) {
            //CPMoviePlayerController *tmpMovie = [_movieList objectAtIndex:i];
			CPMovieController *tmpMovie = [_movieList objectAtIndex:i];
            [tmpMovie pause];


			[tmpMovie preRotate:toInterfaceOrientation];
			
			if ([tmpMovie.view isHidden]) {
				//[tmpMovie.view setHidden:FALSE];
				[tmpMovie.player.moviePlayer setCurrentPlaybackTime:0];

			} else {
				if (![tmpMovie landscapeIsPortrait]) {
					[tmpMovie.view setHidden:TRUE];
				}
			}
            // [_movieList removeObjectAtIndex:i];
        }

		/*

        for (int n = 0; n < _imageList.count; n++) {
            CPImageView *tmpImage = (id)[_imageList objectAtIndex:n];
            [tmpImage removeFromSuperview];
            [_imageList removeObjectAtIndex:n];
        }
		
		*/

    }

}

- (void)setRenderedView {
    
    // Add Images
    if (_imageList.count == 0) {
        [self addImages];
    } else {
        [self resetImages];
    }
    
    // Add Videos
    if (_movieList.count == 0) {
        [self addVideos];
    } else {
        [self resetVideos];
    }
	
	// Add Maps
    if (_mapList.count == 0) {
        [self addMaps];
    } else {
        [self resetMaps];
    }

	// Add Layers
    if (_layerList.count == 0) {
        [self addLayers];
    } else {
        [self resetLayers];
    }
	
	// Add Webs
    if (_webList.count == 0) {
        [self addWebs];
    } else {
        [self resetWebs];
    }
	
	// ADD OpenGL
	if (_openGLList.count == 0) {
        [self addOpenGL];
    } else {
        [self resetOpenGL];
    }
	
	[_hud show:NO];
}

- (void)addImages {

	for (SMXMLElement *image in [_page childrenNamed:@"image"]) {

		_tagCount++;

		CPImageView *imageView = [[CPImageView alloc] initWithXML:image contentPath:_contentPath];
		
		[imageView setTag:_tagCount];

		[self addSubview:imageView];
		
        [_imageList addObject:(id)imageView];
		if (imageView.xmlID) {
			[_objectList insertObject:imageView.xmlID atIndex:_tagCount];
		} else {
			[_objectList insertObject:@"" atIndex:_tagCount];
		}
    }
}

- (void)resetImages {
    
    for (int i = 0; i < _imageList.count; i++) {
        CPImageView *imageView = [_imageList objectAtIndex:i];
		[imageView resetLayout];
    }
    
}

- (void)addVideos {
    
    for (SMXMLElement *video in [_page childrenNamed:@"video"]) {
		_tagCount++;

		CPMovieController *movie = [[CPMovieController alloc] initWithXML:video contentPath:_contentPath];
		
		[[movie view] setTag:_tagCount];
		
		[_movieList addObject:movie];
		
		if (movie.xmlID) {
			[_objectList insertObject:movie.xmlID atIndex:_tagCount];
		} else {
			[_objectList insertObject:@"" atIndex:_tagCount];
		}
		
		[self addSubview:movie.view];
		
    }
}

- (void)resetVideos {
    for (int i = 0; i < _movieList.count; i++) {
		CPMovieController *movie = [_movieList objectAtIndex:i];
        [movie resetLayout:[UIApplication sharedApplication].statusBarOrientation];

		[movie postRotate];

		/*
		if ([movie controlAutoplay]) {
			[movie performSelector:@selector(playFromSelector:) withObject:nil afterDelay:0.5];
		}
		*/
    }
}

- (void)addMaps {

	
	for (SMXMLElement *map in [_page childrenNamed:@"map"]) {

		_tagCount++;

        CPMapView *mapView = [[CPMapView alloc] initWithXML:map contentPath:_contentPath pageView:self];

		[mapView setTag:_tagCount];

		[self addSubview:mapView];
			
		[_mapList addObject:mapView];
		
		if(mapView.xmlID) {
			[_objectList insertObject:mapView.xmlID atIndex:_tagCount];
		} else {
			[_objectList insertObject:@"" atIndex:_tagCount];
		}

		// Add the Map Controllers

		for (SMXMLElement *controller in [map childrenNamed:@"controller"]) {
			
			_tagCount++;

			CPMapControllerView *controllerView = [[CPMapControllerView alloc] initWithXML:controller mapView:mapView contentPath:_contentPath];
			
			[controllerView setTag:_tagCount];
			
			[self addSubview:controllerView];
			
			[_mapControllerList addObject:controllerView];
			if (controllerView.xmlID) {
				[_objectList insertObject:controllerView.xmlID atIndex:_tagCount];
			} else {
				[_objectList insertObject:@"" atIndex:_tagCount];
			}

		}
    }
}

- (void)resetMaps {

	for (int i = 0; i < _mapList.count; i++) {
        CPMapView *mapView = [_mapList objectAtIndex:i];
		[mapView resetLayout:[UIApplication sharedApplication].statusBarOrientation];
    }

	for (int i = 0; i < _mapControllerList.count; i++) {
        CPMapControllerView *mapControllerView = [_mapControllerList objectAtIndex:i];
		[mapControllerView resetLayout];
    }
	
}

- (void)addLayers {
	
	for (SMXMLElement *layer in [_page childrenNamed:@"layer"]) {
		
		_tagCount++;
		
		CPLayerView *layerView = [[CPLayerView alloc] initWithXML:layer contentPath:_contentPath pageView:self];
		
		[layerView setTag:_tagCount];

		[self addSubview:layerView];

		[_layerList addObject:(id)layerView];

		if (layerView.xmlID) {
			[_objectList insertObject:layerView.xmlID atIndex:_tagCount];
		} else {
			[_objectList insertObject:@"" atIndex:_tagCount];
		}
    }
}

- (void)resetLayers {

    for (int i = 0; i < _layerList.count; i++) {
        CPLayerView *layerView = [_layerList objectAtIndex:i];
		[layerView resetLayout:[UIApplication sharedApplication].statusBarOrientation];
    }
    
}

- (void)addWebs {
	
	for (SMXMLElement *web in [_page childrenNamed:@"weblayer"]) {
		
		_tagCount++;
		
		CPWebView *webView = [[CPWebView alloc] initWithXML:web contentPath:_contentPath pageView:self];
		
		[webView setTag:_tagCount];
		
		[self addSubview:webView];
		
		[_webList addObject:(id)webView];
		
		if (webView.xmlID) {
			[_objectList insertObject:webView.xmlID atIndex:_tagCount];
		} else {
			[_objectList insertObject:@"" atIndex:_tagCount];
		}
    }
}

- (void)resetWebs {
	
    for (int i = 0; i < _webList.count; i++) {
        CPWebView *webView = [_webList objectAtIndex:i];
		[webView resetLayout:[UIApplication sharedApplication].statusBarOrientation];
    }
    
}

- (void)addOpenGL {
	
	for (SMXMLElement *opengl in [_page childrenNamed:@"opengl"]) {
		
		_tagCount++;
		
		CPOpenGLView *openGLView = [[CPOpenGLView alloc] initWithXML:opengl contentPath:_contentPath pageView:self];
		
		[openGLView setTag:_tagCount];
		
		DLog(@"/////// ADD OPEN GL");
		
		[self addSubview:openGLView];
		
		[_openGLList addObject:(id)openGLView];
		
		if (openGLView.xmlID) {
			[_objectList insertObject:openGLView.xmlID atIndex:_tagCount];
		} else {
			[_objectList insertObject:@"" atIndex:_tagCount];
		}
    }
}

- (void)resetOpenGL {
	
	for (int i = 0; i < _openGLList.count; i++) {
        CPOpenGLView *openGLView = [_openGLList objectAtIndex:i];
		[openGLView resetLayout:[UIApplication sharedApplication].statusBarOrientation];
    }
    
}

- (void)setMustRender:(BOOL)mustRender {
	_mustRender = mustRender;
}

- (void)setCurrentPage:(BOOL)currentPage {
	_currentPage = currentPage;
}

- (void)moviePlaybackDidFinish:(id)sender {
    
}

- (id)getObjectByID:(NSString *)objID {
	return (id)[self viewWithTag:[_objectList indexOfObject:objID]];
}

- (void)dealloc {
    // dealloc
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
