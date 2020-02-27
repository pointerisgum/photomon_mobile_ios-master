//
//  OrderDetailViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 15..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "UIView+Toast.h"

@interface OrderDetailViewController ()
@end

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
//	if (@available(iOS 13.0, *)) {
//	} else {
//		UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//		if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
//			statusBar.backgroundColor = [UIColor colorWithRed:246.0f/255.0f green:246.0f/255.0f blue:246.0f/255.0f alpha:1.0f];;
//		}
//	}

	[[self navigationController] setNavigationBarHidden:YES animated:NO];

	if(_webview != nil)
		_webview.delegate = self;

    
    NSString *url_str = [NSString stringWithFormat:@"https://www.photomon.com/wapp/order/OrderListLoading.asp?userid=%@&cart_session=%@&osinfo=ios&uniquekey=%@", [Common info].user.mUserid, [PhotomonInfo sharedInfo].cartSession, [Common info].device_uuid];
    
    if (![[Common info].nonMemberName isEqual: @""] ) {
        
        url_str = [NSString stringWithFormat:@"https://www.photomon.com/wapp/order/OrderListLoading.asp?username=%@&useremail=%@",[Common info].nonMemberName,[Common info].nonMemberEmail];
        
        url_str = [url_str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"nonmember webview requeststring : %@", url_str);
        
        [Common info].nonMemberName = @"";
        [Common info].nonMemberEmail = @"";

    }
    
	//url_str = [NSString stringWithFormat:@"http://m.photomon.com/wapp/order/OrderListLoading.asp?userid=jkfacet&cart_session=123123&osinfo=ios"];
	NSURL *url = [NSURL URLWithString:url_str];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[_webview loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSLog(@"webview: %@", requestString);
    
//    if ([requestString containsString:@"OrderListLoading.asp"] && ![[Common info].nonMemberName isEqual: @""] ) {
//
//        requestString = [NSString stringWithFormat:@"https://www.photomon.com/wapp/order/OrderListLoading.asp?username=%@&useremail=%@",[Common info].nonMemberName,[Common info].nonMemberEmail];
//
//
////        requestString = [requestString stringByReplacingOccurrencesOfString:@"username=" withString:[NSString stringWithFormat:@"username=%@", [Common info].nonMemberName]];
////        requestString = [requestString stringByReplacingOccurrencesOfString:@"useremail=" withString:[NSString stringWithFormat:@"useremail=%@", [Common info].nonMemberEmail]];
//
//        NSLog(@"nonmember webview requeststring : %@", requestString);
//
//        [Common info].nonMemberName = @"";
//        [Common info].nonMemberEmail = @"";
//    }
    
    if ([requestString hasPrefix:@"jscall:"]) {
        NSArray *components = [requestString componentsSeparatedByString:@"://"];
        if (components.count > 0) {
            NSString *command = [components objectAtIndex:1];
            if ([command isEqualToString:@"close"]) {
                
                [self dismissViewControllerAnimated:YES completion:nil];

                //[self close:self];
                return NO;
            }
			// SJYANG : 운송장 조회가 되지 않는 버그 수정
            else if ([command containsString:@"openurl"]) {
                NSString *workStr = [requestString copy];
                workStr = [workStr stringByReplacingOccurrencesOfString:@"jscall://openurl%7C" withString:@""];
                workStr = [workStr stringByReplacingOccurrencesOfString:@"jscall://openurl|" withString:@""];
				// PTODO
                workStr = [workStr stringByReplacingOccurrencesOfString:@"http//" withString:@"http://"];
                workStr = [workStr stringByReplacingOccurrencesOfString:@"https//" withString:@"https://"];
                
                NSString *_resultUrl = workStr;
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_resultUrl]];
				return NO;
            }
        }
    }
    return YES;
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
