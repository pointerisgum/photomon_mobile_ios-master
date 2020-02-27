//
//  UnloginMenuViewController.h
//  PHOTOMON
//
//  Created by 김민아 on 05/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UnloginMenuDelegate  <NSObject>

- (void)didTouchCloseButton;
- (void)didTouchJoinButton;
- (void)didTouchFindIdButton;
- (void)didtouchFindPwButton;
- (void)didTouchViewNomemberOrderButton;
- (void)didTouchSocialLogin:(NSString *)type;
- (void)didTouchSettingButton;
@end


@interface UnloginMenuViewController : UIViewController

@property (assign, nonatomic) id<UnloginMenuDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
