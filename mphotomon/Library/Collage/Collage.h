//
//  Collage.h
//  PhotoMon
//
//  Created by 경현 이 on 2015. 12. 25..
//  Copyright © 2015년 LeeKyunghyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cell.h"

#define COLLAGE_CELL_MAX    12

// Collage Data Key
//
#define CollageDataKey_ImageEditPixel   @"ImageEditPixel"
#define CollageDataKey_Layout           @"Layout"
#define CollageDataKey_CellList         @"CellList"
#define CollageDataKey_Ratio            @"Ratio"
#define CollageDataKey_BGColor          @"BGColor"
#define CollageDataKey_CellPadding      @"CellPadding"
#define CollageDataKey_CellCornerRadius @"CellCornerRadius"
#define CollageDataKey_Inch             @"Inch"
#define CollageDataKey_OSInfo           @"osinfo"

@class Collage;

@protocol CollageDelegate <NSObject>

@optional

// Collage에서 하나의 셀이 선택됨
//
- (void)collage:(Collage *)collage selectedCell:(Cell *)cell;


// Collage에서 하나의 셀이 움직일 예정
//
- (void)collage:(Collage *)collage willMoveCell:(Cell *)cell;


// Collage에서 셀이 움직이고 있음
//
- (void)collage:(Collage *)collage movingCell:(Cell *)cell;


// Collage에서 셀이 움직임을 멈췄음
//  반환값이 YES면 삭제한다.
- (BOOL)collage:(Collage *)collage didMoveCell:(Cell *)cell;

//
//
- (void)completeCollage;

@end

// Layout
//
typedef NS_ENUM(NSInteger, CollageLayout)
{
    // Layout 모양은
    // Sutterfly style의 순서와 일치한다.
    //
    CollageLayout_1,
    CollageLayout_2,
    CollageLayout_3,
    CollageLayout_4,
};

// Collage class
//
//  사진 합치기에서 컨테이너 역활을 하는 View.
//  Collage안에 cell 들이 배치되어서 layout을 구성한다.
//
@interface Collage : UIView
{
@private
    
    // Main container
    //  Collage는 외부에서 지정한 영역으로 설정되지만
    //  Main container는 좌/우 비율을 보고 크기를 설정된다.
    UIView *_mainContainer;
    

    // Cell list
    //
    NSMutableArray<Cell *> *_cellList;
    
    
    // 이동 중인 cell
    //
    Cell *_movingCell;
    
    
    // Swap cell
    //
    Cell *_swapCell;
    
    
    // 이동중임을 보여주기 위한 dummy cell
    //
    Cell *_dummyCell;
    
    UIImageView *_guideImage;
}

// Delegate
//
@property (nonatomic, assign) id<CollageDelegate> delegate;


// Layout
//
@property (nonatomic, assign) CollageLayout layout;


// BG Color
//
@property (nonatomic, assign) UIColor *bgColor;


// Ratio
//  Collage의 너비/높이 비율
@property (nonatomic, assign) CGSize ratio;


// 셀간 거리
//
@property (nonatomic, assign) float cellPadding;


// 셀 corner radius
//
@property (nonatomic, assign) float cellCornerRadius;


// 액자 크기 정보
//
@property (strong, nonatomic) NSString *inch;


// Initialize with representation
//
- (instancetype)initWithRepresentation:(NSDictionary *)representation;


// Layout을 적용하고, animate를 할지 결정한다.
//
- (void)setLayout:(CollageLayout)layout animate:(BOOL)animate;


// 사진으로 추가 및 삭제
//
- (void)insertPhotos:(NSArray<UIImage *> *)photos andPaths:(NSArray<NSString *> *)paths andPhotoInfos:(NSArray<CellPhotoInfo *> *)infos;
- (void)deletePhotos:(NSArray<UIImage *> *)photos;


// Cell로 추가 및 삭제
//
- (void)insertCells:(NSArray<Cell *> *)cells;
- (void)deleteCells:(NSArray<Cell *> *)cells;


// Shuffle
//
- (void)shuffle;


// Represenation
//  현재의 상태를 JSON형태로 받는다.
- (NSString *)representation;

// cell 개수 리턴
- (int)cellCount; // daypark

// daypark
- (NSString *)fileList;
- (NSMutableArray *)filenameList;
- (UIImage *)getThumbImage;
- (void)setInchAndRatio:(NSString *)size;

- (void)setGuideInfo:(UIImage *)guideImage;

@end
