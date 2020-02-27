//
//  WVCartController.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 20..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "WVCartViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "LoginViewController.h"
#import "UIView+Toast.h"


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

@interface WVCartViewController ()<WKUIDelegate, WKNavigationDelegate>
@property BOOL hasLoginAction;
@end

@implementation WVCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"WVCartView"];


    _is_innerrequest = NO;
    _resultAction = ACTION_NONE;
    _osinfo = @"ios"; // PTODO : android => ios

	//_web_view = [[WKWebView alloc] initWithFrame:self.view.frame];
	_web_view = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];


	[_web_view setUIDelegate:self];
	[_web_view setNavigationDelegate:self];

	[_web_view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self.view addSubview:_web_view];


	if([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)
		_web_view.translatesAutoresizingMaskIntoConstraints = FALSE;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_web_view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_web_view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_web_view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_web_view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];

	_web_view.backgroundColor = [UIColor clearColor];
	_web_view.opaque = NO;
    
    [self loadCart];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.hasLoginAction) {
        self.hasLoginAction = NO;
        [self loadCart];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"WVCartView" ScreenClass:[self.classForCoder description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"1. didCommitNavigation");
}
 
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"2. didFinishNavigation");
}
 
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    if([error code] != NSURLErrorCancelled) {
        NSLog(@"WEBVIEW ERROR : %@", error.description);
        [self.view makeToast:@"인터넷 연결이 원활하지 않습니다.\n잠시 후에 다시 시도 바랍니다."];
    }
}

