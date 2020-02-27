//
//  PayWebViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 20..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PayWebViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "UIView+Toast.h"

@interface PayWebViewController ()

@end

@implementation PayWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"PayWebView"];
    
    _is_paycomplete = FALSE;
    self.navigationItem.rightBarButtonItem = nil; // 스토리보드를 위한 더미 버튼이라 보일 필요가 없다.
    
    NSString *poid = [PhotomonInfo sharedInfo].payment.p_oid;
    if (poid && ![poid isEqualToString:@"error"]) {
        [[PhotomonInfo sharedInfo] postPaymentInfo:_web_view];
    }
    else {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        [[Common info].main_controller onCartviaExternalController];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"PayWebView" ScreenClass:[self.classForCoder description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Webview delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"WEBVIEW ERROR");
    [self.view makeToast:@"연결에 실패했습니다."];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
}

#if 1 // 임시 코드: 성공/실패를 판단할 기준이 정해지면 옮길것.
#define PAYMENT_SUCCESS @"/orderPay_step3.asp?tuid=%@"
#define PAYMENT_ERROR01 @"http://m.photomon.com/"
#define PAYMENT_ERROR02 @"https://m.photomon.com/"
#define PAYMENT_ERROR03 @"http://m.photomon.com/mOrder/orderCart.asp"
#define PAYMENT_ERROR04 @"http://m.photomon.com/?errCode=Y"
#endif

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString* URLString = [NSString stringWithString:[request.URL absoluteString]];
    NSLog(@"webview: %@", URLString);

    if (_is_paycomplete) {
        [self performSegueWithIdentifier:@"OrderCompleteSegue" sender:self];
        return NO;
    }

    NSString * tempStr = [NSString stringWithFormat:PAYMENT_SUCCESS, [PhotomonInfo sharedInfo].payment.p_oid];
    if ([URLString rangeOfString:tempStr].location != NSNotFound) {
        NSLog(@"결제 완료!!: %@", [PhotomonInfo sharedInfo].payment.p_oid);
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = nil; // 이미 결제가 완료되어 BACK 할 수 없다.
        _is_paycomplete = TRUE;
        
        // 마지막 결제 완료 페이지(깨져보임)를 보여주지 않고, 바로 장바구니로 넘어가게 한다.
        [self performSegueWithIdentifier:@"OrderCompleteSegue" sender:self];
    }
    else if ([URLString isEqualToString:PAYMENT_ERROR01]
             || [URLString isEqualToString:PAYMENT_ERROR02]
             || [URLString isEqualToString:PAYMENT_ERROR03]
             || [URLString isEqualToString:PAYMENT_ERROR04]) {
        NSLog(@"결제 취소!!");
        [self.navigationController popViewControllerAnimated:YES];
    }
    return YES;
}

- (IBAction)cancel:(id)sender {
    if (!_is_paycomplete) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
