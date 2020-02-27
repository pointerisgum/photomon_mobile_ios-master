//
//  GiftPhonecaseDetailViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "PhotobookUpload.h"

@interface GiftPhonecaseDetailViewController : UIViewController <NSURLConnectionDataDelegate, PhotobookDelegate>

@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) BookInfo *book_info;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UIPageControl *page_control;

@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *discount;
@property (weak, nonatomic) IBOutlet UIButton *device;
@property (weak, nonatomic) IBOutlet UIButton *device_btn;
@property (weak, nonatomic) IBOutlet UIButton *design;
@property (strong, nonatomic) IBOutlet UILabel *design_title;
@property (weak, nonatomic) IBOutlet UIButton *design_btn;
@property (strong, nonatomic) IBOutlet UILabel *material;
@property (strong, nonatomic) IBOutlet UILabel *material_title;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_material_top_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_material_title_top_space;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg;
@property (strong, nonatomic) IBOutlet UILabel *deliverymsg_title;
@property (strong, nonatomic) IBOutlet UIButton *done_button;

- (void)updateTheme;
- (IBAction)popupDetail:(id)sender;
- (IBAction)popupMore:(id)sender;
- (IBAction)selectOption:(id)sender;
- (IBAction)selectOption2:(id)sender;

@end
