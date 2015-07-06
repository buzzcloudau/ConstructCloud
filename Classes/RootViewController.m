//
//  RootViewController.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <NewsstandKit/NewsstandKit.h>
#import "RootViewController.h"
#import "ViewControllerForMagazine.h"
#import "AppDelegate.h"
#import "SSZipArchive.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "defs.h"
#import <Foundation/NSData.h>
#import "Reachability.h"
#import "Issue.h"

@implementation RootViewController

@synthesize viewControllerForMagazine;
@synthesize appDelegate         = _appDelegate;
@synthesize mainScrollView		= _mainScrollView;
@synthesize issuesList			= _issuesList;
@synthesize viewList			= _viewList;
@synthesize currIndex			= _currIndex;
@synthesize loadCompleted		= _loadCompleted;
@synthesize loadWaitTime		= _loadWaitTime;
@synthesize hud					= _hud;
@synthesize settings			= _settings;
@synthesize interfaceSet		= _interfaceSet;
@synthesize statusCode			= _statusCode;
@synthesize dataManager			= _dataManager;
@synthesize subSheet			= _subSheet;
@synthesize storeController     = _storeController;


- (IBAction)updateApp:(UITapGestureRecognizer *)sender {
	UIAlertView *versionMsg = [[UIAlertView alloc] initWithTitle:@"Update Required"
														 message:[NSString stringWithFormat:@"Your version of %@ is out of date. Please update to the latest version to view this content.",_settings.publicationName]
														delegate:self
											   cancelButtonTitle:@"Ok"
											   otherButtonTitles:@"Update Now",nil];
	[versionMsg show];
}

- (IBAction)loadScrollViewControllerForMagazine:(UITapGestureRecognizer *)sender {

	UIView *theSuperview = self.view;
	CGPoint touchPointInSuperview = [sender locationInView:theSuperview];
	UIView *touchedView = [theSuperview hitTest:touchPointInSuperview withEvent:nil];

	@try {

		if([touchedView isKindOfClass:[UIButton class]]) {

			//dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
			// QUEUE CHANGE
			dispatch_async(dispatch_get_main_queue(), ^{

				[self showHUD];

				// QUEUE CHANGE
				dispatch_async(dispatch_get_main_queue(), ^{

					[[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
					[CATransaction flush];
					
					NKLibrary *nkLib		= [NKLibrary sharedLibrary];
					NSDictionary *objData	= [_issuesList objectAtIndex:(((touchedView.tag-2)/10) - 1)];
					NSString *issueUUID		= [objData objectForKey:@"UUID"];
					NSString *issueName		= [objData objectForKey:@"Name"];
					// NSString *issueURL	= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@",_baseURL,issueUUID,[objData objectForKey:@"Content"]]];
					NKIssue *nkIssue		= [nkLib issueWithName:issueUUID];

					[_settings setCurrentIssue:issueName];
					
					// QUEUE CHANGE
					dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
						
						if ([_settings internetActive]) {
							

							// TRACK THE LAUNCH
							id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
							[tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"uiLibrary"
																				   action:@"issueload"
																					label:[NSString stringWithFormat:@"/app/mag/%@/%@/load/",_settings.publication,_settings.currentIssue]
																					value:[NSNumber numberWithInt:1]] set:@"start" forKey:kGAISessionControl] build]];
							
							dispatch_async( dispatch_get_main_queue(), ^{
								[_hud show:FALSE];
							});
						}
					// QUEUE CHANGE
					});
					
					// NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[nkIssue.contentURL path] error:NULL];
					
					_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
					
					if(self.viewControllerForMagazine != nil) {
						self.viewControllerForMagazine = nil;
					}
					
					ViewControllerForMagazine *magazineView = [[ViewControllerForMagazine alloc] initWithNibName:@"ViewControllerForMagazine" bundle:nil];
					
					self.viewControllerForMagazine = magazineView;
					
					_appDelegate.magView = magazineView;
					_appDelegate.rootView = self;
					_appDelegate.magView.contentPath = [nkIssue.contentURL path];
					
					UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStyleBordered target:nil action:nil];
					self.navigationItem.backBarButtonItem = backButton;
					
					_currIndex = 0;
					
					[_appDelegate.navigationController setNavigationBarHidden:YES animated:NO];
					//[_rootAppDelegate.navigationController setToolbarHidden:YES animated:NO];
					[_appDelegate.navigationController.view setBackgroundColor:[UIColor clearColor]];
					
					[_appDelegate.navigationController pushViewController:self.viewControllerForMagazine animated:NO];
					
				// QUEUE CHANGE
				});
				
			});
		}
	} @catch (NSException *e) {

		UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:e.name
														  message:e.reason
														 delegate:self
												cancelButtonTitle:@"Ok."
												otherButtonTitles:nil];
		[errorMsg performSelector:@selector(show) withObject:nil afterDelay:1];

	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[self setRootPager:nil];
	[self setRootPager:nil];
	[self setMainScrollView:nil];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (([_settings.device isEqualToString:@"iPhone"] || [_settings.device isEqualToString:@"iPhone5"]) && interfaceOrientation == UIDeviceOrientationPortrait) {
		return NO;
	} else {
		return _settings.shouldAllowRotate;
	}
}

- (BOOL) shouldAutorotate
{
    if ([_settings.device isEqualToString:@"iPhone"] || [_settings.device isEqualToString:@"iPhone5"]) {
		return NO;
	} else {
		return _settings.shouldAllowRotate;
	}
}

