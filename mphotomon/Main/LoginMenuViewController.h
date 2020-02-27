//
//  LoginMenuViewController.h
//  PHOTOMON
//
//  Created by 김민아 on 05/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LoginMenuDelegate  <NSObject>

- (void)didTouchCloseButton;
- (void)didTouchSettingButton;
- (void)didTouchMenuCategory:(NSInteger)categoryNum;
- (void)didTouchLogoutButton;

@end

@interface LoginMenuViewController : UIViewController

@property (assign, nonatomic) id<LoginMenuDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
