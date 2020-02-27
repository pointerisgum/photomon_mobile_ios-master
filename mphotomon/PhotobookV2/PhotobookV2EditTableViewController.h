//
//  PhotobookV2EditTableViewController.h
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 23..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photobook.h"
//#import "ThumbCollectionViewController.h"
#import "PhotobookV2LayoutViewController.h"
#import "PhotobookV2BackgroundViewController.h"
#import "CardEditTextViewController.h"
#import "PhotoCropViewController.h"
#import "GuideViewController.h"
#import "MBProgressHUD.h"
#import "ProgressView.h"

@interface PhotobookV2EditTableViewController : UIViewController <PhotobookV2LayoutViewControllerDelegate, PhotobookV2BackgroundViewControllerDelegate, PhotoCropViewControllerDelegate, PhotobookDelegate, SelectPhotoDelegate, MBProgressHUDDelegate, GuideDelegate, CardEditTextDelegate>

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) ProgressView *progressView;

@property (strong, nonatomic) IBOutlet UITableView *table_view;

@property (assign) BOOL is_warning;
@property (assign) BOOL is_new;
@property (assign) NSInteger selected_page;
@property (strong, nonatomic) NSString *select_popupBtnTitle;
@property (strong, nonatomic) Page *default_page;
@property (strong, nonatomic) Layer *selected_layer;
@property (strong, nonatomic) IBOutlet UIView *cover_popup;
@property (strong, nonatomic) IBOutlet UIView *cover_onlyLayout_popup;//cmh 구닥북일 경우에는 레이아웃 변경만 나오게 처리
@property (strong, nonatomic) IBOutlet UIView *prolog_popup;
@property (strong, nonatomic) IBOutlet UIView *page_popup;
@property (strong, nonatomic) IBOutlet UIView *fixed_page_popup;
@property (strong, nonatomic) IBOutlet UIView *analogpage_popup;
@property (strong, nonatomic) IBOutlet UIView *photo_popup;
@property (strong, nonatomic) IBOutlet UIView *premiumpage_popup;
@property (strong, nonatomic) IBOutlet UIView *premiumfirstpage_popup;
//@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *premiumfirstpage_popup;
@property (weak, nonatomic) IBOutlet UIButton *page_button;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *message_constraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *title_constraint;
@property (strong, nonatomic) IBOutlet UITextField *title_text;
@property (strong, nonatomic) IBOutlet UIButton *title_button;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *save_button;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel_button;
@property (nonatomic) CGFloat edittext_width;
@property (nonatomic) CGFloat edittext_height;

- (void)clearSelectedInfo;
- (void)startFillPhotoThread;

- (IBAction)setBookTitle:(id)sender;
- (IBAction)clickMessage:(id)sender;
- (IBAction)clickPageButton:(id)sender;
- (IBAction)addPage:(id)sender;
- (IBAction)deletePage:(id)sender;
- (IBAction)moveupPage:(id)sender;
- (IBAction)movedownPage:(id)sender;
- (IBAction)changePageLayout:(id)sender;
- (IBAction)changePageBackground:(id)sender;
- (IBAction)resetTitle:(id)sender;
- (IBAction)addPhoto:(id)sender;
- (IBAction)deletePhoto:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)goCropPhoto:(id)sender;

@end