-(NSUInteger)supportedInterfaceOrientations
{
    if ([_settings.device isEqualToString:@"iPhone"] || [_settings.device isEqualToString:@"iPhone5"]) {
		return UIInterfaceOrientationMaskPortrait;
	} else {
		return _settings.supportedOrientation;
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration {

	if (_subSheet != nil) {
		[_subSheet dismissWithClickedButtonIndex:-1 animated:NO];
	}

	_currIndex = _mainScrollView.contentOffset.x / _mainScrollView.bounds.size.width;
	
}

- (void)loadPreviewImages:(UIInterfaceOrientation)interfaceOrientation {
	
	NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

	[_issuesList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		UIView *holderView = (UIImageView *)[_mainScrollView viewWithTag:(((idx + 1) * 10) + 6)];
		UIImageView * imageView = (UIImageView *)[_mainScrollView viewWithTag:((idx + 1) * 10)];
		[imageView setImage:nil];

		NSString *fooDir = [documentsPath stringByAppendingPathComponent:[(NSDictionary *)obj objectForKey:@"UUID"]];

		BOOL isDirectory;
		BOOL dirExists = [[NSFileManager defaultManager] fileExistsAtPath:fooDir isDirectory:&isDirectory]; // Why is the &isDirectory required?? Please let me know. #RR
		if (!dirExists) {
			[[NSFileManager defaultManager] createDirectoryAtPath:fooDir
									  withIntermediateDirectories:YES
													   attributes:nil
															error:nil];
		}

		if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {

			[holderView setFrame:CGRectMake(((([UIScreen mainScreen].bounds.size.height - holderHeight) / 2) + (idx * [UIScreen mainScreen].bounds.size.height)),15,holderHeight,holderWidth)];
			[imageView setFrame:CGRectMake(0,0,holderHeight,holderWidth)];
			[imageView setBounds:CGRectMake(0,0,holderHeight,holderWidth)];
			
			NSString* foofile = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@"
																			   , [(NSDictionary *)obj objectForKey:@"UUID"]
																			   , [(NSDictionary *)obj objectForKey:@"PreviewL"]]];

			BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];

			if (!fileExists) {
				
				imageView.image = [UIImage imageNamed:@"loader_1_l.png"];

				dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

					NSURL *imageURL = [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@/%@", _settings.baseContentURL
															 , [(NSDictionary *)obj objectForKey:@"UUID"]
															 , [(NSDictionary *)obj objectForKey:@"PreviewL"]
															 ]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

					UIImage *remoteImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
					NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(remoteImage)];

					NSError *error = nil;
					[data1 writeToFile:foofile options:NSDataWritingAtomic error:&error];

					dispatch_async( dispatch_get_main_queue(), ^{

						UIImage * toImage = [UIImage imageWithContentsOfFile:foofile];
						[UIView transitionWithView:self.view
										  duration:1.1
										   options:UIViewAnimationOptionTransitionCrossDissolve
										animations:^{ imageView.image = toImage; }
										completion:NULL];
					});
				});

			} else {

				imageView.image = [UIImage imageWithContentsOfFile:foofile];

			}
				
		} else {

			[holderView setFrame:CGRectMake(((([UIScreen mainScreen].bounds.size.width - holderWidth) / 2) + (idx * [UIScreen mainScreen].bounds.size.width)),holderOffsetTop,holderWidth,holderHeight)];
			[imageView setFrame:CGRectMake(0,0,holderWidth,holderHeight)];
			[imageView setBounds:CGRectMake(0,0,holderWidth,holderHeight)];
			
			NSString* foofile = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@"
																			   , [(NSDictionary *)obj objectForKey:@"UUID"]
																			   , [(NSDictionary *)obj objectForKey:@"PreviewP"]]];
			
			BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
			
			if (!fileExists) {
				
				imageView.image = [UIImage imageNamed:@"loader_1_p.png"];

				dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

					NSURL *imageURL = [NSURL URLWithString:[[NSString stringWithFormat:@"%@%@/%@", _settings.baseContentURL
															 , [(NSDictionary *)obj objectForKey:@"UUID"]
															 , [(NSDictionary *)obj objectForKey:@"PreviewP"]
															 ]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

					UIImage *remoteImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
					NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(remoteImage)];

					NSError *error = nil;
					[data1 writeToFile:foofile options:NSDataWritingAtomic error:&error];

					dispatch_async( dispatch_get_main_queue(), ^{

						UIImage * toImage = [UIImage imageWithContentsOfFile:foofile];
						[UIView transitionWithView:self.view
										  duration:1.1
										   options:UIViewAnimationOptionTransitionCrossDissolve
										animations:^{ imageView.image = toImage; }
										completion:NULL];
						
					});
				});

			} else {

				imageView.image = [UIImage imageWithContentsOfFile:foofile];

			}

		}

	}];
}

- (UIInterfaceOrientation)currentOrientation {
	
	UIInterfaceOrientation orientation;
	
	if ([_settings.device isEqualToString:@"iPhone"] || [_settings.device isEqualToString:@"iPhone5"]) {
		
		orientation = UIInterfaceOrientationPortrait;
		
	} else {
		
		orientation = [UIApplication sharedApplication].statusBarOrientation;
		
	}
	
	return orientation;
	
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	if (_loadCompleted) {
		[self loadPreviewImages:[self currentOrientation]];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
										 duration:(NSTimeInterval)duration {
	
	if ([_settings.device isEqualToString:@"iPhone"] || [_settings.device isEqualToString:@"iPhone5"]) {
		interfaceOrientation = [self currentOrientation];
	}
	
	_mainScrollView.contentSize = CGSizeMake([_issuesList count]*_mainScrollView.bounds.size.width,
											 _mainScrollView.bounds.size.height);
	
	
	[_issuesList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

		UIView *holderView = (UIView *)[_mainScrollView viewWithTag:(((idx + 1) * 10) + 6)];
		UIImageView * imageView = (UIImageView *)[_mainScrollView viewWithTag:((idx + 1) * 10)];
		UILabel * label = (UILabel *)[_mainScrollView viewWithTag:(((idx + 1) * 10) + 1)];
		UIButton *issueBtn =(UIButton *)[_mainScrollView viewWithTag:(((idx + 1) * 10) + 2)];
		
		if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
			
			[holderView setFrame:CGRectMake(((([UIScreen mainScreen].bounds.size.height - holderHeight) / 2) + (idx * [UIScreen mainScreen].bounds.size.height)),15,holderHeight,holderWidth)];
			[imageView setFrame:CGRectMake(0,0,holderHeight,holderWidth)];
			[imageView setBounds:CGRectMake(0,0,holderHeight,holderWidth)];
			[label setFrame:CGRectMake(holderView.frame.origin.x, holderView.frame.size.height + 10, holderHeight, 44)];
			[issueBtn setFrame:CGRectMake(((holderView.frame.origin.x + holderView.frame.size.width) - 120), (holderView.frame.size.height + 22), 120, 30)];
			
		} else {

			int labelOffset = 35;
			int buttonOffset = 47;
			
			if ([_settings.device isEqualToString:@"iPhone"]) {
				labelOffset = 0;
				buttonOffset = 6;
			} else if ([_settings.device isEqualToString:@"iPhone5"]) {
				labelOffset = 15;
				buttonOffset = 23;
			}
			
			[holderView setFrame:CGRectMake(((([UIScreen mainScreen].bounds.size.width - holderWidth) / 2) + (idx * [UIScreen mainScreen].bounds.size.width)),holderOffsetTop,holderWidth,holderHeight)];
			[imageView setFrame:CGRectMake(0,0,holderWidth,holderHeight)];
			[imageView setBounds:CGRectMake(0,0,holderWidth,holderHeight)];
			[label setFrame:CGRectMake(holderView.frame.origin.x, holderView.frame.size.height + labelOffset, holderHeight, 44)];
			[issueBtn setFrame:CGRectMake(((holderView.frame.origin.x + holderView.frame.size.width) - 120), (holderView.frame.size.height + buttonOffset), 120, 30)];
		}

		[self loadPreviewImages:interfaceOrientation];
		
		_mainScrollView.contentOffset = CGPointMake(_currIndex * _mainScrollView.bounds.size.width, 0);

	}];
	
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    _currIndex = _mainScrollView.contentOffset.x / _mainScrollView.bounds.size.width;
	[_rootPager setCurrentPage:_currIndex];
}

