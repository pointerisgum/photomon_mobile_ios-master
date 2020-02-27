//
//  Cell.m
//  PhotoMon
//
//  Created by 경현 이 on 2015. 12. 25..
//  Copyright © 2015년 LeeKyunghyun. All rights reserved.
//

#import "Cell.h"
#import "Util.h"
#import "Collage.h"
#import "UIImage+Rotation.h"


@implementation CellPhotoInfo

- (id)init {
    if (self = [super init]) {
        _ImageOriWidth = 0;
        _ImageOriHeight = 0;
        _EditImageMaxSize = 0;
        _inchWidth = 0;
        _inchHeight = 0;
    }
    return self;
}
@end





@implementation Cell


#pragma mark - Initialize

// 초기화
//
- (void)initialize
{
    // 기본 속성 설정
    //
    self.autoresizesSubviews = NO;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor blackColor]; // blue..
    self.layer.masksToBounds = YES;
    _photoPosition = CGPointMake(0.5f, 0.5f);
    _photoScale = 1.f;
    _photoRotate = 0;
    _photoInfo = nil;
    
    
    // 사진을 보여주는 photo image view를 생성해서 붙인다.
    //
    _photoImageView = [[UIImageView alloc] init];
    _photoImageView.backgroundColor = [UIColor blackColor]; // cyan..
    _photoImageView.contentMode = UIViewContentModeScaleToFill;
    _photoImageView.clipsToBounds = YES;
    [self addSubview:_photoImageView];
    
    // 화질저하 경고 아이콘.
    _warningView = [[UIImageView alloc] init];
    _warningView.contentMode = UIViewContentModeScaleToFill;
    _warningView.clipsToBounds = YES;
    _warningView.alpha = 0.8f;
    _warningView.image = [UIImage imageNamed:@"photo_warning.png"];
    _warningView.hidden = YES;
    [self addSubview:_warningView];
}


// XIB또는 Storyboard로 생성되는 경우 이 초기화 함수가 호출된다.
//
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if( self = [super initWithCoder:aDecoder] )
    {
        [self initialize];
    }
    
    return self;
}


// InitWithFrame, Code로 직접 생성
//
- (instancetype)initWithFrame:(CGRect)frame
{
    if( self = [super initWithFrame:frame] )
    {
        [self initialize];
    }
    
    return self;
}


// Initialize with representation
//  Template처럼 복원한다.
- (instancetype)initWithRepresentation:(NSDictionary *)representaion
{
    if( self = [super init] )
    {
        // 값들을 복원한다.
        //
        _photoPosition = CGPointFromString(representaion[CellDataKey_PhotoPosition]);
        _photoScale = [representaion[CellDataKey_PhotoScale] floatValue];
        _photoRotate = [representaion[CellDataKey_PhotoRotate] intValue];
        
        NSArray *docPathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [docPathArray objectAtIndex:0];
        NSString *pathname = [NSString stringWithFormat:@"%@/collage/%@", docPath, representaion[CellDataKey_PhotoPath]];
        
        [self setPhoto:[UIImage imageWithContentsOfFile:pathname]
               andPath:representaion[CellDataKey_PhotoPath]];
        
        if (_photoRotate != 0) {
            [self rotatePhoto:_photoImageView.image andRotate:_photoRotate];
        }
    }
    
    return self;
}


#pragma mark - Layout


// Frame이 변경될때 자식들의 layout을 변경하기 위해서 호출된다.
// UI Engine에서 자동으로 불러주는 함수이며, Override해서 사용하면 된다.
//
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    // 기존의 사진의 크기와 위치를 비슷하게 복원하기 위해서
    // 기존의 크기를 비교해서 사진의 가운데 좌표를 설정하도록 한다.
    //
    [self setPhotoPosition:_photoPosition
                  andScale:_photoScale];
    
    
    // Corner radius에 사용할 shape을 다시 만든다.
    //
    [self applyCornerRadius];
}


#pragma mark - Photo


// 사진을 설정한다.
//
- (void)setPhoto:(UIImage *)photo andPath:(NSString *)path
{
    // _photoImageView에 사진을 설정한다.
    //
    _photoImageView.image = photo;
    
    
    // 사진 경로를 설정한다.
    //
    _photoPath = path;
    
    
    // 셀 가운데 위치하도록 배치한다.
    //
    [self setPhotoPosition:_photoPosition
                  andScale:_photoScale];
}

