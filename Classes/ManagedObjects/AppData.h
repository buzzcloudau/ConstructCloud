//
//  AppData.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AppData : NSManagedObject

@property (nonatomic) int16_t recordid;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * location;

@end