-(void) viewWillAppear:(BOOL)animated {

	if ([_settings.device isEqualToString:@"iPhone"] || [_settings.device isEqualToString:@"iPhone5"]) {
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
	}
	
	_settings = [CPSettingsData getInstance];

	DLog(@"view will appear");

	[_hud show:NO];

	_dataManager = [[CPData alloc] init];

	if (![_settings.device isEqualToString:@"iPhone"]) {

		[[UIApplication sharedApplication] setStatusBarHidden:NO];

		CGRect frame = self.navigationController.navigationBar.frame;
		frame.origin.y = 20.0;
		self.navigationController.navigationBar.frame = frame;

	} else {

		[[UIApplication sharedApplication] setStatusBarHidden:YES];

	}
	
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
								  UIViewAutoresizingFlexibleRightMargin |
								  UIViewAutoresizingFlexibleBottomMargin |
								  UIViewAutoresizingFlexibleLeftMargin);

	if (_interfaceSet != TRUE) {
		
		DLog(@"interface is not set.....");
		
		if ([_settings.device isEqualToString:@"iPhone5"]) { // iPhone 5

			holderHeight = 400;
			holderWidth = 300;
			holderOffsetTop = 20;
			//splashScrollHeight = 0;
			//splashScrollWidth = 0;
			//_settings.device = @"iPhone5";

		} else if ([_settings.device isEqualToString:@"iPad"]) { // iPad

			holderHeight = 800;
			holderWidth = 600;
			holderOffsetTop = 40;
			
			//splashScrollHeight = 0;
			//splashScrollWidth = 0;
			//_settings.device = @"iPad";

		} else { // iPhone 4

			holderHeight = 400;
			holderWidth = 300;
			holderOffsetTop = -1;
			//splashScrollHeight = 0;
			//splashScrollWidth = 0;
			//_settings.device = @"iPhone";

		}
		
		// check for internet connection
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
		
		[self setNetworkStatus];

		[_mainScrollView setPagingEnabled:TRUE];
		[_mainScrollView setBackgroundColor:[UIColor blackColor]];
		[_mainScrollView setScrollsToTop:TRUE];
		[_mainScrollView setDelegate:self];
		[_mainScrollView setShowsHorizontalScrollIndicator:NO];
		[_mainScrollView setShowsVerticalScrollIndicator:NO];
		[_mainScrollView setBounces:TRUE];
		[_mainScrollView setClipsToBounds:TRUE];
		
		[_mainScrollViewHolder setClipsToBounds:TRUE];
		[_mainScrollViewHolder setBackgroundColor:[UIColor blackColor]];
		
		_loadCompleted = TRUE;

		if ([_settings.device isEqualToString:@"iPhone"]) {

			[_rootPager setFrame:CGRectMake(_rootPager.frame.origin.x, 415, _rootPager.frame.size.width, (_rootPager.frame.size.height))];

		} else if ([_settings.device isEqualToString:@"iPhone5"]) {

			[_rootPager setFrame:CGRectMake(_rootPager.frame.origin.x, 480, _rootPager.frame.size.width, _rootPager.frame.size.height)];

		}

	} else {
		[self displayIssues];
	}

	[super viewWillAppear:animated];

}

-(void)setNetworkStatus {

	[_settings setInternetReachable:[Reachability reachabilityForInternetConnection]];
	[[_settings internetReachable] startNotifier];
	
	[_settings setIssueDomainReachable:[Reachability reachabilityWithHostName:[_settings issueDomain]]];
	[[_settings issueDomainReachable] startNotifier];
	
	[_settings setContentDomainReachable:[Reachability reachabilityWithHostName:[_settings contentDomain]]];
	[[_settings contentDomainReachable] startNotifier];
	
	[self checkNetworkStatus:nil];
}

-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [[_settings internetReachable] currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            DLog(@"The internet is down.");
            [_settings setInternetActive:FALSE];
			
            break;
        }
        case ReachableViaWiFi:
        {
            DLog(@"The internet is working via WIFI.");
            [_settings setInternetActive:TRUE];
			
            break;
        }
        case ReachableViaWWAN:
        {
            DLog(@"The internet is working via WWAN.");
            [_settings setInternetActive:TRUE];
			
            break;
        }
    }
	
    NetworkStatus issueDomainStatus = [[_settings issueDomainReachable] currentReachabilityStatus];
    switch (issueDomainStatus)
    {
        case NotReachable:
        {
            DLog(@"A gateway to the issue domain server is down.");
            [_settings setIssueDomainActive:FALSE];
			
            break;
        }
        case ReachableViaWiFi:
        {
            DLog(@"A gateway to the issue domain server is working via WIFI.");
            [_settings setIssueDomainActive:TRUE];
			
            break;
        }
        case ReachableViaWWAN:
        {
            DLog(@"A gateway to the issue domain server is working via WWAN.");
            [_settings setIssueDomainActive:TRUE];
			
            break;
        }
    }
	
	NetworkStatus contentDomainStatus = [[_settings contentDomainReachable] currentReachabilityStatus];
    switch (contentDomainStatus)
    {
        case NotReachable:
        {
            DLog(@"A gateway to the content domain server is down.");
            [_settings setContentDomainActive:FALSE];
			
            break;
        }
        case ReachableViaWiFi:
        {
            DLog(@"A gateway to the content domain server is working via WIFI.");
            [_settings setContentDomainActive:TRUE];
			
            break;
        }
        case ReachableViaWWAN:
        {
            DLog(@"A gateway to the content domain server is working via WWAN.");
            [_settings setContentDomainActive:TRUE];
			
            break;
        }
    }

	if (_settings.internetActive) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPInternetIsNowActive" object:self];
	}

}

