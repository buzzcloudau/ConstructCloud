//
//  CPMapPin.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPMapPin.h"
#import "defs.h"
#import "CPLayerView.h"
#import "CPWebView.h"

@implementation CPMapPin

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize actions = _actions;
@synthesize actionsLeft = _actionsLeft;
@synthesize actionsRight = _actionsRight;
@synthesize actionOnTap = _actionOnTap;
@synthesize actionID = _actionID;
@synthesize actionURL = _actionURL;
@synthesize actionIndex = _actionIndex;
@synthesize canShowCallout = _canShowCallout;
@synthesize leftImage = _leftImage;
@synthesize rightImage = _rightImage;
@synthesize leftButton = _leftButton;
@synthesize rightButton = _rightButton;
@synthesize pageView = _pageView;
@synthesize contentPath = _contentPath;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description pageView:(id)pageView contentPath:(NSString *)contentPath {
    
	self = [super init];
	
    if (self != nil) {
        _coordinate = location;
        _title = placeName;
        _subtitle = description;
		_actions = [[NSMutableArray alloc] init];
		_leftImage = nil;
		_rightImage = nil;
		_pageView = pageView;
		_contentPath = contentPath;
		[self setCanShowCallout:YES];
    }
    return self;
}

- (void) setTouchActions:(SMXMLElement *)actions {
	
	if ([[actions attributeNamed:@"disablecallout"] isEqualToString:@"true"]) {
		[self setCanShowCallout:NO];
	}
	
	for (SMXMLElement *action in [actions childrenNamed:@"ontap"]) {
	
		[[self actions] addObject:action];
		
	}
	
	for (SMXMLElement *action in [actions childrenNamed:@"onlefttap"]) {
		
		[[self actionsLeft] addObject:action];
		
	}
	
	for (SMXMLElement *action in [actions childrenNamed:@"onrighttap"]) {
		
		[[self actionsRight] addObject:action];
		
	}
}

- (NSString *)leftImage {
	return _leftImage;
}

- (NSString *)rightImage {
	return _rightImage;
}

- (UIButtonType)leftButton {
	return _leftButton;
}

- (UIButtonType)rightButton {
	return _rightButton;
}

- (id)getObjectByID:(NSString *)objID {
	return [(CPMagazinePageView *)_pageView getObjectByID:objID];
}

-(void)gotoURL:(NSString *)actionURL
{
    NSURL *requestURL = [[NSURL alloc] initWithString:actionURL];
	
	DLog(@"%@",requestURL);
	
    if ( [[requestURL scheme] isEqualToString:@"http"]
		|| [[requestURL scheme] isEqualToString:@"https"]
		) {
        //return ![[UIApplication sharedApplication ] openURL:requestURL];
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:requestURL forKey:@"url"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPNavigateWebNavigator" object:nil userInfo:userInfo];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPShowWebNavigator" object:self];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPHandleExpNavCollapse" object:nil];
		
	} else {
		
		[[UIApplication sharedApplication] openURL:requestURL];
		
	}
}

- (void) processTap:(SMXMLElement *)element {
	
	id tmpLayerView = nil;
	_actionOnTap = [element attributeNamed:@"action"];
	
	if ([_actionOnTap isEqualToString:@"geturl"]) {
		tmpLayerView = (CPWebView *)[self getObjectByID:_actionID];
	} else {
		tmpLayerView = (CPLayerView *)[self getObjectByID:_actionID];
	}
	
	if ([_actionOnTap isEqualToString:@"setstate"]){
		
		CPLayerView *tmpLayerView = (CPLayerView *)[self getObjectByID:[element attributeNamed:@"target"]];
		
		[tmpLayerView setScrollPage:_actionIndex];
		[tmpLayerView setpanimage];
		
	} else if ([_actionOnTap isEqualToString:@"geturl"] && tmpLayerView) {
		
		[(CPWebView *)tmpLayerView gotoURL:[element attributeNamed:@"url"]];
		
	} else if (tmpLayerView) {
		
		//if (([forState isEqualToString:@"visible"] && [tmpLayerView alpha] == 1) || ([forState isEqualToString:@"hidden"] && [tmpLayerView alpha] == 0)) {
		
		[UIView animateWithDuration:(NSTimeInterval)[[element attributeNamed:@"duration"] floatValue]
							  delay:(NSTimeInterval)[[element attributeNamed:@"delay"] floatValue]
							options:UIViewAnimationOptionBeginFromCurrentState
						 animations:^{
							 if ([_actionOnTap isEqualToString:@"show"]){
								 [tmpLayerView setAlpha:1];
							 } else if ([_actionOnTap isEqualToString:@"hide"]){
								 [tmpLayerView setAlpha:0];
							 }
						 }
						 completion:^(BOOL finished) {
							 
						 }];
		
		//}
		
	} else if ([_actionOnTap isEqualToString:@"geturl"]){
		
		[self gotoURL:[element attributeNamed:@"url"]];
		
	} else if ([_actionOnTap isEqualToString:@"playvideo"]){
		
		NSURL *movieURL = nil;
		NSString *fooFile = [NSString stringWithFormat:@"%@/%@",_contentPath,[element attributeNamed:@"url"]];
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:fooFile]) {
			movieURL = [NSURL fileURLWithPath:fooFile];
		} else {
			movieURL = [NSURL URLWithString:_actionURL];
		}
		
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:movieURL forKey:@"movieurl"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPPlayFullScreenVideo" object:nil userInfo:userInfo];
		
	} else if ([_actionOnTap isEqualToString:@"goto"]){
		
		NSString *actionPage = _actionID;
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:actionPage forKey:@"pageid"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPNavigateToPage" object:nil userInfo:userInfo];
		
	} else {
		
		// Nothing else assigned. So lets fire off the single tap event
		// [[NSNotificationCenter defaultCenter] postNotificationName:@"CPHandleSingleTap" object:nil userInfo:nil];
	}
	
}

- (void) pinTap {
	
	NSEnumerator *e = [_actions objectEnumerator];
	id object;
	
	while (object = [e nextObject]) {
		[self processTap:(SMXMLElement *)object];
	}
}

- (void) rightTap {
	
	NSEnumerator *e = [_actions objectEnumerator];
	id object;
	
	while (object = [e nextObject]) {
		[self processTap:(SMXMLElement *)object];
	}
	
}

- (void) leftTap {
	
	NSEnumerator *e = [_actions objectEnumerator];
	id object;
	
	while (object = [e nextObject]) {
		[self processTap:(SMXMLElement *)object];
	}
	
}


@end