/*
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}
*/

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
	//[WKWebViewPanelManager presentAlertOnController:self.view.window.rootViewController title:@"Alert" message:message handler:completionHandler];
	[WKWebViewPanelManager presentAlertOnController:self title:@"알림" message:message handler:completionHandler];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    //[WKWebViewPanelManager presentConfirmOnController:self.view.window.rootViewController title:@"Confirm" message:message handler:completionHandler];
    [WKWebViewPanelManager presentConfirmOnController:self title:@"확인" message:message handler:completionHandler];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    [WKWebViewPanelManager presentPromptOnController:self title:@"입력" message:prompt defaultText:defaultText handler:completionHandler];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
	/*
    if (navigationAction.navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSURL *url = navigationAction.request.URL;
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
	*/
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    //쿠키 강제 허용 (이니시스 코드)
    NSHTTPCookieStorage *cookieSto = [NSHTTPCookieStorage sharedHTTPCookieStorage]; 
    [cookieSto setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways]; 

    NSString* requestString = [NSString stringWithString:[navigationAction.request.URL absoluteString]];
    requestString = [requestString stringByReplacingOccurrencesOfString:@"jscall://?" withString:@"jscall://"];


	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	// 임시 : 테스트 코드
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	/*
	// http://m.photomon.com/wapp/order/OrderCompleteGate.asp?userid=naver@59112666&cart_session=37374214384539&osinfo=ios?P_STATUS=00&tuid=3595938
    //if(_is_innerrequest == NO && requestString!=nil && [requestString containsString:@"ordercart"]) {
    if(_is_innerrequest == NO && requestString!=nil) {
	    requestString = [requestString stringByReplacingOccurrencesOfString:@"=ios?" withString:@"=ios&"];     
		NSURL *url = [[NSURL alloc] initWithString:requestString];
        NSData *ret_val = [self downloadSyncWithURL:url];

        if (ret_val != nil) {
            _is_innerrequest = YES;
            NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
			
			{
				NSString *target_url = [NSString stringWithFormat:@"javascript:goodscancelGo();"];
				data = [data stringByReplacingOccurrencesOfString:@"goodscancelGo();" withString:target_url];             
			}

			NSLog(@"\r\n\r\nWEBVIEW_DATA : %@", data);

			NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            [_web_view loadHTMLString:data baseURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
			return;
        }
    }
    _is_innerrequest = NO;
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	*/


    requestString = [requestString stringByReplacingOccurrencesOfString:@"jscall://?" withString:@"jscall://"];

    NSLog(@"requestString : %@", requestString);

    if ([requestString containsString:@"ordercart.asp"]) {
        self.navigationItem.title = @"장바구니";

        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"닫기" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = leftBarButton;

        [[self navigationController] setNavigationBarHidden:NO animated:NO];
    }
    else if ([requestString containsString:@"OrderPay.asp"]) {
        self.navigationItem.title = @"주문결제";

        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"뒤로" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = leftBarButton;

        [[self navigationController] setNavigationBarHidden:NO animated:NO];
    }
    else if ([requestString containsString:@"OrderComplete.asp"]) {
        self.navigationItem.title = @"주문완료";

        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"닫기" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = leftBarButton;

        [[self navigationController] setNavigationBarHidden:NO animated:NO];
    }
    else if ([requestString containsString:@"orderlistloading.asp"] || [requestString containsString:@"OrderList.asp"] || [requestString containsString:@"order_Cancel.asp"]) {
        self.navigationItem.title = @"주문내역";

        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"뒤로" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = leftBarButton;

        [[self navigationController] setNavigationBarHidden:YES animated:NO];
    }   
    else {
        if(![requestString containsString:@"m.photomon.com"] && ![requestString containsString:@"about:blank"]) {
            self.navigationItem.title = @"장바구니";

            UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"닫기" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
            self.navigationItem.leftBarButtonItem = leftBarButton;

            [[self navigationController] setNavigationBarHidden:NO animated:NO];
        }
    } 

    NSLog(@"webview: %@", requestString);

    if ([requestString hasPrefix:@"jscall:"]) {
        NSArray *components = [requestString componentsSeparatedByString:@"://"];
        if (components.count > 0) {
            NSString *command = [components objectAtIndex:1];

            if ([command isEqualToString:@"close"]) {
                _resultAction = ACTION_CLOSE;
                [self doAction];
                decisionHandler(WKNavigationActionPolicyCancel);
				return;
            }
            else if ([command containsString:@"login"]) {
                _resultAction = ACTION_GOLOGIN;
                [self doAction];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
            else if ([command containsString:@"openurl"]) {
                _resultAction = ACTION_OPENURL;

                NSString *workStr = [requestString copy];
                workStr = [workStr stringByReplacingOccurrencesOfString:@"jscall://openurl%7C" withString:@""];
				// PTODO
                workStr = [workStr stringByReplacingOccurrencesOfString:@"http//" withString:@"http://"];
                workStr = [workStr stringByReplacingOccurrencesOfString:@"https//" withString:@"https://"];
                
                _resultUrl = workStr;
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_resultUrl]];
                decisionHandler(WKNavigationActionPolicyCancel);
				return;
            }
            else if ([command isEqualToString:@"gocart_webview"]) {
                _resultAction = ACTION_GOCART;
                [self doAction];
                decisionHandler(WKNavigationActionPolicyCancel);
				return;
            }
            else if ([command containsString:@"gopayment_webview"]) {
                NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *userID = [userDefaults objectForKey:@"userID"];
                void (^goPayment)() = ^void() {
                    _resultAction = ACTION_GOPAYMENT;

                    NSString *workStr = [requestString copy];
                    _resultParam = [workStr stringByReplacingOccurrencesOfString:@"jscall://gopayment_webview%7C" withString:@""];

                    [self doAction];
                    decisionHandler(WKNavigationActionPolicyCancel);
                };

                if (userID.length > 0) {
                    goPayment();
                } else {
                    //MAcheck
                    [[Common info] alert:self Title:@"비회원 상태입니다. 회원으로 주문하시면 가격할인 등\n다양한 혜택을 받으실 수 있습니다." Msg:@"" okCompletion:^{
                        goPayment();

                    } cancelCompletion:^{
                        
                        [self dismissViewControllerAnimated:YES completion:^{
                            [[Common info].main_controller didTouchMenuButton:nil];
                        }];
                        
//                        decisionHandler(WKNavigationActionPolicyCancel);

                    } okTitle:@"비회원 주문" cancelTitle:@"로그인"];
                                    }
				return;
            }
            else if ([command containsString:@"ordercomplete"]) {
                _resultAction = ACTION_ORDERCOMPLETE;

                NSString *workStr = [requestString copy];
                _resultParam = [workStr stringByReplacingOccurrencesOfString:@"jscall://ordercomplete%7C" withString:@""];

                [self doAction];
                decisionHandler(WKNavigationActionPolicyCancel);
				return;
            }
            else if ([command containsString:@"orderlist"]) {
                _resultAction = ACTION_ORDERLIST;

                NSString *workStr = [requestString copy];
                _resultParam = [workStr stringByReplacingOccurrencesOfString:@"jscall://orderlist%7C" withString:@""];

                [self doAction];
                decisionHandler(WKNavigationActionPolicyCancel);
				return;
            }
        }
    }

    if (![requestString hasPrefix:@"http://"] && ![requestString hasPrefix:@"https://"]) {
        NSURL *url = navigationAction.request.URL;
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (IBAction)cancel:(id)sender {
	if ([self.navigationItem.title isEqualToString:@"주문결제"]) {
        [self loadCart];
    }
    else if ([self.navigationItem.title isEqualToString:@"결제진행중"]) {
        [self loadOrderPay];
    }
    else if ([self.navigationItem.title isEqualToString:@"주문완료"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if ([self.navigationItem.title isEqualToString:@"주문내역"]) {
        [self loadOrderComplete];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
//        if(self.dismissCallBack){
//            [self dismissViewControllerAnimated:YES completion:^{
//                self.dismissCallBack();
//            }];
//        }else{
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
    }
}

- (void)doAction {
	if(_resultAction == ACTION_CLOSE) {
        [self dismissViewControllerAnimated:YES completion:nil];
		return;
	}
    else if(_resultAction == ACTION_GOLOGIN) {
        LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginPage"];
//        [[Common info].main_controller presentViewController:vc animated:YES completion:nil];
        [self presentViewController:vc animated:YES completion:^{
            self.hasLoginAction = YES;
        }];
        return;
    }
	else if(_resultAction == ACTION_GOCART) {
        [self loadCart];
		return;
	}
	else if(_resultAction == ACTION_GOPAYMENT) {
        [self loadOrderPay];
		return;
	}
	else if(_resultAction == ACTION_ORDERCOMPLETE) {
        [self loadOrderComplete];
		return;
	}
	else if(_resultAction == ACTION_ORDERLIST) {
        [self loadOrderList];
		return;
	}
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

- (void)loadCart {
    NSString *userid = [Common info].user.mUserid;
    
    if (userid == nil) {
        userid = @"";
    }
    
    NSString *cartsession = [PhotomonInfo sharedInfo].cartSession;

    NSString *loading_url = [NSString stringWithFormat:@"https://www.photomon.com/wapp/order/OrderCart.asp?userid=%@&cart_session=%@&osinfo=%@&uniquekey=%@", userid, cartsession, _osinfo, [Common info].device_uuid];
	//NSString *loading_url = @"http://m.photomon.com/wapp/order/order_Cancel.asp?userid=naver@59112666&cart_session=37374214384539&osinfo=ios&username=&useremail=&divview=member&tuid=3597564";
    NSURL *nsurl = [[NSURL alloc] initWithString:loading_url];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:nsurl];
    [_web_view loadRequest:request];
}

- (void)loadOrderPay {
    NSString *userid = [Common info].user.mUserid;
    
    if (userid == nil) {
        userid = @"";
    }
    
    NSString *cartsession = [PhotomonInfo sharedInfo].cartSession;

    NSString *loading_url = [NSString stringWithFormat:@"https://www.photomon.com/wapp/order/OrderPay.asp?userid=%@&cart_session=%@&osinfo=%@%@&uniquekey=%@", userid, cartsession, _osinfo, _resultParam, [Common info].device_uuid];
	//NSString *loading_url = @"http://m.photomon.com/wapp/order/OrderCompleteGate.asp?userid=naver@59112666&cart_session=37374214384539&osinfo=ios&P_STATUS=00&tuid=3595992";
    NSURL *nsurl = [[NSURL alloc] initWithString:loading_url];

	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:nsurl];
    [_web_view loadRequest:request];
}

- (void)loadOrderComplete {
    NSString *userid = [Common info].user.mUserid;
    
    if (userid == nil) {
        userid = @"";
    }
    
    NSString *cartsession = [PhotomonInfo sharedInfo].cartSession;

    NSString *loading_url = [NSString stringWithFormat:@"https://www.photomon.com/wapp/order/OrderComplete.asp?userid=%@&cart_session=%@&osinfo=%@%@&uniquekey=%@", userid, cartsession, _osinfo, _resultParam, [Common info].device_uuid];
    NSURL *nsurl = [[NSURL alloc] initWithString:loading_url];

	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:nsurl];
    [_web_view loadRequest:request];
}

- (void)loadOrderList {
	NSString *userid = [Common info].user.mUserid;
    
    if (userid == nil) {
        userid = @"";
    }
    
	NSString *cartsession = [PhotomonInfo sharedInfo].cartSession;

    NSString *loading_url = [NSString stringWithFormat:@"https://www.photomon.com/wapp/order/orderlistloading.asp?userid=%@&cart_session=%@&osinfo=%@&uniquekey=%@", userid, cartsession, _osinfo, [Common info].device_uuid];
    NSURL *nsurl = [[NSURL alloc] initWithString:loading_url];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:nsurl];
    [_web_view loadRequest:request];
}

@end
