//
//  PhotoCropEditView.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 28..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

// crop info
@interface PhotoCropInfo : NSObject

@property (strong, nonatomic) UIImage *image;
@property (assign) int rotate_angle;
@property (assign) CGRect mask_rect;
@property (assign) CGRect crop_rect;
@property (assign) int long_side;

// 마그넷 : guideinfo
@property (assign) int npage;
@property (assign) int nlayer;
@property (strong, nonatomic) Layer *layer;

- (PhotoCropInfo *)copy;
@end


// crop view
@interface PhotoCropEditView : UIView <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *mask_view; // 마스크 뷰
@property (strong, nonatomic) UIImageView *photo_view; // 사진 뷰

@property (assign) int rotate_angle;
@property (strong, nonatomic) PhotoCropInfo *cropinfo;

- (void)load:(PhotoCropInfo *)crop_info;
- (void)save;
- (void)rotateAngle:(int)angle;
- (void)undoAll;

@end
