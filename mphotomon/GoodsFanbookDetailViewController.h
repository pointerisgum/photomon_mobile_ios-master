//
//  GoodsFanbookDetailViewController.h
//  PHOTOMON
//
//  Created by 안영건 on 02/05/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookInfo;
@class Theme;

NS_ASSUME_NONNULL_BEGIN

@interface GoodsFanbookDetailViewController : UIViewController

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;
@property (strong, nonatomic) NSString *select_size;
@property (strong, nonatomic) NSString *select_covertype;

@property (assign) int option_idx; // SJYANG
@property (assign) int coverlogo_y; // SJYANG
@property (weak, nonatomic) IBOutlet UIView *coverlogo_popup_view;
@property (weak, nonatomic) IBOutlet UIWebView *coverlogo_popup_webview;

@property (weak, nonatomic) IBOutlet UIScrollView *scroll_view;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;
@property (weak, nonatomic) IBOutlet UIView *content_view;

//@property (strong, nonatomic) NSMutableArray *thumbs;
@property (weak, nonatomic) IBOutlet UILabel *booksize_title;
@property (strong, nonatomic) IBOutlet UIButton *booksize;
@property (weak, nonatomic) IBOutlet UIButton *booksize_icon;
@property (weak, nonatomic) IBOutlet UILabel *innerCorting;//내지코팅
@property (weak, nonatomic) IBOutlet UIButton *innerCorting_btn;//내지코팅
@property (weak, nonatomic) IBOutlet UIButton *innerCorting_btn_opt;//내지코팅
@property (weak, nonatomic) IBOutlet UILabel *covertype_title;
@property (weak, nonatomic) IBOutlet UILabel *price_title;
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *price_strike;
@property (strong, nonatomic) IBOutlet UILabel *discount;
@property (weak, nonatomic) IBOutlet UILabel *minpictures_title;
@property (strong, nonatomic) IBOutlet UILabel *minpictures;
@property (strong, nonatomic) IBOutlet UILabel *pages_title;
@property (strong, nonatomic) IBOutlet UILabel *pages;
@property (weak, nonatomic) IBOutlet UILabel *papertype_title;
@property (strong, nonatomic) IBOutlet UILabel *papertype;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;
@property (weak, nonatomic) IBOutlet UILabel *deliverymsg_title;
@property (weak, nonatomic) IBOutlet UILabel *coverlogo_title;
@property (weak, nonatomic) IBOutlet UIButton *coverlogo;
@property (weak, nonatomic) IBOutlet UIButton *coverlogo_dropdown;
@property (weak, nonatomic) IBOutlet UIButton *coverlogo_help;
@property (strong, nonatomic) IBOutlet UIButton *done_button;
@property (weak, nonatomic) IBOutlet UIButton *detail_btn;
@property (weak, nonatomic) IBOutlet UIButton *covertype;
@property (weak, nonatomic) IBOutlet UIButton *covertypeIcon;



- (void)updateTheme;
- (IBAction)selectBookSize:(id)sender;
- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;
- (IBAction)selectOption:(id)sender;
- (IBAction)popupCoverLogo:(id)sender;
- (void)setLabelTopConstraint:(UILabel *)obj pos:(int)pos;
- (void)setButtonTopConstraint:(UIButton *)obj pos:(int)pos;
- (IBAction)closePopupCoverLogo:(id)sender;
- (IBAction)selectCoverType:(id)sender;

@end

NS_ASSUME_NONNULL_END
