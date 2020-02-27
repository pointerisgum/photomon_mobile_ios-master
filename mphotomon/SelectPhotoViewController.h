//
//  SelectPhotoViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 1..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "PhotoPool.h"

@interface SelectPhotoViewController : UIViewController

@property (assign) BOOL is_singlemode;
@property (assign) int  min_pictures;
@property (strong, nonatomic) NSString *param;

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) UIActivityIndicatorView *wait_indicator;
@property (strong) PHCachingImageManager* image_manager;

@property (strong, nonatomic) id<SelectPhotoDelegate> delegate;
@property (strong, nonatomic) PHAssetCollection	*selected_group;
@property (strong, nonatomic) NSMutableArray *asset_array;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *next_button;
@property (strong, nonatomic) IBOutlet UICollectionView *selthumb_view;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (weak, nonatomic) IBOutlet UIView *bottom_view;
@property (strong, nonatomic) IBOutlet UIButton *select_toggle;
@property (weak, nonatomic) IBOutlet UIButton *deselect_toggle;
@property (weak, nonatomic) IBOutlet UIButton *done_button;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_done_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_done_centerx;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_deselect_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_select_width;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selthumb_view_constraint_h;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_view_constraint_h;

- (void)resetTitle;
- (IBAction)clickDelete:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)deselectAll:(id)sender;
- (IBAction)done:(id)sender;

@end
