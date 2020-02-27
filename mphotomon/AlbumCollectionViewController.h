//
//  AlbumCollectionViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 2..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbCollectionViewController.h"
#import "PhotoPool.h"

@interface AlbumCollectionViewController : UIViewController

@property (assign) BOOL is_first; // 가이드 한번만 보이도록

@property (assign) BOOL is_singlemode;
@property (assign) int count_max;
//@property (assign) int parent_editor_type;
@property (strong, nonatomic) id<SelectPhotoDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *group_array;

@property (strong, nonatomic) IBOutlet UICollectionView *selthumb_view;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selthumb_view_constraint_h;

- (IBAction)clickDelete:(id)sender;
- (IBAction)cancel:(id)sender;

@end
