//
//  ProvisionDetailViewController.m
//  PHOTOMON
//
//  Created by cmh on 2018. 9. 11..
//  Copyright © 2018년 maybeone. All rights reserved.
//

#import "ProvisionDetailViewController.h"

@interface ProvisionDetailViewController ()

@property (nonatomic, strong) WKWebView *wkWebView;

@end

@implementation ProvisionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame];
    [self.wkWebView setNavigationDelegate:self];
    [self.view addSubview:self.wkWebView];
    
    
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.google.co.kr"]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url]];
    [self.wkWebView loadRequest:request];
    
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

@end