-(void) setupIssueView:(NSString *)uuid
			  previewL:(NSString *)previewL
			  previewP:(NSString *)previewP
				 title:(NSString *)title
				 issue:(NKIssue *)issue
			 issueDate:(NSDate *)issueDate
				 index:(int)index
			   version:(float)version {
	
	if (_interfaceSet != TRUE) {

		UIView *holderView = nil;

		UIImageView *imageView = nil;

		// add the button
		UIButton *tmpBtn = [UIButton buttonWithType:UIButtonTypeCustom];

		// add the label
		UILabel *label = nil;
		
		if (UIInterfaceOrientationIsLandscape([self currentOrientation])) {
			
			holderView = [[UIView alloc] initWithFrame:CGRectMake(((([UIScreen mainScreen].bounds.size.height - holderHeight) / 2) + (index * [UIScreen mainScreen].bounds.size.height)),15,holderHeight,holderWidth)];
			imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,holderHeight,holderWidth)];
			[imageView setBounds:CGRectMake(0,0,holderHeight,holderWidth)];

			CGRect frame = CGRectMake(holderView.frame.origin.x, holderView.frame.size.height + 10, (holderHeight / 2), 44);
			label = [[UILabel alloc] initWithFrame:frame];

			[tmpBtn setFrame:CGRectMake(((holderView.frame.origin.x + holderView.frame.size.width) - 120), (holderView.frame.size.height + 22), 120, 30)];
			
		} else {

			int labelOffset = 35;
			int buttonOffset = 47;

			if ([_settings.device isEqualToString:@"iPhone"]) {
				labelOffset = -9;
				buttonOffset = -2;
			} else if ([_settings.device isEqualToString:@"iPhone5"]) {
				labelOffset = 15;
				buttonOffset = 23;
			}
			
			holderView = [[UIView alloc] initWithFrame:CGRectMake(((([UIScreen mainScreen].bounds.size.width - holderWidth) / 2) + (index * [UIScreen mainScreen].bounds.size.width)),holderOffsetTop,holderWidth,holderHeight)];
			imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,holderWidth,holderHeight)];
			[imageView setBounds:CGRectMake(0,0,holderWidth,holderHeight)];

			CGRect frame = CGRectMake(holderView.frame.origin.x, holderView.frame.size.height + labelOffset, (holderHeight / 2), 44);
			label = [[UILabel alloc] initWithFrame:frame];

			[tmpBtn setFrame:CGRectMake(((holderView.frame.origin.x + holderView.frame.size.width) - 120), (holderView.frame.size.height + buttonOffset), 120, 30)];
		}


		[[imageView layer] setBorderColor: [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3] CGColor]];
		[[imageView layer] setBorderWidth: 1.0];

		[imageView setClipsToBounds:true];
		
		// Remove it first if we have an old one
		UIImageView *oldImageView = (UIImageView *)[_mainScrollView viewWithTag:((index + 1) * 10)];
		if (oldImageView != nil) {
			[oldImageView removeFromSuperview];
			oldImageView = nil;
		}

		// Remove it first if we have an old one
		UIView *oldHolderView = (UIImageView *)[_mainScrollView viewWithTag:(((index + 1) * 10) + 6)];
		if (oldHolderView != nil) {
			[oldHolderView removeFromSuperview];
			oldHolderView = nil;
		}

		[holderView addSubview:imageView];
		[_mainScrollView addSubview:holderView];

		[holderView setTag:(((index + 1) * 10) + 6)];
		[imageView setTag:((index + 1) * 10)];

		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentLeft;
		label.textColor = [UIColor whiteColor];
		label.text = title;

		[label setShadowColor:[UIColor darkGrayColor]];
		[label setShadowOffset:CGSizeMake(0, -0.5)];
		
		// Remove it first if we have an old one
		UILabel *oldLabel = (UILabel *)[_mainScrollView viewWithTag:(((index + 1) * 10) + 1)];
		if (oldLabel != nil) {
			[oldLabel removeFromSuperview];
			oldLabel = nil;
		}
			
		[_mainScrollView addSubview:label];
		label.tag = (((index + 1) * 10) + 1);
		
		[tmpBtn setBackgroundImage:[UIImage imageNamed:@"button-120.png"] forState:UIControlStateNormal];
		[tmpBtn setBackgroundImage:[UIImage imageNamed:@"button-120-2.png"] forState:UIControlStateHighlighted];
		
		// Remove it first if we have an old one
		UIButton *oldTmpBtn = (UIButton *)[_mainScrollView viewWithTag:(((index + 1) * 10) + 2)];
		
		if (oldTmpBtn != nil) {
			[oldTmpBtn removeFromSuperview];
			oldTmpBtn = nil;
		}
		
		[_mainScrollView addSubview:tmpBtn];
		tmpBtn.tag = (((index + 1) * 10) + 2);

	}

	UIButton *issueBtn = (UIButton *)[_mainScrollView viewWithTag:(((index + 1) * 10) + 2)];

	NSMutableArray *aryGestures = [[NSMutableArray alloc] init];
	UITapGestureRecognizer *buttonTapRecogniser;
	
	[issueBtn setUserInteractionEnabled:TRUE];

	NSDictionary *objData	= [_issuesList objectAtIndex:index];
	Issue *thisIssue = [_dataManager getIssue:[objData objectForKey:@"UUID"]];

	if ([[thisIssue status] isEqualToString:@"installing"]) {

		[issueBtn setTitle:@"Please Wait" forState:UIControlStateDisabled];
		[issueBtn setTitle:@"Please Wait" forState:UIControlStateNormal];
		[issueBtn setEnabled:FALSE];

		[self showHUD];
		
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Installing"
														 message:[NSString stringWithFormat:@"%@ %@ is currently instaling.",_settings.publicationName,thisIssue.title]
														delegate:self
											   cancelButtonTitle:@"Ok"
											   otherButtonTitles:nil];

		[message show];

		[self installIssue:[objData objectForKey:@"UUID"] btnTag:issueBtn.tag];

	} else if (issue.status == NKIssueContentStatusAvailable && ![issue.date isEqualToDate:issueDate]) {
		[issueBtn setTitle:@"Update" forState:UIControlStateDisabled];
		[issueBtn setTitle:@"Update" forState:UIControlStateNormal];
		[issueBtn setEnabled:TRUE];

		if (version > _settings.appVersion) {
			buttonTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateApp:)];
		} else {
			buttonTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadMagazineIssue:)];
		}

	} else if (issue.status == NKIssueContentStatusDownloading) {

		[issueBtn setTitle:@"Downloading" forState:UIControlStateDisabled];
		[issueBtn setTitle:@"Downloading" forState:UIControlStateNormal];
		[issueBtn setEnabled:FALSE];
		buttonTapRecogniser = nil;

	} else if (issue.status == NKIssueContentStatusAvailable) {

		[issueBtn setTitle:@"View" forState:UIControlStateDisabled];
		[issueBtn setTitle:@"View" forState:UIControlStateNormal];
		[issueBtn setEnabled:TRUE];

		if (version > _settings.appVersion) {
			buttonTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateApp:)];
		} else {
			buttonTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadScrollViewControllerForMagazine:)];
		}


	} else {
		[issueBtn setTitle:@"Download" forState:UIControlStateDisabled];
		[issueBtn setTitle:@"Download" forState:UIControlStateNormal];
		[issueBtn setEnabled:TRUE];

		if (version > _settings.appVersion) {
			buttonTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateApp:)];
		} else {
			buttonTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadMagazineIssue:)];
		}
	}

	if (buttonTapRecogniser) {
		[aryGestures addObject:buttonTapRecogniser];
		issueBtn.gestureRecognizers = aryGestures;
	}

	[self loadPreviewImages:[self currentOrientation]];
}

