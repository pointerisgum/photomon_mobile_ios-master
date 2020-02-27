//
//  SignupViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 5..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "SignupViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "FrameWebViewController.h"

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // keyboard_bar
    [self registerForKeyboardNotifications];
    _activeTextField = nil;
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"KeyboardBar" owner:nil options:nil];
    UIView *keyboardView = [nibViews lastObject];
    UIButton *button1 = (UIButton *)[keyboardView viewWithTag:100];
    UIButton *button2 = (UIButton *)[keyboardView viewWithTag:101];
    [button1 addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [button2 addTarget:self action:@selector(signup:) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"뒤로" forState:UIControlStateNormal];
    [button2 setTitle:@"가입" forState:UIControlStateNormal];
    _userName.inputAccessoryView = keyboardView;
    _userID.inputAccessoryView = keyboardView;
    _emailAddress.inputAccessoryView = keyboardView;
    _password.inputAccessoryView = keyboardView;
    _passwordConfirm.inputAccessoryView = keyboardView;
    _phoneID.inputAccessoryView = keyboardView;
    _phoneFrontNum.inputAccessoryView = keyboardView;
    _phoneRearNum.inputAccessoryView = keyboardView;
    
    _userIDConfirm = @"";
    _emailConfirm = @"";
    
    UIImage *normal_image = [UIImage imageNamed:@"common_check_off.png"];
    UIImage *press_image = [UIImage imageNamed:@"common_check_on.png"];
    [_checkEmail setImage:normal_image forState:UIControlStateNormal];
    [_checkEmail setImage:press_image forState:UIControlStateSelected];
    [_checkPhone setImage:normal_image forState:UIControlStateNormal];
    [_checkPhone setImage:press_image forState:UIControlStateSelected];
    //cmh. 약관분리
    [_checkProvision setImage:normal_image forState:UIControlStateNormal];
    [_checkProvision setImage:press_image forState:UIControlStateSelected];
    [_checkPrivacy setImage:normal_image forState:UIControlStateNormal];
    [_checkPrivacy setImage:press_image forState:UIControlStateSelected];

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)keyboardWillShow:(NSNotification*)aNotification {
}
- (void)keyboardDidShow:(NSNotification*)aNotification {
    if (_activeTextField == nil) {
        return;
    }
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollview.contentInset = contentInsets;
    _scrollview.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _activeTextField.frame.origin) ) {
        [_scrollview scrollRectToVisible:_activeTextField.frame animated:YES];
    }
}
- (void)keyboardWillHide:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollview.contentInset = contentInsets;
    _scrollview.scrollIndicatorInsets = contentInsets;
}
- (void)keyboardDidHide:(NSNotification*)aNotification {
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _activeTextField = nil;
    [self.view endEditing:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        UIResponder *next = [textField.superview viewWithTag:textField.tag+1];
        [next becomeFirstResponder];
    } else if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
        
        [self signup:nil];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES]; // 이 함수를 통과하지 못함. 원인 파악 필요..
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickIDCheck:(id)sender {
    if (_userID.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"아이디를 입력하세요."];
        return;
    }
    _userIDConfirm = @"";
    if ([SignupUser sendIDCheck:_userID.text]) {
        [[PhotomonInfo sharedInfo] alertMsg:@"사용 가능한 아이디입니다."];
        _userIDConfirm = _userID.text;
    }
    else {
        [[PhotomonInfo sharedInfo] alertMsg:@"사용할 수 없는 아이디입니다."];
    }
}

- (IBAction)clickEmailCheck:(id)sender {
    if (_emailAddress.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"이메일을 입력하세요."];
        return;
    }
    _emailConfirm = @"";
    if ([SignupUser sendEmailCheck:_emailAddress.text]) {
        [[PhotomonInfo sharedInfo] alertMsg:@"사용 가능한 이메일입니다."];
        _emailConfirm = _emailAddress.text;
    }
    else {
        [[PhotomonInfo sharedInfo] alertMsg:@"사용할 수 없는 이메일입니다."];
    }
}

