//
//  AppDelegate.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <NewsstandKit/NewsstandKit.h>
#import "AppDelegate.h"
#import "CPMagazinePageView.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "defs.h"
#import "CPData.h"

@implementation AppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize magView;
@synthesize rootView;
@synthesize settings = _settings;
@synthesize dataManager = _dataManager;
@synthesize genericConnection = _genericConnection;
@synthesize subActionSheet = _subActionSheet;
@synthesize mainWindowTabBar = _mainWindowTabBar;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //sleep(3);
    
    _settings = [CPSettingsData getInstance];
    _dataManager = [[CPData alloc] init];
    _genericConnection = [CPGenericConnection alloc];
    _contentCache = [[NSCache alloc] init];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    // Override point for customization after application launch.
    
    // Add the navigation controller's view to the window and display.
    [window setAutoresizesSubviews:YES];
    //[window addSubview:navigationController.view];
    [window setRootViewController:navigationController];
    [window makeKeyAndVisible];
    
    NKLibrary *nkLib = [NKLibrary sharedLibrary];
    
    //self.rootView.rootAppDelegate = self;
    
    for(NKAssetDownload *asset in [nkLib downloadingAssets]) {
        [asset downloadWithDelegate:self];
    }
    
    [_settings setUUID:[_dataManager getAppUUID]];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Optional: automatically track uncaught exceptions with Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [[GAI sharedInstance].logger setLogLevel:_settings.analyticsLoggingLevel];
    
    // Create tracker instance.
    DLog(@"!!!!!!!! _settings.kAnalyticsAccountId : %@",_settings.kAnalyticsAccountId);
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:[NSString stringWithFormat:@"%@",_settings.kAnalyticsAccountId]];
    [tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"uiApp"
                                                           action:@"applaunch"
                                                            label:[NSString stringWithFormat:@"/app/mag/%@/launch",[_settings publication]]
                                                            value:[NSNumber numberWithInt:1]] set:@"start" forKey:kGAISessionControl] build]];
    
    return TRUE;
}

-(void)showSplashScreen:(id)sender {
    
    // Fade out the splash screen
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    UIImageView *splash = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-Portrait.png"]];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:splash];
    
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        
        DLog(@"UIInterfaceOrientationLandscapeRight");
        
        [splash setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
        
        [splash setFrame:CGRectMake(0, 0, 1024, 768)];
        [splash setBounds:CGRectMake(0, 0, 1024, 768)];
        [splash setCenter:CGPointMake(384, 512)];
        
        splash.transform = CGAffineTransformMakeRotation(M_PI * 0.50);
        
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        
        DLog(@"UIInterfaceOrientationLandscapeLeft");
        
        [splash setImage:[UIImage imageNamed:@"Default-Landscape.png"]];
        
        [splash setFrame:CGRectMake(0, 0, 1024, 768)];
        [splash setBounds:CGRectMake(0, 0, 1024, 768)];
        [splash setCenter:CGPointMake(384, 512)];
        
        splash.transform = CGAffineTransformMakeRotation(M_PI * -0.50);
        
    } else if (orientation == UIDeviceOrientationPortrait) {
        
        DLog(@"UIInterfaceOrientationPortrait");
        
        [splash setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
        
        [splash setFrame:CGRectMake(0, 0, 768, 1024)];
        [splash setBounds:CGRectMake(0, 0, 768, 1024)];
        
    } else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        
        DLog(@"UIInterfaceOrientationPortraitUpsideDown");
        
        [splash setImage:[UIImage imageNamed:@"Default-Portrait.png"]];
        
        [splash setFrame:CGRectMake(0, 0, 768, 1024)];
        [splash setBounds:CGRectMake(0, 0, 768, 1024)];
        
        splash.transform = CGAffineTransformMakeRotation(M_PI * 1.00);
    }
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         splash.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [splash removeFromSuperview];
                     }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // You can send here, for example, an asynchronous HTTP request to your web-server to store this deviceToken remotely.
    DLog(@"Did register for remote notifications: %@", deviceToken);
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , ^(void) {
        
        // Remove the spaces from the APNS Token
        
        NSString *theString = [NSString stringWithFormat:@"%@",deviceToken];
        NSString *tokenString = @"";
        
        NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
        NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
        
        NSArray *parts = [theString componentsSeparatedByCharactersInSet:whitespaces];
        NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
        NSString *tmpStr = [filteredArray componentsJoinedByString:@""];
        
        // Remove the first and last characters
        
        if ( [tmpStr length] > 0 )
            tokenString = [tmpStr substringWithRange:NSMakeRange(1,[tmpStr length] - 2)];
        
        // Create The URL
        
        _settings.apnsRegistration = [NSString stringWithFormat:@"%@?register_apns&apns_id=%@&app_id=%@&device_id=%@",_settings.registerURL,tokenString,_settings.publication,_settings.UUID];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sendAPNSRegistration)
                                                     name:@"CPInternetIsNowActive"
                                                   object:nil];
        
        // Back to the main queue
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
        });
        
    });
    
}