-(void) downloadMagazineIssue:(UITapGestureRecognizer *)sender {

	UIView *theSuperview = self.view;
	CGPoint touchPointInSuperview = [sender locationInView:theSuperview];
	UIView *touchedView = [theSuperview hitTest:touchPointInSuperview withEvent:nil];

	UIAlertView *message = nil;
	
	if (![_settings internetActive]) {
		
		message = [[UIAlertView alloc] initWithTitle:@"Connection Error"
											 message:[NSString stringWithFormat:@"It appears you do not have an active internet connection. Please check your connection settings and try again."]
											delegate:self
								   cancelButtonTitle:@"Ok"
								   otherButtonTitles:nil];
		
		[message performSelector:@selector(show) withObject:nil afterDelay:1];
		
	} else if (![_settings contentDomainActive]) {
	
		message = [[UIAlertView alloc] initWithTitle:@"Connection Error"
											 message:[NSString stringWithFormat:@"Although you do have an active internet connection, you currently are unable to access the download server. This may be due to your connection settings, or the server being down for maintenance. Please check your connection settings and try again."]
											delegate:self
								   cancelButtonTitle:@"Ok"
								   otherButtonTitles:nil];
		
		[message performSelector:@selector(show) withObject:nil afterDelay:1];
		
	} else {
		
		[self showHUD];

		if([touchedView isKindOfClass:[UIButton class]])
		{
			
			NKLibrary *nkLib		= [NKLibrary sharedLibrary];
			NSDictionary *objData	= [_issuesList objectAtIndex:(((touchedView.tag-2)/10) - 1)];
			NSString *issueUUID		= [objData objectForKey:@"UUID"];

			NSString *content		= nil;

			if ([_settings.device isEqualToString:@"iPad"] && [objData objectForKey:@"ContentiPad"] != nil) {

				content				= [objData objectForKey:@"ContentiPad"];

			} else if ([_settings.device isEqualToString:@"iPhone"] && [objData objectForKey:@"ContentiPhone"] != nil) {

				content				= [objData objectForKey:@"ContentiPhone"];

			} else if ([_settings.device isEqualToString:@"iPhone5"] && [objData objectForKey:@"ContentiPhone5"] != nil) {

				content				= [objData objectForKey:@"ContentiPhone5"];

			} else {

				content				= [objData objectForKey:@"Content"];

			}

			NSString *date			= nil;

			if ([_settings.device isEqualToString:@"iPad"] && [objData objectForKey:@"DateiPad"] != nil) {

				date				= [objData objectForKey:@"DateiPad"];

			} else if ([_settings.device isEqualToString:@"iPhone"] && [objData objectForKey:@"DateiPhone"] != nil) {

				date				= [objData objectForKey:@"DateiPhone"];

			} else if ([_settings.device isEqualToString:@"iPhone5"] && [objData objectForKey:@"DateiPhone5"] != nil) {

				date				= [objData objectForKey:@"DateiPhone5"];

			} else {

				date				= [objData objectForKey:@"Date"];
				
			}

			NSURL *issueURL		= [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@?uuid=%@",_settings.baseContentURL,issueUUID,content,[[NSUUID UUID] UUIDString]]];

			NKIssue *nkIssue		= [nkLib issueWithName:issueUUID];
			
			[self setButtonTitleByTag:touchedView.tag newTitle:@"Downloading" isEnabled:FALSE];
			
			NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:(NSURL *)issueURL];
			NKAssetDownload *asset = [nkIssue addAssetWithRequest:downloadRequest];

			DLog(@"download content - url %@",issueURL);

			NSMutableDictionary *userValues = [[NSMutableDictionary alloc] init];

			[userValues setObject:[NSNumber numberWithInt:touchedView.tag]		forKey:@"btnIndex"];
			[userValues setObject:[NSString stringWithFormat:@"Please Wait"]	forKey:@"btnText"];
			[userValues setObject:content										forKey:@"content"];
			[userValues setObject:[objData objectForKey:@"PreviewL"]			forKey:@"previewL"];
			[userValues setObject:[objData objectForKey:@"PreviewP"]			forKey:@"previewP"];
			[userValues setObject:[objData objectForKey:@"Newsstand"]			forKey:@"newsStand"];
			[userValues setObject:[objData objectForKey:@"Name"]				forKey:@"name"];
			[userValues setObject:[objData objectForKey:@"UUID"]				forKey:@"uuid"];
			[userValues setObject:[objData objectForKey:@"Title"]				forKey:@"title"];
			[userValues setObject:date											forKey:@"date"];
			[userValues setObject:[objData objectForKey:@"Version"]				forKey:@"version"];

			[asset setUserInfo:[NSDictionary dictionaryWithObject:userValues forKey:@"issueData"]];

			[(AppDelegate*)[[UIApplication sharedApplication] delegate] startDownloadWithAsset:asset];

			Issue *thisIssue = [_dataManager getIssue:[objData objectForKey:@"UUID"]];

			[thisIssue setStatus:@"downloading"];
			[[_dataManager managedObjectContext] save:nil];

			// Reset the issue date (in case we updated)
			// [nkIssue setValue:[objData objectForKey:@"Date"] forKey:@"date"];
		}
	}
}

