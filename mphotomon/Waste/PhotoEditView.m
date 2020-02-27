//
//  PhotoEditView.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 22..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "PhotoEditView.h"
#import "Common.h"

@implementation PhotoEditView

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
    self.backgroundColor = [UIColor lightGrayColor];
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = 1.0f;
    
    _maskView = [[UIScrollView alloc] init];
    _maskView.backgroundColor = [UIColor clearColor];
    _maskView.bounces = NO;
    _maskView.clipsToBounds = NO;
    _maskView.layer.borderColor = [UIColor yellowColor].CGColor;
    _maskView.layer.borderWidth = 1.2f;
    
    _photoView = [[UIImageView alloc] init];
    _photoView.image = nil;

    [self addSubview:_maskView];
    [_maskView addSubview:_photoView];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchZoom:)];
    [self addGestureRecognizer:pinchRecognizer];
}

- (void)setImageInfo:(Layer *)layer MaskRect:(CGRect)mask_rect CropRect:(CGRect)crop_rect{
    NSString *fullpath = [NSString stringWithFormat:@"%@/edit/%@", [Common info].photobook.base_folder, layer.ImageEditname];
    _image_full = [UIImage imageWithContentsOfFile:fullpath];
    _photoView.image = _image_full;
    _photoView.transform = CGAffineTransformIdentity;
    _rotate_angle = layer.ImageR;
    _mask_rect = mask_rect;
    _crop_rect = crop_rect;
    
    _photoView.hidden = YES;
    [_photoView setFrame:CGRectMake(0, 0, _image_full.size.width, _image_full.size.height)];
    _photoView.transform = CGAffineTransformRotate(_photoView.transform, _rotate_angle * (2.0 * M_PI / 360.0));
}

- (void)updatePreview {
    // 1. 배경 영역에 내접하는 레이어 영역 생성
    CGRect backRect = CGRectInset(self.bounds, 20, 20);
    CGRect scaled_mask_rect = [[Common info] getScaledRect:backRect.size src:_mask_rect.size isInnerFit:YES];
    scaled_mask_rect.origin.x += backRect.origin.x;
    scaled_mask_rect.origin.y += backRect.origin.y;
    [_maskView setFrame:scaled_mask_rect];
    
    // 2. 크롭 정보로 부터 이미지 뷰 크기/위치 결정.
    CGFloat scale = scaled_mask_rect.size.width / _crop_rect.size.width;
    CGPoint crop_offset = CGPointMake(_crop_rect.origin.x * scale, _crop_rect.origin.y * scale);
    
    CGSize org_size = [[Common info] getRotatedSize:_image_full.size Rotate:_rotate_angle];
    CGSize image_size = CGSizeMake(org_size.width * scale, org_size.height * scale);
    CGRect image_rect = CGRectMake(-crop_offset.x, -crop_offset.y, image_size.width, image_size.height);

    image_rect.origin = CGPointZero;
    [_photoView setFrame:image_rect];

    [_maskView setContentSize:_photoView.frame.size];
    [_maskView setContentOffset:crop_offset];
    
    _photoView.hidden = NO;
}

- (CGRect)getImageCropRect:(CGFloat)original_long_side {
    CGFloat long_side = MAX(_photoView.frame.size.width, _photoView.frame.size.height);
    CGFloat scale = long_side / original_long_side;
    
    CGPoint offset = _maskView.contentOffset;

    CGRect crop_rect = CGRectZero;
    crop_rect.origin.x = offset.x / scale;
    crop_rect.origin.y = offset.y / scale;
    crop_rect.size.width = _maskView.frame.size.width / scale;
    crop_rect.size.height = _maskView.frame.size.height / scale;
    
    return crop_rect;
}

- (void)pinchZoom:(UIGestureRecognizer *)sender {
    UIPinchGestureRecognizer *pinchGesture = (UIPinchGestureRecognizer *)sender;

    CGFloat pinch_scale = [pinchGesture scale];
    //CGFloat pinch_velocity = [pinchGesture velocity];
    
    switch (pinchGesture.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            _pinch_scale_old = 1.0f;
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat scale = 1.0f - (_pinch_scale_old - pinch_scale);

            CGAffineTransform trans = CGAffineTransformScale(_photoView.transform, scale, scale);
            _photoView.transform = trans;
            [_maskView setContentSize:_photoView.frame.size];

            _pinch_scale_old = pinch_scale;
            break;
        }
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
        case UIGestureRecognizerStateEnded:
            [self centerPhoto];
            break;
    }
}

- (void)fitPhoto {
    CGRect crop_rect = _maskView.frame;
    CGRect photo_rect = _photoView.frame;

    CGRect scaledImageRect = [[Common info] getScaledRect:crop_rect.size src:photo_rect.size isInnerFit:NO];
    CGPoint offset = CGPointMake(-scaledImageRect.origin.x, -scaledImageRect.origin.y);

    scaledImageRect.origin = CGPointZero;
    [_photoView setFrame:scaledImageRect];
    [_maskView setContentSize:_photoView.frame.size];
    [_maskView setContentOffset:offset];
}

- (void)centerPhoto {
    CGRect crop_rect = _maskView.frame;
    CGRect photo_rect = _photoView.frame;
    
    if (photo_rect.size.width < crop_rect.size.width || photo_rect.size.height < crop_rect.size.height) {
        [self fitPhoto];
    }
    else {
        photo_rect.origin = CGPointZero;
        [_photoView setFrame:photo_rect];
        [_maskView setContentSize:_photoView.frame.size];
        
        CGFloat diff_x = (photo_rect.size.width - crop_rect.size.width)/2;
        CGFloat diff_y = (photo_rect.size.height - crop_rect.size.height)/2;
        [_maskView setContentOffset:CGPointMake(diff_x, diff_y)];
    }
}

- (void)rotateAngle:(NSInteger)angle {
    double radians = angle * (2.0 * M_PI / 360.0);
    CGAffineTransform rotationTransform = CGAffineTransformRotate(_photoView.transform, radians);
    _photoView.transform = rotationTransform;
    [self centerPhoto];
}

@end
