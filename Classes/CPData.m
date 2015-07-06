//
//  CPData.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPData.h"
#import "AppData.h"
#import "Issue.h"
#import "defs.h"

@implementation CPData

//@synthesize objectContext = _objectContext;
@synthesize appArray = _appArray;
//@synthesize storeCoordinator = _storeCoordinator;
//@synthesize store = _store;
//
//@synthesize managedObjectContext;
//@synthesize persistentStoreCoordinator;
//@synthesize persistentStore;

-(id) init {
	
	self = [super init];

	_appArray = [[NSMutableArray alloc] init];
//	_objectContext = [[NSManagedObjectContext alloc] init];
//
//	_storeCoordinator = [[NSPersistentStoreCoordinator alloc] init];
//	_store = [[NSPersistentStore alloc] initWithPersistentStoreCoordinator:_storeCoordinator configurationName:@"CPModel" URL:nil options:nil];
//
//	if (_storeCoordinator != nil) {
//        _objectContext = [[NSManagedObjectContext alloc] init];
//        [_objectContext setPersistentStoreCoordinator:_storeCoordinator];
//        [_objectContext setUndoManager:nil];
//    }

	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath:self.persistentStorePath]) {
//		NSError *error = nil;
//		BOOL oldStoreRemovalSuccess = [[NSFileManager defaultManager] removeItemAtPath:self.persistentStorePath error:&error];
//		NSAssert3(oldStoreRemovalSuccess, @"Unhandled error adding persistent store in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);

		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"CPModel" ofType:@"momd"];
		if (defaultStorePath) {
			[fileManager copyItemAtPath:defaultStorePath toPath:self.persistentStorePath error:NULL];
		}

		DLog(@"init - %@ - %d",defaultStorePath,[[NSFileManager defaultManager] fileExistsAtPath:defaultStorePath]);
		DLog(@"init - %d",[[NSFileManager defaultManager] fileExistsAtPath:self.persistentStorePath]);
	}

	if (!self.managedObjectContext)
	{
		// should trigger managedObjectContext generation.
	}

	if (!self.persistentStoreCoordinator)
	{
		// should trigger persistentStoreCoordinator generation.
	}

	return self;

}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {

	NSLog(@"persistentStoreCoordinator");
	
    if (persistentStoreCoordinator == nil) {

		NSString *tmpStr = [NSString stringWithFormat:@"%@",[NSURL fileURLWithPath:self.persistentStorePath]];
		tmpStr = [tmpStr substringWithRange:NSMakeRange(0,[tmpStr length] - 2)];

        NSURL *storeUrl = [NSURL URLWithString:tmpStr];


		DLog(@"self.persistentStorePath - %@ - %d",storeUrl,[[NSFileManager defaultManager] fileExistsAtPath:self.persistentStorePath]);

        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
        NSError *error = nil;
        NSPersistentStore *persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error];

		if (error) {

			DLog(@"store error - %@",error);

		}

        NSAssert3(persistentStore != nil, @"Unhandled error adding persistent store in %s at line %d: %@", __FUNCTION__, __LINE__, [error localizedDescription]);
		persistentStore = nil; //hide the warning;
    }
    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {

	if (managedObjectContext == nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return managedObjectContext;
}

- (NSString *)persistentStorePath {

	if (persistentStorePath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths lastObject];
        persistentStorePath = [documentsDirectory stringByAppendingPathComponent:@"CPModel.momd"];
		DLog(@"persistentStorePath - %@ - %d",persistentStorePath,[[NSFileManager defaultManager] fileExistsAtPath:self.persistentStorePath]);
    }
    return persistentStorePath;
}

-(NSString *) getAppUUID {

	AppData *appdata = nil;
	int16_t recordNum = 1;
	NSError *error = nil;
	NSString *uuidStr = nil;
	
	// Check If We Have A Record

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"AppData" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];

	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recordid" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];

	NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];

	appArray = mutableFetchResults;

	if ([appArray count] == 0) {

		// Create The UUID

		CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
		uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);

		appdata = (AppData *)[NSEntityDescription insertNewObjectForEntityForName:@"AppData" inManagedObjectContext:self.managedObjectContext];

		[appdata setRecordid:recordNum];
		[appdata setUuid:uuidStr];

		if (![self.managedObjectContext save:&error]) {
			// Handle the error.
			DLog(@"Save Error");
		} else {
			DLog(@"Saved");
		}

	} else {

		uuidStr = [[appArray objectAtIndex:0] valueForKey:@"uuid"];

	}

	return uuidStr;
}

-(Issue *) getIssue : (NSString *) issueUUID {

	Issue *data = nil;
	NSError *error = nil;
	//Issue *issue = (Issue *)[NSEntityDescription insertNewObjectForEntityForName:@"Issue" inManagedObjectContext:self.managedObjectContext];

	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Issue" inManagedObjectContext:self.managedObjectContext];
	[request setEntity:entity];

	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"uuid" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid = %@",issueUUID];
	[request setPredicate:predicate];

	NSMutableArray *issueList = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];

	if ([issueList count] == 0) {

		data = (Issue *)[NSEntityDescription insertNewObjectForEntityForName:@"Issue" inManagedObjectContext:self.managedObjectContext];
		[data setUuid:issueUUID];

	} else {

		data = [issueList objectAtIndex:0];

	}

	return data;
}

@end
