//
//  CalendarDetailViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 10..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface CalendarDetailViewController : UIViewController

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;

@property (assign) int start_year;
@property (assign) int start_month;

@property (assign) NSInteger selectOptionIdx;

@property (strong, nonatomic) NSString *discountValue;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;

@property (strong, nonatomic) NSMutableArray *thumbs;
@property (strong, nonatomic) IBOutlet UIButton *selected_start;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *discount;
@property (strong, nonatomic) IBOutlet UILabel *minpictures;
@property (strong, nonatomic) IBOutlet UILabel *pages;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;
@property (strong, nonatomic) IBOutlet UILabel *price_hypen;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *price_width_constraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_content_view_top_space;

@property (strong, nonatomic) IBOutlet UILabel *select_option;
@property (weak, nonatomic) IBOutlet UIButton *select_option_btn;
@property (weak, nonatomic) IBOutlet UIButton *select_option_sidebtn;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *option_select_constraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *minpicture_constraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *option_select_btn_constraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *minpicture_btn_constraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *option_select_sidebtn_constraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *minpicture_sidebtn_constraint;

@property (weak, nonatomic) IBOutlet UIButton *product_size;
@property (weak, nonatomic) IBOutlet UIButton *product_size_btn;

- (void)updateTheme;
- (IBAction)selectStartYearMonth:(id)sender;
- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;
- (IBAction)onSubmit:(id)sender;
- (IBAction)selectSize:(id)sender;
- (IBAction)selectOption:(id)sender;

@end
