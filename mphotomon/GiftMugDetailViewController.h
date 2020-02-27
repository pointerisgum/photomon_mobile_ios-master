//
//  GiftMugDetailViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface GiftMugDetailViewController : UIViewController

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;

@property (strong, nonatomic) IBOutlet UILabel *product_size;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *discount;
@property (strong, nonatomic) IBOutlet UILabel *ml;
@property (strong, nonatomic) IBOutlet UILabel *material;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;
@property (strong, nonatomic) IBOutlet UIButton *done_button;

- (void)updateTheme;
- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;

@end
