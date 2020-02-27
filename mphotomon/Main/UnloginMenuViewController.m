//
//  UnloginMenuViewController.m
//  PHOTOMON
//
//  Created by 김민아 on 05/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "UnloginMenuViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "UIImageView+WebCache.h"
#import "MainContents.h"

@interface UnloginMenuViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfId;
@property (weak, nonatomic) IBOutlet UITextField *tfPw;
@property (weak, nonatomic) IBOutlet UIImageView *ivBanner;
@property (strong, nonatomic) Contents *content;

@end

@implementation UnloginMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(didTouchCloseButton:)];
    
    
    gesture.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:gesture];
    
    [self initBoxColor];
    
    NSString *url_str = @"http://www.photomon.com/wapp/xml/msidemenu_banner.asp";
    
    url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url_str]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> bannerinfo Result: %@", data);
        
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
        
        self.content = [[Contents alloc]initWithDictionary:dict[@"guest"] error:nil];
        NSLog(@"self.content: %@", self.content);
        
        [self.ivBanner sd_setImageWithURL:[NSURL URLWithString:self.content.thumb]];
    }
}

- (void)initBoxColor {
    
    UIView *view = [self.view viewWithTag:2000];
    view.backgroundColor = GRAY_COLOR;
    
    view = [self.view viewWithTag:2001];
    view.backgroundColor = GRAY_COLOR;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self initBoxColor];
    
    if (textField == self.tfId) {
        UIView *view = [self.view viewWithTag:2000];
        view.backgroundColor = YELLOW_COLOR;
    } else if (textField == self.tfPw) {
        UIView *view = [self.view viewWithTag:2001];
        view.backgroundColor = YELLOW_COLOR;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self initBoxColor];
    [textField resignFirstResponder];
    
    return true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.tfPw) {
        return [self checkValidatePw:string];
    }
    
    return true;
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
    
    NSString *ptn = @"^[\\sa-zA-Z0-9]*[!@#$%^*+=-\\[\\]{}_\\\\:;\"'<>/?]*$";
    NSRange checkRange = [string rangeOfString:ptn options:NSRegularExpressionSearch];
    
    if (checkRange.length == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (IBAction)didTouchBanner:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(didTouchJoinButton)]) {
        [self.delegate didTouchJoinButton];
    }}

- (IBAction)didTouchLoginButton:(UIButton *)sender {
    
    if (self.tfId.text.length < 1) {
        [self.tfId becomeFirstResponder];
        [[Common info] alert:self Msg:@"아이디를 입력하세요."];
        return;
    }
    if (self.tfPw.text.length < 1) {
        [self.tfPw becomeFirstResponder];
        [[Common info] alert:self Msg:@"비밀번호를 입력하세요."];
        return;
    }
    
    [self.tfId resignFirstResponder];
    [self.tfPw resignFirstResponder];
    
    if ([[Common info].login_info sendLoginInfo:self.tfId.text PW:self.tfPw.text LOGINTYPE:@""]) {
        
        [Analysis log:@"photomonLoginComplete"];
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject: self.tfId.text forKey:@"userID"];
        [userDefaults setObject: self.tfPw.text forKey:@"userPassword"];
        [userDefaults setObject: @"" forKey:@"loginType"];
        [userDefaults synchronize];
        
        [Common info].login_status_changed = YES;
        
        NSString *welcome = [NSString stringWithFormat:@"%@님 반갑습니다.", [Common info].user.mUserName];
        [[Common info] alert:self Msg:welcome];
        
        if([self.delegate respondsToSelector:@selector(didTouchCloseButton)]) {
            [self.delegate didTouchCloseButton];
        }
        
    }
    else {
        if ([[Common info].user.mcheck isEqualToString:@"S"]) {
            [[Common info] alert:self Msg:@"해당 계정은 휴면 상태입니다.\n\n웹사이트로 접속하여 휴면 상태 해제 후 이용해 주시기 바랍니다."];
        }
        else {
            [[Common info] alert:self Msg:@"로그인에 실패했습니다."];
        }
    }  
}

// kakao 3000, naver 3001, facebook 3002
- (IBAction)didTouchSocialLoginButton:(UIButton *)sender {
    
    NSString *type;
    
    switch (sender.tag) {
        case 3000:
            type = @"kakao";
            break;
        case 3001:
            type = @"naver";
            break;
        case 3002:
            type = @"facebook";
            break;
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(didTouchSocialLogin:)]) {
        [self.delegate didTouchSocialLogin:type];
    }
}

- (IBAction)didTouchSettingButton:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(didTouchSettingButton)]) {
        [self.delegate didTouchSettingButton];
    }
}

- (IBAction)didTouchCloseButton:(UIButton *)sender {
    
    if ([self.tfId isFirstResponder]) {
        [self.tfId resignFirstResponder];
    }
    
    if ([self.tfPw isFirstResponder]) {
        [self.tfPw resignFirstResponder];
    }
    
    if([self.delegate respondsToSelector:@selector(didTouchCloseButton)]) {
        [self.delegate didTouchCloseButton];
    }
    
}

- (IBAction)didTouchJoinButton:(UIButton *)sender {
    
    if([self.delegate respondsToSelector:@selector(didTouchJoinButton)]) {
        [self.delegate didTouchJoinButton];
    }
}

- (IBAction)didTouchFindIdButton:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(didTouchFindIdButton)]) {
        [self.delegate didTouchFindIdButton];
    }
}

- (IBAction)didTouchFindPwButton:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(didtouchFindPwButton)]) {
        [self.delegate didtouchFindPwButton];
    }
}

- (IBAction)didTouchViewNomemberOrderButton:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(didTouchViewNomemberOrderButton)]) {
        [self.delegate didTouchViewNomemberOrderButton];
    }
}

@end
