//
//  PhotoCropEditView.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 28..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "PhotoCropEditView.h"
#import "Common.h"

@implementation PhotoCropInfo

- (id)init {
    if (self = [super init]) {
        _image = nil;
        _rotate_angle = 0;
        _mask_rect = CGRectZero;
        _crop_rect = CGRectZero;
        _long_side = 0;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (PhotoCropInfo *)copy {
    PhotoCropInfo *ci = [[PhotoCropInfo alloc] init];
    ci.image = _image;
    ci.rotate_angle = _rotate_angle;
    ci.mask_rect = _mask_rect;
    ci.crop_rect = _crop_rect;
    ci.long_side = _long_side;
    return ci;
}

@end

#if 1
@implementation PhotoCropEditView

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
    self.clipsToBounds = TRUE;
    
    _mask_view = [[UIScrollView alloc] init];
    _mask_view.backgroundColor = [UIColor clearColor];
    _mask_view.bounces = NO;
    _mask_view.clipsToBounds = NO;
    _mask_view.layer.borderColor = [UIColor yellowColor].CGColor;
    _mask_view.layer.borderWidth = 1.2f;
    _mask_view.delegate = self;
    
    _photo_view = [[UIImageView alloc] init];
    _photo_view.image = nil;
    
    [self addSubview:_mask_view];
    [_mask_view addSubview:_photo_view];
    
    _rotate_angle = 0;
    _cropinfo = nil;
    
    for (int i = 101; i < 106; i++) {
        UIButton *button = (UIButton *)[self viewWithTag:i];
        [self bringSubviewToFront:button];
    }
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchZoom:)];
    [self addGestureRecognizer:pinchRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [doubleTapRecognizer setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTapRecognizer];
}

- (void)load:(PhotoCropInfo *)ci {
    _cropinfo = ci;
    _rotate_angle = ci.rotate_angle;
    _photo_view.image = ci.image;

    [self initLayout];
}

- (void)save {
    CGFloat long_side = MAX(_photo_view.frame.size.width, _photo_view.frame.size.height);
    CGFloat scale = long_side / _cropinfo.long_side;
    CGPoint offset = _mask_view.contentOffset;
    
    _cropinfo.crop_rect = CGRectMake(offset.x/scale, offset.y/scale, _mask_view.frame.size.width/scale, _mask_view.frame.size.height/scale);
    _cropinfo.rotate_angle = _rotate_angle;
}

- (void)initLayout {
    if (_cropinfo != nil) {
        PhotoCropInfo *ci = _cropinfo;
        
        // 1. set mask_view frame
        CGRect back_rect = CGRectInset(self.bounds, 50, 50);
        CGRect scaled_mask_rect = [[Common info] getScaledRect:back_rect.size src:ci.mask_rect.size isInnerFit:YES];
        scaled_mask_rect.origin.x += back_rect.origin.x;
        scaled_mask_rect.origin.y += back_rect.origin.y;
        [_mask_view setFrame:scaled_mask_rect];
        
        // 2. set photo_view frame
        [_photo_view setFrame:CGRectMake(0, 0, _photo_view.image.size.width, _photo_view.image.size.height)];
        _photo_view.transform = CGAffineTransformIdentity;
        _photo_view.transform = CGAffineTransformRotate(_photo_view.transform, ci.rotate_angle * (2.0 * M_PI / 360.0));

        // 3. adjust mask_view & crop_rect's scale
        CGSize image_size = [[Common info] getRotatedSize:ci.image.size Rotate:ci.rotate_angle];
        CGFloat scale = _mask_view.frame.size.width / ci.crop_rect.size.width;
        CGPoint scaled_offset = CGPointMake(ci.crop_rect.origin.x * scale, ci.crop_rect.origin.y * scale);
        CGRect  scaled_rect = CGRectMake(0, 0, image_size.width * scale, image_size.height * scale);
/*
        CGFloat scale = _mask_view.frame.size.width / ci.crop_rect.size.width;
        CGPoint scaled_offset = CGPointMake(ci.crop_rect.origin.x * scale, ci.crop_rect.origin.y * scale);
        CGRect  scaled_rect = CGRectMake(0, 0, _photo_view.frame.size.width * scale, _photo_view.frame.size.height * scale);
*/
        [_photo_view setFrame:scaled_rect];
        [_mask_view setContentSize:scaled_rect.size];
        [_mask_view setContentOffset:scaled_offset];
        
        [self setNeedsLayout];
    }
}