- (void) sendAPNSRegistration {
    
    if (_settings.internetActive && ![_settings.apnsRegistration isEqualToString:@""]) {
        
        DLog(@" --- Sending Registration");
        
        NSURL *registerURL = [[NSURL alloc] initWithString:_settings.apnsRegistration];
        
        // Send the request
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:registerURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
        
        [request setHTTPMethod: @"GET"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [request setHTTPBody:nil];
        
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:_genericConnection];
        
        [theConnection start];
        
        DLog(@"registerURL - %@",registerURL);
        
        _settings.apnsRegistration = @"";
        
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DLog(@"Fail to register for remote notifications: %@", error);
}

-(void)startDownloadWithAsset:(NKAssetDownload *)asset {
    
    DLog(@"startDownloadWithAsset - starting");
    
    NSURLConnection *connection = [asset downloadWithDelegate:self];
    [connection self]; // hide the warning for unused 'conenction'
    
    DLog(@"startDownloadWithAsset - connection %@",connection);
    DLog(@"startDownloadWithAsset - connection %@",connection.currentRequest.URL);
    
}

-(void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    UIAlertView *message = nil;
    
    NSString *errorString = [NSString stringWithFormat:@"%@",error];
    NSString *errorCode = [errorString substringWithRange:NSMakeRange(([errorString length] - 4), 3)];
    
    DLog(@"Error Code %@",errorCode);
    
    if ([errorCode isEqualToString:@"404"]) {
        message = [[UIAlertView alloc] initWithTitle:@"Download Error"
                                             message:@"It appears the download is not currently available on the server. Plese try again later."
                                            delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
    } else {
        message = [[UIAlertView alloc] initWithTitle:@"Download Error"
                                             message:@"It appears that you have lost your internet connection. Please check your connection and try again."
                                            delegate:self
                                   cancelButtonTitle:@"Retry"
                                   otherButtonTitles:nil];
    }
    
    DLog(@"DOWNLOAD ERROR - %@",error);
    
    [message show];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"Retry %@",alertView);
    
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Retry"] || [title isEqualToString:@"OK"])
    {
        
        DLog(@"Retry");
        
        // NKLibrary *nkLib = [NKLibrary sharedLibrary];
        
        /*
         for(NKAssetDownload *asset in [nkLib downloadingAssets]) {
         [asset downloadWithDelegate:self];
         DLog(@"Retry %@",asset);
         }
         */
        
        RootViewController *tmpRootView = (RootViewController *)self.navigationController.topViewController;
        
        [tmpRootView loadIssues];
        
    } else {
        DLog(@"cancel");
    }
}

-(void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    
    DLog(@"connectionDidResumeDownloading - start");
    
    @try {
        [self updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    } @catch (NSException *e) {
        [connection start];
    }
}

-(void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    
    RootViewController *tmpRootView = (RootViewController *)self.navigationController.topViewController;
    
    if (tmpRootView != nil) {
        [tmpRootView connectionDidFinishDownloadingForMagazine:connection destinationURL:destinationURL];
    }
    
}

-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    
    RootViewController *tmpRootView = (RootViewController *)self.navigationController.topViewController;
    
    if (tmpRootView != nil) {
        [tmpRootView updateProgressOfConnection:connection withTotalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    
    [magView willResume];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    DLog(@"applicationDidBecomeActive");
    
    _settings = [CPSettingsData getInstance]; // because its not loading fast enough.
    
    if ([self.navigationController.viewControllers count] == 1) {
        RootViewController *tmpRootView = (RootViewController *)self.navigationController.topViewController;
        
        if (tmpRootView != nil && [[tmpRootView issuesList] count] > 0) {
            [tmpRootView setInterfaceSet:FALSE];
            [tmpRootView loadIssues];
        }
    }
    
    // TRACK THE LAUNCH
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"uiApp"
                                                           action:@"appactive"
                                                            label:[NSString stringWithFormat:@"/app/mag/%@/active",[_settings publication]]
                                                            value:[NSNumber numberWithInt:1]] set:@"start" forKey:kGAISessionControl] build]];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

- (IBAction)subBarBtnClick:(id)sender event:(UIEvent*)event {
    
    if (_subActionSheet == nil) {
        
        _subActionSheet = [[CPSubscribeActionSheet alloc] initWithNavController:self.navigationController];
        
        RootViewController *tmpRootView = (RootViewController *)self.navigationController.topViewController;
        
        [tmpRootView setSubSheet:_subActionSheet];
        
    }
    
    [_subActionSheet showSheet:event];
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return _settings.shouldAllowRotate;
}

- (BOOL) shouldAutorotate
{
    _settings = [CPSettingsData getInstance]; // because its not loading fast enough.
    
    return _settings.shouldAllowRotate;
}

-(NSUInteger)supportedInterfaceOrientations
{
    
    _settings = [CPSettingsData getInstance]; // because its not loading fast enough.
    
    return _settings.supportedOrientation;
}

@end

