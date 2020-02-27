//
//  SocialLoginViewController.m
//  PHOTOMON
//
//  Created by 곽세욱 on 05/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "SNSLoginViewController.h"
#import "UIView+Toast.h"
#import "SocialBase.h"
#import "Common.h"

@implementation SNSLoginViewController

- (void)setData:(int)snsType delegate:(id<socialAuthDelegate>)delegate
{
	_snsType = snsType;
	_delegate = delegate;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_isSuccess = NO;
	
	NSString *oAuthURL = [[SocialManager inst] oAuthURL:_snsType];
	if (oAuthURL.length > 0) {
		NSURL *url = [[NSURL alloc] initWithString:oAuthURL];
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
		[_webview loadRequest:request];
		[_webview reload];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"Start CheckLogin");
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
	[_delegate oAuthDone:_isSuccess snsType:_snsType];
	[self dismissViewControllerAnimated:YES completion:nil];
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
    
    //해당 오류로 인한 진행불가를 무시
    if(error.code == 102 && [error.domain isEqualToString:@"WebKitErrorDomain"]){
        return;
    }
    
	[self.view makeToast:@"인터넷 연결이 원활하지 않습니다.\n잠시 후에 다시 시도 바랍니다."];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSLog(@"webViewDidFinishLoad");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString* requestString = [request.URL absoluteString];
	NSLog(@"webview: %@", requestString);
	
	if ([requestString hasPrefix:@"jscall:"]) {
		NSArray *components = [requestString componentsSeparatedByString:@"://"];
		if (components.count > 0) {
			NSString *command = [components objectAtIndex:1];
			if ([command isEqualToString:@"close"]) {
				[self close:self];
				return NO;
			}
		}
	}
	else {
		if([[SocialManager inst] evaluateAuthResponse:_snsType response:requestString]) {
			_isSuccess = YES;
			[self close:self];
			return NO;
		}
//		if ([[Instagram info] evaluateAuthResponse:requestString]) {
//			_is_success = YES;
//			[self close:self];
//			return NO;
//		}
	}
	return YES;
}

@end
