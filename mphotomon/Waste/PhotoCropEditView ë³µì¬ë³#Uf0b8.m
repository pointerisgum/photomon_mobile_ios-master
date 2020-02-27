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
}

- (void)load:(PhotoCropInfo *)ci {
    _cropinfo = ci;
    _rotate_angle = ci.rotate_angle;
    
    _photo_view.image = ci.image;
    _photo_view.transform = CGAffineTransformIdentity;
    [_photo_view setFrame:CGRectMake(0, 0, _photo_view.image.size.width, _photo_view.image.size.height)];
    _photo_view.transform = CGAffineTransformRotate(_photo_view.transform, _rotate_angle * (2.0 * M_PI / 360.0));

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
        
        // 1. 배경 영역에 내접하는 mask_view 위치 결정
        CGRect back_rect = CGRectInset(self.bounds, 50, 50);
        CGRect scaled_mask_rect = [[Common info] getScaledRect:back_rect.size src:ci.mask_rect.size isInnerFit:YES];
        scaled_mask_rect.origin.x += back_rect.origin.x;
        scaled_mask_rect.origin.y += back_rect.origin.y;
        [_mask_view setFrame:scaled_mask_rect];
        
        // 2. photo_view 크기/위치 결정
        CGSize image_size = [[Common info] getRotatedSize:ci.image.size Rotate:ci.rotate_angle];
        CGFloat scale = scaled_mask_rect.size.width / ci.crop_rect.size.width;
        CGPoint scaled_offset = CGPointMake(ci.crop_rect.origin.x * scale, ci.crop_rect.origin.y * scale);
        CGRect  scaled_rect = CGRectMake(0, 0, image_size.width * scale, image_size.height * scale);
        
        [_photo_view setFrame:scaled_rect];
        [_mask_view setContentSize:_photo_view.frame.size];
        [_mask_view setContentOffset:scaled_offset];
/*
        _mask_view.minimumZoomScale = 0.5f;
        _mask_view.maximumZoomScale = 1.0f;
        _mask_view.zoomScale = 0.5f;*/
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

static CGFloat pinch_scale_old = 1.0f;
static CGPoint scroll_offset_old;

- (void)pinchZoom:(UIGestureRecognizer *)sender {
    UIPinchGestureRecognizer *pinchGesture = (UIPinchGestureRecognizer *)sender;
    
    CGFloat pinch_scale = [pinchGesture scale];
    //CGFloat pinch_velocity = [pinchGesture velocity];
    
    switch (pinchGesture.state) {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            pinch_scale_old = 1.0f;
            scroll_offset_old = _mask_view.contentOffset;
            NSLog(@"start_offset>%.0f,%.0f", scroll_offset_old.x, scroll_offset_old.y);
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat scale = 1.0f - (pinch_scale_old - pinch_scale);
            
            CGAffineTransform trans = CGAffineTransformScale(_photo_view.transform, scale, scale);
            _photo_view.transform = trans;
            [_mask_view setContentSize:_photo_view.frame.size];
            
            pinch_scale_old = pinch_scale;
            NSLog(@"frame>%.0f,%.0f", _photo_view.frame.origin.x, _photo_view.frame.origin.y);
            break;
        }
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
        case UIGestureRecognizerStateEnded: {
            CGRect scaled_rect = _photo_view.frame;
            CGPoint scaled_offset = CGPointMake(scroll_offset_old.x-scaled_rect.origin.x, scroll_offset_old.y-scaled_rect.origin.y);
            NSLog(@"end_offset>%.0f,%.0f", scaled_offset.x, scaled_offset.y);

            scaled_rect.origin = CGPointZero;
            [_photo_view setFrame:scaled_rect];
            [_mask_view setContentSize:_photo_view.frame.size];
            [_mask_view setContentOffset:scaled_offset];
            break;
        }
    }
}

- (void)rotateAngle:(int)angle {
    _rotate_angle = _rotate_angle + angle;
    if (labs(_rotate_angle) >= 360) _rotate_angle = 0;
    
    double radians = angle * (2.0 * M_PI / 360.0);
    CGAffineTransform rotationTransform = CGAffineTransformRotate(_photo_view.transform, radians);
    _photo_view.transform = rotationTransform;
    
    [self fitPhoto];
}
/*
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photo_view;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv {
    UIView *zoomView = [sv.delegate viewForZoomingInScrollView:sv];
    CGRect zvf = zoomView.frame;
    if(zvf.size.width < sv.bounds.size.width)
    {
        zvf.origin.x = (sv.bounds.size.width - zvf.size.width) / 2.0;
    }
    else
    {
        zvf.origin.x = 0.0;
    }
    if(zvf.size.height < sv.bounds.size.height)
    {
        zvf.origin.y = (sv.bounds.size.height - zvf.size.height) / 2.0;
    }
    else
    {
        zvf.origin.y = 0.0;
    }
    zoomView.frame = zvf;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"Point: %@", NSStringFromCGPoint(scrollView.contentOffset));
}
*/
@end