-(void) installIssue:(NSString *)uuid btnTag:(int)btnTag {

	Issue *thisIssue		= [_dataManager getIssue:uuid];
	NSURL *destinationURL	= [NSURL URLWithString:[thisIssue destination]];
	NSURL *contentURL		= [NSURL URLWithString:[thisIssue contentpath]];
	UIButton  *dlBtn		= (UIButton *)[_mainScrollView viewWithTag:btnTag];

	[self setButtonTitleByTag:btnTag newTitle:@"Installing" isEnabled:FALSE];

	[thisIssue setStatus:@"installing"];
	[[_dataManager managedObjectContext] save:nil];

	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

		NSError *error = nil;

		DLog(@"Unzipping file from : %@",[destinationURL path]);
		DLog(@"Unzipping file to : %@",[contentURL path]);

		[SSZipArchive unzipFileAtPath:[destinationURL path] toDestination:[contentURL path] overwrite:YES password:nil error:&error];

		if (error) {
			DLog(@"Unzip Error - retrying - %@",error);
			error = nil;

			[SSZipArchive unzipFileAtPath:[destinationURL path] toDestination:[contentURL path] overwrite:YES password:nil error:&error];

			if (error) {
				DLog(@"Unzip Failure :(");
				error = nil;
			}
			
		}

		[[NSFileManager defaultManager] removeItemAtURL:destinationURL error:&error];

		if (error) {
			DLog(@"Remove File Error - retrying - %@",error);
			error = nil;

			[[NSFileManager defaultManager] removeItemAtURL:destinationURL error:&error];

			if (error) {
				DLog(@"Remove Failure :(");
				error = nil;
			}

		}

		DLog(@"Deleting temp files;");

		[self deleteFile:[destinationURL path]];
		//[self deleteFile:[contentURL path]];

		for(UIGestureRecognizer *gesture in [dlBtn gestureRecognizers]) {
			if([gesture isKindOfClass:[UITapGestureRecognizer class]]){
				[dlBtn removeGestureRecognizer:gesture];
			}
		}

		NSMutableArray *aryGestures = [[NSMutableArray alloc] init];
		UITapGestureRecognizer *buttonTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadScrollViewControllerForMagazine:)];

		[aryGestures addObject:buttonTapRecogniser];
		dlBtn.gestureRecognizers = aryGestures;

		[thisIssue setDestination:@""];
		[thisIssue setStatus:@"installed"];
		[[_dataManager managedObjectContext] save:nil];
		
		dispatch_async(dispatch_get_main_queue(), ^{

			[self setButtonTitleByTag:btnTag newTitle:@"View" isEnabled:TRUE];

			[_hud show:NO];

		});
	});
}

-(void)connectionDidFinishDownloadingForMagazine:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    // copy file to destination URL
    NKAssetDownload *dnl = connection.newsstandAssetDownload;
    NKIssue *nkIssue = dnl.issue;

    NKAssetDownload *asset		= connection.newsstandAssetDownload;
	NSString *contentFile		= [[[asset userInfo] objectForKey:@"issueData"] objectForKey:@"content"];
	NSString *contentPath		= [[[nkIssue contentURL] path] stringByAppendingPathComponent:contentFile];

	DLog(@"File is being copied to %@",contentPath);
	
	NSInteger btnTag			= [[[[asset userInfo] objectForKey:@"issueData"] objectForKey:@"btnIndex"] integerValue];

	NSDictionary *objData	= [_issuesList objectAtIndex:(((btnTag-2)/10) - 1)];

	// UIView *tmpView = [_mainScrollView viewWithTag:(btnTag + 4)];

	Issue *thisIssue = [_dataManager getIssue:[[[asset userInfo] objectForKey:@"issueData"] objectForKey:@"uuid"]];
	[thisIssue setDestination:[NSString stringWithFormat:@"%@",destinationURL]];
	[thisIssue setContentpath:[NSString stringWithFormat:@"%@",nkIssue.contentURL]];

	[[_dataManager managedObjectContext] save:nil];

	[self installIssue:[thisIssue uuid] btnTag:btnTag];
	
	NSDate *date			= nil;

	if ([_settings.device isEqualToString:@"iPad"] && [objData objectForKey:@"DateiPad"] != nil) {

		date				= [objData objectForKey:@"DateiPad"];

	} else if ([_settings.device isEqualToString:@"iPhone"] && [objData objectForKey:@"DateiPhone"] != nil) {

		date				= [objData objectForKey:@"DateiPhone"];

	} else if ([_settings.device isEqualToString:@"iPhone5"] && [objData objectForKey:@"DateiPhone5"] != nil) {

		date				= [objData objectForKey:@"DateiPhone5"];

	} else {

		date				= [objData objectForKey:@"Date"];

	}

	// Reset the issue date (in case we updated)
	[connection.newsstandAssetDownload.issue setValue:[NSDate dateWithTimeInterval:0 sinceDate:date] forKey:@"date"];

	DLog(@"RootViewController connectionDidFinishDownloading");
}

-(void)updateProgressOfConnection:(NSURLConnection *)connection withTotalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {

	NKAssetDownload *asset		= connection.newsstandAssetDownload;
	NSInteger btnTag			= [[[[asset userInfo] objectForKey:@"issueData"] objectForKey:@"btnIndex"] integerValue];

	[self setButtonTitleByTag:btnTag newTitle:[NSString stringWithFormat:@"%i%%",(int)((1.f*totalBytesWritten/expectedTotalBytes)*100)] isEnabled:FALSE];
		
	// DLog(@"RootViewController updateProgressOfConnection: %f",1.f*totalBytesWritten/expectedTotalBytes);
}

