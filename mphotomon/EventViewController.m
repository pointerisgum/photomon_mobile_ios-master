//
//  EventViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 11..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "EventViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "LoginViewController.h"
#import "SignupViewController.h"
#import "WebpageViewController.h"
#import <Security/Security.h>

@interface EventViewController ()<UIWebViewDelegate, NSURLConnectionDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler> {
//    BOOL hasGallaryEvent;
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

@implementation EventViewController

//-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
//{
//    if ( self.presentedViewController)
//    {
//        [super dismissViewControllerAnimated:flag completion:completion];
//    } else {
//        hasGallaryEvent = YES;
//    }
//}

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

// 정책 제어를 통해 WKNavigationActionPolicyAllow 또는 WKNavigationActionPolicyCancel
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSString* requestString = navigationAction.request.URL.absoluteString;
    requestString = [requestString stringByReplacingOccurrencesOfString:@"jscall://?" withString:@"jscall://"];
    NSLog(@"%@", requestString);
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
    
//    [self.webview loadHTMLString:@"<input type=\"file\" accept=\"image/*;capture=camera\">" baseURL:nil];
//
//    return;
//
//    NSURL *url = [NSURL URLWithString:@"http://html5demos.com/file-api-simple"];
//
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//
//    self.webview.scalesPageToFit = YES;
//
//    [self.webview loadRequest:request];
//
//    return;
    
    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    
    [contentController addScriptMessageHandler:self name:@"notification"];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = contentController;
    
    CGSize size = [UIScreen.mainScreen bounds].size;
    CGSize statusBar = [UIApplication sharedApplication].statusBarFrame.size;
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height) configuration:config];
    
    [self.view insertSubview:self.wkWebView atIndex:0];

    _resultAction = ACTION_NONE;
    
    [_checkDontShow setImage:[UIImage imageNamed:@"common_check_off.png"] forState:UIControlStateNormal];
    [_checkDontShow setImage:[UIImage imageNamed:@"common_check_on.png"] forState:UIControlStateSelected];
    _checkDontShow.selected = NO;
    _checkDontShow.hidden = (_eventType != 0);
    _labelDontShow.hidden = (_eventType != 0);

    _resultUrl = @"http://www.photomon.com"; // SJYANG : 기본적으로 "http://www.photomon.com" 을 세팅해 준다
    
    // load webview
    NSString *event_url = @"";
    if (_eventType == 0) {
#if 1
        NSString *urlstr = [Common info].connection.event_url; // popup event
        NSString *userid = [Common info].user.mUserid;
        NSString *cartsession = [PhotomonInfo sharedInfo].cartSession;
        event_url = [NSString stringWithFormat:@"%@?userid=%@&cart_session=%@&osinfo=ios&uniquekey=%@", urlstr, userid, cartsession, [Common info].device_uuid];
#else
        event_url = [Common info].connection.event_url;
#endif
    }
    else if (_eventType == 1) {
        NSString *urlstr = [Common info].connection.main_event_url; // mainview event
        NSString *userid = [Common info].user.mUserid;
        NSString *cartsession = [PhotomonInfo sharedInfo].cartSession;
        event_url = [NSString stringWithFormat:@"%@?userid=%@&cart_session=%@&osinfo=ios&uniquekey=%@", urlstr, userid, cartsession, [Common info].device_uuid];
    }
    
    if (event_url.length > 0) {
        NSURL *url = [[NSURL alloc] initWithString:event_url];

        // 2017.11.13 : SJYANG : openurl 작업
        /*
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [_webview loadRequest:request];
        */
        NSData *ret_val = [self downloadSyncWithURL:url];
        if (ret_val != nil) {
            NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
			//data = [data stringByReplacingOccurrencesOfString:@"http://www.daum.net" withString:@"http://www.aladin.co.kr/search/wsearchresult.aspx?SearchTarget=All&SearchWord=url+%B0%CB%BB%F5&x=0&y=0"]; // <== 테스트
			data = [data replacingWithPattern:@"ios_photomon_app.executeIOSapp\\('([\\S]+)',[\\s]+'([\\S]+)'\\);" withTemplate:@"window.location='jscall://?$1|$2';" error:nil];
            NSLog(@"\r\n\r\n%@", data);         
//            _webview.delegate = self;
//            [_webview loadHTMLString:data baseURL:url];
            self.wkWebView.UIDelegate = self;
            self.wkWebView.navigationDelegate = self;
            [self.wkWebView loadHTMLString:data baseURL:url];
	        //[_webview loadData:[data dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:url];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    if (!hasGallaryEvent) {
//        [self.wkWebView reload];
//    } else {
//        hasGallaryEvent = NO;
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

- (IBAction)clickDontShow:(id)sender {
    _checkDontShow.selected = !_checkDontShow.selected;
}

- (IBAction)close:(id)sender {
    if (_eventType == 0) {
        NSString *is_show = _checkDontShow.selected ? @"N" : @"Y";
        //NSString *eventID = [PhotomonInfo sharedInfo].eventID;
        NSString *eventID = [Common info].connection.event_id;
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject: eventID forKey:@"eventID"];
        [userDefaults setObject: is_show forKey:@"eventShow"];
        [userDefaults synchronize];
    }
    [super dismissViewControllerAnimated:YES completion:^{
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
            // SJYANG : openurl 작업
			/*
            case ACTION_OPENURL: {
				NSLog(@"_resultUrl : [%@]", _resultUrl);
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_resultUrl]];
                break;
            }
			*/
        }
#endif
    }];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return YES;
}

//
#pragma mark - Webview delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"WEBVIEW ERROR");
    [self.view makeToast:@"인터넷 연결이 원활하지 않습니다.\n잠시 후에 다시 시도 바랍니다."];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString* requestString = [NSString stringWithString:[request.URL absoluteString]];
	requestString = [requestString stringByReplacingOccurrencesOfString:@"jscall://?" withString:@"jscall://"];
    NSLog(@"%@", requestString);
    if ([requestString hasPrefix:@"jscall:"]) {
        NSArray *components = [requestString componentsSeparatedByString:@"://"];
        if (components.count > 0) {
            NSString *command = [components objectAtIndex:1];

            if ([command isEqualToString:@"close"]) {
                _resultAction = ACTION_NONE;
                [self close:self];
                return NO;
            }
            if ([command isEqualToString:@"signup"]) {
                _resultAction = ACTION_SIGNUP;
                [self close:self];
                return NO;
            }
            if ([command isEqualToString:@"login"]) {
                _resultAction = ACTION_LOGIN;
                [self close:self];
                return NO;
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
                return NO;
            }
        }
    }
    /*
    if ([requestString hasPrefix:@"android_photomon_app.executeAndroidapp('"]) {
    }
    */
    return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    NSURLCredential *cred;
    cred = [NSURLCredential credentialForTrust:trust];
    [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

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

@end
