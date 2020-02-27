//
//  FrameWebViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 11..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "FrameWebViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "WebpageViewController.h"
#import "WVCartViewController.h"

@interface FrameWebViewController ()<NSURLConnectionDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler> {
    BOOL goCartFlag;
}

@end

@implementation NSString(RegularExpression)

- (NSString *)replacingWithPattern:(NSString *)pattern withTemplate:(NSString *)withTemplate error:(NSError **)error {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:error];
    return [regex stringByReplacingMatchesInString:self
                                           options:0
                                             range:NSMakeRange(0, self.length)
                                      withTemplate:withTemplate];
}
@end

@implementation FrameWebViewController

NSString* last_url;

/**
 *  인증서 신뢰
 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    CFDataRef exceptions = SecTrustCopyExceptions (serverTrust);
    SecTrustSetExceptions (serverTrust, exceptions);
    CFRelease (exceptions);
    completionHandler (NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:serverTrust]);
}

// 콘텐츠가 웹뷰에 로드되기 시작할 때 호출 (1)
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSLog(@"didStartProvisionalNavigation: %@", navigation);
}


- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation: %@", navigation);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"didFailProvisionalNavigation: %@navigation, error: %@", navigation, error);
}

// 네비게이션이 요청되었을 때 (2)
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"didCommitNavigation");
}

// 네비게이션이 완료 되었을 떄 (3)
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSLog(@"didFinishNavigation");
//    if (self.wkWebView.canGoBack) {
//        [self.wkWebView goBack];
//        NSLog(@"ASDF : CAN GO BACK");
//    } else {
//        NSLog(@"ASDF : CAN NOT GO BACK");
//    }
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(nonnull WKNavigationResponse *)navigationResponse decisionHandler:(nonnull void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSString* responseString = navigationResponse.response.URL.absoluteString;
//    responseString = [responseString stringByReplacingOccurrencesOfString:@"jscall://?" withString:@"jscall://"];
    NSLog(@"ASDF : [RESPONSE] %@", responseString);
    
    /**
     *  add_cart_ok.asp
     *  add_cart_graphic_ok.asp
     *  위의 두 개의 액션이 있고 난 후 jscall://gocart_webview 요청이 일어난 뒤에
     *  하얀 화면처리가 되는 부분 제거
     *  goCartFlag 불린 값을 이용해서 만약 해당 플래그가 NO 값이면
     *  decidePolicyForNavigationAction 에서 "CartSegue" 세그위에 실행
     */
    if ([responseString containsString:@"add_cart_ok.asp"] || [responseString containsString:@"add_cart_graphic_ok.asp"] ) {
//        [self.wkWebView goBack];
        [self performSegueWithIdentifier:@"CartSegue" sender:self];
        if (decisionHandler) {
            goCartFlag = YES;
            decisionHandler(WKNavigationResponsePolicyCancel);
        }
    } else {
        
        if (decisionHandler) {
            goCartFlag = NO;
            decisionHandler(WKNavigationResponsePolicyAllow);
        }
    }
    
    
}

// 정책 제어를 통해 WKNavigationActionPolicyAllow 또는 WKNavigationActionPolicyCancel
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString* requestString = navigationAction.request.URL.absoluteString;
    requestString = [requestString stringByReplacingOccurrencesOfString:@"jscall://?" withString:@"jscall://"];
    NSLog(@"ASDF : [REQUEST] %@", requestString);
    if ([requestString hasPrefix:@"jscall:"]) {
        NSArray *components = [requestString componentsSeparatedByString:@"://"];
        if (components.count > 0) {
            NSString *command = [components objectAtIndex:1];
            
            if ([command isEqualToString:@"close"]) {
                _resultAction = ACTION_NONE;
                [self close:self];
            }
            if ([command isEqualToString:@"signup"]) {
                _resultAction = ACTION_SIGNUP;
                [self close:self];
            }
            if ([command isEqualToString:@"login"]) {
                _resultAction = ACTION_LOGIN;
                [self close:self];
            }
            if ([command isEqualToString:@"gocart_webview"]) {
                
                if (!goCartFlag) {
                    [self performSegueWithIdentifier:@"CartSegue" sender:self];
                }
            }
            // SJYANG : openurl 작업
            if ([command containsString:@"openurl"]) {
                _resultAction = ACTION_OPENURL;
                
                NSString *workStr = [requestString copy];
                workStr = [workStr stringByReplacingOccurrencesOfString:@"jscall://openurl%7C" withString:@""];
                
                _resultUrl = workStr;
                NSLog(@"_resultUrl : [%@]", _resultUrl);
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_resultUrl]];
                [self close:self];
            }
        }
    }
    /*
     if ([requestString hasPrefix:@"android_photomon_app.executeAndroidapp('"]) {
     }
     */
    
    if (decisionHandler) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Title" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Title" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/**
 *  자바스크립트 연동
 */
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message{
    NSDictionary *sentData = (NSDictionary*)message.body;
    NSString *code = [sentData objectForKey:@"resultCode"];
    
    if ([code isEqualToString:@"REGIST_CANCEL"]) {
        //        [self cancelJoinMember];
    } else if ([code isEqualToString:@"REGIST_FAILURE"]) {
        //        [self failureJoinMember];
    } else if ([code isEqualToString:@"REGIST_SUCCESS"]) {
        //        [self successJoinMember:[sentData objectForKey:@"memberId"]];
    } else if ([code isEqualToString:@"EXIST_MEMBER"]) {
        //        [self existMember];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    
    [contentController addScriptMessageHandler:self name:@"notification"];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = contentController;
    
    CGSize size = [UIScreen.mainScreen bounds].size;
    CGSize statusBar = [UIApplication sharedApplication].statusBarFrame.size;
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height) configuration:config];
    
    [self.view insertSubview:self.wkWebView atIndex:0];

    _resultAction = ACTION_NONE;
    
    // load webview
    NSString *wvUrl = @"";
	NSString *urlstr = _webviewUrl;
	NSString *userid = [Common info].user.mUserid;
	NSString *cartsession = [PhotomonInfo sharedInfo].cartSession;
	wvUrl = [NSString stringWithFormat:@"%@&userid=%@&cart_session=%@&osinfo=ios&uniquekey=%@", urlstr, userid, cartsession, [Common info].device_uuid];
	//NSLog(@"wvUrl : %@", wvUrl);
    
	NSURL *url = [[NSURL alloc] initWithString:wvUrl];

	// 2017.11.13 : SJYANG : openurl 작업
	/*
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	[_webview loadRequest:request];
	*/
	NSData *ret_val = [self downloadSyncWithURL:url];
	if (ret_val != nil) {
		NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
		data = [data replacingWithPattern:@"ios_photomon_app.executeIOSapp\\('([\\S]+)',[\\s]+'([\\S]+)'\\);" withTemplate:@"window.location='jscall://?$1|$2';" error:nil];
		//NSLog(@"\r\n\r\n%@", data);         
        self.wkWebView.UIDelegate = self;
        self.wkWebView.navigationDelegate = self;
		[self.wkWebView loadHTMLString:data baseURL:url];
	}

	last_url = wvUrl;
}

