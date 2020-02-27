//
//  SubCell.m
//  PHOTOMON
//
//  Created by 김민아 on 10/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "SubCell.h"
#import "UIImageView+WebCache.h"

@interface SubCell ()

@property (weak, nonatomic) IBOutlet UIImageView *ivThumb;
@property (weak, nonatomic) IBOutlet UILabel *lbSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcHeightOfSubTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcHeightOfThumb;

@end

@implementation SubCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSubCell:(BOOL)isNewDesign thumb:(NSString *)urlString title:(NSString *)titleString subTitle:(NSString *)subTitle {
    
    if (isNewDesign) {
        self.lbSubTitle.hidden = false;
        self.alcHeightOfSubTitle.constant = 12.0f;
        self.alcHeightOfThumb.constant = 165.0f;
        self.lbSubTitle.text = subTitle;
        
    } else {
        self.alcHeightOfThumb.constant = 160.0f;
        self.lbSubTitle.hidden = true;
        self.alcHeightOfSubTitle.constant = 0.0f;
    }
    
    [self layoutIfNeeded];
    
    [self.ivThumb sd_setImageWithURL:[NSURL URLWithString:urlString]];
    self.lbTitle.text = titleString;
}

@end
