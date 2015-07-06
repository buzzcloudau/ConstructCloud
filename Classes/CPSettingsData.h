//
//  CPSettingsData.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "GAI.h"

@interface CPSettingsData : NSObject {

}

@property (nonatomic, retain) NSString *kAnalyticsAccountId;
@property (nonatomic, retain) NSString *kAnalyticsAccountId_master;
@property (nonatomic, retain) NSString *issueDomain;
@property (nonatomic, retain) NSString *contentDomain;
@property (nonatomic, retain) NSString *publication;
@property (nonatomic, retain) NSString *publicationName;
@property (nonatomic, retain) NSString *baseIssueURL;
@property (nonatomic, retain) NSString *baseContentURL;
@property (nonatomic, retain) NSString *facebookURL;
@property (nonatomic, retain) NSString *twitterURL;
@property (nonatomic, retain) NSString *youtubeURL;
@property (nonatomic, retain) NSString *currentIssue;
@property (nonatomic, retain) NSString *registerURL;
@property (nonatomic, retain) NSString *UUID;
@property (nonatomic, retain) NSString *device;
@property (nonatomic) int osVersion;

@property (nonatomic, retain) Reachability *internetReachable;
@property (nonatomic, retain) Reachability *issueDomainReachable;
@property (nonatomic, retain) Reachability *contentDomainReachable;

@property (nonatomic) BOOL internetActive;
@property (nonatomic) BOOL issueDomainActive;
@property (nonatomic) BOOL contentDomainActive;
@property (nonatomic) NSString *apnsRegistration;
@property (nonatomic, retain) NSString *subscribeID;
@property (nonatomic) float appVersion;
@property (nonatomic, retain) NSString *appID;
@property (nonatomic) BOOL isFullScreen;

@property (nonatomic) UIInterfaceOrientationMask supportedOrientation;
@property (nonatomic) BOOL shouldAllowRotate;

@property (nonatomic) NSLocale *locale;
@property (nonatomic) NSLocale *autoLocale;

@property (nonatomic) NSString *countryCode;
@property (nonatomic) NSString *countryName;

@property (nonatomic) NSString *autoCountryCode;
@property (nonatomic) NSString *autoCountryName;

@property (nonatomic) int analyticsLoggingLevel;

+(CPSettingsData*) getInstance;

@end