-(void) deleteFile:(NSString *)foofile {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:foofile error:NULL];
}

- (void) viewDidAppear:(BOOL)animated {

	if ([_settings.device isEqualToString:@"iPhone"] || [_settings.device isEqualToString:@"iPhone5"]) {
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
	}
	
	[self setLoadCompleted:TRUE];
	[self loadIssues];
	
	_currIndex = _mainScrollView.contentOffset.x / _mainScrollView.bounds.size.width;
	[_rootPager setCurrentPage:_currIndex];
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	
    if([title isEqualToString:@"Retry"])
    {
		[self setNetworkStatus];
		[self performSelector:@selector(showLoading) withObject:nil afterDelay:1];
    }

	if([title isEqualToString:@"Update Now"])
    {

		NSURL *appLink = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@&mt=8",_settings.appID]];
		[[UIApplication sharedApplication] openURL:appLink];
		
    }
}

- (void) showLoading {

	[self showHUD];

	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		DLog(@"showLoading loadIssues");
		[self loadIssues];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[_hud show:NO];
			DLog(@"showLoading 2 loadIssues");
			[self loadIssues];
		});
	});
}

-(void) viewDidLoad {

	DLog(@"view did load");
	
	if ([_settings.device isEqualToString:@"iPhone"] || [_settings.device isEqualToString:@"iPhone5"]) {
		
		 [self presentViewController:[UIViewController new] animated:NO completion:^{ [self dismissViewControllerAnimated:NO completion:nil]; }];
		
	}

	[[[self navigationController] navigationBar] setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
	
	if (_interfaceSet != TRUE) {

//		dispatch_async(dispatch_get_main_queue(), ^{
//			
//			[self showHUD:self.view];
//			
//			dispatch_async(dispatch_get_main_queue(), ^{
//				DLog(@"viewDidLoad loadIssues");
//				[self loadIssues];
//
//			});
//
//		});
		
	} else {
		DLog(@"viewDidLoad displayIssues");
		[self displayIssues];
	}

}

-(void) displayIssues {

	[_hud show:NO];

	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	[[UIApplication sharedApplication] cancelAllLocalNotifications];

	NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString* foofile = [documentsPath stringByAppendingPathComponent:@"issues.plist"];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
	
	if (!fileExists && (![_settings internetActive] || ![_settings issueDomainActive])) {

		if (_loadWaitTime == 8) {


			[self showHUD];

			_loadWaitTime = 20;

			[self performSelector:@selector(showLoading) withObject:nil afterDelay:8];

		} else {

			UIAlertView *message = nil;
			
			if (![_settings internetActive]) {
				message = [[UIAlertView alloc] initWithTitle:@"Connection Error"
													 message:[NSString stringWithFormat:@"It appears you do not have an active internet connection. Please check your connection settings and try again."]
													delegate:self
										   cancelButtonTitle:@"Retry"
										   otherButtonTitles:nil];
			} else {
				message = [[UIAlertView alloc] initWithTitle:@"Connection Error"
													 message:[NSString stringWithFormat:@"Although you do have an active internet connection, you currently are unable to access the download server. This may be due to your connection settings, or the server being down for maintenance. Please check your connection settings and try again."]
													delegate:self
										   cancelButtonTitle:@"Retry"
										   otherButtonTitles:nil];
			}
			
			//[message show];
			[message performSelector:@selector(show) withObject:nil afterDelay:1];

		}

	} else {

		if (!fileExists && _issuesList == NULL && _statusCode != 200) {

			UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Connection Error"
															  message:[NSString stringWithFormat:@"Unable to load issues list from device or server. Please check your internet connection and try again."]
															 delegate:self
													cancelButtonTitle:@"Retry"
													otherButtonTitles:nil];

			//[message show];
			[message performSelector:@selector(show) withObject:nil afterDelay:1];

		} else {

			NKLibrary *nkLib = [NKLibrary sharedLibrary];

			NSDictionary *issuesDict = [[NSDictionary alloc] initWithContentsOfFile:foofile];

			_issuesList = [[NSMutableArray alloc] initWithArray:[issuesDict objectForKey:@"issues"]];

			// [[MKStoreManager sharedManager] removeAllKeychainData];

			[self setInterfaceSet:FALSE];
			
			_mainScrollView.contentSize = CGSizeMake([_issuesList count]*_mainScrollView.frame.size.width, _mainScrollView.frame.size.height);
			
			[_issuesList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				
				NSString *name = [(NSDictionary *)obj objectForKey:@"UUID"];
				NKIssue *tmpIssue = [nkLib issueWithName:name];

				NSString *content		= nil;

				if ([_settings.device isEqualToString:@"iPad"] && [obj objectForKey:@"ContentiPad"] != nil) {

					content				= [obj objectForKey:@"ContentiPad"];

				} else if ([_settings.device isEqualToString:@"iPhone"] && [obj objectForKey:@"ContentiPhone"] != nil) {

					content				= [obj objectForKey:@"ContentiPhone"];

				} else if ([_settings.device isEqualToString:@"iPhone5"] && [obj objectForKey:@"ContentiPhone5"] != nil) {

					content				= [obj objectForKey:@"ContentiPhone5"];

				} else {

					content				= [obj objectForKey:@"Content"];
					
				}

				NSDate *date			= nil;

				if ([_settings.device isEqualToString:@"iPad"] && [obj objectForKey:@"DateiPad"] != nil) {

					date				= [obj objectForKey:@"DateiPad"];

				} else if ([_settings.device isEqualToString:@"iPhone"] && [obj objectForKey:@"DateiPhone"] != nil) {

					date				= [obj objectForKey:@"DateiPhone"];

				} else if ([_settings.device isEqualToString:@"iPhone5"] && [obj objectForKey:@"DateiPhone5"] != nil) {

					date				= [obj objectForKey:@"DateiPhone5"];

				} else {

					date				= [obj objectForKey:@"Date"];
					
				}
				
				if(!tmpIssue) {

					tmpIssue = [nkLib addIssueWithName:name date:date];
					
					if (idx == 0) {
						NSURL *newstandURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://%@/%@/%@/%@?uuid=%@",_settings.contentDomain,_settings.publication,name,[(NSDictionary *)obj objectForKey:@"Newsstand"],[[NSUUID UUID] UUIDString]]];

						UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:newstandURL]];
						[[UIApplication sharedApplication] setNewsstandIconImage:img];
						[[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
					}
				}

				Issue *thisIssue = [_dataManager getIssue:[obj objectForKey:@"UUID"]];

				[thisIssue setContent:content];
				[thisIssue setPreviewl:[obj objectForKey:@"PreviewL"]];
				[thisIssue setPreviewp:[obj objectForKey:@"PreviewP"]];
				[thisIssue setNewsstand:[obj objectForKey:@"Newsstand"]];
				[thisIssue setName:[obj objectForKey:@"Name"]];
				[thisIssue setTitle:[obj objectForKey:@"Title"]];
				[thisIssue setDate:date];
				[thisIssue setVersion:[obj objectForKey:@"Version"]];
				[[_dataManager managedObjectContext] save:nil];

				[self setupIssueView:[(NSDictionary *)obj objectForKey:@"UUID"]
							previewL:[(NSDictionary *)obj objectForKey:@"PreviewL"]
							previewP:[(NSDictionary *)obj objectForKey:@"PreviewP"]
							   title:[(NSDictionary *)obj objectForKey:@"Title"]
							   issue:tmpIssue
						   issueDate:date
							   index:idx
							 version:[[(NSDictionary *)obj objectForKey:@"Version"] floatValue]];

			}];
			
			[self setInterfaceSet:TRUE];

			CGRect frame = CGRectMake(0, 0, 400, 44);
			UILabel *label = [[UILabel alloc] initWithFrame:frame];
			label.backgroundColor = [UIColor clearColor];
			label.textAlignment = NSTextAlignmentCenter;
			label.textColor = [UIColor whiteColor];
			label.text = _settings.publicationName;

			// emboss in the same way as the native title

			[label setShadowColor:[UIColor darkGrayColor]];
			[label setShadowOffset:CGSizeMake(0, -0.5)];
			self.navigationItem.titleView = label;

			[_rootPager setNumberOfPages:[_issuesList count]];
			[_rootPager setCurrentPage:0];
			[_rootPager setHidesForSinglePage:NO];
			[_rootPager setHidden:NO];

			if ([_settings.device isEqualToString:@"iPhone"]) {
				[_rootPager setUserInteractionEnabled:NO];
			}

		}
	}
}

