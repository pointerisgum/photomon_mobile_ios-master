//
//  DdukddakSianBoardViewController.m
//  PHOTOMON
//
//  Created by 곽세욱 on 2019/10/20.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "DdukddakSianBoardViewController.h"
#import "Common.h"
#import "PhotomonInfo.h"
#import "Ddukddak.h"

@interface DdukddakSianBoardViewController () <NSURLConnectionDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@end

@implementation DdukddakSianBoardViewController

-(BOOL)prefersHomeIndicatorAutoHidden
{
	return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-dismiss-notification"
														  object:nil
														   queue:[NSOperationQueue mainQueue]
													  usingBlock:^(NSNotification *note) {
														  [self dismissViewControllerAnimated:NO completion:nil];
													  }];
		
	[Common info].deeplink_url = nil;
	
	WKUserContentController *contentController = [[WKUserContentController alloc] init];
	[contentController addScriptMessageHandler:self name:@"notification"];
	
	WKPreferences *pref = [[WKPreferences alloc] init];
	[pref setJavaScriptEnabled:YES];
	
	WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
	config.userContentController = contentController;
	config.preferences = pref;
	
	CGSize size = [UIScreen.mainScreen bounds].size;
	CGSize statusBar = [UIApplication sharedApplication].statusBarFrame.size;
    CGSize navigationBar = self.navigationController.navigationBar.frame.size;
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"뒤로" style:UIBarButtonItemStylePlain target:self action:@selector(Back)];
	self.navigationItem.leftBarButtonItem = backButton;
	
	_mainWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, statusBar.height + navigationBar.height, size.width, size.height - statusBar.height - navigationBar.height) configuration:config];
	
//	_mainWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];

	[self.view addSubview:_mainWebView];
	
	[_mainWebView setUIDelegate:self];
	[_mainWebView setNavigationDelegate:self];
	[_mainWebView sizeToFit];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self loadURL:URL_DDUKDDAK_SIAN_LIST];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UI

- (IBAction)Back
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WebView

- (void) loadURL:(NSString *)url {
	if ([Common info].user.mUserid.length > 0) {
		NSString *cartsession = [PhotomonInfo sharedInfo].cartSession;
		
		NSURL *reqURL = [Common buildQueryURL:url
										query:@[
												[NSURLQueryItem queryItemWithName:@"userid" value:[Common info].user.mUserid]
												,[NSURLQueryItem queryItemWithName:@"uniquekey" value:[Common info].device_uuid]
												,[NSURLQueryItem queryItemWithName:@"cart_session" value:cartsession]
												,[NSURLQueryItem queryItemWithName:@"osinfo" value:@"ios"]
												]];
		
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:reqURL];
		[_mainWebView loadRequest:request];
	}
	else {
		NSURL *reqURL = [Common buildQueryURL:url
										query:@[]];
		
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:reqURL];
		[_mainWebView loadRequest:request];
	}
}

- (void)webViewDidClose:(WKWebView *)webView {
	[self dismissViewControllerAnimated:YES completion:nil];
}

// 콘텐츠가 웹뷰에 로드되기 시작할 때 호출 (1)
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    NSLog(@"didStartProvisionalNavigation: %@", _mainWebView.URL);
	
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
    
//    CGSize size = [UIScreen.mainScreen bounds].size;
//    CGSize statusBar = [UIApplication sharedApplication].statusBarFrame.size;
//    CGSize navigationBar = self.navigationController.navigationBar.frame.size;
//
//    NSString *curURL = _mainWebView.URL.absoluteString;
//
//	if ([curURL containsString:@"photomon"]) {
//		if ([curURL containsString:@"orderpay.asp"]) {
//			self.navigationController.navigationBarHidden = NO;
//			[_mainWebView setFrame:CGRectMake(0, 0, size.width, size.height - statusBar.height - navigationBar.height)];
//			self.title = @"주문결제";
//		} else if([curURL containsString:@"ordercomplete.asp"]) {
//			self.navigationController.navigationBarHidden = YES;
//			[_mainWebView setFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height)];
//			self.title = @"결제완료";
//		} else if ([curURL isEqualToString:URL_MONTHLY_BABY_MAIN_URL]) {
//			self.navigationController.navigationBarHidden = YES;
//			[_mainWebView setFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height)];
//			self.title = @"월간 포토몬 베이비";
//		} else {
//			self.navigationController.navigationBarHidden = YES;
//			[_mainWebView setFrame:CGRectMake(0, statusBar.height, size.width, size.height - statusBar.height)];
//		}
//	} else {
//		self.navigationController.navigationBarHidden = NO;
//		[_mainWebView setFrame:CGRectMake(0, 0, size.width, size.height - statusBar.height - navigationBar.height)];
//	}

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
            
            if ([command isEqualToString:@"selectPhoto"]) {
            }
			else if([command isEqualToString:@"login"]) {
				if ([Common info].user.mUserid.length > 0){
				}
				else {
					_requestLogin = YES;
					[self dismissViewControllerAnimated:YES completion:^{
						[[Common info].main_controller didTouchMenuButton:nil];
					}];
				}
			}
			else if([command isEqualToString:@"close"]) {
				[self dismissViewControllerAnimated:YES completion:nil];
			}
			else if ([command hasPrefix:@"viewsian_call('"]) {
				NSString *bid = @"";
				if ([command hasSuffix:@"')"] ) {
					bid = [command substringWithRange:NSMakeRange(15, [command length] - 17)];
				} else if ([command hasSuffix:@"');"]) {
					bid = [command substringWithRange:NSMakeRange(15, [command length] - 18)];
				}
				
				[Ddukddak ShowDraft:self BID:bid];
			}
        }
    }
    
    if (decisionHandler) {
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
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
	
	[[Common info] alert:self Title:message Msg:@"" completion:^{
		completionHandler();
	}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
	
	[[Common info] alert:self Title:message Msg:@"" okCompletion:^{
		completionHandler(YES);
	} cancelCompletion:^{
		completionHandler(NO);
	} okTitle:@"확인" cancelTitle:@"취소"];
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

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
}

- (void)setNeedsFocusUpdate {
}

- (void)updateFocusIfNeeded {
}

@end
