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
	// TODO : 마그넷 : guideinfo
	if ([Common info].photobook.product_type != PRODUCT_MAGNET) {
		_mask_view.layer.borderColor = [UIColor yellowColor].CGColor;
		_mask_view.layer.borderWidth = 1.2f;
	}
    _mask_view.delegate = self;
    
    _photo_view = [[UIImageView alloc] init];
    _photo_view.image = nil;
    
    [self addSubview:_mask_view];
    [_mask_view addSubview:_photo_view];
    
    _rotate_angle = 0;
    _cropinfo = nil;
    
    for (int i = 100; i < 106; i++) {
        UIView *view = (UIView *)[self viewWithTag:i];
        [self bringSubviewToFront:view];
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

UIImageView *mview;

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

		
		// 마그넷 : guideinfo
		BOOL outlined = NO;
		if ([Common info].photobook.product_type == PRODUCT_MAGNET && [Common info].photobook.pages.count > _cropinfo.npage) {
			Layer *guideinfo = nil;
			Page *page = (Page *)[Common info].photobook.pages[_cropinfo.npage];
			for (Layer *layer in page.layers) {
				if (layer.AreaType == 3)
					guideinfo = layer;
			}

			Layer *layer = _cropinfo.layer;

			if (guideinfo != nil && guideinfo.W == layer.MaskW && guideinfo.H == layer.MaskH) {
				NSString *tempFolder = [NSString stringWithFormat:@"%@/temp", [Common info].photobook.base_folder];
				NSString *localpathname = [NSString stringWithFormat:@"%@/%@", tempFolder, guideinfo.SkinFilename];
				UIImage *guideinfoImage = [UIImage imageWithContentsOfFile:localpathname];
				if(guideinfoImage != nil) {
					guideinfoImage = [[Common info].photobook maskImage:guideinfoImage];
					guideinfoImage = [[Common info].photobook outlineMaskBitmap:guideinfoImage withR:255 withG:255 withB:0 withA:255];

					UIImage *tguideinfoImage;
					{
						CGSize size = CGSizeMake(_mask_view.frame.size.width, _mask_view.frame.size.height);
						UIGraphicsBeginImageContext(size);
						[guideinfoImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
						tguideinfoImage = UIGraphicsGetImageFromCurrentImageContext();    
						UIGraphicsEndImageContext();
					}

					mview = [[UIImageView alloc] init];
					mview.image = tguideinfoImage;

					mview.frame = CGRectMake(_mask_view.frame.origin.x, _mask_view.frame.origin.y, _mask_view.frame.size.width, _mask_view.frame.size.height);
					[mview setContentMode:UIViewContentModeCenter];
					[self addSubview:mview];

					outlined = YES;
				}
			}
		}

		if (!outlined) {
			_mask_view.layer.borderColor = [UIColor yellowColor].CGColor;
			_mask_view.layer.borderWidth = 1.2f;
		}


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

#pragma mark - UIScrollViewDelegate

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2) {
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photo_view;
}
*/
@end
