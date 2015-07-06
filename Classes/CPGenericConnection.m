//
//  CPGenericConnection.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPGenericConnection.h"
#import "defs.h"

@implementation CPGenericConnection

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return YES;
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	DLog(@"CPGenericConnection - didCancelAuthenticationChallenge - %@",challenge);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	DLog(@"CPGenericConnection - didFailWithError - %@",error);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	DLog(@"CPGenericConnection - didReceiveAuthenticationChallenge - %@",challenge);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	DLog(@"CPGenericConnection - didReceiveData - %@",data);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	DLog(@"CPGenericConnection - didReceiveResponse - %@",response);
}


@end