- (void)viewWillAppear:(BOOL)animated {
	// 2018.06 : SJYANG
    //[_webview reload];
//    if ([last_url rangeOfString:@"frame_list_apptest.asp"].location == NSNotFound) {
//        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:last_url]]];
//    }
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

- (void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
#if 1
        switch (_resultAction) {
            case ACTION_NONE:
                break;
            case ACTION_SIGNUP: {
                SignupViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SignupPage"];
                [[Common info].main_controller presentViewController:vc animated:YES completion:nil];
                break;
            }
            case ACTION_LOGIN: {
                LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginPage"];
                [[Common info].main_controller presentViewController:vc animated:YES completion:nil];
                break;
            }
        }
#endif
    }];
}

//
#pragma mark - Webview delegate
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    NSLog(@"WEBVIEW ERROR");
//    //[self.view makeToast:@"인터넷 연결이 원활하지 않습니다.\n잠시 후에 다시 시도 바랍니다."];
//}
//
//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    NSLog(@"webViewDidStartLoad");
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    NSLog(@"webViewDidFinishLoad");
//}
//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSString* requestString = [NSString stringWithString:[request.URL absoluteString]];
//    requestString = [requestString stringByReplacingOccurrencesOfString:@"jscall://?" withString:@"jscall://"];
//
//    if ([requestString hasPrefix:@"jscall:"]) {
//        NSArray *components = [requestString componentsSeparatedByString:@"://"];
//        if (components.count > 0) {
//            NSString *command = [components objectAtIndex:1];
//
//            if ([command isEqualToString:@"close"]) {
//                _resultAction = ACTION_NONE;
//                [self close:self];
//                return NO;
//            }
//            if ([command isEqualToString:@"signup"]) {
//                _resultAction = ACTION_SIGNUP;
//                [self close:self];
//                return NO;
//            }
//            if ([command isEqualToString:@"login"]) {
//                _resultAction = ACTION_LOGIN;
//                [self close:self];
//                return NO;
//            }
//            if ([command isEqualToString:@"gocart_webview"]) {
//                //NSLog(@"webview:HERE");
//                /*
//                WVCartViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WVCart"];
//                [self presentViewController:vc animated:YES completion:nil];
//                */
//                [self performSegueWithIdentifier:@"CartSegue" sender:self];
//                return NO;
//            }
//            // SJYANG : openurl 작업
//            if ([command containsString:@"openurl"]) {
//                _resultAction = ACTION_OPENURL;
//
//                NSString *workStr = [requestString copy];
//                workStr = [workStr stringByReplacingOccurrencesOfString:@"jscall://openurl%7C" withString:@""];
//
//                _resultUrl = workStr;
//                //NSLog(@"_resultUrl : [%@]", _resultUrl);
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_resultUrl]];
//                [self close:self];
//                return NO;
//            }
//        }
//    }
//    else
//    {
//        // 2018.06 : SJYANG
//        if ([requestString rangeOfString:@"add_cart_graphic_ok.asp"].location == NSNotFound) {
//            last_url = requestString;
//        }
//    }
//    return YES;
//}

- (NSData *)downloadSyncWithURL:(NSURL *)url {
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:5.0f];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"** download error: %@", error);
        //[self alertMsg: NSLocalizedString(@"errorNetworkConnection", nil)];
        return nil;
    }
    return data;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"CartSegue"]) {
//        UINavigationController *nvc = [segue destinationViewController];
//        WVCartViewController *vc = nvc.viewControllers[0];
//        vc.dismissCallBack = ^{
//            [self dismissViewControllerAnimated:NO completion:^{
//
//            }];
//        };
//    }
//}

@end
