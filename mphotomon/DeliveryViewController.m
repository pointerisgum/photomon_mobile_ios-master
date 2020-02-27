//
//  DeliveryViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 17..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "DeliveryViewController.h"
#import "AddressSearchTableViewController.h"
#import "LoginViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface DeliveryViewController ()

@end

@implementation DeliveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"DeliveryInfo"];
    
    [self registerForKeyboardNotifications];
    _activeTextField = nil;
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"KeyboardBar" owner:nil options:nil];
    UIView *keyboardView = [nibViews lastObject];
    UIButton *button1 = (UIButton *)[keyboardView viewWithTag:100];
    UIButton *button2 = (UIButton *)[keyboardView viewWithTag:101];
    [button1 addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [button2 addTarget:self action:@selector(onPayment) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"뒤로" forState:UIControlStateNormal];
    [button2 setTitle:@"결제하기" forState:UIControlStateNormal];
    _userName.inputAccessoryView = keyboardView;
    _phoneFrontNum.inputAccessoryView = keyboardView;
    _phoneRearNum.inputAccessoryView = keyboardView;
    _emailAddress.inputAccessoryView = keyboardView;
    _addressDetail.inputAccessoryView = keyboardView;
    _messageDelivery.inputAccessoryView = keyboardView;
    
    //
    UIImage *normal_image = [UIImage imageNamed:@"common_radio_off.png"];
    UIImage *press_image = [UIImage imageNamed:@"common_radio_on.png"];
    [_phonePaymentCheckBox setImage:normal_image forState:UIControlStateNormal];
    [_phonePaymentCheckBox setImage:press_image forState:UIControlStateSelected];
    [_cardPaymentCheckBox setImage:normal_image forState:UIControlStateNormal];
    [_cardPaymentCheckBox setImage:press_image forState:UIControlStateSelected];
    [_vbankPaymentCheckBox setImage:normal_image forState:UIControlStateNormal];
    [_vbankPaymentCheckBox setImage:press_image forState:UIControlStateSelected];
    
    if ([Common info].user.mUserid.length > 0) {
        _deliveryInputLabel.text = @"고객 아이디 정보";
    }
    else {
        _deliveryInputLabel.text = @"직접 배송지 입력";
    }
    [self fillDeliveryInfo:_deliveryInputLabel.text];
    
    if ([[PhotomonInfo sharedInfo].payment.total_price isEqualToString:@"0"] && [[PhotomonInfo sharedInfo].payment.delivery_cost isEqualToString:@"0"]) {
        _phonePaymentCheckBox.hidden = YES;
        _cardPaymentCheckBox.hidden = YES;
        _vbankPaymentCheckBox.hidden = YES;
        _vbankPaymentCheckBox.selected = YES; // 무통장 only !
        
        for (int tag = 300; tag <= 308; tag++) {
            UILabel *label = (UILabel *)[self.view viewWithTag:tag];
            if (label != nil) {
                label.hidden = YES;
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"DeliveryInfo" ScreenClass:[self.classForCoder description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    int height = 900;
    if ([[PhotomonInfo sharedInfo].payment.total_price isEqualToString:@"0"] && [[PhotomonInfo sharedInfo].payment.delivery_cost isEqualToString:@"0"]) {
        height = 560;
    }
    
    // 스토리보드의 contentview's height constraint의 placeholder를 remove at build time으로 설정하고, 이곳에서 새로 만들어 추가한다.
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.contentview
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:0
                                                                         toItem:self.scrollview
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:1.0
                                                                       constant:height];
    [self.view addConstraint:heightConstraint];

    // reset scroll amount
    self.scrollview.contentSize = self.contentview.frame.size;
    self.scrollview.contentSize = CGSizeMake(self.contentview.frame.size.width, height);
    _scrollview.contentInset = UIEdgeInsetsZero; // 좀 더..
    
    //NSLog(@"view:%f, scollview:%f, contentview:%f", self.view.frame.size.height, self.scrollview.frame.size.height, self.contentview.frame.size.height);
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
        
        [self onPayment];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES]; // 이 함수를 통과하지 못함. 원인 파악 필요..
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *replacedString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    NSString *expr = @"[^ \\-,._@()a-zA-Z0-9ㄱ-ㅎㅏ-ㅣ가-힣]";
    NSRegularExpression *reg_expr = [NSRegularExpression regularExpressionWithPattern:expr options:0 error:nil];
    NSUInteger match_count = [reg_expr numberOfMatchesInString:replacedString options:0 range:NSMakeRange(0, replacedString.length)];
    if (match_count > 0) {
        return NO;
    }
    //NSLog(@"in > %@(%d) - 매치(%d)", replacedString, replacedString.length, match_count);
    return YES;
}


- (void)fillDeliveryInfo:(NSString *)selected {
    if ([selected isEqualToString:@"고객 아이디 정보"]) {
        [self loadUserDeliveryInfo];
    }
    else if ([selected isEqualToString:@"최근 배송 주소"]) {
        [self loadRecentlyDeliveryInfo];
    }
    else {
        // do nothing..
    }
}

- (void)loadUserDeliveryInfo {
    User *info = [Common info].user;
    if (info && info.mUserid.length > 0) {
        _userName.text = info.mUserName;
//
//        NSArray *num_array = [info.phone_num componentsSeparatedByString:@"-"];
//        for (int i = 0; i < num_array.count; i++) {
//            switch (i) {
//                case 0: _phoneID.text = num_array[0]; break;
//                case 1: _phoneFrontNum.text = num_array[1]; break;
//                case 2: _phoneRearNum.text = num_array[2]; break;
//                default: break;
//            }
//        }
//        _emailAddress.text = info.email;
//        _addressPostNum.text = info.post_num;
        /*
        if (info.post_num.length == 6) {
            NSString *a = [info.post_num substringWithRange:NSMakeRange(0, 3)];
            NSString *b = [info.post_num substringWithRange:NSMakeRange(3, 3)];
            _addressPostNum.text = [NSString stringWithFormat:@"%@-%@", a, b];
        }*/
//        _addressBasic.text = info.address_basic;
//        _addressDetail.text = info.address_detail;
    }
}

- (void)loadRecentlyDeliveryInfo {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    _userName.text = [userDefault stringForKey:@"delivery_userName"];
    _phoneID.text = [userDefault stringForKey:@"delivery_phoneID"];
    _phoneFrontNum.text = [userDefault stringForKey:@"delivery_phoneFrontNum"];
    _phoneRearNum.text = [userDefault stringForKey:@"delivery_phoneRearNum"];
    _emailAddress.text = [userDefault stringForKey:@"delivery_emailAddress"];
    _addressPostNum.text = [userDefault stringForKey:@"delivery_postNum"];
    _addressBasic.text = [userDefault stringForKey:@"delivery_addressBasic"];
    _addressDetail.text = [userDefault stringForKey:@"delivery_addressDetail"];
}

- (void)saveRecentlyDeliveryInfo {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject: _userName.text forKey:@"delivery_userName"];
    [userDefaults setObject: _phoneID.text forKey:@"delivery_phoneID"];
    [userDefaults setObject: _phoneFrontNum.text forKey:@"delivery_phoneFrontNum"];
    [userDefaults setObject: _phoneRearNum.text forKey:@"delivery_phoneRearNum"];
    [userDefaults setObject: _emailAddress.text forKey:@"delivery_emailAddress"];
    [userDefaults setObject: _addressPostNum.text forKey:@"delivery_postNum"];
    [userDefaults setObject: _addressBasic.text forKey:@"delivery_addressBasic"];
    [userDefaults setObject: _addressDetail.text forKey:@"delivery_addressDetail"];
    [userDefaults synchronize];

}
/*
- (BOOL)checkEntry {
    if (_userName.text.length < 1) {
        return NO;
    }
    if (_emailAddress.text.length < 1) {
        return NO;
    }
    if (_phoneID.text.length < 1 || _phoneFrontNum.text.length < 1 || _phoneRearNum.text.length < 1) {
        return NO;
    }
    if (_addressPostNum.text.length < 1 || _addressBasic.text.length < 1 || _addressDetail.text.length < 1) {
        return NO;
    }
    
    if (_phonePaymentCheckBox.selected) {
    }
    else if (_cardPaymentCheckBox.selected) {
    }
    else if (_vbankPaymentCheckBox.selected) {
    }
    else {
        return NO;
    }
    return TRUE;
}
*/
- (BOOL)checkEntryMsg {
    if (_userName.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"이름을 입력하세요."];
        return FALSE;
    }
    if (_emailAddress.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"이메일을 입력하세요."];
        return FALSE;
    }
    if (_phoneID.text.length < 1 || _phoneFrontNum.text.length < 1 || _phoneRearNum.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"전화번호를 입력하세요."];
        return FALSE;
    }
    if (_addressPostNum.text.length < 1 || _addressBasic.text.length < 1 || _addressDetail.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"주소를 입력하세요."];
        return FALSE;
    }
    
    if (_phonePaymentCheckBox.selected) {
        [PhotomonInfo sharedInfo].payment.pay_type = @"휴대폰";
    }
    else if (_cardPaymentCheckBox.selected) {
        [PhotomonInfo sharedInfo].payment.pay_type = @"카드";
    }
    else if (_vbankPaymentCheckBox.selected) {
        [PhotomonInfo sharedInfo].payment.pay_type = @"무통장";
    }
    else {
        [[PhotomonInfo sharedInfo] alertMsg:@"결제 방법을 선택해 주세요."];
        return FALSE;
    }
    return TRUE;
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"PaySegue"]) {
        if (![self checkEntryMsg]) {
            return NO;
        }
        /*
        if ([PhotomonInfo sharedInfo].payment.p_oid == nil || [PhotomonInfo sharedInfo].payment.p_oid.length < 1) {
            [[PhotomonInfo sharedInfo] alertMsg:@"send deliveryinfo error."];
            return NO;
        }*/
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"PaySegue"]) {
        [self saveRecentlyDeliveryInfo];
        
        [PhotomonInfo sharedInfo].payment.user_id = [Common info].user.mUserid;
        [PhotomonInfo sharedInfo].payment.user_name = _userName.text;
        [PhotomonInfo sharedInfo].payment.email = _emailAddress.text;
        [PhotomonInfo sharedInfo].payment.phone_num = [NSString stringWithFormat:@"%@-%@-%@", _phoneID.text, _phoneFrontNum.text, _phoneRearNum.text];
        //NSArray *postnum_array = [_addressPostNum.text componentsSeparatedByString:@"-"];
        //[PhotomonInfo sharedInfo].payment.post_num = [NSString stringWithFormat:@"%@%@", postnum_array[0], postnum_array[1]];
        [PhotomonInfo sharedInfo].payment.post_num = _addressPostNum.text;
        [PhotomonInfo sharedInfo].payment.addr1 = _addressBasic.text;
        [PhotomonInfo sharedInfo].payment.addr2 = _addressDetail.text;
        [PhotomonInfo sharedInfo].payment.delivery_msg = _messageDelivery.text;
        
        //[[PhotomonInfo sharedInfo] sendDeliveryInfo];
        [[PhotomonInfo sharedInfo] postDeliveryInfo];
    }
    else if ([segue.identifier isEqualToString:@"SearchAddressSegue"]) {
        AddressSearchTableViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.delivery_controller = self;
        }
    }
    
}

