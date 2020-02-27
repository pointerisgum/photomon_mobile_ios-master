//
//  JoinTypeViewController.m
//  PHOTOMON
//
//  Created by 김민아 on 07/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "JoinTypeViewController.h"
#import "SocialLoginViewController.h"
#import "NewWebViewController.h"
#import "Common.h"

@interface JoinTypeViewController () 

@end

@implementation JoinTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([Common info].user.mUserid.length > 0) {
        [self dismissViewControllerAnimated:false completion:nil];
    }
}

- (void)moveToSocialJoinVC:(NSString *)type {
    
    SocialLoginViewController *socialLoginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stid-socialLoginVC"];
    
    socialLoginVC.agent = type;
    
    [self.navigationController presentViewController:socialLoginVC animated:true completion:nil];

}

- (IBAction)didTouchKakaoJoinButton:(UIButton *)sender {
    [self moveToSocialJoinVC:@"kakao"];
}

- (IBAction)didTouchNaverJoinButton:(UIButton *)sender {
    [self moveToSocialJoinVC:@"naver"];
}

- (IBAction)didTouchFacebookJoinButton:(UIButton *)sender {
    [self moveToSocialJoinVC:@"facebook"];
}

- (IBAction)didTouchCloseButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTouchLoginButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:^{
        [[Common info].main_controller didTouchMenuButton:nil];
    }];
}

- (IBAction)didTouchTermButton:(UIButton *)sender {
    NewWebViewController *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stid-newWebVC"];
    webVC.type = WebViewTypeTerms;
    [self.navigationController pushViewController:webVC animated:true];
}

- (IBAction)didTouchUserInfoButton:(UIButton *)sender {
    NewWebViewController *webVC = [self.storyboard instantiateViewControllerWithIdentifier:@"stid-newWebVC"];
    webVC.type = WebViewTypeUserInfo;
    [self.navigationController pushViewController:webVC animated:true];

}


@end
