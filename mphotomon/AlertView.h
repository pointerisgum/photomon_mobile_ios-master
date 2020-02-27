//
//  AlertView.h
//  PHOTOMON
//
//  Created by 김민아 on 11/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^alertCompletion)(void);

@interface AlertView : UIView

+ (void)ShowAlertTitle:(NSString *)title
              subTitle:(NSString *)subTitle
            completion:(alertCompletion)completion;

+ (void)ShowAlertWithCancelTitle:(NSString *)title
                        subTitle:(NSString *)subTitle
                    okCompletion:(alertCompletion)okCompletion
                cancelCompletion:(alertCompletion)cancelConpletion
                        okButton:(NSString *)okTitle cancelButton:(NSString *)cancelTItle;


@end

NS_ASSUME_NONNULL_END
