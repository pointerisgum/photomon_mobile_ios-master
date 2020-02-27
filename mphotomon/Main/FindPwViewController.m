//
//  FindPwViewController.m
//  PHOTOMON
//
//  Created by 김민아 on 09/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "FindPwViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface FindPwViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UITextField *tfId;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;

@end

@implementation FindPwViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resultView.hidden = true;
    
    self.tfId.delegate = self;
    self.tfName.delegate = self;
    self.tfEmail.delegate = self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.tfEmail) {
        return [self checkValidateEmail:string];
    }
    
    if (textField == self.tfName) {
        return [self checkValidateName:string];
    }
    
    if (textField == self.tfId) {
        return [self checkValidateId:string];
    }
    
    return true;
}

- (BOOL)checkValidateId:(NSString *)string {
    if (!string || [string isEqual: @""]) {
        return YES;
    }
    
    NSUInteger bytes = [self.tfId.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    if (bytes > 12) {
        return NO;
    }
    
    NSString *ptn = @"^[\\sa-zA-Z0-9@]*$";
    NSRange checkRange = [string rangeOfString:ptn options:NSRegularExpressionSearch];
    
    if (checkRange.length == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)checkValidateName:(NSString *)string {
    if (!string || [string isEqual: @""]) {
        return YES;
    }
    
    NSUInteger bytes = [self.tfName.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
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

- (IBAction)didTouchGetTempPwButton:(UIButton *)sender {
    if (self.tfId.text.length < 1) {
        [[Common info] alert:self Msg:@"아이디를 입력하세요."];
        return;
    }
    
    if (self.tfName.text.length < 1) {
        [[Common info] alert:self Msg:@"이름을 입력하세요."];
        return;
    }
   
    if (self.tfEmail.text.length < 1) {
        [[Common info] alert:self Msg:@"이메일 주소를 입력하세요."];
        return;
    }
    
    NSString *search_email = [[Common info].login_info sendSearchPWInfo:self.tfName.text Email:self.tfEmail.text ID:self.tfId.text];
    
    if ([search_email isEqualToString:@""]) {
        [[Common info] alert:self Msg:@"해당 정보를 찾을 수 없습니다."];
    } else {
        self.resultView.hidden = false;
    }
}

- (IBAction)didTouchLoginButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:^{
        MainViewController *mainVC = [Common info].main_controller;
        [mainVC didTouchMenuButton:nil];
    }];
}

- (IBAction)didTouchHomeButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTouchCloseButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
