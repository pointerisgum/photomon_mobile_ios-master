//
//  ProgressView.h
//  PHOTOMON
//
//  Created by 김민아 on 12/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProgressView : UIView

- (instancetype)initWithTitle:(NSString *)title;
- (void)changeProgressTitle:(NSString *)title;
- (void)manageProgress:(CGFloat)progress title:(NSString *)title;
- (void)manageProgress:(CGFloat)progress;
- (void)endProgress;

@end

NS_ASSUME_NONNULL_END
