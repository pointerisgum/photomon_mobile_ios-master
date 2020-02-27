//
//  ZoomViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 17..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface ZoomViewController : UIViewController

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) NSString *option_str;
@property (assign) int product_type;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;

//@property (strong, nonatomic) NSMutableArray *thumbs;

- (IBAction)close:(id)sender;

@end
