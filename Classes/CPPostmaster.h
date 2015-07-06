//
//  CPDataPost.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@class AppDelegate;

@interface CPPostmaster : NSObject

- (id) init;

- (NSData *) getAndReceive:(NSURL *)uri
               packageData:(NSDictionary *)packageData
                  cachable:(BOOL)cachable;

- (NSDictionary *) getAndReceiveDictionary:(NSURL *)uri
                               packageData:(NSDictionary *)packageData
                                  cachable:(BOOL)cachable;

- (NSData *) postAndReceive:(NSURL *)uri
                packageData:(NSDictionary *)packageData
                   cachable:(BOOL)cachable;

- (NSDictionary *) postAndReceiveDictionary:(NSURL *)uri
                                packageData:(NSDictionary *)packageData
                                   cachable:(BOOL)cachable;

@property (nonatomic) NSCache *contentCache;
@property (nonatomic) AppDelegate *appDelegate;

@end
