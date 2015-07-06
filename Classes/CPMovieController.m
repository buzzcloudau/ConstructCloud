//
//  ViewController.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPMovieController.h"
#import "defs.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@implementation CPMovieController

- (id)initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath
{
	
	self = [super init];
	
	_contentPath = contentPath;
	_xmlPacket = xmlData;

	_settings = [CPSettingsData getInstance];
	_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	_postmaster = [[CPPostmaster alloc] init];
	_contentCache = [_appDelegate contentCache];
	
	return self;
}

- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation {
	
	if (![_player.moviePlayer.view isHidden]) {
		_preRotatePosition = _player.moviePlayer.currentPlaybackTime;
		_preRotateState = _player.moviePlayer.playbackState;
	} else {
		_preRotatePosition = 0;
		_preRotateState = 0;
		[_player.moviePlayer stop];
	}

	if (!_landscapeIsPortrait) {
		[_player.view setHidden:TRUE];
	}
	
	[self resetLayout:toInterfaceOrientation];

	if (!_landscapeIsPortrait) {
		
		[_player.moviePlayer setContentURL:_positionFileURL];
		[_player.moviePlayer setMovieSourceType:_positionFileSourceType];
		[_player.moviePlayer setCurrentPlaybackTime:_preRotatePosition];
		
	}

	//[self.view setFrame:CGRectMake(_positionLeft, _positionTop, _positionWidth, _positionHeight)];
	//[_player.view setFrame:CGRectMake(0, 0, _positionWidth, _positionHeight)];

	if (_player.moviePlayer.playbackState == MPMoviePlaybackStateStopped) {
		[self.view bringSubviewToFront:_overlayView];
	}
}

- (void) postRotate {

	if (_initComplete) {
	
		if (!_landscapeIsPortrait || _controlAutoplay || _preRotatePosition != 0) {

			[self.view setHidden:FALSE];
			[_player.view setHidden:FALSE];

			[self performSelector:@selector(setPostRotateProperties:) withObject:nil afterDelay:0.01];

		} else {

			[self.view setHidden:FALSE];
			//[_player.view setHidden:TRUE];

		}
	}
}

- (void)setPostRotateProperties:(id)sender {

	if (!_player.moviePlayer.contentURL) {
		[self createPlayer];
	}

	if (_preRotatePosition != 0 || _controlAutoplay) {

		[self.view bringSubviewToFront:_player.view];
		[_player.moviePlayer setInitialPlaybackTime:_preRotatePosition];
		[_player.moviePlayer prepareToPlay];
		[_player.moviePlayer play];

		[_player.moviePlayer setInitialPlaybackTime:0];
	}

	[_player.moviePlayer setInitialPlaybackTime:0];

	_preRotateState = 0;
	_preRotatePosition = 0;

	if (!_positionOverlay) {
		if (_player.moviePlayer.playbackState == MPMoviePlaybackStateStopped) {
			[self.view bringSubviewToFront:_overlayView];
		}
	}

}

- (void)setNotifications {

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidEnd:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_player.moviePlayer];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(checkMovieStatus:)
													 name:MPMoviePlayerLoadStateDidChangeNotification
												   object:_player.moviePlayer];

	[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(checkMovieStatus:)
													 name:MPMoviePlayerNowPlayingMovieDidChangeNotification
												   object:_player.moviePlayer];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(checkMovieStatus:)
												 name:MPMoviePlayerPlaybackStateDidChangeNotification
											   object:_player.moviePlayer];

}

