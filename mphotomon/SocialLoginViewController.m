//
//  SocialLoginViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "SocialLoginViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "UIView+Toast.h"


@implementation SocialLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	[_socialLoginWv setDelegate:self];

	_bLogined = NO;
	_bCanceled = NO;

	NSString* url = [NSString stringWithFormat:URL_USER_SOCIAL_LOGIN_WEBVIEW, self.agent];
    NSLog(@"socialLogin url : %@", url);
    
	[self goToURL:url];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancel:(id)sender {
	if( _bLogined )
		return;

	_bCanceled = true;

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)goToURL:(NSString*) fullURL
{
	NSURL *url = [NSURL URLWithString:fullURL];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[_socialLoginWv loadRequest:requestObj];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	//NSLog(@"webViewDidStartLoad : %@", [[webView.request URL] absoluteString]);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//NSLog(@"webViewDidFinishLoad : %@", [[webView.request URL] absoluteString]);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString *url = [[request URL] absoluteString];
	_currentUrl = url;

	//NSLog(@"shouldStartLoadWithRequest : %@", url);

	if ([url containsString:@"photomon_api://social_login_"]) {
		if( _bLogined==YES )
			return NO;
		_bLogined = YES;

		if ([url containsString:@"photomon_api://social_login_success#"]) {
			NSLog(@"socialLogin OK");

	        @try {
				//url = [url stringByReplacingOccurrencesOfString:@"%23" withString:@"#"];
				url = [(NSString *)url stringByReplacingOccurrencesOfString:@"+" withString:@" "];
				url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
				NSArray* arrT = [url componentsSeparatedByString: @"#"];
				NSString* userid = [arrT objectAtIndex: 1];
				NSString* sns = [arrT objectAtIndex: 3];

                NSLog(@"snsType: %@ userId : %@", sns, userid);
                
				if( _bCanceled )
					return NO;

				if ([[Common info].login_info sendLoginInfo:userid PW:@"" LOGINTYPE:sns]) {
			
					[Analysis log:@"photomonLoginComplete"];
					
					NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
					[userDefaults setObject: userid forKey:@"userID"];
					[userDefaults setObject: @"" forKey:@"userPassword"];
					[userDefaults setObject: sns forKey:@"loginType"];
					[userDefaults synchronize];

					[Common info].login_status_changed = YES;
                    [[Common info].main_controller loadMainData];
                    
					NSString *welcome = [NSString stringWithFormat:@"%@님 반갑습니다.", [Common info].user.mUserName];
					[[PhotomonInfo sharedInfo] alertMsg:welcome];
					
                    [self dismissViewControllerAnimated:YES completion:nil];
				}
				else {
					if( _bCanceled )
						return NO;

					if ([[Common info].user.mcheck isEqualToString:@"S"]) {
                        [[Common info]alert:self Title:@"해당 계정은 휴면 상태입니다.\n웹사이트로 접속하여 휴면 상태 해제 후 이용해 주시기 바랍니다." Msg:@"" completion:^{
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }];
					}
					else {
                        [[Common info]alert:self Title:@"로그인이 실패하였습니다." Msg:@"" completion:^{
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }];
					}
				}
			}
	        @catch(NSException *exception) {
				if( _bCanceled )
					return NO;
                [[Common info]alert:self Title:@"로그인이 실패하였습니다." Msg:@"" completion:^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
			}
		} else {
			if( _bCanceled )
				return NO;

			NSLog(@"socialLogin FAIL");
            [[Common info]alert:self Title:@"로그인이 실패하였습니다." Msg:@"" completion:^{
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
		return NO;
	}

	return YES;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	//NSLog(@"didFailLoadWithError : %@", [[webView.request URL] absoluteString]);
}

@end
