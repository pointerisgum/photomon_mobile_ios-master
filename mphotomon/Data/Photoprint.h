//
//  Photoprint.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 30..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoPool.h"
#import "PhotoContainer.h"

//
// 인화 옵션
@interface PrintItem : NSObject

//@property (strong, nonatomic) PHAsset  *asset;
@property (strong, nonatomic) PhotoItem *photoItem;

//@property (strong, nonatomic) NSString *url;            // url -> key
@property (strong, nonatomic) NSString *filename;       // 파일명
@property (strong, nonatomic) NSString *thumbname;      // 썸네일파일명
@property (strong, nonatomic) UIImage  *thumb;          // 썸네일 이미지

@property (strong, nonatomic) NSString *size_type;      // 사진 크기 (4x6)
@property (strong, nonatomic) NSString *full_type;      // 페이퍼풀/이미지풀 (I:이미지풀, P:페이퍼풀)
@property (strong, nonatomic) NSString *border_type;    // 테두리 유/무 (B:유테, M:무테)
@property (strong, nonatomic) NSString *light_type;     // 무광/유광 (L:유광, N:무광)
@property (strong, nonatomic) NSString *revise_type;    // 보정 유/무 (Y:보정, N:무보정)
@property (strong, nonatomic) NSString *trim_info;      // 트리밍정보 (T:상단, L:좌측, 시작위치_이동값, T_10)
@property (strong, nonatomic) NSString *order_count;    // 주문 수량
@property (strong, nonatomic) NSString *date_type;      // 날짜 표시

@property (assign) CGPoint scroll_offset; //
@property (assign) int offset; //

- (void)clear;
- (PrintItem *)getUploadTypePhotoItem:(int)idx;
@end

//
// 사진 인화
@interface Photoprint : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) NSString *upload_url;
@property (strong, nonatomic) NSString *orderno;

@property (strong, nonatomic) NSMutableArray *types;
@property (strong, nonatomic) NSMutableArray *discounts;
@property (strong, nonatomic) NSMutableArray *prices;
@property (strong, nonatomic) NSMutableArray *sizes;
@property (strong, nonatomic) NSMutableArray *minResolutions;

@property (strong, nonatomic) NSString *sel_type;
@property (strong, nonatomic) NSMutableDictionary *print_items;

@property (strong, nonatomic) NSString *parsing_element;

- (void)clear;
- (BOOL)initPhotoprintInfo;
- (BOOL)initOrderNumber;
- (BOOL)uploadImage:(PrintItem *)upload_photo UploadController:(id)upload_controller;
- (BOOL)uploadImageWithImageData:(PrintItem *)upload_photo withImageData:(NSData*)imageData UploadController:(id)upload_controller;
- (BOOL)addCart;

- (int)getOriginalPrice:(NSString *)productType;
- (int)getDiscountPrice:(NSString *)productType;

- (CGSize)getPaperSize:(NSString *)paperSize PhotoSize:(CGSize)imageSize;
- (NSString *)getDefaultTrimInfo:(PrintItem *)item;
- (int)checkValidateOffset:(int)offset Length:(int)length MaxSize:(int)max;
- (NSString *)makeTrimString:(NSString *)direction Size:(CGSize)photoSize Offset:(int)offset Length:(int)length Orientation:(UIImageOrientation)orientation;

- (BOOL)isInclueLargeTypePrint;
- (void)resetSurfaceType;

- (BOOL)isPrintablePhoto:(PHAsset *)asset;
- (BOOL)isSelectedPhoto:(PHAsset *)asset;
- (void)addPhoto:(PhotoItem *)item;
- (void)removePhoto:(PhotoItem *)item;

@end
