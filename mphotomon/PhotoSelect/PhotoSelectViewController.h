//
//  PhotoSelectViewController.h
//  PHOTOMON
//
//  Created by 곽세욱 on 03/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "PhotoPool.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoSelectViewController : UIViewController

#pragma mark - Data
@property (assign) BOOL isFirst;       // 가이드 한번만 보이도록
@property (assign) BOOL isSinglemode;  // 한장 선택, 다중 선택
@property (assign) BOOL hasMorePhoto;  // 소셜네트워크에서 더이상 로드할 게 없을때 YES
@property (assign) int  minPictureCount;   //
@property (assign) int  positionType;	//
@property (assign) int  groupIndex;
@property (strong, nonatomic) NSString *param; // 사진인화일 경우 크기 정보 포함. 그밖에는 @""

@property (strong, nonatomic) UIImage *radioOnImage;
@property (strong, nonatomic) UIImage *radioOffImage;

@property (strong, nonatomic) PHAssetCollection	*selectedGroup;

- (void)setData:(id<SelectPhotoDelegate>)delegate positionType:(int)positionType isSinglemode:(BOOL)isSinglemode minPictureCount:(int)minPictureCount param:(NSString *)param;
- (void)setData:(id<SelectPhotoDelegate>)delegate positionType:(int)positionType selectedGroup:(PHAssetCollection *)selectedGroup isSinglemode:(BOOL)isSinglemode minPictureCount:(int)minPictureCount param:(NSString *)param;

#pragma mark - Action
@property (strong, nonatomic) id<SelectPhotoDelegate> delegate;
@property (copy) void(^selectDoneOp)(UIViewController *);

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) UIActivityIndicatorView *waitIndicator;
@property (strong) PHCachingImageManager* imageManager;

#pragma mark - UI
@property (strong, nonatomic) IBOutlet UICollectionView *selectListView;
@property (strong, nonatomic) IBOutlet UICollectionView *photoListView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *naviDoneButton;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *deselectButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doneWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doneCenterX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deselectWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectListViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;

- (IBAction)selectAll:(id)sender;
- (IBAction)clickDelete:(id)sender;
- (IBAction)deselectAll:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)more:(id)sender;

- (IBAction) toggleGroupPhotos:(id)sender;

@end

NS_ASSUME_NONNULL_END
