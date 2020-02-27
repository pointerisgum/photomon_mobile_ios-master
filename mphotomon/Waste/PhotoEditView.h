//
//  PhotoEditView.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 22..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "Common.h"

@interface PhotoEditView : UIView

@property (assign) CGFloat pinch_scale_old;

@property (assign) int rotate_angle;
@property (assign) CGRect mask_rect;
@property (assign) CGRect crop_rect;
@property (strong, nonatomic) UIImage *image_full;

@property (strong, nonatomic) UIScrollView *maskView; // 마스크 뷰
@property (strong, nonatomic) UIImageView *photoView; // 사진 뷰

- (void)setImageInfo:(Layer *)layer MaskRect:(CGRect)mask_rect CropRect:(CGRect)crop_rect;
- (void)updatePreview;

- (void)fitPhoto;
- (void)centerPhoto;
- (void)rotateAngle:(NSInteger)angle;

- (CGRect)getImageCropRect:(CGFloat)original_long_side;

@end
