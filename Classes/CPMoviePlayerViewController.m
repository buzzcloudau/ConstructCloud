//
//  CPMoviePlayerViewxController.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPMoviePlayerViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation CPMoviePlayerViewController

@synthesize hasPortrait = _hasPortrait;
@synthesize hasLandscape = _hasLandscape;
@synthesize landscapeIsPortrait = _landscapeIsPortrait;
@synthesize xmlID = _xmlID;
@synthesize xmlPacket = _xmlPacket;
@synthesize movieView = _movieView;
@synthesize borderRadius = _borderRadius;
@synthesize borderWidth = _borderWidth;
@synthesize borderColor = _borderColor;
@synthesize borderImage = _borderImage;
@synthesize mustRender = _mustRender;
@synthesize contentPath = _contentPath;


-(id)initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath {

	_contentPath = contentPath;
	_xmlPacket = xmlData;

	NSString *tmpBG   = @"";
	NSInteger tmpWidth  = 0;
	NSInteger tmpHeight = 0;
	NSInteger tmpLeft   = 0;
	NSInteger tmpTop    = 0;
	NSString *tmpPlay   = @"FALSE";
	NSString *tmpID     = [_xmlPacket attributeNamed:@"id"];
	
	SMXMLElement *tmpSrcL = [_xmlPacket childNamed:@"lsrc"];
	SMXMLElement *tmpSrcP = [_xmlPacket childNamed:@"psrc"];
	
	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		
		tmpBG		= [tmpSrcL valueWithPath:@"file"];
		tmpWidth    = [[tmpSrcL valueWithPath:@"width"] intValue];
		tmpHeight   = [[tmpSrcL valueWithPath:@"height"] integerValue];
		tmpLeft     = [[tmpSrcL valueWithPath:@"left"] intValue];
		tmpTop      = [[tmpSrcL valueWithPath:@"top"] integerValue];
		tmpPlay     = [tmpSrcL valueWithPath:@"autoplay"];
		
	} else if (!UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		
		tmpBG		= [tmpSrcP valueWithPath:@"file"];
		tmpWidth    = [[tmpSrcP valueWithPath:@"width"] intValue];
		tmpHeight   = [[tmpSrcP valueWithPath:@"height"] integerValue];
		tmpLeft     = [[tmpSrcP valueWithPath:@"left"] intValue];
		tmpTop      = [[tmpSrcP valueWithPath:@"top"] integerValue];
		tmpPlay     = [tmpSrcP valueWithPath:@"autoplay"];
		
	}

	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",_contentPath,tmpBG]];
	
	self = [super initWithContentURL:url];
	
	// Movie has started playing
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(moviePlaybackDidStart:object:) 
												 name:MPMoviePlayerPlaybackStateDidChangeNotification 
											   object:self];
	
	// Movie has finished playing
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(moviePlaybackDidFinish:) 
												 name:MPMoviePlayerPlaybackDidFinishNotification 
											   object:self];
	
	[self.moviePlayer setAllowsAirPlay:FALSE];
	[self.moviePlayer setControlStyle:MPMovieControlStyleNone];
	
	[self setFrame:CGRectMake(tmpLeft,tmpTop,tmpWidth,tmpHeight)];

	[self.view setBackgroundColor:[UIColor clearColor]];
	[self.view.layer setBackgroundColor:[UIColor clearColor].CGColor];

	NSLog(@"self.view.frame %u %u %u %u",tmpLeft,tmpTop,tmpWidth,tmpHeight);
	
	_xmlID = tmpID;
	_hasLandscape = ![[tmpSrcL valueWithPath:@"image"] isEqualToString:@""] ? TRUE : FALSE;
	_hasPortrait = ![[tmpSrcP valueWithPath:@"image"] isEqualToString:@""] ? TRUE : FALSE;
	_landscapeIsPortrait = [[tmpSrcL valueWithPath:@"image"] isEqualToString:[tmpSrcP valueWithPath:@"image"]] ? TRUE : FALSE;
	

	if ([[tmpPlay uppercaseString] isEqualToString:@"TRUE"]) {
		[self setShouldAutoplay:TRUE];
	} else {
		[self setShouldAutoplay:FALSE];
	}

    return self;
}

