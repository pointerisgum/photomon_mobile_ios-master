//
//  ThumbCollectionViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 2..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "PhotoPool.h"

@interface ThumbCollectionViewController : UIViewController

@property (assign) BOOL is_singlemode;
@property (assign) int count_max;
@property (strong, nonatomic) id<SelectPhotoDelegate> delegate;

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) UIActivityIndicatorView *wait_indicator;
@property (strong) PHCachingImageManager* image_manager;

@property (strong, nonatomic) PHAssetCollection *selected_group;
@property (strong, nonatomic) NSMutableArray *asset_array;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *next_button;
@property (strong, nonatomic) IBOutlet UICollectionView *selthumb_view;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (weak, nonatomic) IBOutlet UIView *bottom_view;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selthumb_view_constraint_h;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottom_view_constraint_h;

- (void)resetTitle;
- (IBAction)deselectAll:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)clickDelete:(id)sender;
- (IBAction)done:(id)sender;

@end
