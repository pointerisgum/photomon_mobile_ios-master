//
//  LoginViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "LoginViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "SocialLoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // keyboard_bar
    [self registerForKeyboardNotifications];
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"KeyboardBar" owner:nil options:nil];
    UIView *keyboardView = [nibViews lastObject];
    UIButton *button1 = (UIButton *)[keyboardView viewWithTag:100];
    UIButton *button2 = (UIButton *)[keyboardView viewWithTag:101];
    [button1 addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [button2 addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"뒤로" forState:UIControlStateNormal];
    [button2 setTitle:@"로그인" forState:UIControlStateNormal];
    _userID.inputAccessoryView = keyboardView;
    _password.inputAccessoryView = keyboardView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Analysis firAnalyticsWithScreenName:@"photomonLogin" ScreenClass:[self.classForCoder description]];
}

// SJYANG : 2016.06.27
- (void)viewWillLayoutSubviews {
	CGRect btnSocialLoginNaverFrame = [_btnSocialLoginNaver frame];
	CGRect btnSocialLoginKakaoFrame = [_btnSocialLoginKakao frame];
	int x2 = [[self view] bounds].size.width - (btnSocialLoginKakaoFrame.origin.x + btnSocialLoginKakaoFrame.size.width);

	int scBtnWidth = ([[self view] bounds].size.width - btnSocialLoginNaverFrame.origin.x - x2 - 5 * 2) / 3;
    _sc_naver_constraint.constant = scBtnWidth;
    _sc_facebook_constraint.constant = scBtnWidth;
}

// SJYANG : 2016.06.28
- (void)viewWillAppear:(BOOL)animated{
	NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [userDefault stringForKey:@"userID"];
    NSString *loginType = [userDefault stringForKey:@"loginType"];
    if (user_id.length > 0 && loginType.length > 0) {
		[self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        [self dismissViewControllerAnimated:YES completion:nil];
		return;
    }

    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}
- (void)keyboardWillShow:(NSNotification*)aNotification {
}
- (void)keyboardDidShow:(NSNotification*)aNotification {
}
- (void)keyboardWillHide:(NSNotification*)aNotification {
}
- (void)keyboardDidHide:(NSNotification*)aNotification {
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        UIResponder *next = [textField.superview viewWithTag:textField.tag+1];
        [next becomeFirstResponder];
    } else if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
        
        [self login:nil];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// SJYANG : 2016.06.27
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SocialLoginNaverSegue"]) {
        SocialLoginViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.agent = @"naver";
        }
    }
    else if ([segue.identifier isEqualToString:@"SocialLoginFacebookSegue"]) {
        SocialLoginViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.agent = @"facebook";
        }
    }
    else if ([segue.identifier isEqualToString:@"SocialLoginKakaoSegue"]) {
        SocialLoginViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.agent = @"kakao";
        }
    }
}

- (IBAction)login:(id)sender {
    if (_userID.text.length < 1) {
        //[[PhotomonInfo sharedInfo] alertMsg:@"아이디를 입력하세요."];
        //[self.view makeToast:@"아이디를 입력하세요."];
        [[Common info] alert:self Msg:@"아이디를 입력하세요."];
        return;
    }
    if (_password.text.length < 1) {
        //[[PhotomonInfo sharedInfo] alertMsg:@"비밀번호를 입력하세요."];
        //[self.view makeToast:@"비밀번호를 입력하세요."];
        [[Common info] alert:self Msg:@"비밀번호를 입력하세요."];
        return;
    }

    // SJYANG : 2016.06.28
    if ([[Common info].login_info sendLoginInfo:_userID.text PW:_password.text LOGINTYPE:@""]) {
        
        [Analysis log:@"photomonLoginComplete"];
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject: _userID.text forKey:@"userID"];
        [userDefaults setObject: _password.text forKey:@"userPassword"];
        [userDefaults setObject: @"" forKey:@"loginType"];
        [userDefaults synchronize];

		[Common info].login_status_changed = YES;

        NSString *welcome = [NSString stringWithFormat:@"%@님 반갑습니다.", [Common info].user.mUserName];
        [[PhotomonInfo sharedInfo] alertMsg:welcome];

        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        if ([[Common info].login_info.check isEqualToString:@"S"]) {
            //[self.view makeToast:@"해당 계정은 휴면 상태입니다.\n\n웹사이트로 접속하여 휴면 상태 해제 후 이용해 주시기 바랍니다."];
            [[Common info] alert:self Msg:@"해당 계정은 휴면 상태입니다.\n\n웹사이트로 접속하여 휴면 상태 해제 후 이용해 주시기 바랍니다."];
        }
        else {
            //[[PhotomonInfo sharedInfo] alertMsg:@"로그인에 실패했습니다."];
            //[self.view makeToast:@"로그인에 실패했습니다."];
            [[Common info] alert:self Msg:@"로그인에 실패했습니다."];
        }
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// SJYANG : 2016.06.27
- (IBAction)socialLoginNaver:(id)sender {
    //[self performSegueWithIdentifier:@"SocialLoginNaverSegue" sender:self];
}

// SJYANG : 2016.06.27
- (IBAction)socialLoginFacebook:(id)sender {
    //[self performSegueWithIdentifier:@"SocialLoginFacebookSegue" sender:self];
}

// SJYANG : 2016.06.27
- (IBAction)socialLoginKakao:(id)sender {
    //[self performSegueWithIdentifier:@"SocialLoginKakaoSegue" sender:self];

}
@end