-(void) loadIssues {
	
	if (_settings == nil) {
		_settings = [CPSettingsData getInstance];
	}

	_statusCode = 0;

	if (!_loadWaitTime) {
		_loadWaitTime = 8;
	} else {
		_loadWaitTime = 20;
	}
	
	// DO we have an internet connection, and can we reach the issue server??

	if (![_settings internetReachable] || ![_settings issueDomainActive]) {
		[self setNetworkStatus];
	}
	
	if ([_settings internetReachable] && [_settings issueDomainActive]) {
	
		// Replace With NSConnection / didReceiveAuthenticationChallenge:
		// For secure login

		NSString *query		= [NSString stringWithFormat:@"%@issues.plist?uuid=%@", _settings.baseIssueURL, [[NSUUID UUID] UUIDString]];
		NSURL *issuesURL	= [NSURL URLWithString:[query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

		DLog(@"download issues list from url: %@",query);
		DLog(@"download issues list from url: %@",issuesURL);
		
		[self showHUD];

		NSError *error = nil;
		NSData *data = [NSData dataWithContentsOfURL:issuesURL options:NSDataReadingUncached error:&error];
		
		NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString* tempFile = [documentsPath stringByAppendingPathComponent:@"temp-issues.plist"];
		NSString* foofile = [documentsPath stringByAppendingPathComponent:@"issues.plist"];
		
		[data writeToFile:tempFile atomically:TRUE];

		if (data) {

			if ([[NSFileManager defaultManager] fileExistsAtPath:foofile]) {
				
				[[NSFileManager defaultManager] removeItemAtPath:foofile error:&error];
				
				if (error) {
					DLog(@"ERROR(2) >>>> %@",error);
					error = nil;
				}
				
			}
			
			[[NSFileManager defaultManager] moveItemAtPath:tempFile toPath:foofile error:&error];
			
			if (error) {
				DLog(@"ERROR (3) >>>> %@",error);
			}

		}

		[self displayIssues];
		
	} else {

		[self displayIssues];

		if (_loadWaitTime == 8) {
			[self setNetworkStatus]; // check again for the second pass through.
									 //[self showLoading];
			[self showHUD];
			[self performSelector:@selector(loadIssues) withObject:nil afterDelay:4];
		} else {
			DLog(@"-----------> No connection or no server - skipping downloads");
		}
	}

}

- (IBAction)actionSubscribe:(id)sender {

	[_hud show:YES];

	DLog(@"checking subscription");
    
    DLog(@"_storeController : %@",_storeController);
    
    if (_storeController == nil) {
        _storeController = [[CPStoreController alloc] initWithProductList:[[NSDictionary alloc] init] mainScrollView:_mainScrollView];
    }
    
    [_storeController subscribe];
}

- (IBAction)actionRestore:(id)sender {

	DLog(@"restoring purchases");
    
    [_storeController restore];
	
}

- (void) setButtonTitleByTag:(NSInteger)btnTag newTitle:(NSString *)btnTitle isEnabled:(BOOL)isEnabled {

	UIButton *dlBtn				= (UIButton *)[_mainScrollView viewWithTag:btnTag];

	[dlBtn setTitle:btnTitle forState:UIControlStateDisabled];
	[dlBtn setTitle:btnTitle forState:UIControlStateNormal];
	[dlBtn setEnabled:isEnabled];

}

- (void) setSubSheet:(CPSubscribeActionSheet *)subSheet {
	_subSheet = subSheet;
}

-(void) showHUD {

	if (_hud == nil || _hud.activityView.alpha == 0.0f) {
		if (_mainScrollView.superview.superview) {
			_hud = [[CPHUD alloc] initWithView:_mainScrollView.superview.superview];
		} else if (_mainScrollView.superview) {
			_hud = [[CPHUD alloc] initWithView:_mainScrollView.superview];
		} else {
			_hud = [[CPHUD alloc] initWithView:_mainScrollView];
		}
	}
	
	[_hud show:YES];
	
}

@end

