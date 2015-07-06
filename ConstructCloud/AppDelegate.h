//
//  AppDelegate.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import "ViewControllerForMagazine.h"
#import "RootViewController.h"
#import "CPSettingsData.h"
#import <NewsstandKit/NewsstandKit.h>
#import "CPData.h"
#import "CPGenericConnection.h"
#import "CPSubscribeActionSheet.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, NSURLConnectionDownloadDelegate, NSURLConnectionDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
    CPData *dataManager;
    CPGenericConnection *genericConnection;
    UITabBarController *mainWindowTabBar;
    
}

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet UINavigationController *navigationController;
@property (nonatomic) ViewControllerForMagazine *magView;
@property (nonatomic) RootViewController *rootView;
@property (nonatomic) CPSettingsData *settings;
@property (nonatomic) CPData *dataManager;
@property (nonatomic) CPGenericConnection *genericConnection;
@property (nonatomic) CPSubscribeActionSheet *subActionSheet;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *subBarBtn;
@property (weak, nonatomic) IBOutlet UINavigationController *mainWindowTabBar;

@property (nonatomic) NSCache *contentCache;

- (IBAction)subBarBtnClick:(id)sender event:(UIEvent*)event;
- (void)startDownloadWithAsset:(NKAssetDownload *)asset;



@end

