//
//  PhotoCollectionViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 6. 26..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PhotoCollectionViewController : UIViewController

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *next_button;
@property (strong, nonatomic) IBOutlet UIButton *select_toggle;
@property (strong, nonatomic) UIActivityIndicatorView *wait_indicator;
@property (strong) PHCachingImageManager* image_manager;

@property (strong, nonatomic) PHAssetCollection *selectedGroup;
@property (strong, nonatomic) NSMutableArray *assetArray;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

- (void)resetTitle;
- (IBAction)deselectAll:(id)sender;
- (IBAction)selectAll:(id)sender;


@end
