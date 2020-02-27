//
//  PhotoCropView.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 27..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "PhotoCropView.h"


@implementation PhotoCropView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _photoView = [[UIImageView alloc] init];
    [self addSubview:_photoView];
    
    _photoView.clipsToBounds = TRUE;
}

- (void)setPhotoCropInfo:(PhotoCropInfo *)ci {
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