- (IBAction)clickDeliveryInput:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"배송지 입력 정보 선택"
                                                                message:@"배송지 정보를 선택하세요."
                                                         preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *alert_action1 = [UIAlertAction actionWithTitle:@"직접 배송지 입력"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       _deliveryInputLabel.text = @"직접 배송지 입력";
                                       [vc dismissViewControllerAnimated:YES completion:nil];
                                   }];
    [vc addAction:alert_action1];

    if ([Common info].user.mUserid.length > 0) {
        UIAlertAction *alert_action2 = [UIAlertAction actionWithTitle:@"고객 아이디 정보"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action)
                                        {
                                            _deliveryInputLabel.text = @"고객 아이디";
                                            [vc dismissViewControllerAnimated:YES completion:nil];
                                            
                                            if ([Common info].user.mUserid.length < 1) {
                                                //MAcheck
                                                [[Common info] alert:self Title:@"로그인을 해주세요." Msg:@"" okCompletion:^{
                                                    LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginPage"];
                                                    [self presentViewController:vc animated:YES completion:nil];

                                                } cancelCompletion:^{
                                                    self.deliveryInputLabel.text = @"직접 배송지 입력";
                                                } okTitle:@"확인" cancelTitle:@"취소"];
                                            }
                                        }];
        [vc addAction:alert_action2];
    }

    UIAlertAction *alert_action3 = [UIAlertAction actionWithTitle:@"최근 배송 주소"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       self.deliveryInputLabel.text = @"최근 배송 주소";
                                       [vc dismissViewControllerAnimated:YES completion:nil];
                                       
                                       [self loadRecentlyDeliveryInfo];
                                   }];
    [vc addAction:alert_action3];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
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