-(id) resetLayout {

	NSString *tmpBG   = @"";
	NSInteger tmpWidth  = 0;
	NSInteger tmpHeight = 0;
	NSInteger tmpLeft   = 0;
	NSInteger tmpTop    = 0;
	NSString *tmpPlay   = @"FALSE";
	
	SMXMLElement *tmpSrcL = [_xmlPacket childNamed:@"lsrc"];
	SMXMLElement *tmpSrcP = [_xmlPacket childNamed:@"psrc"];
	
	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		
		tmpBG		= [tmpSrcL valueWithPath:@"file"];
		tmpWidth    = [[tmpSrcL valueWithPath:@"width"] intValue];
		tmpHeight   = [[tmpSrcL valueWithPath:@"height"] integerValue];
		tmpLeft     = [[tmpSrcL valueWithPath:@"left"] intValue];
		tmpTop      = [[tmpSrcL valueWithPath:@"top"] integerValue];
		tmpPlay     = [tmpSrcL valueWithPath:@"autoplay"];
		
	} else if (!UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		
		tmpBG		= [tmpSrcP valueWithPath:@"file"];
		tmpWidth    = [[tmpSrcP valueWithPath:@"width"] intValue];
		tmpHeight   = [[tmpSrcP valueWithPath:@"height"] integerValue];
		tmpLeft     = [[tmpSrcP valueWithPath:@"left"] intValue];
		tmpTop      = [[tmpSrcP valueWithPath:@"top"] integerValue];
		tmpPlay     = [tmpSrcP valueWithPath:@"autoplay"];
		
	}
	
	// reset the video src
	if (!_landscapeIsPortrait && ![tmpBG isEqualToString:@""]) {
		[self setContentURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",_contentPath,tmpBG]]];
	}

	// reset the video position
	if (![tmpBG isEqualToString:@""]) {
		
		//// NSLog(@"Added video");
		
		self.view.frame = CGRectMake(tmpLeft,tmpTop,tmpWidth,tmpHeight);
		//[self addSubview:[se view]];
		
		if ([[tmpPlay uppercaseString] isEqualToString:@"TRUE"]) {
			[self setShouldAutoplay:TRUE];
		} else {
			[self setShouldAutoplay:FALSE];
		}

		UITapGestureRecognizer *sngTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopPlay:)];
		sngTap.numberOfTouchesRequired = 1;
		sngTap.numberOfTapsRequired = 1;
		[self.view addGestureRecognizer:sngTap];
	}

	return self;
}

-(void)stopPlay:(UITapGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
		if([self.moviePlayer playbackState] == 1) {
			[self.moviePlayer pause];
		} else {
			[self.moviePlayer play];
		}
    }
}

- (void) preRotate:(UIInterfaceOrientation)toInterfaceOrientation {
	
}

-(void) setAllowsAirPlay:(BOOL)allowsAirPlay {
    [self.moviePlayer setAllowsAirPlay:allowsAirPlay];
}

-(void) setContentURL:(NSURL *)contentURL {
    [self.moviePlayer setContentURL:contentURL];
}

-(void) setAlpha:(CGFloat)alpha {
    // [super setAlpha:alpha];
}

-(void) setMustRender:(BOOL)mustRender {
	_mustRender = mustRender;
}

-(BOOL) mustRender {
	return _mustRender;
}

- (float) borderRadius {
	return _borderRadius;
}

- (float) borderWidth {
	return _borderWidth;
}

- (NSString *) borderColor {
	return _borderColor;
}

- (NSString *) borderImage {
	return _borderImage;
}

- (void) removeFromSuperview {
	[self.view removeFromSuperview];
}

- (void) setShouldAutoplay:(BOOL)shouldAutoplay {
	[self.moviePlayer setShouldAutoplay:shouldAutoplay];
}

- (BOOL) shouldAutoplay {
	return [self.moviePlayer shouldAutoplay];
}

- (void) prepareToPlay {
	[self.moviePlayer prepareToPlay];
}

-(void) setFrame:(CGRect)frame {
    [self.movieView.view setFrame:frame];
}

/*
-(void) setBounds:(CGRect)bounds {
    super.bounds = bounds;
}
*/

- (void)moviePlaybackDidStart:(id)sender object:(id)object {
    
    /*
	 MPMoviePlaybackState playbackState = [object playbackState];
	 
	 switch (playbackState) {
	 case MPMoviePlaybackStatePlaying :
	 //// NSLog(@"MPMoviePlaybackStatePlaying");
	 //[sender stopAnimating];
	 break;
	 
	 case MPMoviePlaybackStateStopped :
	 //// NSLog(@"MPMoviePlaybackStateStopped");
	 break;
	 
	 case MPMoviePlaybackStateInterrupted :
	 //[sender startAnimating];
	 //// NSLog(@"MPMoviePlaybackStateInterrupted");
	 break;
	 }
	 */
}

- (void)moviePlaybackDidFinish:(id)sender {
	
}

@end