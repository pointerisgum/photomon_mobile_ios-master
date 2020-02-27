//
//  MonthlyOptionCoverEditViewController.h
//  PHOTOMON
//
//  Created by Codenist on 2019. 7. 23..
//  Copyright © 2019년 maybeone. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Photobook.h"
#import "PhotoCropViewController.h"
#import "GuideViewController.h"
#import "CardEditTextViewController.h"
#import "MBProgressHUD.h"

@interface MonthlyOptionCoverEditViewController : UIViewController <PhotoCropViewControllerDelegate, PhotobookDelegate, SelectPhotoDelegate, MBProgressHUDDelegate, GuideDelegate, CardEditTextDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) MBProgressHUD *HUD;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (weak, nonatomic) IBOutlet UICollectionView *nav_view;

@property (assign) BOOL is_new;
@property (assign) int product_type;

@property (assign) NSString *imageKey;

@property (assign) NSInteger selected_page;
@property (assign) NSInteger current_position;
@property (strong, nonatomic) NSMutableArray *nav_item_cnt;
@property (strong, nonatomic) NSMutableArray *nav_item_theme;

@property (nonatomic) CGFloat edittext_width;
@property (nonatomic) CGFloat edittext_height;
@property (strong, nonatomic) Layer *selected_layer;
@property (strong, nonatomic) IBOutlet UIView *photo_popup;
@property (weak, nonatomic) IBOutlet UIButton *btn_pageadd;
@property (strong, nonatomic) IBOutlet UIView *buttonViedw;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *message_constraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *save_button;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel_button;
@property (strong, nonatomic) IBOutlet UILabel *uploadInfoLabel;

@property (strong, nonatomic) Photobook *photobook;
//@property (strong, nonatomic) Photo *selectedPhoto;
@property (strong, nonatomic) PhotoItem *selectedPhoto;

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UITextField *mainTitleTextField;
@property (strong, nonatomic) IBOutlet UITextField *subTitleTextField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewYOffset;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *nextButtonYPositionConstraint;

- (void)clearSelectedInfo;
- (void)startFillPhotoThread;

- (IBAction)button_pageedit_click:(UIButton *)btn;
- (IBAction)button_removepage_click:(UIButton *)btn;
- (IBAction)button_increasecnt_click:(UIButton *)btn;
- (IBAction)button_decreasecnt_click:(UIButton *)btn;
- (IBAction)addPage:(id)sender;
- (void)removePage:(int)pageno;
- (IBAction)clickMessage:(id)sender;
- (IBAction)addPhoto:(id)sender;
- (IBAction)changePhoto:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)goCropPhoto:(id)sender;
- (IBAction)moveNext:(id)sender;

@end
