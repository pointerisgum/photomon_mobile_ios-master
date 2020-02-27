//
//  GoodsTransparentCardEditViewController.h
//  PHOTOMON
//
//  Created by 안영건 on 08/05/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCropViewController.h"
#import "MBProgressHUD.h"
#import "GuideViewController.h"
#import "CardEditTextViewController.h"
#import "ProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoodsTransparentCardEditViewController : UIViewController <PhotoCropViewControllerDelegate, PhotobookDelegate, SelectPhotoDelegate, MBProgressHUDDelegate, GuideDelegate, CardEditTextDelegate>

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) ProgressView *progressView;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (weak, nonatomic) IBOutlet UICollectionView *nav_view;

@property (assign) BOOL is_new;

@property (assign) NSInteger selected_page;
@property (assign) NSInteger current_position;
@property (strong, nonatomic) NSMutableArray *nav_item_cnt;
@property (strong, nonatomic) NSMutableArray *nav_item_theme;

@property (nonatomic) CGFloat edittext_width;
@property (nonatomic) CGFloat edittext_height;
@property (strong, nonatomic) Layer *selected_layer;
@property (strong, nonatomic) IBOutlet UIView *photo_popup;
@property (weak, nonatomic) IBOutlet UIButton *btn_pageadd;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *message_constraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *save_button;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel_button;

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

@end

NS_ASSUME_NONNULL_END
