//
//  ThanksViewController.m
//  
//
//  Created by photoMac on 2015. 8. 4..
//
//

#import "ThanksViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface ThanksViewController ()

@end

@implementation ThanksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Analysis log:@"PayComplete"];
    [Analysis commerce];

    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [Analysis firAnalyticsWithScreenName:@"className" ScreenClass:[self.classForCoder description]];
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

- (IBAction)clickAppstore:(id)sender {
    // https://itunes.apple.com/kr/app/photomon/id723333895?mt=8
    //NSURL *url = [NSURL URLWithString:[PhotomonInfo sharedInfo].appUrl];
    NSURL *url = [NSURL URLWithString:[Common info].connection.appstore_url];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)clickHome:(id)sender {
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

@end
