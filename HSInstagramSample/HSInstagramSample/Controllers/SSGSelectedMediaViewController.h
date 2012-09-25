//
//  SSGSelectedMediaViewController.h
//  HSInstagramSample
//
//  Created by Sarabjeet Singh Gaba on 24/09/12.
//  Copyright (c) 2012 Pushbits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSGSelectedMediaViewController : UIViewController

@property (nonatomic, strong) UIScrollView* gridScrollView;
@property (nonatomic, strong) NSMutableArray* images;
@property (nonatomic, strong) NSMutableArray* thumbnails;

@end
