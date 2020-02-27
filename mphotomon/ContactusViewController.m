//
//  ContactusViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 10..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>
#import "ContactusViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface ContactusViewController ()

@end

@implementation ContactusViewController

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
    [button1 setTitle:@"목록보기" forState:UIControlStateNormal];
    [button2 setTitle:@"확인" forState:UIControlStateNormal];
    _titleText.inputAccessoryView = keyboardView;
    _contentText.inputAccessoryView = keyboardView;
    
    [_contentText.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [_contentText.layer setBorderWidth:0.3];
    [_contentText.layer setCornerRadius:6.0f];
    
    [_securityButton setImage:[UIImage imageNamed:@"common_check_off.png"] forState:UIControlStateNormal];
    [_securityButton setImage:[UIImage imageNamed:@"common_check_on.png"] forState:UIControlStateSelected];
    _securityButton.selected = YES;

    _done_clicked = NO;
    
    [[PhotomonInfo sharedInfo] loadContactList:[Common info].user.mUserid];
    //[[PhotomonInfo sharedInfo] loadContactPost:@"444236"];
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
    aRect.size.height -= (kbSize.height+40);

    if (_activeTextField != _contentText) {
        if (!CGRectContainsPoint(aRect, _activeTextField.frame.origin)) {
            [_scrollview scrollRectToVisible:_activeTextField.frame animated:YES];
        }
    }
    else {
        CGRect tvRect = _activeTextField.frame;
        tvRect.origin.y += _activeTextField.frame.size.height/2;
        if (!CGRectContainsPoint(aRect, tvRect.origin)) {
            [_scrollview scrollRectToVisible:tvRect animated:YES];
        }
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
        [_contentText becomeFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textField {
    _activeTextField = textField;
}

- (void)textViewDidEndEditing:(UITextView *)textField {
    _activeTextField = nil;
    [self.view endEditing:YES];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (_contentText.text.length > 0 && _contentText.textColor == [UIColor blackColor]) {
        return YES;
    }
    _contentText.text = @"";
    _contentText.textColor = [UIColor blackColor];
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView {
    if (_contentText.text.length < 1) {
        _contentText.textColor = [UIColor lightGrayColor];
        _contentText.text = @"내용을 입력해 주세요.";
        [_contentText resignFirstResponder];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)clickSecurity:(id)sender {
    _securityButton.selected = !_securityButton.selected;
}

- (IBAction)clickType:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = [UIAlertAction actionWithTitle:@"회원정보문의" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _typeText.text = @"회원정보문의";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];
    
    alert_action = [UIAlertAction actionWithTitle:@"상품문의" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _typeText.text = @"상품문의";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];
    
    alert_action = [UIAlertAction actionWithTitle:@"주문결제문의" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _typeText.text = @"주문결제문의";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];
    
    alert_action = [UIAlertAction actionWithTitle:@"배송문의" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _typeText.text = @"배송문의";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];
    
    alert_action = [UIAlertAction actionWithTitle:@"포토볼/쿠폰문의" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _typeText.text = @"포토볼/쿠폰문의";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];
    
    alert_action = [UIAlertAction actionWithTitle:@"취소/반품문의" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _typeText.text = @"취소/반품문의";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    alert_action = [UIAlertAction actionWithTitle:@"기타" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _typeText.text = @"기타";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];

    alert_action = [UIAlertAction actionWithTitle:@"제휴/광고문의" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        _typeText.text = @"제휴/광고문의";
        [vc dismissViewControllerAnimated:YES completion:nil];
    }];
    [vc addAction:alert_action];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)clickCall:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:02-548-4684"]];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    NSRange range = [_typeText.text rangeOfString:@"문의분야" options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        [[PhotomonInfo sharedInfo] alertMsg:@"문의분야를 선택하세요."];
        return;
    }
    if (_titleText.text.length < 1) {
        [[PhotomonInfo sharedInfo] alertMsg:@"제목을 입력하세요."];
        return;
    }
    if (_contentText.text.length < 1 || [_contentText.text isEqualToString:@"내용을 입력하세요."]) {
        [[PhotomonInfo sharedInfo] alertMsg:@"내용을 입력하세요."];
        return;
    }
    
    if( _done_clicked==YES )
        return;
    _done_clicked = YES;

    @try {
        ContactusItem *item = [[ContactusItem alloc] init];
        item.category = _typeText.text;
        item.subject = _titleText.text;
        item.content = _contentText.text;
        item.userID = [Common info].user.mUserid;
        item.userName = [Common info].user.mUserName;
        item.security = _securityButton.selected ? item.userID : @"";
        
        if ([[PhotomonInfo sharedInfo] sendContactInfo:item]) {
            [[PhotomonInfo sharedInfo] loadContactList:[Common info].user.mUserid];
            if (_parent_controller != nil) {
                [_parent_controller.table_view reloadData];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [[PhotomonInfo sharedInfo] alertMsg:@"전송에 실패했습니다."];
        }
    }
    @finally {
        _done_clicked = NO;
    }
}
@end
