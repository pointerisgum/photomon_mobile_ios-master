//
//  BabyDetailViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface BabyDetailViewController : UIViewController

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;
@property (weak, nonatomic) IBOutlet UIView *info_popup_view;
@property (weak, nonatomic) IBOutlet UIWebView *info_popup_webview;
@property (weak, nonatomic) IBOutlet UIView *info_btn;
@property (weak, nonatomic) IBOutlet UIButton *info_close_btn;
@property (weak, nonatomic) IBOutlet UIButton *information_btn;
@property (weak, nonatomic) IBOutlet UIButton *zoom_btn;

@property (strong, nonatomic) IBOutlet UILabel *product_size;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *price_strike;
@property (strong, nonatomic) IBOutlet UILabel *discount;
@property (strong, nonatomic) IBOutlet UILabel *basicset;
@property (strong, nonatomic) IBOutlet UILabel *minpictures;
@property (strong, nonatomic) IBOutlet UILabel *material;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;
@property (strong, nonatomic) IBOutlet UIButton *done_button;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_info_btn_leading_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_info_popup_leading_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_contentview_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_info_popup_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_top_margin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_view_height;

- (void)updateTheme;
- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;
- (IBAction)openPopupInfo:(id)sender;
- (IBAction)closePopupInfo:(id)sender;

@end
