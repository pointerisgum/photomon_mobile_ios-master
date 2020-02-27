//
//  FindIdViewController.m
//  PHOTOMON
//
//  Created by 김민아 on 09/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "FindIdViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface FindIdViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UILabel *lbEmail;

@end

@implementation FindIdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resultView.hidden = true;
    self.tfName.delegate = self;
    self.tfEmail.delegate = self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.tfName) {
        return [self checkValidateName:string];
    }
    
    if (textField == self.tfEmail) {
        return [self checkValidateEmail:string];
    }
    
    return true;
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

- (IBAction)didTouchCloseButton:(UIButton *)sender {
    
    if ([self.tfEmail isFirstResponder]) {
        [self.tfEmail resignFirstResponder];
    } else if ([self.tfName isFirstResponder]) {
        [self.tfName resignFirstResponder];
    }
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTouchFindIdButton:(UIButton *)sender {
    
    if ([self.tfName.text isEqualToString:@""]) {
        [[Common info] alert:self Msg:@"이름을 입력하세요."];
        return;
    }
    
    if ([self.tfEmail.text isEqualToString:@""]) {
        [[Common info] alert:self Msg:@"이메일 주소를 입력하세요."];
        return;
    }
    
    NSString *search_id = [[Common info].login_info sendSearchIDInfo:self.tfName.text Email:self.tfEmail.text];
    
    if (search_id.length > 0) {
//
//        NSArray* words = [search_id componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        search_id = [words componentsJoinedByString:@""];
//
//        if (search_id.length > 2) {
//            search_id = [search_id stringByReplacingCharactersInRange:NSMakeRange(search_id.length-2, 2) withString:@"**"];
//        }
//
        self.resultView.hidden = false;
        self.lbEmail.text = search_id;
    }
    else {
        [[Common info] alert:self Msg:@"아이디를 찾을 수 없습니다."];
    }
}

- (IBAction)didTouchLoginButton:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:true completion:^{
        [[Common info].main_controller didTouchMenuButton:nil];
    }];
}

- (IBAction)didTouchHomeButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
