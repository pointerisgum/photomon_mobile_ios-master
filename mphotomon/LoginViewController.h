//
//  LoginViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LoginViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UITextField *userID;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *btnSocialLoginNaver;
@property (weak, nonatomic) IBOutlet UIButton *btnSocialLoginFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btnSocialLoginKakao;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sc_naver_constraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sc_facebook_constraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leading_constraint;

- (IBAction)login:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)socialLoginNaver:(id)sender;
- (IBAction)socialLoginFacebook:(id)sender;
- (IBAction)socialLoginKakao:(id)sender;

@end
