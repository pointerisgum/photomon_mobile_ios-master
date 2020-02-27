//
//  JoinEmailViewController.m
//  PHOTOMON
//
//  Created by 김민아 on 08/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "JoinEmailViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"


@interface JoinEmailViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcBottomOfNameView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcBottomOfEmailView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcBottomOfPwView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcBottomOfRePwView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcBottomOfPickerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcHeightOfPickerView;

@property (weak, nonatomic) IBOutlet UILabel *lbNameWarning;
@property (weak, nonatomic) IBOutlet UILabel *lbWarningEmail;
@property (weak, nonatomic) IBOutlet UILabel *lbWarningPw;
@property (weak, nonatomic) IBOutlet UILabel *lbWarningRePw;
@property (weak, nonatomic) IBOutlet UILabel *lbWarningNum;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIImageView *ivSelectBoxEmail;
@property (weak, nonatomic) IBOutlet UIImageView *ivSelectBoxSns;
@property (weak, nonatomic) IBOutlet UIImageView *ivSelectBoxMale;
@property (weak, nonatomic) IBOutlet UIImageView *ivSelectBoxFemale;

@property (weak, nonatomic) IBOutlet UILabel *lbYear;
@property (weak, nonatomic) IBOutlet UILabel *lbMonth;
@property (weak, nonatomic) IBOutlet UILabel *lbDay;
@property (weak, nonatomic) IBOutlet UIButton *btnHideKeyboard;


@end

// UITextField tag 1000~
// textField background UIView tag 2000~

@implementation JoinEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.btnHideKeyboard.hidden = true;
    
    self.alcBottomOfPickerView.constant = - self.alcHeightOfPickerView.constant;
    self.ivSelectBoxEmail.highlighted = true;
    self.ivSelectBoxSns.highlighted = true;
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];

    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    self.datePicker.maximumDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%ld",year-14,month,day]];
    self.datePicker.minimumDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%ld",year-100,month,day]];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChage:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - User Action
- (IBAction)didTouchDateButton:(UIButton *)sender {
    
    self.alcBottomOfPickerView.constant = 0.0f;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)didTouchDoneDateButton:(UIButton *)sender {
    self.alcBottomOfPickerView.constant = - self.alcHeightOfPickerView.constant;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSString *dateString = [dateFormatter stringFromDate:self.datePicker.date];
    
    NSArray *temp = [dateString componentsSeparatedByString:@"-"];
    
    self.lbYear.text = temp[0];
    self.lbMonth.text = temp[1];
    self.lbDay.text = temp[2];
    
}

- (IBAction)didTouchEmailButton:(UIButton *)sender {
    self.ivSelectBoxEmail.highlighted = !self.ivSelectBoxEmail.isHighlighted;
}

- (IBAction)didTouchSnsButton:(UIButton *)sender {
    self.ivSelectBoxSns.highlighted = !self.ivSelectBoxSns.isHighlighted;
}

- (IBAction)didTouchMaleButton:(UIButton *)sender {
    self.ivSelectBoxMale.highlighted = true;
    self.ivSelectBoxFemale.highlighted = false;
}

- (IBAction)didTouchFemaleButton:(UIButton *)sender {
    self.ivSelectBoxMale.highlighted = false;
    self.ivSelectBoxFemale.highlighted = true;

}

- (IBAction)didTouchHideKeyboardButton:(UIButton *)sender {
    
    if ([((UITextField *)[self.view viewWithTag:1000]) isFirstResponder]) {
        [((UITextField *)[self.view viewWithTag:1000]) resignFirstResponder];
    }
    
    if ([((UITextField *)[self.view viewWithTag:1001]) isFirstResponder]) {
        [((UITextField *)[self.view viewWithTag:1001]) resignFirstResponder];
    }
    
    if ([((UITextField *)[self.view viewWithTag:1002]) isFirstResponder]) {
        [((UITextField *)[self.view viewWithTag:1002]) resignFirstResponder];
    }
    
    if ([((UITextField *)[self.view viewWithTag:1003]) isFirstResponder]) {
        [((UITextField *)[self.view viewWithTag:1003]) resignFirstResponder];
    }
    
    if ([((UITextField *)[self.view viewWithTag:1004]) isFirstResponder]) {
        [((UITextField *)[self.view viewWithTag:1004]) resignFirstResponder];
    }
}

