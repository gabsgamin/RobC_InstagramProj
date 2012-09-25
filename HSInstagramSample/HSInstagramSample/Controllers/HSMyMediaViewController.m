//
//  HSMyMediaViewController.m
//  HSInstagramSample
//
//  Created by Harminder Sandhu on 12-05-01.
//  Copyright (c) 2012 Pushbits. All rights reserved.
//

#import "HSMyMediaViewController.h"
#import "HSInstagramUserMedia.h"
#import "HSImageViewController.h"
#import "SSGSelectedMediaViewController.h"

const NSInteger kthumbnailWidth = 80;
const NSInteger kthumbnailHeight = 80;
const NSInteger kImagesPerRow = 4;

@interface HSMyMediaViewController ()
- (void)requestImages;
- (void)loadImages;
@end

@implementation HSMyMediaViewController

@synthesize webView = _webView;
@synthesize images = _images;
@synthesize thumbnails = _thumbnails;
@synthesize gridScrollView = _gridScrollView;
@synthesize accessToken = _accessToken;

int item = 0, row = 0, col = 0;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        /*
         * Uncomment to re-auth a new user on each view.
         *
        NSHTTPCookie *cookie;
        for (cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            if ([[cookie domain] compare:@"instagram.com"] == NSOrderedSame) 
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        */
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Selected Photos" style:UIBarButtonItemStyleBordered target:self action:@selector(showSelectedPhotos)];
    
    self.thumbnails = [[NSMutableArray alloc] init];
    self.gridScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.gridScrollView.contentSize = self.view.bounds.size;
    [self.view addSubview:self.gridScrollView];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    NSURLRequest* request = 
    [NSURLRequest requestWithURL:[NSURL URLWithString:
                                  [NSString stringWithFormat:kAuthenticationEndpoint, kClientId, kRedirectUrl]]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    self.title = @"my photos";
    
    self.images = [[NSMutableArray alloc] init];
}

- (void)showSelectedPhotos
{
    //if (self.webView.hidden) 
    //{
        SSGSelectedMediaViewController* objSelectedMedia = [[SSGSelectedMediaViewController alloc] init];
        [self.navigationController pushViewController:objSelectedMedia animated:YES];
    /*}
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Login First" message:@"Please login and select some media to see this list" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }*/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.wantsFullScreenLayout = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView 
            shouldStartLoadWithRequest:(NSURLRequest *)request 
                        navigationType:(UIWebViewNavigationType)navigationType 
{
    
    if ([request.URL.absoluteString rangeOfString:@"#"].location != NSNotFound) {
        NSString* params = [[request.URL.absoluteString componentsSeparatedByString:@"#"] objectAtIndex:1];
        self.accessToken = [params stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
        self.webView.hidden = YES;
        [self requestImages];
        //[self requestUserfeed];
    }
    
	return YES;
}

#pragma mark - image loading

- (void)requestImages
{
    [HSInstagramUserMedia getUserMediaWithId:@"self" withAccessToken:self.accessToken block:^(NSArray *records) {
        [self.images addObjectsFromArray:records];
        //self.images = records;
        for (NSDictionary* image in records) {
            UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(col*kthumbnailWidth,
                                                                          row*kthumbnailHeight,
                                                                          kthumbnailWidth,
                                                                          kthumbnailHeight)];
            button.tag = item;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            ++col;++item;
            if (col >= kImagesPerRow) {
                row++;
                col = 0;
            }
            [self.gridScrollView addSubview:button];
            [self.thumbnails addObject:button];
        }
        //[self loadImages];
        [self requestUserfeed];
    }];
}

- (void)requestUserfeed
{
    [HSInstagramUserMedia getUserFeedMedia:@"self" withAccessToken:self.accessToken block:^(NSArray *records) {
        [self.images addObjectsFromArray:records];
        //self.images = records;
        //int item = 0, row = 0, col = 0;
        for (NSDictionary* image in records) {
            UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(col*kthumbnailWidth,
                                                                          row*kthumbnailHeight,
                                                                          kthumbnailWidth,
                                                                          kthumbnailHeight)];
            button.tag = item;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            ++col;++item;
            if (col >= kImagesPerRow) {
                row++;
                col = 0;
            }
            [self.gridScrollView addSubview:button];
            [self.thumbnails addObject:button];
        }
        [self loadImages];
    }];
}

- (void)loadImages
{
    int item = 0;

    for (HSInstagramUserMedia* media in self.images) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSString* thumbnailUrl = media.thumbnailUrl;
            NSData* data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:thumbnailUrl]];
            UIImage* image = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                UIButton* button = [self.thumbnails objectAtIndex:item];
                [button setImage:image forState:UIControlStateNormal];
            });
        });
        ++item;
    }

}

#pragma mark - button actions

- (void)buttonAction:(id)sender
{
    UIButton* button = sender;
    HSImageViewController* img = [[HSImageViewController alloc] initWithMedia:[self.images objectAtIndex:button.tag]];
    [self.navigationController pushViewController:img animated:YES];
}

@end
