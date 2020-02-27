//
//  CollageEditViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 1. 26..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Collage.h"
#import "Common.h"
#import "ColorView.h"
#import "FrameUploadViewController.h"
#import "GuideViewController.h"
#import "MBProgressHUD.h"
#import "ProgressView.h"

@protocol CollageEditDelegate <NSObject>
@optional
- (void)completeEdit;
@end

@interface CollageEditViewController : UIViewController <UIScrollViewDelegate, CollageDelegate, FrameUploadDelegate, MBProgressHUDDelegate, GuideDelegate>

@property (strong, nonatomic) id<CollageEditDelegate> delegate;

@property (assign) BOOL is_first;
@property (assign) BOOL is_collage;
@property (assign) BOOL no_hud;

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) MBProgressHUD *HUD;
@property (strong, nonatomic) ProgressView *progressView;

@property (strong, nonatomic) BookInfo *book_info;
@property (strong, nonatomic) NSString *base_folder;

@property (strong, nonatomic) NSString *guideImage;

@property (strong, nonatomic) Cell *editCell;
@property (strong, nonatomic) Cell *dummyCell;

@property (strong, nonatomic) UIScrollView *cellScrollView;
@property (strong, nonatomic) UIImageView *cellImageView;

@property (strong, nonatomic) IBOutlet Collage *collage;
@property (strong, nonatomic) IBOutlet UIView *cellEditView;
@property (strong, nonatomic) IBOutlet UIImageView *deleteView;
@property (strong, nonatomic) IBOutlet UIView *toolbarView;
@property (strong, nonatomic) IBOutlet UIView *popupLayout;
@property (strong, nonatomic) IBOutlet UIView *popupBorder;
@property (strong, nonatomic) IBOutlet UISlider *slider_gap_thumb;
@property (strong, nonatomic) IBOutlet UISlider *slider_round_thumb;
@property (strong, nonatomic) IBOutlet UISlider *slider_color_thumb;
@property (strong, nonatomic) IBOutlet UILabel *color_value;
@property (strong, nonatomic) IBOutlet ColorView *color_view;
@property (strong, nonatomic) IBOutlet UILabel *gap_label;
@property (strong, nonatomic) IBOutlet UILabel *round_label;
@property (strong, nonatomic) IBOutlet UILabel *color_label;

@property (weak, nonatomic) IBOutlet UIButton *cancel_button;
@property (weak, nonatomic) IBOutlet UIButton *done_button;

- (IBAction)undoAll:(id)sender;
- (IBAction)rotateLeft:(id)sender;
- (IBAction)rotateRight:(id)sender;

- (IBAction)addPhoto:(id)sender;
- (IBAction)shuffle:(id)sender;
- (IBAction)changeLayout:(id)sender;
- (IBAction)changeBorder:(id)sender;
- (IBAction)exitCellEditMode:(id)sender;

- (IBAction)layout01:(id)sender;
- (IBAction)layout02:(id)sender;
- (IBAction)layout03:(id)sender;
- (IBAction)layout04:(id)sender;
- (IBAction)changedGap:(id)sender;
- (IBAction)changedRound:(id)sender;
- (IBAction)changedColor:(id)sender;
- (IBAction)touchUpInsideColor:(id)sender;
- (IBAction)touchUpOutsideColor:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