- (IBAction)clickPhoneID:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = [UIAlertAction actionWithTitle:@"010" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _phoneID.text = @"010";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];
    
    alert_action = [UIAlertAction actionWithTitle:@"011" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _phoneID.text = @"011";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];
    
    alert_action = [UIAlertAction actionWithTitle:@"016" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _phoneID.text = @"016";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];
    
    alert_action = [UIAlertAction actionWithTitle:@"017" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _phoneID.text = @"017";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];
    
    alert_action = [UIAlertAction actionWithTitle:@"018" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _phoneID.text = @"018";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];
    
    alert_action = [UIAlertAction actionWithTitle:@"019" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _phoneID.text = @"019";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)clickRecvEmail:(id)sender {
    _checkEmail.selected = !_checkEmail.selected;
}

- (IBAction)clickRecvPhone:(id)sender {
    _checkPhone.selected = !_checkPhone.selected;
}

//cmh. 약관분리
- (IBAction)clickAgreeProvision:(id)sender {
    NSLog(@"22");
    _checkProvision.selected = !_checkProvision.selected;
}
- (IBAction)clickAgreePrivacy:(id)sender {
    NSLog(@"11");
    _checkPrivacy.selected = !_checkPrivacy.selected;
}

- (IBAction)clickViewProvision:(id)sender {
//    FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
//    frameWebView.webviewUrl = URL_PROVISION_LAW;
//    [self presentViewController:frameWebView animated:YES completion:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_PROVISION_LAW]];
}
- (IBAction)clickViewPrivacy:(id)sender {
//    FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
//    frameWebView.webviewUrl = URL_PROVISION_PRIVACY;
//    [self presentViewController:frameWebView animated:YES completion:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_PROVISION_PRIVACY]];
}




- (IBAction)signup:(id)sender {
    if (_userName.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"이름을 입력하세요."];
        return;
    }
    if (_userID.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"아이디를 입력하세요."];
        return;
    }
    if (![_userID.text isEqualToString:_userIDConfirm]) {
        [[PhotomonInfo sharedInfo] alertMsg:@"아이디 중복확인을 해주세요."];
        return;
    }
    if (_emailAddress.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"이메일을 입력하세요."];
        return;
    }
    if (![_emailAddress.text isEqualToString:_emailConfirm]) {
        [[PhotomonInfo sharedInfo] alertMsg:@"이메일 중복확인을 해주세요."];
        return;
    }
    if (_password.text.length < 1 || _passwordConfirm.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"비밀번호를 입력하세요."];
        return;
    }
    if (![_password.text isEqualToString:_passwordConfirm.text]) {
        [[PhotomonInfo sharedInfo] alertMsg:@"비밀번호를 확인하세요."];
        return;
    }
    if (_phoneID.text.length < 1 || _phoneFrontNum.text.length < 1 || _phoneRearNum.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"전화번호를 입력하세요."];
        return;
    }
    //cmh. 약관분리
    if (!_checkProvision.selected) {
        [[PhotomonInfo sharedInfo] alertMsg:@"이용약관에 동의하세요."];
        return;
    }
    if (!_checkPrivacy.selected) {
        [[PhotomonInfo sharedInfo] alertMsg:@"개인정보 취급방침에 동의하세요."];
        return;
    }

    
    SignupUser *user = [[SignupUser alloc] init];
    user.userName = _userName.text;
    user.userID = _userID.text;
    user.emailAddress = _emailAddress.text;
    user.password = _password.text;
//    user.cell1 = _phoneID.text;
//    user.cell2 = _phoneFrontNum.text;
//    user.cell3 = _phoneRearNum.text;
    user.recvEmail = _checkEmail.selected ? @"1" : @"";
    user.recvSMS = _checkPhone.selected ? @"1" : @"";
    
    if ([user sendSignupUserInfo]) {
        [Analysis log:@"registrationComplete"];
        [[PhotomonInfo sharedInfo] alertMsg:@"회원가입에 성공했습니다."];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [[PhotomonInfo sharedInfo] alertMsg:@"회원가입에 실패했습니다."];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [Analysis firAnalyticsWithScreenName:@"className" ScreenClass:[self.classForCoder description]];
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