- (void) createPlayer {

	if (_initComplete) {

		_player = [[MPMoviePlayerViewController alloc] initWithContentURL:_positionFileURL];
		[_player.moviePlayer setMovieSourceType:_positionFileSourceType];
		
		// DEPRECIATED [_player.moviePlayer setUseApplicationAudioSession:FALSE];
		
		[_player.view setFrame:CGRectMake(0, 0, _positionWidth, _positionHeight)];

		if ([_controlController isEqualToString:@"full"]) {
			
			[_player.moviePlayer setControlStyle:MPMovieControlStyleDefault];
			
		} else if ([_controlController isEqualToString:@"mini"]) {
			
			[_player.moviePlayer setControlStyle:MPMovieControlStyleEmbedded];
			
		} else {
			
			[_player.moviePlayer setControlStyle:MPMovieControlStyleNone];
			
		}
		
		[_player.moviePlayer.view setBackgroundColor:[UIColor clearColor]];
		[_player.view setBackgroundColor:[UIColor clearColor]];
		[_player.view.layer setBackgroundColor:[UIColor clearColor].CGColor];
		
		[_player.view setAutoresizingMask:UIViewAutoresizingNone];
		
		[self.view setAutoresizingMask:UIViewAutoresizingNone];
		
		[self setNotifications];
		
		[_player.moviePlayer setShouldAutoplay:_controlAutoplay];
				
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	if (_initComplete != TRUE) {

		_preRotatePosition = 0;
		_preRotateState = 0;
		
		[self setInitComplete:FALSE];

		if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
			[self resetLayout:UIInterfaceOrientationLandscapeLeft];
		} else {
			[self resetLayout:UIInterfaceOrientationPortrait];
		}
		
		[self postRotate];

		NSString *srcFile		= [[[_xmlPacket childNamed:@"src"] childNamed:@"position"] valueWithPath:@"file"];
		NSString *psrcFile		= [[[_xmlPacket childNamed:@"psrc"] childNamed:@"position"] valueWithPath:@"file"];
		NSString *lsrcFile		= [[[_xmlPacket childNamed:@"lsrc"] childNamed:@"position"] valueWithPath:@"file"];
		
		_hasPortrait			= srcFile || psrcFile ? TRUE : FALSE;
		_hasLandscape			= srcFile || lsrcFile ? TRUE : FALSE;
		_landscapeIsPortrait	= (srcFile || [psrcFile isEqualToString:lsrcFile]) ? TRUE : FALSE;
		_xmlID					= [_xmlPacket attributeNamed:@"id"];


		[self.view setFrame:CGRectMake(_positionLeft, _positionTop, _positionWidth, _positionHeight)];
		[self.view setClipsToBounds:TRUE];

		[self.view setBackgroundColor:[UIColor clearColor]];

		_overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _positionWidth, _positionHeight)];
		[_overlayView setBackgroundColor:[UIColor clearColor]];
		
		if (!_controlAutoplay && ([_controlController isEqualToString:@"none"] || _positionOverlay)) {
			
			UITapGestureRecognizer *sngTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchPlay:)];
			sngTap.numberOfTouchesRequired = 1;
			sngTap.numberOfTapsRequired = 1;
			
			[_overlayView addGestureRecognizer:sngTap];
			
		}

		[_player.view setHidden:TRUE];
		[self.view addSubview:_overlayView];
		
		if (_positionOverlay) {
			if (!_positionOverlayAbsolute) {
					
				UIImage *overImg = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",_contentPath,_positionOverlay]];
				[_overlayView setBackgroundColor:[UIColor colorWithPatternImage:overImg]];
			
			} else {
				
				dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
				
				dispatch_async(queue, ^{
					
					DLog(@"_positionOverlay VIDEO OVERLAY : %@",_positionOverlay);
					
					NSData *imageData = [_postmaster getAndReceive:[NSURL URLWithString:_positionOverlay] packageData:nil cachable:YES];
					
					UIImage *tmpImg = [UIImage imageWithData:imageData];
					
					dispatch_sync(dispatch_get_main_queue(), ^{
						
						[_overlayView setBackgroundColor:[UIColor colorWithPatternImage:tmpImg]];
						
					});
					
				});
			}
		}

		if (!_controlAutoplay && ![_controlController isEqualToString:@"none"]) {
			[self.view bringSubviewToFront:_overlayView];
		}

		[self setInitComplete:TRUE];
		
		if (_controlAutoplay) {
			[self createPlayer];
		}


	}
}

