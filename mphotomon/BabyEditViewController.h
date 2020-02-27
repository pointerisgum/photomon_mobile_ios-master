//
//  BabyEditViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 5..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photobook.h"
#import "PhotoCropViewController.h"
#import "GuideViewController.h"
#import "MBProgressHUD.h"
#import "ProgressView.h"

@interface BabyEditViewController : UIViewController <PhotoCropViewControllerDelegate, PhotobookDelegate, SelectPhotoDelegate, MBProgressHUDDelegate, GuideDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIView *activeTextField;

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) ProgressView *progressView;

@property (strong, nonatomic) IBOutlet UITableView *table_view;

@property (assign) BOOL is_new;

@property (assign) NSInteger selected_page;
@property (strong, nonatomic) Layer *selected_layer;
@property (strong, nonatomic) IBOutlet UIView *photo_popup;

@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view4;
@property (weak, nonatomic) IBOutlet UIView *view5;
@property (weak, nonatomic) IBOutlet UIScrollView* scrollview;

@property (weak, nonatomic) IBOutlet UITextField *v1_f1;
@property (weak, nonatomic) IBOutlet UITextView *v1_f2;
@property (weak, nonatomic) IBOutlet UITextView *v1_f3;
@property (weak, nonatomic) IBOutlet UILabel *v1_f4;
@property (weak, nonatomic) IBOutlet UIButton *v1_f4_1;
@property (weak, nonatomic) IBOutlet UITextField *v2_f1;
@property (weak, nonatomic) IBOutlet UITextView *v2_f2;
@property (weak, nonatomic) IBOutlet UILabel *v2_f3;
@property (weak, nonatomic) IBOutlet UIButton *v2_f3_1;
@property (weak, nonatomic) IBOutlet UITextView *v2_f4;
@property (weak, nonatomic) IBOutlet UILabel *v3_f1;
@property (weak, nonatomic) IBOutlet UIButton *v3_f1_1;
@property (weak, nonatomic) IBOutlet UILabel *v3_f3;
@property (weak, nonatomic) IBOutlet UIButton *v3_f3_1;
@property (weak, nonatomic) IBOutlet UITextView *v3_f4;
@property (weak, nonatomic) IBOutlet UILabel *v4_f1;
@property (weak, nonatomic) IBOutlet UIButton *v4_f1_1;
@property (weak, nonatomic) IBOutlet UILabel *v4_f2;
@property (weak, nonatomic) IBOutlet UIButton *v4_f2_1;
@property (weak, nonatomic) IBOutlet UITextView *v4_f3;
@property (weak, nonatomic) IBOutlet UILabel *v5_f1;
@property (weak, nonatomic) IBOutlet UIButton *v5_f1_1;
@property (weak, nonatomic) IBOutlet UILabel *v5_f2;
@property (weak, nonatomic) IBOutlet UIButton *v5_f2_1;
@property (weak, nonatomic) IBOutlet UITextView *v5_f3;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *message_constraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *save_button;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel_button;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_v1_f1_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_v2_f1_width;

- (void)clearSelectedInfo;
- (void)startFillPhotoThread;

- (IBAction)clickMessage:(id)sender;
- (IBAction)addPhoto:(id)sender;
- (IBAction)changePhoto:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