- (void)rotatePhoto:(UIImage *)photo andRotate:(int)rotate {
    if (rotate != 0) {
        
        _photoRotate = _photoRotate + rotate;
        if (labs(_photoRotate) >= 360) _photoRotate = 0;
        
        photo = [UIImage rotateImage:photo Rotation:rotate];
        
        _photoImageView.image = photo;
//        _photoRotate = rotate;
        
        [self setPhotoPosition:CGPointMake(0.5f, 0.5f)
                      andScale:1.0f];
    }
}


// Photo getter
//
- (UIImage *)photo
{
    return _photoImageView.image;
}


// 사진 영역
//
//  Cell내에서 사진이 나타내는 중간 좌표와 사진의 스케일 값을 설정한다.
- (void)setPhotoPosition:(CGPoint)center andScale:(float)scale
{
    // Exception
    //
    if( !self.photo || CGRectGetWidth(self.bounds) == 0.f || CGRectGetHeight(self.bounds) == 0.f )
        return;
    
    
    // Center 및 Scale 값을 기억하고 있어야 나중에 셀 크기가 변했을때 위치 복원이 가능하다.
    //
    _photoPosition = center;
    _photoScale = scale;
    
    
    // 현재 Cell 영역에서 aspectfill의 크기로 _photoImageView의 크기를 설정한다.
    //
    CGSize imageSize = _photoImageView.image.size;
    
    
    // 사진이 셀 안에 들어갈 때 가로/세로 중 짧은 쪽을 기준으로 길이를 맞춘다.
    //  사진 비율로 결졍되는 것이 아니고 사진의 비율과 셀의 비율을 동시에 고려해서 판단해야 한다.
    //
    _photoImageView.frame = CGRectApplyAffineTransform(aspectFillRect(imageSize, self.bounds),
                                                       CGAffineTransformMakeScale(scale, scale));
    
    
    // 최대/최소값 보정
    //  사진이 영역을 벗어나지 않도록 보정한다.
    _photoPosition.x = MIN(_photoPosition.x, (CGRectGetWidth(_photoImageView.frame) - CGRectGetWidth(self.bounds) / 2.f) / CGRectGetWidth(_photoImageView.frame));
    _photoPosition.x = MAX(_photoPosition.x, (CGRectGetWidth(self.bounds) / 2.f) / CGRectGetWidth(_photoImageView.frame));
    _photoPosition.y = MIN(_photoPosition.y, (CGRectGetHeight(_photoImageView.frame) - CGRectGetHeight(self.bounds) / 2.f) / CGRectGetHeight(_photoImageView.frame));
    _photoPosition.y = MAX(_photoPosition.y, (CGRectGetHeight(self.bounds) / 2.f) / CGRectGetHeight(_photoImageView.frame));
    
    
    // 이 두점이 가운데에 위치하게 한다.
    //
    float x = CGRectGetWidth(_photoImageView.frame) * _photoPosition.x;
    float y = CGRectGetHeight(_photoImageView.frame) * _photoPosition.y;
    _photoImageView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + (CGRectGetWidth(_photoImageView.bounds) / 2.f - x),
                                         CGRectGetHeight(self.bounds) / 2.f + (CGRectGetHeight(_photoImageView.bounds) / 2.f - y));
    
    // 해상도 체크..
    CGRect photoFrame = CGRectMake(-CGRectGetMinX(_photoImageView.frame),
                                   -CGRectGetMinY(_photoImageView.frame),
                                   CGRectGetWidth(self.bounds),
                                   CGRectGetHeight(self.bounds));
    CGFloat ratio = self.photo.size.width / CGRectGetWidth(_photoImageView.frame);
    photoFrame = CGRectApplyAffineTransform(photoFrame, CGAffineTransformMakeScale(ratio, ratio));
    
    // 장축 기준으로 사진 스케일 계산.
    CGFloat image_scale = (CGFloat)MAX(self.photoInfo.ImageOriWidth, self.photoInfo.ImageOriHeight) / self.photoInfo.EditImageMaxSize;
    
    //CGFloat res = MAX(CGRectGetWidth(photoFrame), CGRectGetHeight(photoFrame));
    CGFloat res = (CGRectGetWidth(photoFrame) + CGRectGetHeight(photoFrame)) / 2.0f;
    res *= image_scale;
    
    CGFloat minRes = (CGFloat)MIN(self.photoInfo.inchWidth, self.photoInfo.inchHeight);
    NSLog(@"[%.2f]: org(%dx%d) minRes(%.0f<%.0f)", image_scale, self.photoInfo.ImageOriWidth, self.photoInfo.ImageOriHeight, res, minRes * 100.f);
    
    if (res < (minRes * 100.f)) { // 100 dpi
        CGRect waring_rect = CGRectZero;
        waring_rect.origin.x = (self.frame.size.width/2 - 30/2);
        waring_rect.origin.y = (self.frame.size.height/2 - 30/2);
        waring_rect.size.width = 30;
        waring_rect.size.height = 30;
        [_warningView setFrame:waring_rect];
        _warningView.hidden = NO;
    }
    else {
        _warningView.hidden = YES;
    }
}


