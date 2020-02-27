//
//  PolaroidDetailViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 2..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface PolaroidDetailViewController : UIViewController

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;

@property (assign) int coating_idx;
@property (assign) int option_idx;
//@property (strong, nonatomic) SelectOption *sel_coating;
//@property (strong, nonatomic) SelectOption *sel_option;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;

@property (strong, nonatomic) NSMutableArray *thumbs;
//@property (strong, nonatomic) IBOutlet UILabel *booksize;
@property (strong, nonatomic) IBOutlet UIButton *booksizes;
@property (strong, nonatomic) IBOutlet UILabel *discount;
@property (strong, nonatomic) IBOutlet UIButton *coating_button;
@property (strong, nonatomic) IBOutlet UIButton *option_button;
@property (strong, nonatomic) IBOutlet UILabel *minphotocountmsg;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_optionbtn_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_optionbtn_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_optionbtn_topmargin;

- (void)updateTheme;
- (void)updateTheme:(int)idx;

- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;
- (IBAction)selectBookSize:(id)sender;
- (IBAction)selectCoating:(id)sender;
- (IBAction)selectOption:(id)sender;
@end