- (IBAction)didTouchJoinButton:(UIButton *)sender {
    SignupUser *user = [[SignupUser alloc] init];
    user.userName = ((UITextField *)[self.view viewWithTag:1000]).text;
    user.emailAddress = ((UITextField *)[self.view viewWithTag:1001]).text;
    user.password = ((UITextField *)[self.view viewWithTag:1002]).text;
    user.cellNum = ((UITextField *)[self.view viewWithTag:1004]).text;
    user.birth1 = [self.lbYear.text isEqualToString:@"년도"] ? @"" : self.lbYear.text;
    user.birth2 = [self.lbMonth.text isEqualToString:@"월"] ? @"" : self.lbMonth.text;
    user.birth3 = [self.lbDay.text isEqualToString:@"일"] ? @"" : self.lbDay.text;
    user.recvEmail = self.ivSelectBoxEmail.isHighlighted ? @"1" : @"";
    user.recvSMS = self.ivSelectBoxSns.isHighlighted ? @"1" : @"";
    
    if (self.lbNameWarning.hidden == false) {
        [[Common info] alert:self Msg:@"이름을 확인해주세요"];
        return;
    }
    
    if (self.lbWarningEmail.hidden == false) {
        [[Common info] alert:self Msg:@"이메일을 확인해주세요"];
        return;
    }
    
    if (self.lbWarningPw.hidden == false || self.lbWarningRePw.hidden == false) {
        [[Common info] alert:self Msg:@"비밀번호를 확인해주세요"];
        return;
    }
    
    if (self.lbWarningNum.hidden == false) {
        [[Common info] alert:self Msg:@"휴대폰 번호를 확인해주세요"];
        return;
    }
    
    
    if (self.ivSelectBoxMale.isHighlighted == false && self.ivSelectBoxFemale.isHighlighted == false ) {
        user.gender = @"";
    } else {
        user.gender = self.ivSelectBoxMale.isHighlighted ? @"M" : @"F";
    }

    if ([user sendSignupUserInfo]) {
        [Analysis log:@"registrationComplete"];
        
        [[Common info] alert:self Msg:@"회원가입에 성공했습니다."];

        if ([[Common info].login_info sendLoginInfo:user.emailAddress PW:user.password LOGINTYPE:@""]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else {
        [[Common info] alert:self Msg:@"회원가입에 실패했습니다."];
    }
}

- (IBAction)didTouchCloseButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}


#pragma mark - UITextFieldDelgate

- (void)textFieldDidChage:(NSNotification *)noti {
    
    UITextField *textField = (UITextField *)noti.object;
    

}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.btnHideKeyboard.hidden = false;
    
    static int highlightedTag = 0;
    
    UIView *colorView = [self.view viewWithTag: textField.tag+1000];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        colorView.backgroundColor = YELLOW_COLOR;

    });
    highlightedTag = textField.tag + 1000;
    
    if (highlightedTag == 0) { return; }
    
    UIView *coloredView = [self.view viewWithTag:highlightedTag];
    
    coloredView.backgroundColor = GRAY_COLOR;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == (UITextField *)[self.view viewWithTag:1001]) {
   
    }
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.btnHideKeyboard.hidden = true;
    
    UIView *colorView = [self.view viewWithTag:textField.tag + 1000];
    
    colorView.backgroundColor = GRAY_COLOR;
    
    if (textField.tag == 1000) {
        if ([textField.text isEqual: @""]) {
            self.alcBottomOfNameView.constant = 29.5f;
            self.lbNameWarning.text = @"이름을 입력해 주세요.";
            self.lbNameWarning.hidden = false;
            
        } else if ([self checkContainSpecialCharacters:textField.text]) {
            self.alcBottomOfNameView.constant = 29.5f;
            self.lbNameWarning.text = @"한글 또는 영문만 입력 가능합니다.";
            self.lbNameWarning.hidden = false;
            
        } else {
            self.alcBottomOfNameView.constant = 9.5f;
            self.lbNameWarning.hidden = true;
        }
    } else if (textField.tag == 1001) {
        if ([textField.text isEqual: @""]) {
            self.alcBottomOfEmailView.constant = 29.5f;
            self.lbWarningEmail.text = @"이메일을 입력해 주세요.";
            self.lbWarningEmail.hidden = false;
        } else {
            self.alcBottomOfEmailView.constant = 6.5;
            self.lbWarningEmail.hidden = true;
            
            if ([SignupUser sendEmailCheck:textField.text]) {
                [self showEmailWarning:@""];
            }
            else {
                [self showEmailWarning:@"사용할 수 없는 이메일입니다."];
            }
        }
    } else if (textField.tag == 1002) {
        if ([textField.text isEqual: @""]) {
            self.alcBottomOfPwView.constant = 29.5f;
            self.lbWarningPw.text = @"비밀번호를 입력해 주세요.";
            self.lbWarningPw.hidden = false;
        } else if (textField.text.length < 6) {
            self.alcBottomOfPwView.constant = 29.5f;
            self.lbWarningPw.text = @"비밀번호가 너무 짧습니다.";
            self.lbWarningPw.hidden = false;
        } else {
            self.alcBottomOfPwView.constant = 6.5;
            self.lbWarningPw.hidden = true;
        }
    } else if (textField.tag == 1003) {
        if ([textField.text isEqual: @""]) {
            self.alcBottomOfRePwView.constant = 29.5f;
            self.lbWarningRePw.text = @"비밀번호를 입력해 주세요.";
            self.lbWarningRePw.hidden = false;
        } else if (![textField.text isEqualToString:((UITextField *)[self.view viewWithTag:1002]).text]) {
            self.alcBottomOfRePwView.constant = 29.5f;
            self.lbWarningRePw.text = @"비밀번호가 일치하지 않습니다.";
            self.lbWarningRePw.hidden = false;
        } else {
            self.alcBottomOfRePwView.constant = 6.5;
            self.lbWarningRePw.hidden = true;
        }
    } else if (textField.tag == 1004) {
        if ([textField.text isEqual: @""]){
            self.lbWarningNum.text = @"휴대폰번호를 입력해 주세요.";
            self.lbWarningNum.hidden = false;
        } else if ([textField.text length] < 9 || [textField.text length] > 11){
            self.lbWarningNum.text = @"휴대폰번호가 올바르지 않습니다.";
            self.lbWarningNum.hidden = false;
        } else {
            self.lbWarningNum.hidden = true;
        }
    }

}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    return true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == 1000 && ![self checkValidateName:string])  {
        return false;
    } else if (textField.tag == 1001 && ![self checkValidateEmail:string])  {
        return false;
    } else if ((textField.tag == 1002 || textField.tag == 1003) && ![self checkValidatePw:string])  {
        return false;
    } else if (textField.tag == 1004 && ![self checkValidateNum:string])  {
        return false;
    }
    
    return true;
}

