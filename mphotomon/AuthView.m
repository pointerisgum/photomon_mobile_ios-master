//
//  AuthView.m
//  PHOTOMON
//
//  Created by 김민아 on 02/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "AuthView.h"

@interface AuthView ()

@property (weak, nonatomic) IBOutlet UIView *fileView;
@property (weak, nonatomic) IBOutlet UIView *idView;
@property (weak, nonatomic) IBOutlet UIView *phoneView;

@property (assign, nonatomic) id<AuthViewDelegate> delegate;

@end

@implementation AuthView

+ (void)ShowAuthView:(CGRect)targetFrame
                      self:(id<AuthViewDelegate>)delegate{
    
    AuthView *authView = [[AuthView alloc]init];
    
    authView.frame = targetFrame;
    
    [authView initLayout];
    authView.delegate = delegate;
    
    [[UIApplication sharedApplication].keyWindow addSubview:authView];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle]loadNibNamed:@"AuthView" owner:self options:nil]lastObject];
        
        [self initLayout];
        
    }
    return self;
}

- (void)initLayout {
    self.fileView.layer.cornerRadius = 42.5/2;
    self.idView.layer.cornerRadius = 42.5/2;
    self.phoneView.layer.cornerRadius = 42.5/2;
}

- (IBAction)didTouchComfirmButton:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(didTouchComfirmButton)]) {
        [self.delegate didTouchComfirmButton];
        
        [self removeFromSuperview];
    }
}



@end
