//
//  CPData.h
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
#import "Issue.h"

@interface CPData : NSObject {

	NSMutableArray *appArray;
	
	NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSString *persistentStorePath;
	
}

@property (nonatomic, retain) NSMutableArray *appArray;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSString *persistentStorePath;

-(id) init;
-(NSString *) getAppUUID;
-(Issue *) getIssue:(NSString *)issueUUID;

@end