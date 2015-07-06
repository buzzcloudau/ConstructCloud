//
//  CPSettingsData.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPSettingsData.h"
#import "defs.h"
#import "GAI.h"

@implementation CPSettingsData

static CPSettingsData *instance = nil;
static dispatch_once_t pred;

+(CPSettingsData *)getInstance
{
		dispatch_once(&pred, ^{
		
            instance							= [CPSettingsData new];
			instance.shouldAllowRotate			= YES;

			#ifdef TARGET_DEFAULT
				
				#ifdef DEBUG_MODE
				
				DLog(@"***************************************");
				DLog(@"*          DEBUG MODE DEFAULT         *");
				DLog(@"***************************************");
				
				instance.kAnalyticsAccountId		= @"UA-00000000-1";
				instance.kAnalyticsAccountId_master = @"UA-00000000-1";
				
				instance.issueDomain				= @"issues.constructcloud.net";
				instance.contentDomain				= @"content.constructcloud.net";

				instance.analyticsLoggingLevel		= kGAILogLevelError;
				
				#else
				
				instance.kAnalyticsAccountId		= @"UA-00000000-1";
				instance.kAnalyticsAccountId_master = @"UA-00000000-1";

				instance.issueDomain				= @"issues.constructcloud.net";
				instance.contentDomain				= @"content.constructcloud.net";
			
				instance.analyticsLoggingLevel		= kGAILogLevelNone;
				
				#endif
			
				instance.supportedOrientation		= UIInterfaceOrientationMaskAll;
				
				instance.publication				= @"net.constructcloud.buzzcloudau";
				instance.publicationName			= @"Buzz Cloud AU";
			
				instance.facebookURL				= @"https://www.facebook.com/BuzzCloudAU";
				instance.twitterURL					= @"https://twitter.com/BuzzCloudAU";
				instance.youtubeURL					= @"http://www.youtube.com";
			
				instance.subscribeID				= @"net.constructcloud.buzzcloudau.freesub";
				instance.appVersion					= 1.0;
				instance.appID						= @"";
			
			
			#endif
			
			instance.locale						= [NSLocale currentLocale];
			instance.autoLocale					= [NSLocale autoupdatingCurrentLocale];
			
			instance.countryCode				= [instance.locale objectForKey: NSLocaleCountryCode];
			instance.countryName				= [instance.locale displayNameForKey: NSLocaleCountryCode value: instance.countryCode];
			
			instance.autoCountryCode			= [instance.autoLocale objectForKey: NSLocaleCountryCode];
			instance.autoCountryName			= [instance.autoLocale displayNameForKey: NSLocaleCountryCode value: instance.autoCountryCode];
			
			instance.baseIssueURL				= [NSString stringWithFormat:@"http://%@/%@/", instance.issueDomain, instance.publication];
			instance.baseContentURL				= [NSString stringWithFormat:@"http://%@/%@/", instance.contentDomain, instance.publication];
			instance.currentIssue				= @"";

			instance.registerURL				= @"http://www.constructcloud.net/gateway/";
			instance.UUID						= @"";
			
			instance.internetReachable			= nil;
			instance.issueDomainReachable		= nil;
			instance.contentDomainReachable		= nil;
			instance.internetActive				= FALSE;
			instance.issueDomainActive			= FALSE;
			instance.contentDomainActive		= FALSE;

			instance.apnsRegistration			= @"";

			instance.isFullScreen				= NO;

			instance.device						= @"";

			if ([UIScreen mainScreen].bounds.size.height == 568) { // iPhone 5

				instance.device = @"iPhone5";

			} else if ([UIScreen mainScreen].bounds.size.height <= 1024) { // iPad

				instance.device = @"iPad";

			} else { // iPhone 4

				instance.device = @"iPhone";
				
			}
			
			instance.osVersion = [[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
			
			DLog(@"device %@",instance.device);
			DLog(@"country %@ - %@",instance.countryCode,instance.countryName);
			DLog(@"auto country %@ - %@",instance.autoCountryCode,instance.autoCountryName);
			
		});
	
    return instance;
}

@end