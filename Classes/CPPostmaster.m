//
//  CPDataPost.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPPostmaster.h"
#import "defs.h"

@implementation CPPostmaster

- (id) init {
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _contentCache = [_appDelegate contentCache];
    
    return self;
}

- (NSData *) getAndReceive:(NSURL *)uri packageData:(NSDictionary *)packageData cachable:(BOOL)cachable {
    
    NSString *postString = [[NSString alloc] init];
    NSData *response = [[NSData alloc] init];
    NSString *cacheKey = [[NSString alloc] init];
	
	if (uri == NULL) {
		
		DLog(@">>>>>>>>>>> URI IS NULL");
		return response;
		
	}
    
    if (packageData != nil) {
        for (id key in packageData) {
            postString = [postString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,[packageData objectForKey:key]]];
        }
        
        if ([postString length] > 0) {
            postString = [postString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            uri = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",[uri absoluteString],postString]];
        }
    }
    
    // Check if we have one in the cache
    if (cachable) {
        
        // create a key for the request.
        cacheKey = [NSString stringWithFormat:@"%@|%@",uri,postString];
        NSData *cacheData = [_contentCache objectForKey:cacheKey];
        
		// if its in the cache, just return it.
        if (cacheData != nil) {
            DLog(@"cacheKey ++ : %@",cacheKey);
			return cacheData;
        } else {
			DLog(@"cacheKey -- : %@",cacheKey);
		}
        
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:uri];
    [request setHTTPMethod:@"GET"];
    [request setValue:0 forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"" forHTTPHeaderField:@"X-APP-NAME"];
    [request setValue:@"" forHTTPHeaderField:@"X-APP-VERSION"];
    [request setValue:@"" forHTTPHeaderField:@"X-APP-KEY"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:nil];
    
    NSError *error;
    NSURLResponse *postResponse;
    
    response = [NSURLConnection sendSynchronousRequest:request returningResponse:&postResponse error:&error];
    
    // add it to the cache
    if (cachable) {
        [_contentCache setObject:response forKey:cacheKey];
    }
    
    return response;
    
}

- (NSDictionary *) getAndReceiveDictionary:(NSURL *)uri packageData:(NSDictionary *)packageData cachable:(BOOL)cachable {
    
    NSDictionary *response = [self dictionaryWithContentsOfData:[self getAndReceive:uri packageData:packageData cachable:cachable]];
    
    return response;
    
}

- (NSData *) postAndReceive:(NSURL *)uri packageData:(NSDictionary *)packageData cachable:(BOOL)cachable {
    
    NSMutableData *body = [NSMutableData data];
    NSString *cacheKey = [[NSString alloc] init];
    NSString *boundary = @"-------------------------------------1234567890";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    NSLog(@"postAndReceive");
    
    if (packageData != nil) {
        for (id key in packageData) {
            
            if ([[packageData objectForKey:key] isKindOfClass:[UIImage class]]) {
                
                NSLog(@"postAndReceive : package -> Image");
                
                NSData *imgData = [NSData dataWithData:UIImagePNGRepresentation([packageData objectForKey:key])];
            
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=%@\"\r\n", key, key] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[NSData dataWithData:imgData]];
                 
            } else if ([[packageData objectForKey:key] isKindOfClass:[NSData class]]) {
                
                NSLog(@"postAndReceive : package -> Data");
                
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=%@\"\r\n", key, key] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[NSData dataWithData:[packageData objectForKey:key]]];
                
            } else {
                
                NSLog(@"postAndReceive : package -> String %@ : %@",key,[packageData valueForKey:key]);
                
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, [packageData objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
                
            }
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
    }
    
    // Check if we have one in the cache
    if (cachable) {
        
        // create a key for the request.
        cacheKey = [NSString stringWithFormat:@"%@|%@",uri,body];
        NSData *cacheData = [_contentCache objectForKey:cacheKey];
        
        // if its in the cache, just return it.
        if (cacheData) {
            return cacheData;
        }
        
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    
    [request setURL:uri];
    [request setHTTPMethod:@"POST"];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:body];
    
    NSError *error;
    NSURLResponse *postResponse;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&postResponse error:&error];
    
    // add it to the cache
    if (cachable) {
		DLog(@"cacheKey : %@",cacheKey);
        [_contentCache setObject:response forKey:cacheKey];
    }
    
    return response;
    
}

- (NSDictionary *) postAndReceiveDictionary:(NSURL *)uri packageData:(NSDictionary *)packageData cachable:(BOOL)cachable {

    NSData *data = [self postAndReceive:uri packageData:packageData cachable:cachable];
    NSDictionary *response = [self dictionaryWithContentsOfData:data];
    
    
    return response;
}

- (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data
{
	NSString *string;
    NSDictionary *dictionary;
    
    string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    dictionary = [string propertyList];
    
    return dictionary;
}

@end
