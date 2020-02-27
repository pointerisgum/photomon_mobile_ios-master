//
//  CardEditTableViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 10..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photobook.h"
//#import "ThumbCollectionViewController.h"
#import "PageEditCalendarViewController.h"
#import "PhotoCropViewController.h"
#import "GuideViewController.h"
#import "MBProgressHUD.h"
#import "CardEditTextViewController.h"
#import "ProgressView.h"

@interface CardEditTableViewController : UIViewController <PageEditCalendarViewControllerDelegate, PhotoCropViewControllerDelegate, PhotobookDelegate, SelectPhotoDelegate, MBProgressHUDDelegate, GuideDelegate, CardEditTextDelegate>

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) ProgressView *progressView;

@property (strong, nonatomic) IBOutlet UITableView *table_view;

@property (assign) BOOL is_new;

@property (assign) NSInteger selected_page;
@property (nonatomic) CGFloat edittext_width;
@property (nonatomic) CGFloat edittext_height;
@property (strong, nonatomic) Layer *selected_layer;
@property (strong, nonatomic) IBOutlet UIView *photo_popup;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *message_constraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *save_button;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel_button;

- (void)clearSelectedInfo;
- (void)startFillPhotoThread;

- (IBAction)clickMessage:(id)sender;
- (IBAction)addPhoto:(id)sender;
- (IBAction)changePhoto:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
