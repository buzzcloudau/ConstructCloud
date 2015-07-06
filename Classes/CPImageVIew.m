//
//  CPImageView.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPImageView.h"

@implementation CPImageView

-(id)initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath {

	_contentPath = contentPath;
	_xmlPacket = xmlData;

	self = [super init];
	[self resetLayout];

	return self;
}

-(void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
}

- (void)removeFromSuperview {
	[super removeFromSuperview];
}

-(void)setCurrentPage:(id)currentPage {
    
}

-(void)resetLayout {
	
    NSString *tmpFile   = @"";
	NSString *tmpType   = @"";
	NSInteger tmpWidth  = 0;
	NSInteger tmpHeight = 0;
	NSInteger tmpLeft   = 0;
	NSInteger tmpTop    = 0;
	NSString *tmpID     = [_xmlPacket attributeNamed:@"id"];
	BOOL tmpIsAbsolute	= false;
	
	SMXMLElement *tmpSrcL = [_xmlPacket childNamed:@"lsrc"];
	SMXMLElement *tmpSrcP = [_xmlPacket childNamed:@"psrc"];
	SMXMLElement *tmpSrc = [_xmlPacket childNamed:@"src"];
	
	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		
		tmpFile     = [tmpSrcL valueWithPath:@"file"];
		tmpType     = [tmpSrcL valueWithPath:@"type"];
		tmpWidth    = [[tmpSrcL valueWithPath:@"width"] intValue];
		tmpHeight   = [[tmpSrcL valueWithPath:@"height"] integerValue];
		tmpLeft     = [[tmpSrcL valueWithPath:@"left"] intValue];
		tmpTop      = [[tmpSrcL valueWithPath:@"top"] integerValue];
		tmpIsAbsolute = [[tmpSrcL attributeNamed:@"absolute"] boolValue];
		
	} else if (!UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		
		tmpFile     = [tmpSrcP valueWithPath:@"file"];
		tmpType     = [tmpSrcP valueWithPath:@"type"];
		tmpWidth    = [[tmpSrcP valueWithPath:@"width"] intValue];
		tmpHeight   = [[tmpSrcP valueWithPath:@"height"] integerValue];
		tmpLeft     = [[tmpSrcP valueWithPath:@"left"] intValue];
		tmpTop      = [[tmpSrcP valueWithPath:@"top"] integerValue];
		tmpIsAbsolute = [[tmpSrcP attributeNamed:@"absolute"] boolValue];
		
	}
	
	if ([tmpFile isEqualToString:@""]) {
		
		tmpFile     = [tmpSrc valueWithPath:@"file"];
		tmpType     = [tmpSrc valueWithPath:@"type"];
		tmpWidth    = [[tmpSrc valueWithPath:@"width"] intValue];
		tmpHeight   = [[tmpSrc valueWithPath:@"height"] integerValue];
		tmpLeft     = [[tmpSrc valueWithPath:@"left"] intValue];
		tmpTop      = [[tmpSrc valueWithPath:@"top"] integerValue];
		tmpIsAbsolute = [[tmpSrc attributeNamed:@"absolute"] boolValue];
		
	}
	
	// reset the image position
	[self setFrame:CGRectMake(tmpLeft,tmpTop,tmpWidth,tmpHeight)];
	[self setBounds:CGRectMake(0,0,tmpWidth,tmpHeight)];
	
	// reset the image src
	if (!_landscapeIsPortrait && ![tmpFile isEqualToString:@""]) {
		
		if (!tmpIsAbsolute) {
			
			NSString *imgName = [NSString stringWithFormat:@"%@/%s.%s"
								 ,_contentPath
								 ,[tmpFile UTF8String]
								 ,[tmpType UTF8String]];
			
			[self setImage:[UIImage imageWithContentsOfFile:imgName]];
			
		} else {
			
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
			
			dispatch_async(queue, ^{
				
				NSData *imageData = [_postmaster getAndReceive:[NSURL URLWithString:tmpFile] packageData:nil cachable:YES];
				
				UIImage *tmpImg = [UIImage imageWithData:imageData];
				
				dispatch_sync(dispatch_get_main_queue(), ^{
					
					[self setImage:tmpImg];
					
				});
				
			});
			
		}
	}
    
	[self setAlpha:0.0];
	[UIView setAnimationsEnabled:TRUE];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelay:(NSTimeInterval)1.5];
	[self setAlpha:1.0];
	[UIView commitAnimations];
	
	_hasPortrait = ![[tmpSrcP valueWithPath:@"file"] isEqualToString:@""] || ![[tmpSrc valueWithPath:@"file"] isEqualToString:@""] ? TRUE : FALSE;
	_hasLandscape = ![[tmpSrcL valueWithPath:@"file"] isEqualToString:@""] || ![[tmpSrc valueWithPath:@"file"] isEqualToString:@""] ? TRUE : FALSE;
	_landscapeIsPortrait = [[tmpSrcL valueWithPath:@"file"] isEqualToString:[tmpSrcP valueWithPath:@"file"]] ? TRUE : FALSE;
	_xmlID = tmpID;
}

- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation {

}


@end
