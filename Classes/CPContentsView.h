//
//  CPContentsView.m
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
#import "CPSettingsData.h"
#import "CPPostmaster.h"
#import "AppDelegate.h"

@class AppDelegate;
@class CPPostmaster;

@interface CPContentsView : UIView <UITabBarDelegate, UITableViewDataSource, UIWebViewDelegate>
{
    UIView *view;
	UITableViewCell *customCell;
}

- (id)initWithFrame:(CGRect)frame xmlDoc:(SMXMLDocument *)xmlDoc contentPath:(NSString *)contentPath navBar:(UINavigationController *)navBar parentController:(id)parentController;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@property (weak, nonatomic) IBOutlet UIView *contentsTableViewHolder;
@property (weak, nonatomic) IBOutlet UITableView *contentsTableView;

@property (weak, nonatomic) IBOutlet UIView *facebookWebViewHolder;
@property (weak, nonatomic) IBOutlet UIWebView *facebookWebView;

@property (weak, nonatomic) IBOutlet UIView *twitterTableViewHolder;
@property (weak, nonatomic) IBOutlet UITableView *twitterTableView;

@property (weak, nonatomic) IBOutlet UITabBar *contentsTabBar;
@property (weak, nonatomic) IBOutlet UINavigationBar *contentsNavBar;


@property (nonatomic, retain) IBOutlet UITableViewCell *customCell;
@property (nonatomic, retain) IBOutlet UIView *view;

@property (nonatomic) SMXMLDocument *xmlDoc;
@property (nonatomic) NSMutableArray *articles;
@property (nonatomic) NSMutableArray *twitterData;

@property (nonatomic) UINavigationController *navBar;
@property (nonatomic) NSString *contentPath;

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) id parentController;

@property (nonatomic) CPSettingsData *settings;

@property (nonatomic) AppDelegate *appDelegate;
@property (nonatomic) CPPostmaster *postmaster;
@property (nonatomic) NSCache *contentCache;

@end