//
//  oAuthViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 3. 11..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "oAuthViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "Instagram.h"

@interface oAuthViewController ()

@end

@implementation oAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _is_success = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    if (_oauth_url.length > 0) {
        NSURL *url = [[NSURL alloc] initWithString:_oauth_url];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [_webview loadRequest:request];
        [_webview reload];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate oAuthDone:_is_success];
    }];
}


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
        if ([[Instagram info] evaluateAuthResponse:requestString]) {
            _is_success = YES;
            [self close:self];
            return NO;
        }
    }
    return YES;
}

@end
