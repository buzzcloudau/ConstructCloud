//
//  ViewControllerForMagazine.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CoreAnimation.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SMXMLDocument.h"
#import "CPContentsView.h"
#import "CPWebNavigatorView.h"
#import "ExpandableNavigation.h"
#import "CPSettingsData.h"
#import "CPPageControl.h"

@class ExpandableNavigation;
@class CPContentsView;

@interface ViewControllerForMagazine : UIViewController <UIScrollViewDelegate , UIWebViewDelegate> {
	IBOutlet UIScrollView *scrollView;
    
    CGRect screenRect;
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat screenScale;
    UITapGestureRecognizer *tapGestureRecognizer;
    
    NSMutableArray *articlePages;

	int prevIndex;
	int currIndex;
	int nextIndex;

	UIButton* button1;
    UIButton* button2;
    UIButton* button3;
    UIButton* button4;
    UIButton* button5;
    UIButton* main;
    ExpandableNavigation* navigation;
    
}

// EXPANDABLE MENU

@property (nonatomic, retain) IBOutlet UIButton *button1;
@property (nonatomic, retain) IBOutlet UIButton *button2;
@property (nonatomic, retain) IBOutlet UIButton *button3;
@property (nonatomic, retain) IBOutlet UIButton *button4;
@property (nonatomic, retain) IBOutlet UIButton *button5;
@property (nonatomic, retain) IBOutlet UIButton *main;

@property (nonatomic) CPSettingsData *settings;

@property (retain) ExpandableNavigation* navigation;
@property (weak, nonatomic) IBOutlet UIView *ExpNavView;
@property (weak, nonatomic) IBOutlet UIButton *buttonSocial;



@property (nonatomic, retain) CPPageControl *articlePager;

// END EXPANDABLE

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray *articlePages;

@property (nonatomic) int prevIndex;
@property (nonatomic) int currIndex;
@property (nonatomic) int nextIndex;
@property (nonatomic) int currentOffset;
@property (nonatomic) int pageCount;

@property (nonatomic) NSString *docVersion;

@property (nonatomic) SMXMLDocument *xmlDoc;

@property (nonatomic) NSString *contentPath;

@property (nonatomic) BOOL disableRotations;

@property (nonatomic) CPContentsView *contentsView;
@property (nonatomic) CPWebNavigatorView *webNavView;

@property (nonatomic) UIView *contentsBGView;
@property (nonatomic) NSMutableArray *navigationPages;
@property (nonatomic) BOOL navAnimating;

@property (nonatomic) BOOL setupComplete;
@property (nonatomic) MPMoviePlayerController *player;

- (void)runSetupv1;
- (void)setViewSize;
- (void)alignSubviews;
- (void)willResume;
- (void)performContentsOverlayActionOpen;
- (void)performContentsOverlayActionClose;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

- (IBAction) touchMenuItem:(id)sender;
- (IBAction)socialButtonTouch:(id)sender forEvent:(UIEvent *)event;

@end