- (void)checkMovieStatus:(id)sender {
	
	if (_initComplete) {
		
		if (!_player) {
			[self createPlayer];
		}
		
		if (!_player.view.superview || _player.view.superview != self.view) {
			[self.view addSubview:_player.view];
		} else {
			[self.view bringSubviewToFront:_player.view];
		}

		if (_player.moviePlayer.playbackState == 2 || _player.moviePlayer.playbackState == 1) {

			[self.view bringSubviewToFront:_player.view];

			[self performSelector:@selector(showView) withObject:nil afterDelay:0];
			
			if (_player.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
				// TRACK THE LAUNCH
				id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
				[tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"uiVideo"
																	   action:@"videostatechange"
																		label:[NSString stringWithFormat:@"/app/mag/%@/%@/playvideo/%@",_settings.publication,_settings.currentIssue,_positionFile]
																		value:[NSNumber numberWithInt:1]] set:@"start" forKey:kGAISessionControl] build]];

			}


			if (_player.moviePlayer.playbackState == MPMoviePlaybackStatePaused) {
				// TRACK THE LAUNCH
				id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
				[tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"uiVideo"
																	   action:@"videostatechange"
																		label:[NSString stringWithFormat:@"/app/mag/%@/%@/pausevideo/%@",_settings.publication,_settings.currentIssue,_positionFile]
																		value:[NSNumber numberWithInt:1]] set:@"start" forKey:kGAISessionControl] build]];

			}

			if (_player.moviePlayer.playbackState == MPMoviePlaybackStateStopped) {
				// TRACK THE LAUNCH
				id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
				[tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"uiVideo"
																	   action:@"videostatechange"
																		label:[NSString stringWithFormat:@"/app/mag/%@/%@/stopvideo/%@",_settings.publication,_settings.currentIssue,_positionFile]
																		value:[NSNumber numberWithInt:1]] set:@"start" forKey:kGAISessionControl] build]];
			}


		} else {

			[_player.view setHidden:TRUE];

			[self.view bringSubviewToFront:_overlayView];
		}

		if (_player.moviePlayer.loadState == 3 && _player.moviePlayer.playbackState == 1) {
			_preRotatePosition = 0;
			_preRotateState = 0;
		}

		if ([_controlController isEqualToString:@"none"]) {
			[self.view bringSubviewToFront:_overlayView];
		}

	}
}

-(void) showView {
	[_player.view setHidden:FALSE];
}

-(void) setInitComplete:(BOOL)initComplete {
	_initComplete = initComplete;
}

- (void)moviePlayBackDidEnd:(id)sender {

	[_player.moviePlayer setInitialPlaybackTime:0];

	if (_controlAutoloop) {
		[self play];
	} else {
		[self.view bringSubviewToFront:_overlayView];
	}

}

- (void)setMustRender:(BOOL)mustRender {
	_mustRender = mustRender;
}

