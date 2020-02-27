//
//  SocialLoginViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SocialLoginViewController : BaseViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *socialLoginWv;
@property (nonatomic) BOOL bLogined;
@property (nonatomic) BOOL bCanceled;
@property (strong, nonatomic) NSString* agent; //snsType
@property (strong, nonatomic) NSString* currentUrl;

- (IBAction)cancel:(id)sender;

@end
