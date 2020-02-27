//
//  PhotoPool.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 3..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol SelectPhotoDelegate <NSObject>
@optional
- (void)selectPhotoDone:(BOOL)is_singlemode;
- (void)selectPhotoCancel:(BOOL)is_singlemode;
@end

//
// 인화 옵션 (사용 보류)
@interface PrintOption : NSObject

@property (strong, nonatomic) NSString *size_type;      // 사진 크기 (4x6)
@property (strong, nonatomic) NSString *full_type;      // 페이퍼풀/이미지풀 (I:이미지풀, P:페이퍼풀)
@property (strong, nonatomic) NSString *border_type;    // 테두리 유/무 (B:유테, M:무테)
@property (strong, nonatomic) NSString *light_type;     // 무광/유광 (L:유광, N:무광)
@property (strong, nonatomic) NSString *revise_type;    // 보정 유/무 (Y:보정, N:무보정)
@property (strong, nonatomic) NSString *trim_info;      // 트리밍정보 (T:상단, L:좌측, 시작위치_이동값, T_10)
@property (strong, nonatomic) NSString *order_count;    // 주문 수량
- (void)clear;
@end

//
// 단위 사진 정보
@interface Photo : NSObject

@property (strong, nonatomic) PHAsset *asset;
@property (strong, nonatomic) PrintOption *print_option; // 사진인화일 경우 (사용보류)
- (void)clear;
@end

//
// 전체 사진 관리
@interface PhotoPool : NSObject

@property (strong, nonatomic) NSMutableArray *sel_photos;

- (BOOL)isSelected:(PHAsset *)asset;
- (BOOL)isPrintable:(PHAsset *)asset;

- (void)add:(PHAsset *)asset Param:(NSString *)param;
- (void)remove:(PHAsset *)asset;
- (void)removeAtIndex:(NSUInteger)index;
- (void)removeAll;
- (NSUInteger)totalCount;

@end
