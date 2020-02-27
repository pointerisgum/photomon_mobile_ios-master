//
//  ProgressView.m
//  PHOTOMON
//
//  Created by 김민아 on 12/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "ProgressView.h"

#define MAX_WIDTH                             113.0f

@interface ProgressView ()

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcWidthOfProgressView;

@end

@implementation ProgressView

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle]loadNibNamed:@"ProgressView" owner:self options:nil]lastObject];
        
        self.frame = [UIScreen mainScreen].bounds;
//        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

        [[UIApplication sharedApplication].keyWindow addSubview:self];
        self.lbTitle.text = title;
        [self layoutIfNeeded];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//        });
        
//        self.alcWidthOfProgressView.constant = MAX_WIDTH * 0.6;
//
//        [UIView animateWithDuration:2.5f delay:1.5f options:nil animations:^{
//            [self layoutIfNeeded];
//
//        } completion:nil];
        


//        [UIView animateWithDuration:0.0f delay:0.0f options:nil animations:^{
//        } completion:^(BOOL finished) {
//
//        }];
    }
    return self;
}

- (void)manageProgress:(CGFloat)progress title:(NSString *)title {
    self.lbTitle.text = title;
    
    [self manageProgress:progress];
}

- (void)changeProgressTitle:(NSString *)title {
    self.lbTitle.text = title;
   
}

- (void)manageProgress:(CGFloat)progress {
    NSLog(@"manageProgress : %f", progress);
	
	progress = MIN(1.0f, progress);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.alcWidthOfProgressView.constant = MAX_WIDTH * progress ;
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self layoutIfNeeded];
            
        } completion:nil];
        
    });
    
}

- (void)endProgress {
//    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

    self.alcWidthOfProgressView.constant = MAX_WIDTH;
    
    [UIView animateWithDuration:1.5f delay:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];

    }];
}

@end
