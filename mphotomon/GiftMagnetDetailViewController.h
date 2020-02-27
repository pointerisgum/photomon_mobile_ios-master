//
//  GiftMagnetDetailViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 18..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface GiftMagnetDetailViewController : UIViewController

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;

@property (strong, nonatomic) NSMutableArray *thumbs;
@property (strong, nonatomic) IBOutlet UILabel *booksize;
@property (strong, nonatomic) IBOutlet UILabel *discount;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UIButton *pagecount_button;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;
@property (weak, nonatomic) IBOutlet UILabel *option_title;
@property (weak, nonatomic) IBOutlet UIButton *option_select;
@property (weak, nonatomic) IBOutlet UIButton *option_button1;
@property (weak, nonatomic) IBOutlet UIButton *option_button2;

@property (assign) int pagecount_idx;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_deliverymsg_top_space;

- (void)updateTheme;
- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;
- (IBAction)selectOption1:(id)sender;
- (IBAction)selectOption2:(id)sender;

@end