#pragma mark - Private Method

- (BOOL)checkValidateName:(NSString *)string {
    if (!string || [string isEqual: @""]) {
        return YES;
    }
    
    NSUInteger bytes = [((UITextField *)[self.view viewWithTag:1000]).text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    if (bytes > 20) {
        return NO;
    }

    NSString *ptn = @"^[\\sㄱ-ㅎㅏ-ㅣa-zA-Z0-9가-힣]*$";
    NSRange checkRange = [string rangeOfString:ptn options:NSRegularExpressionSearch];
    
    if (checkRange.length == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)checkValidateEmail:(NSString *)string {
    if (!string || [string isEqual: @""]) {
        return YES;
    }
    
    NSString *ptn = @"^[\\sㄱ-ㅎㅏ-ㅣa-zA-Z0-9가-힣@.]*$";
    NSRange checkRange = [string rangeOfString:ptn options:NSRegularExpressionSearch];
    
    if (checkRange.length == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)checkValidatePw:(NSString *)string {
    if (!string || [string isEqual: @""]) {
        return YES;
    }
    
    NSString *ptn = @"^[\\sa-zA-Z0-9]*$";
    NSRange checkRange = [string rangeOfString:ptn options:NSRegularExpressionSearch];
    
    if (checkRange.length == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)checkValidateNum:(NSString *)string {
    if (!string || [string isEqual: @""]) {
        return YES;
    }
    
    NSString *ptn = @"^[\\s0-9]*$";
    NSRange checkRange = [string rangeOfString:ptn options:NSRegularExpressionSearch];
    
    if (checkRange.length == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)checkContainSpecialCharacters:(NSString *)string {
    
    NSString *specialCharacterString = @"!~`@#$%^&*-+();:={}[],.<>?\\/\"\'";
    NSCharacterSet *specialCharacterSet = [NSCharacterSet
                                           characterSetWithCharactersInString:specialCharacterString];
    
    if ([string.lowercaseString rangeOfCharacterFromSet:specialCharacterSet].length) {
        return true;
    }
    
    return false;
}

- (void)showEmailWarning:(NSString *)warning {
    
    if ([warning isEqualToString:@""]) {
        self.alcBottomOfEmailView.constant = 6.5;
        self.lbWarningEmail.hidden = true;
    } else {
        self.alcBottomOfEmailView.constant = 29.5f;
        self.lbWarningEmail.text = warning;
        self.lbWarningEmail.hidden = false;
    }
}


@end