#pragma mark - Corner radius

// Setter
//  self.cornerRadius
- (void)setCornerRadius:(float)cornerRadius
{
    _cornerRadius = cornerRadius;
    
    // Corner radius를 적용한다.
    //
    [self applyCornerRadius];
}


// Corner radius를 적용한다.
//
- (void)applyCornerRadius
{
    if( _cornerRadius > 0.f )
    {
        CAShapeLayer *shape = (CAShapeLayer *)self.layer.mask;
        if( !shape )
        {
            // 새로운 마스크 쉐입을 생성한다.
            //
            shape = [CAShapeLayer layer];
            shape.lineWidth = 0.f;
            self.layer.mask = shape;
        }
        // 새로운 패쓰를 설정한다.
        //
        shape.path = [self cornerPath];
    }
    else
    {
        self.layer.mask = nil;
    }
}


// Corner path를 생성한다.
//
- (CGPathRef)cornerPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect rect = self.bounds;
    float cornerRadius;
    
    
    // Top-Left
    //
    cornerRadius = (_side & CollageSide_Left || _side & CollageSide_Top) ? 0.f : _cornerRadius;
    CGPathMoveToPoint(path, NULL, MIN(cornerRadius, CGRectGetWidth(rect) / 2.f), 0.f);
    
    
    // Top-Left -> Top-Right
    //
    cornerRadius = (_side & CollageSide_Right || _side & CollageSide_Top) ? 0.f : _cornerRadius;
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(rect) - MIN(cornerRadius, CGRectGetWidth(rect) / 2.f), 0.f);
    
    if( cornerRadius )
        CGPathAddQuadCurveToPoint(path, NULL, CGRectGetWidth(rect), 0.f, CGRectGetWidth(rect), MIN(cornerRadius, CGRectGetHeight(rect) / 2.f));
    
    
    // Top-Right -> Bottom-Right
    //
    cornerRadius = (_side & CollageSide_Right || _side & CollageSide_Bottom) ? 0.f : _cornerRadius;
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(rect), CGRectGetHeight(rect) - MIN(cornerRadius, CGRectGetHeight(rect) / 2.f));
    
    if( cornerRadius )
        CGPathAddQuadCurveToPoint(path, NULL, CGRectGetWidth(rect), CGRectGetHeight(rect), CGRectGetWidth(rect) - MIN(cornerRadius, CGRectGetWidth(rect) / 2.f), CGRectGetHeight(rect));
    
    
    // Bottom-Right -> Bottom->Left
    //
    cornerRadius = (_side & CollageSide_Left || _side & CollageSide_Bottom) ? 0.f : _cornerRadius;
    CGPathAddLineToPoint(path, NULL, MIN(cornerRadius, CGRectGetWidth(rect) / 2.f), CGRectGetHeight(rect));
    
    if( cornerRadius )
        CGPathAddQuadCurveToPoint(path, NULL, 0.f, CGRectGetHeight(rect), 0.f, CGRectGetHeight(rect) - MIN(cornerRadius, CGRectGetHeight(rect) / 2.f));
    
    
    // Bottom-Left -> Top-Left
    //
    cornerRadius = (_side & CollageSide_Left || _side & CollageSide_Top) ? 0.f : _cornerRadius;
    CGPathAddLineToPoint(path, NULL, 0.f, MIN(cornerRadius, CGRectGetHeight(rect) / 2.f));
    
    if( cornerRadius )
        CGPathAddQuadCurveToPoint(path, NULL, 0.f, 0.f, MIN(cornerRadius, CGRectGetWidth(rect) / 2.f), 0.f);
    
    
    CGPathCloseSubpath(path);
    
    
    return path;
}


