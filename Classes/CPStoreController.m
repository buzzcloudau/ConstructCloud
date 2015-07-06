//
//  CPStoreController.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPStoreController.h"

@implementation CPStoreController

@synthesize appStoreRequest		= _appStoreRequest;
@synthesize productRequest		= _productRequest;
@synthesize product				= _product;
@synthesize settings			= _settings;
@synthesize subscriptionData	= _subscriptionData;
@synthesize issueData			= _issueData;
@synthesize subscriptionProduct	= _subscriptionProduct;
@synthesize hud					= _hud;
@synthesize purchaseOnLoad		= _purchaseOnLoad;
@synthesize msv					= _msv;
@synthesize connector			= _connector;

- (id) initWithProductList:(NSDictionary *)productList mainScrollView:(UIScrollView *)mainScrollView
{

	_appStoreRequest = [[SKRequest alloc] init];
	[_appStoreRequest setDelegate:self];

	_productRequest = [[SKProductsRequest alloc] init];
	[_productRequest setDelegate:self];

	_settings = [CPSettingsData getInstance];

	_issueData = [productList objectForKey:@"issues"];
	_subscriptionData = [productList objectForKey:@"subscription"];

	_purchaseOnLoad = NO;
	_msv = mainScrollView;

	_connector = [CPGenericConnection alloc];

	[self showHUD];

	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	
	return self;

}

-(void) showHUD {

    if (_hud == nil) {
        _hud = [[CPHUD alloc] initWithView:_msv];
    }
    
    [_hud show:TRUE];

}

- (void) subscribe
{
	NSLog(@"--------> Subscribe : %@" , [_subscriptionData objectForKey:@"ProductID"]);

	[self showHUD];

	[self setPurchaseOnLoad:YES];
	[self requestProductData:[_subscriptionData objectForKey:@"ProductID"]];
}

- (void) subscribeShow
{
	DLog(@"--------> Subscribe");

	[_hud show:NO];

	UIAlertView *message = nil;

	if ([SKPaymentQueue canMakePayments]) {

		/*
		NSString *cost = [_subscriptionProduct.price isEqualToNumber:[[NSNumber alloc] initWithFloat:0.00]] ? @"FREE" : [NSString stringWithFormat:@"%@",_subscriptionProduct.price];

		message = [[UIAlertView alloc] initWithTitle:@"Subscription"
											 message:[NSString stringWithFormat:@"Would you like to subscribe to %@ for %@?",_settings.publicationName,cost]
											delegate:self
								   cancelButtonTitle:@"Cancel"
								   otherButtonTitles:@"Subscribe", nil];
		*/

		SKPayment * payment = [SKPayment paymentWithProduct:_subscriptionProduct];
		[[SKPaymentQueue defaultQueue] addPayment:payment];

	} else {

		message = [[UIAlertView alloc] initWithTitle:@"Subscription Error"
											 message:[NSString stringWithFormat:@"It appears purchasing is currently disabled on your device."]
											delegate:self
								   cancelButtonTitle:@"Ok"
								   otherButtonTitles:nil];



	}

	[message show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];

    if([title isEqualToString:@"Subscribe"])
    {

		[self subscribeOK];

    }
	else if ([title isEqualToString:@"Restore"])
	{

		[self restoreOK];

	}
	else if ([title isEqualToString:@"Cancel"])
	{

		// Do Noting.

	}
}

- (void) subscribeOK
{

	DLog(@"--------> Subscribe OK");

}

- (void) restore
{
	DLog(@"--------> Restore");

	UIAlertView *message = nil;

	message = [[UIAlertView alloc] initWithTitle:@"Restore Purchases"
										 message:@"Would you like to restore to restore your previous purchases?"
										delegate:self
							   cancelButtonTitle:@"Cancel"
							   otherButtonTitles:@"Restore", nil];

	[message show];
}

- (void) restoreOK
{

	DLog(@"--------> Restore OK");

	//	MyStoreObserver *observer = [[MyStoreObserver alloc] init];
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void) purchase
{
	DLog(@"--------> Purchase");
}

// Payment Observer Delegate

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{

	DLog(@"--------> paymentQueue - removedTransactions");

}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{

	DLog(@"--------> paymentQueue - restoreCompletedTransactionsFailedWithError");

}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{

	DLog(@"--------> paymentQueue - updatedDownloads");

}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{

	DLog(@"--------> paymentQueue - updatedTransactions");

	for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }

}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{

	DLog(@"--------> paymentQueue - paymentQueueRestoreCompletedTransactionsFinished");

}

- (void)completeTransaction:(SKPaymentTransaction *) transaction
{

	DLog(@"--------> paymentQueue - completeTransaction - %@",transaction);

	// Your application should implement these two methods.
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];

    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

}

- (void)recordTransaction:(SKPaymentTransaction *) transaction
{

	DLog(@"--------> paymentQueue - recordTransaction - %@",transaction);

	[_hud show:YES];
	
	NSString *subReg = [NSString stringWithFormat:@"%@?register_subscription",_settings.registerURL];
	NSURL *registerURL = [[NSURL alloc] initWithString:subReg];

	DLog(@"--------> registerURL : %@",registerURL);
	
	// Send the request

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:registerURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];

	[request setHTTPMethod: @"POST"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
//	[request setValue:[transa forKey:@"receipt"];
	[request setHTTPBody:nil];

	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:_connector];

	[theConnection start];

}

- (void)failedTransaction:(SKPaymentTransaction *) transaction
{

	DLog(@"--------> paymentQueue - failedTransaction - %@",transaction);

	if (transaction.error.code != SKErrorPaymentCancelled) {

//		UIAlertView *message = nil;
//
//		message = [[UIAlertView alloc] initWithTitle:@"Transaction Failure"
//											 message:@"There was an error processing your purchase. Please try again."
//											delegate:self
//								   cancelButtonTitle:@"Ok"
//								   otherButtonTitles:nil];
//
//		[message show];

    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

}

- (void)restoreTransaction:(SKPaymentTransaction *) transaction
{

	DLog(@"--------> paymentQueue - restoreTransaction - %@",transaction);

	[self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

}

-(void) provideContent:(NSString *)identifier
{

	DLog(@"--------> paymentQueue - provideContent - %@",identifier);

}

// Store Request Delegate

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	DLog(@"SKRequest didFailWithError: %@ : %@" , request , error);
    DLog(@"request - didFailWithError: %@", [[error userInfo] objectForKey:@"NSLocalizedDescription"]);
}

- (void)requestDidFinish:(SKRequest *)request
{
	DLog(@"SKRequest requestDidFinish: %@" , request );
}


// Product Request Delegate

- (void) requestProductData:(NSString *)identifier
{

	DLog(@"--------> paymentQueue - requestProductData %@",identifier);

    if (identifier != NULL) {
        
        _productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject: identifier]];
        [_productRequest setDelegate:self];
        [_productRequest start];
        
    } else {
        
        UIAlertView *tmpAlert = [[UIAlertView alloc] initWithTitle:@"No Products Found" message:@"Sorry, there are no products available for purchase at this time." delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil];
        
        [_hud show:FALSE];
        [tmpAlert show];
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	DLog(@"SKProductRequest didReceiveResponse: %@ : %@" , request , response);

	for (SKProduct *prod in [response products]) {

		DLog(@"Found product: %@ %@ %0.2f",
              prod.productIdentifier,
              prod.localizedTitle,
              prod.price.floatValue);

		if ([prod.productIdentifier isEqualToString:_settings.subscribeID]) {
			_subscriptionProduct = prod;
			if(_purchaseOnLoad) {
				[self subscribeShow];
			}
		}

	}

}

@end
