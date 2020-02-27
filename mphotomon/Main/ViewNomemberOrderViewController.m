//
//  ViewNomemberOrderViewController.m
//  PHOTOMON
//
//  Created by 김민아 on 09/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "ViewNomemberOrderViewController.h"
#import "Common.h"

@interface ViewNomemberOrderViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;

@end

@implementation ViewNomemberOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

- (IBAction)didTouchCheckOrderButton:(UIButton *)sender {
    
    if ([self.tfName.text isEqualToString:@""]) {
        [[Common info]alert:self Msg:@"이름을 입력해주세요"];
    }
    
    if ([self.tfEmail.text isEqualToString:@""]) {
        [[Common info]alert:self Msg:@"메일 주소를 입력해주세요"];
    }
    
    [self.tfEmail resignFirstResponder];
    [self.tfName resignFirstResponder];
    
    NSString *url_str = [NSString stringWithFormat:URL_ORDER_LIST_NOMEMBER, self.tfName.text, self.tfEmail.text];
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> URL_ORDER_LIST_NOMEMBER Result: %@", data);
        
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
        
        
        if ([dict[@"mcheck"] isEqualToString: @"Y"]) {

            [Common info].nonMemberName = self.tfName.text;
            [Common info].nonMemberEmail = self.tfEmail.text;
            
            [self dismissViewControllerAnimated:true completion:^{
                [[Common info].main_controller didTouchMenuCategory:1];
            }];
            
        } else {
            [[Common info]alert:self Msg:@"입력하신 정보와 일치하는 주문내역이 없습니다.\n정보 확인이 어려운 경우 고객센터로 문의해 주시기 바랍니다."];
        }
    }
}

- (IBAction)didTouchCloseButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTouchJoinButton:(UIButton *)sender {
    [self dismissViewControllerAnimated:false completion:^{
        [[Common info].main_controller didTouchJoinButton];
    }];
}

- (IBAction)didTouchLoginButton:(UIButton *)sender {
    [[Common info].main_controller didTouchMenuButton:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
