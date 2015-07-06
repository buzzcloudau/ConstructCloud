//
//  CPStoreController.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "CPSettingsData.h"
#import "defs.h"
#import "CPSettingsData.h"
#import "CPGenericConnection.h"
#import "CPHUD.h"

@interface CPStoreController : NSObject <SKRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver> {
	SKRequest *appStoreRequest;
	SKProductsRequest *productRequest;
	SKProduct *product;
	CPSettingsData *settings;
	SKProduct *subscriptionProduct;
}

-(id) initWithProductList:(NSDictionary *)productList mainScrollView:(UIScrollView *)mainScrollView;
-(void) subscribe;
-(void) restore;
-(void) purchase;

// SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions;
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error;
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads;
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue;


@property (nonatomic) SKRequest *appStoreRequest;
@property (nonatomic) SKProductsRequest *productRequest;
@property (nonatomic) SKProduct *product;
@property (nonatomic) CPSettingsData *settings;
@property (nonatomic) NSDictionary *subscriptionData;
@property (nonatomic) NSMutableArray *issueData;
@property (nonatomic) SKProduct *subscriptionProduct;
@property (nonatomic) CPHUD *hud;
@property (nonatomic) BOOL purchaseOnLoad;
@property (nonatomic) UIScrollView *msv;
@property (nonatomic) CPGenericConnection *connector;


@end
