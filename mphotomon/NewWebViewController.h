//
//  NewWebViewController.h
//  PHOTOMON
//
//  Created by 김민아 on 11/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WebViewType) {
    WebViewTypeUserInfo = 0,
    WebViewTypeTerms,
    WebViewTypeDeliver,
    WebViewTypeCustom,
};

@interface NewWebViewController : UIViewController

@property (assign, nonatomic) WebViewType type;
@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *urlString;

@end

NS_ASSUME_NONNULL_END
