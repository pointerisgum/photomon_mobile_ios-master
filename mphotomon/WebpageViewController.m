//
//  WebpageViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 8..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "WebpageViewController.h"
#import "UIView+Toast.h"

@interface WebpageViewController ()

@end

@implementation WebpageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    NSURL *url = [[NSURL alloc] initWithString:_url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	//NSLog(@"url : %@", url);
    [_webview loadRequest:request];
    [_webview reload];
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

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    return YES;
}

@end