#pragma mark - Copy properties


// 설정한 셀의 속성을 그대로 copy한다.
//
- (void)copyCell:(Cell *)cell
{
    [self setPhoto:cell.photo andPath:cell.photoPath];
    [self setPhotoPosition:cell.photoPosition andScale:cell.photoScale];
    self.photoInfo = cell.photoInfo;
}


#pragma mark - Representation


// Represenation
//  현재의 상태를 NSDictionary형태로 받는다.
- (NSDictionary *)representation
{
    // 속성 3개를 설정할 수 있는 dictionary를 생성한다.
    //
    NSMutableDictionary *representation = [NSMutableDictionary dictionaryWithCapacity:3];
    
    
    // Photo path
    //
    representation[CellDataKey_PhotoPath] = self.photoPath;
    
    
    // Photo position
    //
#if 0
    representation[CellDataKey_PhotoPosition] = [NSString stringWithFormat:@"\"{%.4f, %.4f}\"", self.photoPosition.x, self.photoPosition.y];
#else
    representation[CellDataKey_PhotoPosition] = NSStringFromCGPoint(self.photoPosition);
#endif
    
    // Photo scale
    //
    representation[CellDataKey_PhotoScale] = @(self.photoScale);
    
    // Photo rotate
    //
    representation[CellDataKey_PhotoRotate] = @(self.photoRotate);
    
    //
    //
    representation[CellDataKey_PhotoOrgPixel] = [NSString stringWithFormat:@"%d %d", self.photoInfo.ImageOriWidth, self.photoInfo.ImageOriHeight];
    
    
    // Cell frame
    //  셀이 collage에서 차지하는 영역을 원래 크기(현재는 collage.ratio)를 기준으로 변환해서 저장한다.
    CGSize size = _collage.ratio;
    CGSize realSize = aspectFitRect(size, _collage.frame).size;
    CGFloat ratio = size.width / realSize.width;
    CGRect cellFrame = CGRectApplyAffineTransform(self.frame, CGAffineTransformMakeScale(ratio, ratio));
    
#if 0
    representation[CellDataKey_CellFrame] = @[[NSString stringWithFormat:@"%.4f", CGRectGetMinX(cellFrame)],
                                              [NSString stringWithFormat:@"%.4f", CGRectGetMinY(cellFrame)],
                                              [NSString stringWithFormat:@"%.4f", CGRectGetWidth(cellFrame)],
                                              [NSString stringWithFormat:@"%.4f", CGRectGetHeight(cellFrame)]];
#else
    representation[CellDataKey_CellFrame] = @[@(CGRectGetMinX(cellFrame)),
                                              @(CGRectGetMinY(cellFrame)),
                                              @(CGRectGetWidth(cellFrame)),
                                              @(CGRectGetHeight(cellFrame))];
#endif
    
    
    // Photo frame
    //  화면에 보여지는 사진의 영역
    CGRect photoFrame = CGRectMake(-CGRectGetMinX(_photoImageView.frame),
                                   -CGRectGetMinY(_photoImageView.frame),
                                   CGRectGetWidth(self.bounds),
                                   CGRectGetHeight(self.bounds));
    ratio = self.photo.size.width / CGRectGetWidth(_photoImageView.frame);
    photoFrame = CGRectApplyAffineTransform(photoFrame, CGAffineTransformMakeScale(ratio, ratio));
    
#if 0
    representation[CellDataKey_PhotoFrame] = @[[NSString stringWithFormat:@"%.4f", CGRectGetMinX(photoFrame)],
                                               [NSString stringWithFormat:@"%.4f", CGRectGetMinY(photoFrame)],
                                               [NSString stringWithFormat:@"%.4f", CGRectGetWidth(photoFrame)],
                                               [NSString stringWithFormat:@"%.4f", CGRectGetHeight(photoFrame)]];
#else
    representation[CellDataKey_PhotoFrame] = @[@(CGRectGetMinX(photoFrame)),
                                               @(CGRectGetMinY(photoFrame)),
                                               @(CGRectGetWidth(photoFrame)),
                                               @(CGRectGetHeight(photoFrame))];
#endif
    
    
    return representation;
}

- (void)hideWarningView {
    _warningView.hidden = YES;
}

@end
