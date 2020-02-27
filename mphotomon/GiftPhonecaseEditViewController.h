//
//  GiftPhonecaseEditViewController.h
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

@interface GiftPhonecaseEditViewController : UIViewController <PhotoCropViewControllerDelegate, PhotobookDelegate, SelectPhotoDelegate, MBProgressHUDDelegate, GuideDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) ProgressView *progressView;
@property (strong, nonatomic) UIView *activeTextField;

@property (strong, nonatomic) IBOutlet UITableView *table_view;

@property (assign) BOOL is_new;
@property (assign) BOOL has_textlayer;
@property (weak, nonatomic) IBOutlet UIView *title_view;

@property (assign) NSInteger selected_page;
@property (strong, nonatomic) Layer *selected_layer;
@property (strong, nonatomic) IBOutlet UIView *photo_popup;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *message_constraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *save_button;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel_button;
@property (weak, nonatomic) IBOutlet UIButton *title_button;
@property (weak, nonatomic) IBOutlet UITextField *title_text;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *title_constraint;

- (void)clearSelectedInfo;
- (void)startFillPhotoThread;

- (IBAction)clickMessage:(id)sender;
- (IBAction)addPhoto:(id)sender;
- (IBAction)changePhoto:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)setPhonecaseTitle:(id)sender;

@end
