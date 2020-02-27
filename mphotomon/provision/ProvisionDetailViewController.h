//
//  ProvisionDetailViewController.h
//  PHOTOMON
//
//  Created by cmh on 2018. 9. 11..
//  Copyright © 2018년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ProvisionDetailViewController : UIViewController<WKNavigationDelegate>

@property(nonatomic) NSString *url;

@end
