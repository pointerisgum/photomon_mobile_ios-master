//
//  AlbumSelectViewController.h
//  PHOTOMON
//
//  Created by 곽세욱 on 03/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlbumSelectViewController : UIViewController

#pragma mark - Data
@property (assign) BOOL isFirst;       // 가이드 한번만 보이도록
@property (assign) BOOL isSinglemode;  // 한장 선택, 다중 선택
@property (assign) int  minPictureCount;   //
@property (assign) int  positionType;	//
@property (strong, nonatomic) NSString *param; // 사진인화일 경우 크기 정보 포함. 그밖에는 @""

@property (strong, nonatomic) NSMutableArray *groupArray;

- (void)setData:(id<SelectPhotoDelegate>)delegate positionType:(int)positionType isSinglemode:(BOOL)isSinglemode minPictureCount:(int)minPictureCount param:(NSString *)param;

#pragma mark - Action
@property (strong, nonatomic) id<SelectPhotoDelegate> delegate;
@property (copy) void(^selectDoneOp)(UIViewController *);

#pragma mark - UI

@property (strong, nonatomic) IBOutlet UICollectionView *selectListView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectListViewHeight;

@property (strong, nonatomic) IBOutlet UITableView      *albumListView;

- (IBAction)clickDelete:(id)sender;
- (IBAction)done:(id)sender;

//- (void)popupGuidePage:(NSString *)guide_id;

@end

NS_ASSUME_NONNULL_END
