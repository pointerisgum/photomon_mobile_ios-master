//
//  AuthView.h
//  PHOTOMON
//
//  Created by 김민아 on 02/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AuthViewDelegate <NSObject>

- (void)didTouchComfirmButton;

@end

@interface AuthView : UIView

+ (void)ShowAuthView:(CGRect)targetFrame
                self:(id<AuthViewDelegate>)delegate;


@end

NS_ASSUME_NONNULL_END
