//
//  SearchIDViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "SearchIDViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface SearchIDViewController ()

@end

@implementation SearchIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // keyboard_bar
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"KeyboardBar" owner:nil options:nil];
    UIView *keyboardView = [nibViews lastObject];
    UIButton *button1 = (UIButton *)[keyboardView viewWithTag:100];
    UIButton *button2 = (UIButton *)[keyboardView viewWithTag:101];
    [button1 addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [button2 addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"뒤로" forState:UIControlStateNormal];
    [button2 setTitle:@"찾기" forState:UIControlStateNormal];
    _userName.inputAccessoryView = keyboardView;
    _emailAddress.inputAccessoryView = keyboardView;
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
        
        [self done:nil];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    if (_userName.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"이름을 입력하세요."];
        return;
    }
    if (_emailAddress.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"이메일 주소를 입력하세요."];
        return;
    }
    
    NSString *search_id = [[Common info].login_info sendSearchIDInfo:_userName.text Email:_emailAddress.text];
    if (search_id.length > 0) {
        NSString *msg = [NSString stringWithFormat:@"아이디는 %@ 입니다.", search_id];
        [[PhotomonInfo sharedInfo] alertMsg:msg];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [[PhotomonInfo sharedInfo] alertMsg:@"아이디를 찾을 수 없습니다."];
    }
}

@end
