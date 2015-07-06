//
//  Issues.h
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


@interface Issue : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * newsstand;
@property (nonatomic, retain) NSString * previewl;
@property (nonatomic, retain) NSString * previewp;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * contentpath;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSString * destination;
@property (nonatomic, retain) NSString * status;

@end
