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

#import "CPContentsView.h"
#import "ViewControllerForMagazine.h"
#import <Twitter/Twitter.h>
#import "CPMagazinePageView.h"
#import "defs.h"

@implementation CPContentsView

@synthesize contentsTableView;
@synthesize facebookWebView;
@synthesize facebookWebViewHolder;
@synthesize twitterTableViewHolder;
@synthesize contentsTabBar;
@synthesize contentsNavBar;
@synthesize contentsTableViewHolder;
@synthesize view;
@synthesize xmlDoc = _xmlDoc;
@synthesize articles = _articles;
@synthesize navBar = _navBar;
@synthesize contentPath = _contentPath;
@synthesize twitterData = _twitterData;
@synthesize scrollView = _scrollView;
@synthesize parentController = _parentController;
@synthesize customCell = _customCell;
@synthesize twitterTableView = _twitterTableView;
@synthesize settings = _settings;

- (id)initWithFrame:(CGRect)frame xmlDoc:(SMXMLDocument *)xmlDoc contentPath:(NSString *)contentPath navBar:(UINavigationController *)navBar parentController:(id)parentController
{

	_xmlDoc = xmlDoc;
	_navBar = navBar;
	_contentPath = contentPath;
	_parentController = (ViewControllerForMagazine *)parentController;
	_scrollView = [_parentController scrollView];

	self = [super initWithFrame:frame];
	
	SMXMLElement *article = nil;// = [_xmlDoc.root childNamed:@"article"];
	_articles = [[NSMutableArray alloc] init];
	_twitterData = [[NSMutableArray alloc] init];

	_settings = [CPSettingsData getInstance];
	_appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	_postmaster = [[CPPostmaster alloc] init];
	_contentCache = [_appDelegate contentCache];

	int pageCount = 0;

	for (article in [_xmlDoc.root childrenNamed:@"article"]) {
		
		if ([[article attributeNamed:@"ad"] isEqualToString:@""] || ![[article attributeNamed:@"ad"] boolValue]) {
			NSMutableDictionary *tmpObj = [[NSMutableDictionary alloc] init];

			[tmpObj setValue:[[article childNamed:@"page"] attributeNamed:@"id"] forKey:@"id"];
			[tmpObj setValue:[article valueWithPath:@"title"] forKey:@"title"];
			[tmpObj setValue:[article valueWithPath:@"section"] forKey:@"section"];
			[tmpObj setValue:[article valueWithPath:@"description"] forKey:@"description"];
			[tmpObj setValue:[article valueWithPath:@"icon"] forKey:@"icon"];
			[tmpObj setValue:[[article childNamed:@"icon"] attributeNamed:@"absolute"] forKey:@"isAbsolute"];
			[tmpObj setValue:[article valueWithPath:@"author"] forKey:@"author"];
			[tmpObj setValue:[NSNumber numberWithInt:pageCount] forKey:@"pageNum"];
			
			[_articles addObject:tmpObj];

		}

		pageCount = pageCount + [[article childrenNamed:@"page"] count];
	}

	if (self)
    {
        [[NSBundle mainBundle] loadNibNamed:@"CPContentsControllerView" owner:self options:nil];
        [self addSubview:self.view];
		[self setFrame:frame];
		[self setBounds:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		//[contentsTabBar setSelectedImageTintColor:[UIColor redColor]];

		UITabBarItem * tmpItem = (UITabBarItem *)[[contentsTabBar items] objectAtIndex:0];
		[contentsTabBar setSelectedItem:tmpItem];

		[contentsTableView setBackgroundColor:[UIColor clearColor]];
		[contentsTableView setOpaque:FALSE];

		UIImage *bgImage = [UIImage imageNamed:@"menuBG.png"];

		[contentsTableView setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
		[contentsTableViewHolder setBackgroundColor:[UIColor darkGrayColor]];

		[[self twitterTableView] setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
		[twitterTableViewHolder setBackgroundColor:[UIColor darkGrayColor]];

		/*
		NSString* userAgent = @"Mozilla/5.0 (iPad; CPU iPad OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3";
		
		
		NSDictionary* initDefaults = [[NSDictionary alloc] initWithObjectsAndKeys:
									  userAgent, @"UserAgent",
									  nil];

		[[NSUserDefaults standardUserDefaults] registerDefaults:initDefaults];
		 */

    }

    return self;
}

- (void) awakeFromNib
{

	[super awakeFromNib];
	
    [[NSBundle mainBundle] loadNibNamed:@"CPContentsControllerView" owner:self options:nil];
    [self addSubview:self.view];
}

- (IBAction)backToLibrary:(id)sender {

	[_navBar setNavigationBarHidden:FALSE animated:FALSE];
	//[_navBar setToolbarHidden:FALSE animated:FALSE];

	if (![_settings.device isEqualToString:@"iPhone"]) {
		[[UIApplication sharedApplication] setStatusBarHidden:FALSE withAnimation:FALSE];
	} else {
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
	}
	
	[_navBar popViewControllerAnimated:FALSE];
	//[_navBar popToRootViewControllerAnimated:TRUE];
}

- (IBAction)closeContents:(id)sender {
	[(ViewControllerForMagazine *)_navBar.topViewController performContentsOverlayActionClose];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
	if(item.tag == 1)
    {
		[[self twitterTableViewHolder] setHidden:TRUE];
		[[self facebookWebViewHolder] setHidden:TRUE];
		[[self contentsTableViewHolder] setHidden:FALSE];
    }
	else if(item.tag == 2)
    {
		[[self twitterTableViewHolder] setHidden:TRUE];
		[[self facebookWebViewHolder] setHidden:FALSE];
		[[self contentsTableViewHolder] setHidden:TRUE];

		if (![[self facebookWebView] request]) {
			
			NSString *fbAddress = _settings.facebookURL;
		
			//Create a URL object.
			NSURL *fbURL = [NSURL URLWithString:fbAddress];
			
			//URL Requst Object
			NSURLRequest *fbRequestObj = [NSURLRequest requestWithURL:fbURL];
			
			//Load the request in the UIWebView.
			[[self facebookWebView] loadHTMLString:@"Loading..." baseURL:[NSURL URLWithString:@""]];
			[[self facebookWebView] loadRequest:fbRequestObj];
		}

    }
	else if(item.tag == 3)
    {
		[[self twitterTableViewHolder] setHidden:FALSE];
		[[self facebookWebViewHolder] setHidden:TRUE];
		[[self contentsTableViewHolder] setHidden:TRUE];

		if ([_twitterData count] == 0) {

			//  First, we create a dictionary to hold our request parameters
			NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
			[params setObject:[[_settings.twitterURL componentsSeparatedByString:@"/"] lastObject] forKey:@"screen_name"];
			[params setObject:@"25" forKey:@"count"];
			[params setObject:@"1" forKey:@"include_entities"];
			[params setObject:@"1" forKey:@"include_rts"];
			
			//  Next, we create an URL that points to the target endpoint
			NSURL *url = 
			[NSURL URLWithString:@"http://api.twitter.com/1/statuses/user_timeline.json"];
			
			//  Now we can create our request.  Note that we are performing a GET request.
			SLRequest *request  = [SLRequest requestForServiceType:SLServiceTypeTwitter
													  requestMethod:SLRequestMethodPOST
																URL:url
														 parameters:params];
			
			//  Perform our request
			[request performRequestWithHandler:
			 ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
				 
				 if (responseData) {
					 //  Use the NSJSONSerialization class to parse the returned JSON
					 NSError *jsonError;
					 _twitterData = [NSJSONSerialization JSONObjectWithData:responseData
													 options:NSJSONReadingMutableLeaves 
													   error:&jsonError];
					 
					 if ([_twitterData count]) {
						 // We have an object that we can parse
						 [[self twitterTableView] reloadData];
						 [[self twitterTableView] performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
					 } 
					 else {
						 // Inspect the contents of jsonError
						 DLog(@"%@", jsonError);
					 }
				 }
			 }];
		}

    }
	else if(item.tag == 4)
    {
		[[self twitterTableViewHolder] setHidden:TRUE];
		[[self facebookWebViewHolder] setHidden:TRUE];
		[[self contentsTableViewHolder] setHidden:TRUE];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[[self contentsTableView] deselectRowAtIndexPath:indexPath animated:FALSE];

	if (tableView == [self twitterTableView]) {

		// NOTHING TO DO FOR TWITTER... YET...

	} else {

		NSString *actionPage = [[_articles objectAtIndex:indexPath.row] objectForKey:@"id"];
		NSDictionary *userInfo = [NSDictionary dictionaryWithObject:actionPage forKey:@"pageid"];

		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPNavigateToPage" object:nil userInfo:userInfo];
	}

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == [self twitterTableView]) {
		return [_twitterData count];
	} else if (tableView == [self contentsTableView]) {
		return [_articles count];
	} else {
		return 0;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == [self twitterTableView]) {
		return 1;
	} else if (tableView == [self contentsTableView]) {
		return 1;
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	
	if (tableView == [self twitterTableView]) {

		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CPTwitterCellView" owner:self options:nil];

		static NSString *CellIdentifier = @"twitterCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		UIView *cellBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
		[cellBG setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.3f]];
		
		if (cell == nil) {
			if(nib.count > 0) {
				cell = self.customCell;
				[cell setSelectedBackgroundView:cellBG];
			} else {
				DLog(@"failed to load CustomCell nib file!");
			}
		}
		
		NSDictionary *cellData = [_twitterData objectAtIndex:indexPath.row];

		if ([cellData valueForKey:@"retweeted_status"]) {
			cellData = [cellData valueForKey:@"retweeted_status"];
		}
		
		UILabel *titleLabel = (UILabel *)[self.customCell viewWithTag:1];
		UILabel *descLabel = (UILabel *)[self.customCell viewWithTag:3];
		UIImageView *profileImage = (UIImageView *)[self.customCell viewWithTag:2];

		titleLabel.text = [[cellData valueForKey:@"user"] valueForKey:@"name"];
		descLabel.text = [cellData valueForKey:@"text"];

		NSString* fullURLString = [[cellData valueForKey:@"user"] valueForKey:@"profile_image_url"];
		NSArray *urlStringParts = [fullURLString componentsSeparatedByString:@"/"];
		NSString* foofile = [[urlStringParts objectAtIndex:([urlStringParts count] - 2)] stringByAppendingString:[urlStringParts objectAtIndex:([urlStringParts count] - 1)]];
		NSString *imagePath = [applicationDocumentsDir stringByAppendingPathComponent:foofile];

		BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
		
		if (!fileExists) {
			
			dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				
				NSURL *imageURL = [NSURL URLWithString:fullURLString];
				
				UIImage *remoteImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:imageURL]];
				NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(remoteImage)];
				[data1 writeToFile:imagePath atomically:YES];

				dispatch_async( dispatch_get_main_queue(), ^{

					[profileImage setImage:[UIImage imageWithContentsOfFile:imagePath]];

				});
			});
			
		} else {
			[profileImage setImage:[UIImage imageWithContentsOfFile:imagePath]];
		}

		[descLabel setNumberOfLines:0];
		[descLabel sizeThatFits:CGSizeMake(240, 69)];
		
		//cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;

	} else if (tableView == [self contentsTableView]) {

		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CPContentsCellView" owner:self options:nil];

		static NSString *CellIdentifier = @"contentsCell";

		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		UIView *cellBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
		//[cellBG setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3f]];
		
		if (cell == nil) {
			if(nib.count > 0) {
				cell = self.customCell;
				[cell setSelectedBackgroundView:cellBG];
			} else {
				DLog(@"failed to load CustomCell nib file!");
			}
		}
		
		[cell setBackgroundColor:[UIColor blackColor]];
		[tableView setBackgroundColor:nil];
		
		NSDictionary *cellData = [_articles objectAtIndex:indexPath.row];
		
		UILabel *titleLabel = (UILabel *)[self.customCell viewWithTag:3];
		UILabel *descLabel = (UILabel *)[self.customCell viewWithTag:1];
		UIImageView *contentsImage = (UIImageView *)[self.customCell viewWithTag:2];
		
		titleLabel.text = [cellData valueForKey:@"title"];
		descLabel.text = [cellData valueForKey:@"section"];
		
		BOOL isAbsolute = [[cellData valueForKey:@"isAbsolute"] boolValue];
		
		DLog(@"icon is absolute : %@",[cellData valueForKey:@"isAbsolute"]);
		
		if (!isAbsolute) {
			
			NSString *imagePath = [_contentPath stringByAppendingPathComponent:[cellData valueForKey:@"icon"]];
			
			[contentsImage setImage:[UIImage imageWithContentsOfFile:imagePath]];
			
		} else {
			
			dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
			
			dispatch_async(queue, ^{
				
				NSData *imageData = [_postmaster getAndReceive:[NSURL URLWithString:[cellData valueForKey:@"icon"]] packageData:nil cachable:YES];
				
				dispatch_sync(dispatch_get_main_queue(), ^{
					
					[contentsImage setImage:[UIImage imageWithData:imageData]];
					
				});
				
			});
			
		}
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		return cell;
		
	} else {

		static NSString *CellIdentifier = @"blankCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		return cell;
		
	}
}

-(void)setFontSizeOfMultiLineLabel: (UILabel*)label 
						 toFitSize: (CGSize) size 
					forMaxFontSize: (CGFloat) maxFontSize 
					andMinFontSize: (CGFloat) minFontSize 
		  startCharacterWrapAtSize: (CGFloat)characterWrapSize{
	
	CGRect constraintSize = CGRectMake(0, 0, size.width, 0);
	label.frame = constraintSize;
	label.lineBreakMode = NSLineBreakByWordWrapping;
	label.numberOfLines = 0; // allow any number of lines
	
	for (int i = maxFontSize; i > minFontSize; i--) {
		
		if((i < characterWrapSize) && (label.lineBreakMode == NSLineBreakByWordWrapping)){
			// start over again with lineBreakeMode set to character wrap 
			i = maxFontSize;
			label.lineBreakMode = NSLineBreakByCharWrapping;
		}
		
		label.font = [label.font fontWithSize:i];
		[label sizeToFit];
		if(label.frame.size.height < size.height){
			break;
		}       
		label.frame = constraintSize;
	} 
}


@end
