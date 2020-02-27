//
//  FancyDivisionStickerDetailViewController.h
//  PHOTOMON
//
//  Created by kim kihwan on 2019. 7. 11..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface FancyDivisionDetailViewController : UIViewController

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;

@property (assign) int option_idx;
@property (assign) int design_idx;
//@property (strong, nonatomic) SelectOption *sel_option;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;

@property (strong, nonatomic) NSMutableArray *thumbs;
//@property (strong, nonatomic) IBOutlet UILabel *booksize;
@property (strong, nonatomic) IBOutlet UIButton *booksizes;
@property (strong, nonatomic) IBOutlet UILabel *discount;
@property (strong, nonatomic) IBOutlet UILabel *option_label;
@property (strong, nonatomic) IBOutlet UIButton *option_button;
@property (strong, nonatomic) IBOutlet UIButton *option_button_opt;
@property (strong, nonatomic) IBOutlet UILabel *design_label;
@property (strong, nonatomic) IBOutlet UIButton *design_button;
@property (strong, nonatomic) IBOutlet UIButton *design_button_opt;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_optionbtn_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_optionbtn_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_optionbtn_topmargin;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_delivery_optionlabel_top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_delivery_nonoptionlabel_top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_delivery_optionbuton_top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_delivery_nonoptionbutton_top;


- (void)updateTheme;

- (IBAction)goEdit:(id)sender;
- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;
- (IBAction)selectBookSize:(id)sender;
- (IBAction)selectOption:(id)sender;
- (IBAction)selectDesign:(id)sender;
@end
