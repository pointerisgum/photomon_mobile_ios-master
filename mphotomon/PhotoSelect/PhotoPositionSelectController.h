//
//  PhotoPositionSelectController.h
//  PHOTOMON
//
//  Created by 곽세욱 on 02/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>

NS_ASSUME_NONNULL_BEGIN

@import GoogleSignIn;
@import FBSDKLoginKit;

@interface PhotoPositionSelectController : UIViewController <UICollectionViewDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

@property (strong, nonatomic) NSArray *allowPosition;

#pragma mark - Data
@property (assign) BOOL isFirst;       // 가이드 한번만 보이도록
@property (assign) BOOL isSinglemode;  // 한장 선택, 다중 선택

@property (assign) int  minPictureCount;   //
@property (assign) int  positionType;	//
@property (strong, nonatomic) NSString *param; // 사진인화일 경우 크기 정보 포함. 그밖에는 @""

@property (copy) void(^cancelOp)(UIViewController *);
@property (copy) void(^selectDoneOp)(UIViewController *);

#pragma mark - Action
@property (strong, nonatomic) id<SelectPhotoDelegate> delegate;

- (void)setData:(id<SelectPhotoDelegate>)delegate isSinglemode:(BOOL)isSinglemode minPictureCount:(int)minPictureCount param:(NSString *)param;

- (IBAction)cancel:(id)sender;

@end

NS_ASSUME_NONNULL_END