- (void)fitPhoto {
    CGRect crop_rect = _mask_view.frame;
    CGRect photo_rect = _photo_view.frame;
    
    CGRect scaled_rect = [[Common info] getScaledRect:crop_rect.size src:photo_rect.size isInnerFit:NO];
    CGPoint scaled_offset = CGPointMake(-scaled_rect.origin.x, -scaled_rect.origin.y);
    
    scaled_rect.origin = CGPointZero;
    [_photo_view setFrame:scaled_rect];
    [_mask_view setContentSize:_photo_view.frame.size];
    [_mask_view setContentOffset:scaled_offset];
}

- (void)rotateAngle:(int)angle {
    _rotate_angle = _rotate_angle + angle;
    if (labs(_rotate_angle) >= 360) _rotate_angle = 0;
    
    CGAffineTransform rotationTransform = CGAffineTransformRotate(_photo_view.transform, angle * (2.0 * M_PI / 360.0));
    _photo_view.transform = rotationTransform;
    
    [self fitPhoto];
}

- (void)undoAll {
    [self load:_cropinfo];
}

static CGFloat old_scale = 1.0f;
static CGFloat old_size = 0.0f;

- (void)pinchZoom:(UIGestureRecognizer *)sender {
    UIPinchGestureRecognizer *pinchGesture = (UIPinchGestureRecognizer *)sender;
    
    CGFloat pinch_scale = pinchGesture.scale;
    
    switch (pinchGesture.state) {
        case UIGestureRecognizerStateBegan:
            old_scale = pinch_scale;
            old_size = _photo_view.frame.size.width;
            break;
        case UIGestureRecognizerStateChanged: {
            if (old_scale == 1.0f) { // 이전 상태가 최소 크기였던 경우, fitPhoto 반복을 막는다.
                return;
            }
            
            CGFloat scale = 1.0f - (old_scale - pinch_scale);
            //NSLog(@"%f = 1 - (%f - %f)", scale, old_scale, pinch_scale);

            CGAffineTransform scaleTransform = CGAffineTransformScale(_photo_view.transform, scale, scale);
            _photo_view.transform = scaleTransform;

            if (_photo_view.frame.size.width < _mask_view.frame.size.width || _photo_view.frame.size.height < _mask_view.frame.size.height) {
                [self fitPhoto];

                old_scale = 1.0f;
                old_size = _photo_view.frame.size.width;
            }
            else {
                CGRect scaled_rect = _photo_view.frame;
                scaled_rect.origin = CGPointZero;
                [_photo_view setFrame:scaled_rect];
                [_mask_view setContentSize:_photo_view.frame.size];
                
                CGFloat diff = (old_size - _photo_view.frame.size.width) / 2.0f;
                CGPoint offset = CGPointMake(_mask_view.contentOffset.x - diff, _mask_view.contentOffset.y - diff);
                if (offset.x < 0) {
                    offset.x = 0;
                }
                if (offset.y < 0) {
                    offset.y = 0;
                }
                [_mask_view setContentOffset:offset];
                
                old_scale = pinch_scale;
                old_size = _photo_view.frame.size.width;
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            break;
        }
        case UIGestureRecognizerStatePossible: break;
        case UIGestureRecognizerStateCancelled: break;
        case UIGestureRecognizerStateFailed: break;
        default: break;
    }
}

- (void)doubleTap:(UIGestureRecognizer *)gestureRecognizer {
    [self fitPhoto];
}

@end

#else

@implementation PhotoCropEditView

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
    self.clipsToBounds = TRUE;
    
    _mask_view = [[UIScrollView alloc] init];
    _mask_view.backgroundColor = [UIColor clearColor];
    _mask_view.bounces = NO;
    _mask_view.clipsToBounds = NO;
    _mask_view.layer.borderColor = [UIColor yellowColor].CGColor;
    _mask_view.layer.borderWidth = 1.2f;
    _mask_view.delegate = self;
    _mask_view.minimumZoomScale = 0.0f;
    _mask_view.maximumZoomScale = 10.0f;
    
    _photo_view = [[UIImageView alloc] init];
    _photo_view.image = nil;
    
    [self addSubview:_mask_view];
    [_mask_view addSubview:_photo_view];

    _rotate_angle = 0;
    _cropinfo = nil;
    
    for (int i = 101; i < 106; i++) {
        UIButton *button = (UIButton *)[self viewWithTag:i];
        [self bringSubviewToFront:button];
    }
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTap];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    [self fitPhoto];
}

