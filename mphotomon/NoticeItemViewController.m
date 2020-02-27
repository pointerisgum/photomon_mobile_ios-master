//
//  NoticeItemViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 11..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "NoticeItemViewController.h"
#import "PhotomonInfo.h"

@interface NoticeItemViewController ()

@end

@implementation NoticeItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSData *data = [[PhotomonInfo sharedInfo] loadNoticeItem:_notice_idx];
    if (data != nil) {
        [_noticeWebview loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@""]];
    }
    else {
        [[PhotomonInfo sharedInfo] alertMsg:@"공지사항 내용을 가져올 수 없습니다."];
    }
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
