//
//  ViewController.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <AVFoundation/AVFoundation.h>

#import "SMXMLDocument.h"
#import "CPSettingsData.h"
#import "CPPostmaster.h"
#import "AppDelegate.h"

@interface CPMovieController : UIViewController

- (id)initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath;
- (void)resetLayout:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation;
- (BOOL)shouldAutoplay;
- (void)prepareToPlay;
- (void)stop;
- (void)play;
- (void)pause;
- (void)postRotate;

@property (nonatomic) UIView *overlayView;
@property (nonatomic) MPMoviePlayerViewController *player;
@property (nonatomic) id pageView;

@property (nonatomic) BOOL initComplete;

@property (nonatomic) BOOL hasLandscape;
@property (nonatomic) BOOL hasPortrait;
@property (nonatomic) BOOL landscapeIsPortrait;
@property (nonatomic) BOOL mustRender;
@property (nonatomic) NSString *xmlID;
@property (nonatomic) SMXMLElement *xmlPacket;

@property (nonatomic) float positionLeft;
@property (nonatomic) float positionTop;
@property (nonatomic) float positionWidth;
@property (nonatomic) float positionHeight;
@property (nonatomic) BOOL positionVisible;
@property (nonatomic) BOOL positionVisibleAnimate;
@property (nonatomic) NSString *positionFile;
@property (nonatomic) NSURL *positionFileURL;
@property (nonatomic) BOOL positionFileAbsolute;
@property (nonatomic) NSString *positionOverlay;
@property (nonatomic) BOOL positionOverlayAbsolute;
@property (nonatomic) MPMovieSourceType positionFileSourceType;

@property (nonatomic) BOOL controlAutoplay;
@property (nonatomic) BOOL controlAutoloop;
@property (nonatomic) BOOL controlEndOnFirstFrame;
@property (nonatomic) NSString *controlController;

@property (nonatomic) float borderRadius;
@property (nonatomic) float borderWidth;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) NSString *borderImage;
@property (nonatomic) NSString *contentPath;

@property (nonatomic) NSString *actionOnTap;
@property (nonatomic) NSString *actionID;

@property (nonatomic) float animationDelay;
@property (nonatomic) float animationDuration;

@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) float backgroundOpacity;
@property (nonatomic) NSString *backgroundImage;
@property (nonatomic) NSString *backgroundPosition; //tile, centre, stretch

@property (nonatomic) UIColor *shadowColor;
@property (nonatomic) float shadowOffsetX;
@property (nonatomic) float shadowOffsetY;
@property (nonatomic) float shadowRadius;
@property (nonatomic) float shadowOpacity;

@property (nonatomic) int preRotateState;
@property (nonatomic) NSTimeInterval preRotatePosition;

@property (nonatomic) CPSettingsData *settings;

@property (nonatomic) AppDelegate *appDelegate;
@property (nonatomic) CPPostmaster *postmaster;
@property (nonatomic) NSCache *contentCache;

@end