- (void)load:(PhotoCropInfo *)ci {
    _cropinfo = ci;
    _rotate_angle = ci.rotate_angle;
    _photo_view.image = ci.image;

    [self initLayout];
}

- (void)save {
    CGFloat long_side = MAX(_photo_view.frame.size.width, _photo_view.frame.size.height);
    CGFloat scale = long_side / _cropinfo.long_side;
    CGPoint offset = _mask_view.contentOffset;

    _cropinfo.crop_rect = CGRectMake(offset.x/scale, offset.y/scale, _mask_view.frame.size.width/scale, _mask_view.frame.size.height/scale);
    _cropinfo.rotate_angle = _rotate_angle;
}

- (void)initLayout {
    if (_cropinfo != nil) {
        PhotoCropInfo *ci = _cropinfo;
        
        // 1. set mask_view frame
        CGRect back_rect = CGRectInset(self.bounds, 50, 50);
        CGRect scaled_mask_rect = [[Common info] getScaledRect:back_rect.size src:ci.mask_rect.size isInnerFit:YES];
        scaled_mask_rect.origin.x += back_rect.origin.x;
        scaled_mask_rect.origin.y += back_rect.origin.y;
        [_mask_view setFrame:scaled_mask_rect];

        // 2. set photo_view frame
        _photo_view.transform = CGAffineTransformIdentity;
        [_photo_view setFrame:CGRectMake(0, 0, ci.image.size.width, ci.image.size.height)];
        _photo_view.transform = CGAffineTransformRotate(_photo_view.transform, ci.rotate_angle * (2.0 * M_PI / 360.0));
        
        // 3. reset photo_view frame (이미지내 크롭 영역과 마스크 영역을 일치시킨다.)
        CGFloat scale = _mask_view.frame.size.width / ci.crop_rect.size.width;
        CGPoint scaled_offset = CGPointMake(ci.crop_rect.origin.x * scale, ci.crop_rect.origin.y * scale);
        CGRect  scaled_rect = CGRectMake(0, 0, _photo_view.frame.size.width * scale, _photo_view.frame.size.height * scale);

        _mask_view.zoomScale = 1.0f;
        
        [_photo_view setFrame:scaled_rect];
        [_mask_view setContentSize:scaled_rect.size];
        [_mask_view setContentOffset:scaled_offset];
    }
}

- (void)fitPhoto {
    CGRect crop_rect = _mask_view.frame;
    CGRect photo_rect = _photo_view.frame;
    
    CGRect scaled_rect = [[Common info] getScaledRect:crop_rect.size src:photo_rect.size isInnerFit:NO];
    CGPoint scaled_offset = CGPointMake(-scaled_rect.origin.x, -scaled_rect.origin.y);
    
    _mask_view.zoomScale = 1.0f;
    
    scaled_rect.origin = CGPointZero;
    [_photo_view setFrame:scaled_rect];
    [_mask_view setContentSize:scaled_rect.size];
    [_mask_view setContentOffset:scaled_offset];
}

- (void)rotateAngle:(int)angle {
    _rotate_angle = _rotate_angle + angle;
    if (labs(_rotate_angle) >= 360) _rotate_angle = 0;

    _photo_view.transform = CGAffineTransformRotate(_photo_view.transform, angle * (2.0 * M_PI / 360.0));
    
    [self fitPhoto];
}

//
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photo_view;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"scale:%f", _mask_view.zoomScale);
    //    UIView *photo_view = [scrollView.delegate viewForZoomingInScrollView:scrollView];
    //    NSLog(@"photo_view(%.0f, %.0f)", photo_view.frame.size.width, photo_view.frame.size.height);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
//    NSLog(@"zoom1>%.0f,%.0f,%.0f,%.0f", _photo_view.frame.origin.x, _photo_view.frame.origin.y, _photo_view.frame.size.width, _photo_view.frame.size.height);
//    NSLog(@"image>%.0f,%.0f (scale:%.2f)", _photo_view.image.size.width, _photo_view.image.size.height, scale);
    if (_photo_view.frame.size.width < _mask_view.frame.size.width || _photo_view.frame.size.height < _mask_view.frame.size.height) {
        [self fitPhoto];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

@end
#endif