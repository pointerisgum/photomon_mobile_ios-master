//
//  NoticeItemViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 11..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoticeItemViewController : UIViewController

@property (strong, nonatomic) NSString *notice_idx;

@property (strong, nonatomic) IBOutlet UIWebView *noticeWebview;

@end