- (IBAction)onPhonePayment:(id)sender {
    if (_phonePaymentCheckBox.selected) {
        _phonePaymentCheckBox.selected = NO;
    }
    else {
        _phonePaymentCheckBox.selected = YES;
        _cardPaymentCheckBox.selected = NO;
        _vbankPaymentCheckBox.selected = NO;
    }
}

- (IBAction)onCardPayment:(id)sender {
    if (_cardPaymentCheckBox.selected) {
        _cardPaymentCheckBox.selected = NO;
    }
    else {
        _phonePaymentCheckBox.selected = NO;
        _cardPaymentCheckBox.selected = YES;
        _vbankPaymentCheckBox.selected = NO;
    }
}

- (IBAction)onVBankPayment:(id)sender {
    if (_vbankPaymentCheckBox.selected) {
        _vbankPaymentCheckBox.selected = NO;
    }
    else {
        _phonePaymentCheckBox.selected = NO;
        _cardPaymentCheckBox.selected = NO;
        _vbankPaymentCheckBox.selected = YES;
    }
}

- (void)onPayment {
    if ([self checkEntryMsg]) {
        [self performSegueWithIdentifier:@"PaySegue" sender:self];
    }
    
/*
    if (![self checkEntry]) {
        return;
    }
    
    [self saveRecentlyDeliveryInfo];

    [PhotomonInfo sharedInfo].payment.user_id = [PhotomonInfo sharedInfo].loginInfo.userID;
    [PhotomonInfo sharedInfo].payment.user_name = _userName.text;
    [PhotomonInfo sharedInfo].payment.email = _emailAddress.text;
    [PhotomonInfo sharedInfo].payment.phone_num = [NSString stringWithFormat:@"%@-%@-%@", _phoneID.text, _phoneFrontNum.text, _phoneRearNum.text];
    NSArray *postnum_array = [_addressPostNum.text componentsSeparatedByString:@"-"];
    [PhotomonInfo sharedInfo].payment.post_num = [NSString stringWithFormat:@"%@%@", postnum_array[0], postnum_array[1]];
    [PhotomonInfo sharedInfo].payment.addr1 = _addressBasic.text;
    [PhotomonInfo sharedInfo].payment.addr2 = _addressDetail.text;
    [PhotomonInfo sharedInfo].payment.delivery_msg = _messageDelivery.text;
    
    //[[PhotomonInfo sharedInfo] sendDeliveryInfo];
    [[PhotomonInfo sharedInfo] postDeliveryInfo];*/
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
