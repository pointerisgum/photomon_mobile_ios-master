//
//  Cell.h
//  PhotoMon
//
//  Created by 경현 이 on 2015. 12. 25..
//  Copyright © 2015년 LeeKyunghyun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IMAGE_EDIT_MAX              500

// Cell data key
//
#define CellDataKey_PhotoPath       @"PhotoPath"
#define CellDataKey_PhotoPosition   @"PhotoPosition"
#define CellDataKey_PhotoScale      @"PhotoScale"
#define CellDataKey_PhotoRotate     @"PhotoRotate"
#define CellDataKey_CellFrame       @"CellFrame"
#define CellDataKey_PhotoFrame      @"PhotoFrame"
#define CellDataKey_PhotoOrgPixel   @"PhotoOriginalPixel"


// 콜라주 side에 인접한 것을 표현하는 enum
//
typedef enum {
    CollageSide_None        = 0x00,
    CollageSide_Left        = 0x01,
    CollageSide_Right       = 0x02,
    CollageSide_Top         = 0x04,
    CollageSide_Bottom      = 0x08,
    CollageSide_All         = CollageSide_Left | CollageSide_Right | CollageSide_Top | CollageSide_Bottom,
} CollageSide;


@class Collage;


//
@interface CellPhotoInfo : NSObject
@property (nonatomic, assign) int ImageOriWidth;
@property (nonatomic, assign) int ImageOriHeight;
@property (nonatomic, assign) int EditImageMaxSize;
@property (nonatomic, assign) int inchWidth;
@property (nonatomic, assign) int inchHeight;
@end


// Collage에서 하나의 사진을 표현하는 class
//
@interface Cell : UIView
{
@private
    
    // Photo
    //
    UIImageView *_photoImageView;
    UIImageView *_warningView;
}

// Collage
//
@property (nonatomic, weak) Collage *collage;

// 사진
//
@property (nonatomic, readonly) UIImage *photo;


// 사진 경로
//  - PHAsset을 사용하는 경우 ID로 사용해도 된다.
@property (nonatomic, readonly) NSString *photoPath;


// _photoImageView의 중점 위치
//  Nomalized 된 값으로 왼쪽 위를 (0.f, 0.f), 오른쪽 하단을 (1.f, 1.f)로 표현한다
@property (nonatomic, readonly) CGPoint photoPosition;


// _photoImageView의 scale
//
@property (nonatomic, readonly) float photoScale;


// _photoImageView의 rotate
//
@property (nonatomic, readonly) int photoRotate;


@property (nonatomic, strong) CellPhotoInfo *photoInfo;


// Corner radius
//
@property (nonatomic, assign) float cornerRadius;


// Collage에서 사이드에 인접 여부
//  이 정보를 바탕으로 corner shape을 생성한다.
@property (nonatomic, assign) CollageSide side;


// Initialize with representation
//
- (instancetype)initWithRepresentation:(NSDictionary *)representaion;


// 사진을 설정한다.
//
- (void)setPhoto:(UIImage *)photo andPath:(NSString *)path;

- (void)rotatePhoto:(UIImage *)photo andRotate:(int)rotate;

// 사진 영역
//
//  Cell내에서 사진이 나타내는 중간 좌표와 사진의 스케일 값을 설정한다.
- (void)setPhotoPosition:(CGPoint)center andScale:(float)scale;


// 설정한 셀의 속성을 그대로 copy한다.
//
- (void)copyCell:(Cell *)cell;


// Represenation
//  현재의 상태를 NSDictionary형태로 받는다.
- (NSDictionary *)representation;

- (void)hideWarningView;

@end
