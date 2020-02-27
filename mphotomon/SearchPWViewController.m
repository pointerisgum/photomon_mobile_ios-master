//
//  SearchPWViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "SearchPWViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface SearchPWViewController ()

@end

@implementation SearchPWViewController

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
    [button2 addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"뒤로" forState:UIControlStateNormal];
    [button2 setTitle:@"찾기" forState:UIControlStateNormal];
    _userName.inputAccessoryView = keyboardView;
    _userID.inputAccessoryView = keyboardView;
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
    if (_userID.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"아이디를 입력하세요."];
        return;
    }
    if (_emailAddress.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"이메일 주소를 입력하세요."];
        return;
    }
    
    NSString *search_email = [[Common info].login_info sendSearchPWInfo:_userName.text Email:_emailAddress.text ID:_userID.text];
    if (search_email.length > 0) {
        NSString *msg = [NSString stringWithFormat:@"임시 비밀번호가 다음 이메일 주소로 발송되었습니다.\n %@", search_email];
        [[PhotomonInfo sharedInfo] alertMsg:msg];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [[PhotomonInfo sharedInfo] alertMsg:@"해당 정보를 찾을 수 없습니다."];
    }
    
}
@end
