//
//  AlertView.m
//  PHOTOMON
//
//  Created by 김민아 on 11/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "AlertView.h"


@interface AlertView ()
@property (weak, nonatomic) IBOutlet UIButton *btnOk;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbSubTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcHeightOfAlert;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcWidthOfOkButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcWidthOfCancelButton;
@property (copy, nonatomic) alertCompletion completion;
@property (copy, nonatomic) alertCompletion cancelCompletion;
@property (strong, nonatomic) AlertView *alertView;
@end

@implementation AlertView

+ (void)ShowAlertTitle:(NSString *)title
              subTitle:(NSString *)subTitle
            completion:(alertCompletion)completion {
    
    AlertView *alert = [[[NSBundle mainBundle]loadNibNamed:@"AlertView" owner:self options:nil]lastObject];
    
    alert.frame = [UIScreen mainScreen].bounds;
    alert.btnCancel.hidden = true;
    
    if ([subTitle isEqualToString:@""]) {
        alert.lbTitle.text = title;
        alert.lbSubTitle.hidden = true;
        
    } else {
        alert.lbTitle.text = title;
        alert.lbSubTitle.text = subTitle;
        alert.lbSubTitle.hidden = true;
        alert.alcHeightOfAlert.constant = 151.0f;
    }
    
    alert.alertView = alert;
    alert.completion = completion;
    
    [[UIApplication sharedApplication].keyWindow addSubview:alert];
}

+ (void)ShowAlertWithCancelTitle:(NSString *)title
                        subTitle:(NSString *)subTitle
                    okCompletion:(alertCompletion)okCompletion
                cancelCompletion:(alertCompletion)cancelConpletion
                        okButton:(NSString *)okTitle cancelButton:(NSString *)cancelTItle{
    
    AlertView *alert = [[[NSBundle mainBundle]loadNibNamed:@"AlertView" owner:self options:nil]lastObject];
    
    alert.frame = [UIScreen mainScreen].bounds;
    alert.btnCancel.hidden = false;

    if ([subTitle isEqualToString:@""]) {
        alert.lbTitle.text = title;
        alert.lbSubTitle.hidden = true;
        
    } else {
        alert.lbTitle.text = title;
        alert.lbSubTitle.text = subTitle;
        alert.lbSubTitle.hidden = true;
        alert.alcHeightOfAlert.constant = 151.0f;
    }
    
    if (![okTitle isEqualToString:@""]) {
        [alert.btnOk setTitle:okTitle forState:UIControlStateNormal];
        alert.alcWidthOfOkButton.constant = [alert widthOfTitle:okTitle];
    }
    
    if (![cancelTItle isEqualToString:@""]) {
        [alert.btnCancel setTitle:cancelTItle forState:UIControlStateNormal];
        alert.alcWidthOfCancelButton.constant = [alert widthOfTitle:cancelTItle];
    }
    
    alert.alertView = alert;
    alert.completion = okCompletion;
    alert.cancelCompletion = cancelConpletion;
    
    [[UIApplication sharedApplication].keyWindow addSubview:alert];
}

- (IBAction)didTouchOkButton:(UIButton *)sender {
    
    if (self.completion) {
        self.completion();
    }
    
    [self.alertView removeFromSuperview];
}

- (IBAction)didTouchCancelButton:(UIButton *)sender {
    if (self.cancelCompletion) {
        self.cancelCompletion();
    }
    
    [self.alertView removeFromSuperview];
}

- (CGFloat)widthOfTitle:(NSString *)string {
    CGSize calCulateSizze =[string sizeWithAttributes:NULL];
    return  calCulateSizze.width + 20;
}

@end
