//
//  CPMoviePlayerViewController.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <MediaPlayer/MediaPlayer.h>
#import "SMXMLDocument.h"

@interface CPMoviePlayerViewController : MPMoviePlayerViewController

- (id) initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath;
- (void) setAllowsAirPlay:(BOOL)allowsAirPlay;
- (void) setMustRender:(BOOL)mustRender;
- (void) setContentURL:(NSURL *)contentURL;
- (void) setAlpha:(CGFloat)alpha;
- (id) resetLayout;
- (void) preRotate:(UIInterfaceOrientation)toInterfaceOrientation;
- (float) borderRadius;
- (float) borderWidth;
- (NSString *) borderColor;
- (NSString *) borderImage;
- (void) removeFromSuperview;
- (void)setShouldAutoplay:(BOOL)shouldAutoplay;
- (BOOL) shouldAutoplay;
- (void)moviePlaybackDidStart:(id)sender object:(id)object;
- (void)moviePlaybackDidFinish:(id)sender;
- (void) prepareToPlay;

/*
-(void) setFrame:(CGRect)frame;
-(void) setBounds:(CGRect)bounds;
*/

@property (nonatomic) BOOL hasLandscape;
@property (nonatomic) BOOL hasPortrait;
@property (nonatomic) BOOL landscapeIsPortrait;
@property (nonatomic) BOOL mustRender;
@property (nonatomic) NSString *contentPath;
@property (nonatomic) NSString *xmlID;
@property (nonatomic) SMXMLElement *xmlPacket;
@property (nonatomic) MPMoviePlayerController *movieView;
@property (nonatomic) float borderRadius;
@property (nonatomic) float borderWidth;
@property (nonatomic) NSString *borderColor;
@property (nonatomic) NSString *borderImage;

@end
