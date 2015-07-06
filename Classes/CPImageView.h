//
//  CPImageView.h
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>
#import "SMXMLDocument.h"
#import "CPPostmaster.h"
#import "AppDelegate.h"

@interface CPImageView : UIImageView

- (id)initWithXML:(SMXMLElement *)xmlData contentPath:(NSString *)contentPath;
- (void)setAlpha:(CGFloat)alpha;
- (void)setCurrentPage:(id)currentPage;
- (void)resetLayout;
- (void)preRotate:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)removeFromSuperview;

@property (nonatomic) BOOL hasLandscape;
@property (nonatomic) BOOL hasPortrait;
@property (nonatomic) BOOL landscapeIsPortrait;
@property (nonatomic) BOOL mustRender;
@property (nonatomic) NSString *xmlID;
@property (nonatomic) SMXMLElement *xmlPacket;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) NSString *contentPath;
@property (nonatomic) AppDelegate *appDelegate;
@property (nonatomic) CPPostmaster *postmaster;
@property (nonatomic) NSCache *contentCache;


@end
