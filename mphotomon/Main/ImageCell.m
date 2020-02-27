//
//  ImageCell.m
//  PHOTOMON
//
//  Created by 김민아 on 10/07/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "ImageCell.h"
#import "UIImageView+WebCache.h"

@interface ImageCell ()
@property (weak, nonatomic) IBOutlet UILabel *lbTItle;
@property (weak, nonatomic) IBOutlet UIImageView *ivThumb;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcHeightOfTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alcBottomOfTitle;

@end

@implementation ImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.ivThumb.image = nil;
}

- (void)setTitle:(NSString *)title image:(NSString *)urlString {
    self.alcHeightOfTitle.constant = 14.5;
    self.alcBottomOfTitle.constant = 15.0;
    self.lbTItle.text = title;
    [self.ivThumb sd_setImageWithURL:[NSURL URLWithString:urlString]];
}

- (void)setImage:(NSString *)imageName {

    self.alcHeightOfTitle.constant = 0.0f;
    self.alcBottomOfTitle.constant = 0.0f;
    
    self.lbTItle.text = @"";
    self.ivThumb.image = [UIImage imageNamed:imageName];
}

@end
