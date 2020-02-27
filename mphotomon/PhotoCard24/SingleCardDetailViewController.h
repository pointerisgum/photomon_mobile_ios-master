//
//  DesignPhotoDetailViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 2..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

typedef enum {
    kPhotoCardPrice = 0,
    kPhotoCardType,
    kPhotoCardSize,
    kPhotoCardForm,
    kPhotoCardOption1,
    kPhotoCardOPCount1,
    kPhotoCardOption2,
    kPhotoCardOPCount2,
    kPhotoCardMeg,
    kPhotoCardCharge,
    kPhotoCardTotal
}kPhotoCardMake;


@interface SingleCardDetailViewController : UIViewController

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;

@property (assign) int option_idx;
@property (assign) int option_idx2;
@property (assign) int option_idx_count;
@property (assign) int option_idx2_count;
//@property (strong, nonatomic) SelectOption *sel_option;
@property (strong, nonatomic) NSString *cardType;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;

@property (strong, nonatomic) NSMutableArray *thumbs;
//@property (strong, nonatomic) IBOutlet UIButton *booksizes;
//@property (strong, nonatomic) IBOutlet UILabel *discount;
//@property (strong, nonatomic) IBOutlet UIButton *option_button;
//@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_optionbtn_width;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_optionbtn_height;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_optionbtn_topmargin;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)updateTheme;

- (IBAction)goEdit:(id)sender;
- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;
- (IBAction)selectBookSize:(id)sender;
- (IBAction)selectOption:(id)sender;
@end
