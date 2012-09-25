//
//  SSGSelectedMediaViewController.m
//  HSInstagramSample
//
//  Created by Sarabjeet Singh Gaba on 24/09/12.
//  Copyright (c) 2012 Pushbits. All rights reserved.
//

#import "SSGSelectedMediaViewController.h"
#import "HSInstagramUserMedia.h"

/*const NSInteger kthumbnailWidth = 80;
const NSInteger kthumbnailHeight = 80;
const NSInteger kImagesPerRow = 4;*/

@interface SSGSelectedMediaViewController ()

@end

@implementation SSGSelectedMediaViewController

@synthesize images = _images;
@synthesize thumbnails = _thumbnails;
@synthesize gridScrollView = _gridScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.thumbnails = [[NSMutableArray alloc] init];
    self.gridScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.gridScrollView.contentSize = self.view.bounds.size;
    [self.view addSubview:self.gridScrollView];
    
    [self fetchSelectedImages];
}

- (void)fetchSelectedImages
{
    int cell = 0, roww = 0, coll = 0;
    
    for (NSDictionary* image in arrSelectedMedia) 
    {
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(coll*80,
                                                                      roww*80,
                                                                      80,
                                                                      80)];
        button.tag = cell;
        //[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        ++coll;++cell;
        if (coll >= 4) {
            roww++;
            coll = 0;
        }
        [self.gridScrollView addSubview:button];
        [self.thumbnails addObject:button];
    }
    [self loadImages];
}

- (void)loadImages
{
    int cell = 0;
    
    for (HSInstagramUserMedia* media in arrSelectedMedia) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSString* thumbnailUrl = media.thumbnailUrl;
            NSData* data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:thumbnailUrl]];
            UIImage* image = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                UIButton* button = [self.thumbnails objectAtIndex:cell];
                [button setImage:image forState:UIControlStateNormal];
            });
        });
        ++cell;
    }
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
