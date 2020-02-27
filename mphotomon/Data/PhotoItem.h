//
//  PhotoItem.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 1..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PhotoItem : NSObject

@property (strong, nonatomic) PHAsset  *asset;

@property (strong, nonatomic) NSString *url;            // url -> key
@property (strong, nonatomic) NSString *filename;       // 파일명
@property (strong, nonatomic) NSString *thumbname;      // 썸네일파일명
@property (strong, nonatomic) UIImage  *thumb;          // 썸네일 이미지

@property (strong, nonatomic) NSString *order_num;      // 주문 번호 (7자리정수)
@property (strong, nonatomic) NSString *size_type;      // 사진 크기 (4x6)
@property (strong, nonatomic) NSString *full_type;      // 페이퍼풀/이미지풀 (I:이미지풀, P:페이퍼풀)
@property (strong, nonatomic) NSString *border_type;    // 테두리 유/무 (B:유테, M:무테)
@property (strong, nonatomic) NSString *light_type;     // 무광/유광 (L:유광, N:무광)
@property (strong, nonatomic) NSString *revise_type;    // 보정 유/무 (Y:보정, N:무보정)
@property (strong, nonatomic) NSString *order_count;    // 주문 수량
@property (strong, nonatomic) NSString *trim_info;      // 트리밍정보 (T:상단, L:좌측, 시작위치_이동값, T_10)
@property (assign) CGPoint scroll_offset; //

- (PhotoItem *)getUploadTypePhotoItem:(int)idx;

@end
