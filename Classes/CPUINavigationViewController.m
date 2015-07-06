//
//  CPUINavigationViewController.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPUINavigationViewController.h"
#import "defs.h"

@interface CPUINavigationViewController ()

@end

@implementation CPUINavigationViewController

@synthesize settings = _settings;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    _settings = [CPSettingsData getInstance];
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	_settings = [CPSettingsData getInstance]; // because its not loading fast enough.
	
	if ([[NSString stringWithFormat:@"%@",[[self topViewController] class]] isEqualToString:@"RootViewController"]) {
	//if (_settings.shouldAllowRotate || interfaceOrientation != _settings.supportedOrientation) {
		return YES;
	} else {
		return _settings.shouldAllowRotate;
	}
	
	
}

- (BOOL) shouldAutorotate
{

	_settings = [CPSettingsData getInstance]; // because its not loading fast enough.
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [[NSString stringWithFormat:@"%@",[[self topViewController] class]] isEqualToString:@"RootViewController"]) {
		return NO;
	} else {
		return _settings.shouldAllowRotate;
	}
	
}

-(NSUInteger)supportedInterfaceOrientations
{
	
	_settings = [CPSettingsData getInstance]; // because its not loading fast enough.
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [[NSString stringWithFormat:@"%@",[[self topViewController] class]] isEqualToString:@"RootViewController"]) {
		return UIInterfaceOrientationMaskPortrait;
	} else {
		return _settings.supportedOrientation;
	}
	
}

@end