-(void)touchPlay:(UITapGestureRecognizer*)recognizer {
	
	if (_initComplete) {
		
		if (!_player) {
			[self createPlayer];
		}
		
		if (recognizer.state == UIGestureRecognizerStateEnded)
		{
			[self.view sendSubviewToBack:_overlayView];
			
			[_player.moviePlayer setContentURL:_player.moviePlayer.contentURL];
			[_player.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
				
			[_player.moviePlayer setInitialPlaybackTime:0];

			[_player.moviePlayer prepareToPlay];
			[_player.moviePlayer play];
		}
	}
}

-(void)stopPlay:(UITapGestureRecognizer*)recognizer {
	
	if (_initComplete) {

		if (recognizer.state == UIGestureRecognizerStateEnded)
		{
			if([_player.moviePlayer playbackState] == 1) {
				[_player.moviePlayer stop];
			} else {
				
				[_player.moviePlayer setContentURL:_player.moviePlayer.contentURL];
				[_player.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
				
				[_player.moviePlayer setInitialPlaybackTime:0];

				[_player.moviePlayer prepareToPlay];
				[_player.moviePlayer play];
			}
		}
	}
}

-(void)resetLayout:(UIInterfaceOrientation)toInterfaceOrientation {

	SMXMLElement *defSrc = [_xmlPacket childNamed:@"src"];
	SMXMLElement *defPos = [defSrc childNamed:@"position"];
	SMXMLElement *defCon = [defSrc childNamed:@"control"];

	SMXMLElement *altSrc = nil;
	
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		altSrc = [_xmlPacket childNamed:@"lsrc"];
	} else {
		altSrc = [_xmlPacket childNamed:@"psrc"];
	}
	
	// POSITION
	
	SMXMLElement *altPos = [altSrc childNamed:@"position"];
	
	_positionWidth			 = [[altPos valueWithPath:@"width"] intValue];
	_positionHeight			 = [[altPos valueWithPath:@"height"] intValue];
	_positionLeft			 = [[altPos valueWithPath:@"left"] intValue];
	_positionTop			 = [[altPos valueWithPath:@"top"] intValue];
	_positionFile			 = [altPos valueWithPath:@"file"];
	_positionFileAbsolute	 = [[[altPos childNamed:@"file"] attributeNamed:@"absolute"] boolValue];
	_positionOverlay		 = [altPos valueWithPath:@"overlay"];
	_positionOverlayAbsolute = [[[altPos childNamed:@"overlay"] attributeNamed:@"absolute"] boolValue];
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
	
	if (!_positionFile) {
		_positionFile  = [defPos valueWithPath:@"file"];
	}
	
	if (!_positionFileAbsolute) {
		_positionFileAbsolute  = [[[defPos childNamed:@"file"] attributeNamed:@"absolute"] boolValue];
	}
	
	if (!_positionFileAbsolute) {
		_positionFileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",_contentPath,_positionFile]];
		_positionFileSourceType = MPMovieSourceTypeFile;
	} else {
		_positionFileURL = [NSURL URLWithString:_positionFile];
		_positionFileSourceType = MPMovieSourceTypeStreaming;
	}
	
	if (!_positionOverlay) {
		_positionOverlay  = [defPos valueWithPath:@"overlay"];
	}
	
	if (!_positionOverlayAbsolute) {
		_positionOverlayAbsolute  = [[[defPos childNamed:@"overlay"] attributeNamed:@"absolute"] boolValue];
	}
	
	if (!_positionVisible) {
		_positionVisible  = [[defPos valueWithPath:@"visible"] boolValue];
	}
	
	if (!_positionVisibleAnimate) {
		_positionVisibleAnimate  = [[[defPos childNamed:@"visible"] attributeNamed:@"animate"] boolValue];
	}

	// POSITION
	
	SMXMLElement *altCon = [altSrc childNamed:@"control"];
	
	_controlAutoplay		 = [[altCon valueWithPath:@"autoplay"] boolValue];
	_controlAutoloop		 = [[altCon valueWithPath:@"autoloop"] boolValue];
	_controlEndOnFirstFrame	 = [[altCon valueWithPath:@"endonfirstframe"] boolValue];
	_controlController		 = [altCon valueWithPath:@"controller"];

	if (!_controlAutoplay) {
		_controlAutoplay  = [[defCon valueWithPath:@"autoplay"] boolValue];
	}

	if (!_controlAutoloop) {
		_controlAutoloop  = [[defCon valueWithPath:@"autoloop"] boolValue];
	}

	if (!_controlEndOnFirstFrame) {
		_controlEndOnFirstFrame  = [[defCon valueWithPath:@"endonfirstframe"] boolValue];
	}
	
	if (!_controlController) {
		_controlController  = [defCon valueWithPath:@"controller"];
	}
	
	if (!_controlController) {
		_controlController  = @"none";
	}
	
//	// BORDER
//	
//	SMXMLElement *altBdr = [altSrc childNamed:@"border"];
//	
//	_borderRadius		= [[altBdr valueWithPath:@"radius"] floatValue];
//	_borderWidth		= [[altBdr valueWithPath:@"width"] floatValue];
//	_borderImage		= [altBdr valueWithPath:@"image"];
//	
//	if (!_borderRadius) {
//		_borderRadius	= [[defBdr valueWithPath:@"radius"] floatValue];
//	}
//	
//	if (!_borderWidth) {
//		_borderWidth	= [[defBdr valueWithPath:@"width"] floatValue];
//	}
//	
//	if (!_borderImage) {
//		_borderImage	= [defBdr valueWithPath:@"image"];
//	}
//	
//	// BORDER COLOR
//	
//	NSString *tmpBorderColor	= [altBdr valueWithPath:@"color"];
//	
//	if (!tmpBorderColor) {
//		tmpBorderColor	= [defBdr valueWithPath:@"color"];
//	}
//	
//	SEL borderColorSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",tmpBorderColor]);
//	_borderColor = [UIColor clearColor];
//	
//	if ([UIColor respondsToSelector:borderColorSelector]) {
//		_borderColor = [UIColor performSelector:borderColorSelector];
//	}
//	
//	// BACKGROUND
//	
//	SMXMLElement *altBck = [altSrc childNamed:@"background"];
//	
//	_backgroundOpacity	= [[altBck valueWithPath:@"opacity"] floatValue];
//	_backgroundImage	= [altBck valueWithPath:@"image"];
//	_backgroundPosition	= [altBck valueWithPath:@"position"];
//	
//	if (!_backgroundOpacity) {
//		_backgroundOpacity	= [[defBck valueWithPath:@"opacity"] floatValue];
//	}
//	
//	if (!_backgroundImage) {
//		_backgroundImage	= [defBck valueWithPath:@"image"];
//	}
//	
//	if (!_backgroundPosition) {
//		_backgroundPosition	= [defBck valueWithPath:@"position"];
//	}
//
//	// BACKGROUND COLOR
//	
//	NSString *tmpBackgroundColor	= [altPos valueWithPath:@"color"];
//	
//	if (!tmpBackgroundColor) {
//		tmpBackgroundColor	= [defPos valueWithPath:@"color"];
//	}
//	
//	SEL backgroundColorSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",tmpBackgroundColor]);
//	_backgroundColor = [UIColor clearColor];
//	
//	if ([UIColor respondsToSelector:backgroundColorSelector]) {
//		_backgroundColor = [UIColor performSelector:backgroundColorSelector];
//	}
//
//	// BACKGROUND COLOR
//	
//	NSString *tmpBackgroundColor	= [altBck valueWithPath:@"color"];
//	
//	if (!tmpBackgroundColor) {
//		tmpBackgroundColor	= [defBck valueWithPath:@"color"];
//	}
//	
//	SEL backgroundColorSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",tmpBackgroundColor]);
//	_backgroundColor = [UIColor clearColor];
//	
//	if ([UIColor respondsToSelector:backgroundColorSelector]) {
//		_backgroundColor = [UIColor performSelector:backgroundColorSelector];
//	}
//	
//	_backgroundColor = [_backgroundColor colorWithAlphaComponent:_backgroundOpacity];
//
//	
//	// ACTIONS
//	
//	SMXMLElement *altAct = [altSrc childNamed:@"actions"];
//	
//	_actionOnTap		= [altAct valueWithPath:@"ontap"];
//	
//	if (!_actionOnTap) {
//		_actionOnTap	= [defAct valueWithPath:@"ontap"];
//		_actionID		= [[defAct childNamed:@"ontap"] attributeNamed:@"id"];
//	} else {
//		_actionID		= [[altAct childNamed:@"ontap"] attributeNamed:@"id"];
//	}
//	
//	
//	// ANIMATIONS
//	
//	SMXMLElement *altAni = [altSrc childNamed:@"animation"];
//	
//	_animationDelay		= [[altAni valueWithPath:@"delay"] floatValue];
//	_animationDuration	= [[altAni valueWithPath:@"duration"] floatValue];
//	
//	if (!_animationDelay) {
//		_animationDelay = [[defAni valueWithPath:@"delay"] floatValue];
//	}
//	
//	if (!_animationDuration) {
//		_animationDuration = [[defAni valueWithPath:@"duration"] floatValue];
//	}
//	
//	// SHADOW
//	
//	SMXMLElement *altShd = [altSrc childNamed:@"shadow"];
//	
//	_shadowRadius		= [[altShd valueWithPath:@"radius"] floatValue];
//	_shadowOffsetX		= [[altShd valueWithPath:@"offsetx"] floatValue];
//	_shadowOffsetY		= [[altShd valueWithPath:@"offsety"] floatValue];
//	_shadowOpacity		= [[altShd valueWithPath:@"opacity"] floatValue];
//	
//	if (!_shadowRadius) {
//		_shadowRadius	= [[defShd valueWithPath:@"radius"] floatValue];
//	}
//	
//	if (!_shadowOffsetX) {
//		_shadowOffsetX	= [[defShd valueWithPath:@"offsetx"] floatValue];
//	}
//	
//	if (!_shadowOffsetY) {
//		_shadowOffsetY	= [[defShd valueWithPath:@"offsety"] floatValue];
//	}
//	
//	if (!_shadowOpacity) {
//		_shadowOpacity	= [[defShd valueWithPath:@"opacity"] floatValue];
//	}
//	
//	// SHADOW COLOR
//	
//	NSString *tmpShadowColor	= [altShd valueWithPath:@"color"];
//	
//	if (!tmpShadowColor) {
//		tmpShadowColor	= [defShd valueWithPath:@"color"];
//	}
//	
//	SEL shadowColorSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",tmpShadowColor]);
//	_shadowColor = [UIColor clearColor];
//	
//	if ([UIColor respondsToSelector:shadowColorSelector]) {
//		_shadowColor = [UIColor performSelector:shadowColorSelector];
//	}

	// RUN SETUP
	
	[self.view setFrame:CGRectMake(_positionLeft, _positionTop, _positionWidth, _positionHeight)];
	
	[self.view setAutoresizesSubviews:FALSE];
	[self.view setAutoresizingMask:UIViewAutoresizingNone];
	
	if (_positionOverlay) {
		[_overlayView setFrame:CGRectMake(0, 0, _positionWidth, _positionHeight)];
		[_overlayView setAutoresizesSubviews:FALSE];
		[_overlayView setAutoresizingMask:UIViewAutoresizingNone];
	}

	//[self.view setBackgroundColor:_backgroundColor];
	
//	[self.layer setBorderWidth:_borderWidth];
//	[self.layer setCornerRadius:_borderRadius];
//	[self.layer setBorderColor:_borderColor.CGColor];
//	
//	if (_backgroundImage) {
//		UIImage *bgImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",_contentPath,_backgroundImage]];
//		[self setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
//	}
//	
//	if (![_borderImage isEqualToString:@""]) {
//		[self.layer setBorderColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:_borderImage]] CGColor]];
//	}
//	
//	if (_shadowOpacity) {
//		[self.layer setShadowColor:_shadowColor.CGColor];
//		[self.layer setShadowOffset:CGSizeMake(_shadowOffsetX, _shadowOffsetY)];
//		[self.layer setShadowOpacity:_shadowOpacity];
//		[self.layer setShadowRadius:_shadowRadius];
//		[self.layer setMasksToBounds:FALSE];
//	}
//
//	// PERFORM ANIMATIONS
//
//	if (!_positionVisible || (_positionVisible && _positionVisibleAnimate)) {
//		[self.view setAlpha:0.0];
//	}
//	
//	if (_animationDuration && _positionVisibleAnimate) {
//		[UIView setAnimationsEnabled:TRUE];
//		[UIView beginAnimations:nil context:nil];
//		[UIView setAnimationDelay:(NSTimeInterval)_animationDelay];
//		[UIView setAnimationDuration:(NSTimeInterval)_animationDuration];
//	}
//	
//	if (_positionVisible) {
//		[self.view setAlpha:1.0];
//	}
//	
//	if (_animationDuration && _positionVisible) {
//		[UIView commitAnimations];
//	}
}

-(BOOL)shouldAutoplay {
	return [_player.moviePlayer shouldAutoplay];
}

- (void)prepareToPlay {
	[_player.moviePlayer prepareToPlay];
}

-(void) pauseMovieInBackGround
{
	[[_player moviePlayer] pause];
	[_player.view removeFromSuperview];
}

-(void) resumeMovieInFrontGround
{
	[self.view addSubview:_player.view];
	[[_player moviePlayer] play];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) stop {
	[_player.moviePlayer stop];
}

- (void) playFromSelector:(id)sender {
	
	if (!_player.moviePlayer.contentURL) {
		[self createPlayer];
	}
	
	[self play];
}

- (void) play {
	[_player.moviePlayer play];
}

- (void) pause {
	[_player.moviePlayer pause];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//	} else {
//	    return YES;
//	}
//}

- (void) viewWillDisappear:(BOOL)animated {

	if(!_player.moviePlayer.fullscreen) {
		[super viewWillDisappear:animated];
	}

}

- (void) viewDidDisappear:(BOOL)animated {

	if(!_player.moviePlayer.fullscreen) {
		[super viewDidDisappear:animated];
	}

}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
