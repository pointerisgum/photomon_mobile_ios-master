//
//  CardDetailViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface CardDetailViewController : UIViewController

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;

@property (strong, nonatomic) IBOutlet UILabel *product_size;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *discount;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;
@property (strong, nonatomic) IBOutlet UIButton *done_button;
@property (weak, nonatomic) IBOutlet UILabel *scodix_title;
@property (weak, nonatomic) IBOutlet UIButton *scodix_button;
@property (weak, nonatomic) IBOutlet UIButton *scodix_select;
@property (weak, nonatomic) IBOutlet UILabel *option_title;
@property (weak, nonatomic) IBOutlet UIButton *option_button;
@property (weak, nonatomic) IBOutlet UIButton *option_select;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_scodix_1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_scodix_2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_scodix_3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_option_1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_option_2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_option_3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_delivery_1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_delivery_2;

@property (assign) int scodix_idx;
@property (assign) int option_idx;

- (void)updateTheme;
- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;
- (IBAction)selectScodix:(id)sender;
- (IBAction)selectOption:(id)sender;

@end
