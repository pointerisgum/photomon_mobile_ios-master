//
//  CartItem.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 9..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CartItem : NSObject

@property (strong, nonatomic) NSString *totalCnt;
@property (strong, nonatomic) NSString *cart_index;
@property (strong, nonatomic) NSString *cart_print;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *pkgcnt;
@property (strong, nonatomic) NSString *thumb_url;
@property (strong, nonatomic) NSString *printingChk;
@property (strong, nonatomic) NSString *orderno;
@property (strong, nonatomic) NSString *intnum;
@property (strong, nonatomic) NSString *seq;
@property (strong, nonatomic) NSString *g_size;         // 포토북에서 사용 (ex) 61p
@property (strong, nonatomic) NSString *g_class;        // 포토북에서 사용 (ex) 151015195742-074300221
@property (strong, nonatomic) NSString *basketname;     // 포토북에서 사용 (ex) 년월일시분초
@property (strong, nonatomic) NSString *recvname;       // 생산업체 이름
@property (strong, nonatomic) NSString *recvamt;        // 생산업체 배송료

// <TotalSizeCnt>4x6:10|D4:10|</TotalSizeCnt>
// <TotalSizeCnt>8x8UV:61:64100:19100:23900|</TotalSizeCnt>
@property (strong, nonatomic) NSMutableArray *unit_types;  // 사진인화 4x6/D4, 포토북 8x8UV, (달력,액자는 할인전 가격)
@property (strong, nonatomic) NSMutableArray *unit_counts; // 사진인화 1장/2장, 포토북 페이지수, (달력,액자는 할인후 가격)
@property (strong, nonatomic) NSMutableArray *price_old;   // 포토북만 해당, 주문 당시 가격 합계 (무시. 그냥 참고용).
@property (strong, nonatomic) NSMutableArray *price_base;  // 할인후 기본 가격 (할인가격)
@property (strong, nonatomic) NSMutableArray *price_org;   // 할인전 기본 가격 (기본원가)

// runtime prop. (장바구니 뷰에서 초기화한 후에 사용됨.)
@property (assign) BOOL is_selected;
//@property (assign) int  unit_price; // 사진 한장 단위 가격.
//@property (strong, nonatomic) NSString *size_type;  // cart_print로 부터 사진 크기 정보만을 추출.

//@property

- (int)getPrice;
- (int)getSumPrice;

- (int)getSumPricePrint;
- (int)getSumPricePrintOriginal;

- (int)getSumPricePhotobook;
- (int)getSumPricePhotobookOriginal;
- (int)getUnitPricePhotobook:(int)price;

- (int)getSumPriceCalendar;
- (int)getSumPriceCalendarOriginal;
- (int)getSumPriceCard;
- (int)getSumPriceCardOriginal;
- (int)getSumPricePolaroid;
- (int)getSumPricePolaroidOriginal;
- (int)getSumPriceFrame;
- (int)getSumPriceFrameOriginal;
- (int)getSumPriceGift;
- (int)getSumPriceGiftOriginal;
- (int)getSumPriceBaby;
- (int)getSumPriceBabyOriginal;
- (int)getSumPriceIDPhotos;

@end
