//
//  FancyDetailViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2018. 1. 30..
//  Copyright © 2018년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface FancyDetailViewController : UIViewController

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;

@property (strong, nonatomic) UITextField *activeTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;

@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *discount;
@property (strong, nonatomic) IBOutlet UILabel *size_desc;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;
@property (strong, nonatomic) IBOutlet UIButton *done_button;
@property (strong, nonatomic) IBOutlet UILabel *order_count;

@property (strong, nonatomic) IBOutlet UILabel *input_title;
@property (strong, nonatomic) IBOutlet UITextField *input_string;
@property (strong, nonatomic) IBOutlet UILabel *input_desc;

@property (strong, nonatomic) IBOutlet UILabel *input_title2;
@property (strong, nonatomic) IBOutlet UITextField *input_string2;
@property (strong, nonatomic) IBOutlet UILabel *input_desc2;

- (void)updateTheme;
- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;
- (IBAction)increaseCount:(id)sender;
- (IBAction)decreaseCount:(id)sender;
- (IBAction)doneClick:(id)sender;

@end
