//
//  RootViewController.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//


#import <UIKit/UIKit.h>
#import "CPHUD.h"
#import "CPSettingsData.h"
#import "CPToolBar.h"
#import <StoreKit/StoreKit.h>
#import "CPData.h"
#import "CPSubscribeActionSheet.h"
#import "CPStoreController.h"

@class ViewControllerForMagazine;
@class AppDelegate;
@class Reachability;

@interface RootViewController : UIViewController <UIScrollViewDelegate> {
	ViewControllerForMagazine *viewControllerForMagazine;
	AppDelegate *appDelegate;
	CPData *dataManager;

	int	holderWidth;
	int holderHeight;
	int holderOffsetTop;
	int holderOffsetLeft;

}

@property (nonatomic) CPData *dataManager;

@property (nonatomic) ViewControllerForMagazine *viewControllerForMagazine;
@property (nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) IBOutlet UIView *mainScrollViewHolder;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *rootPager;

@property (nonatomic) NSMutableArray *issuesList;
@property (nonatomic) NSMutableArray *viewList;

@property (nonatomic) int currIndex;
@property (nonatomic) BOOL loadCompleted;
@property (nonatomic) int loadWaitTime;

@property (nonatomic) CPHUD *hud;
@property (nonatomic) CPSettingsData *settings;

@property (nonatomic) BOOL interfaceSet;

@property (nonatomic) int statusCode;

@property (nonatomic) CPSubscribeActionSheet *subSheet;
@property (nonatomic) CPStoreController *storeController;

-(void) checkNetworkStatus:(NSNotification *)notice;

-(void)connectionDidFinishDownloadingForMagazine:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL;
-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes;
-(void)loadIssues;
-(void)setSubSheet:(CPSubscribeActionSheet *)subSheet;

- (IBAction)actionSubscribe:(id)sender;
- (IBAction)actionRestore:(id)sender;


@end