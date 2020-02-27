//
//  CartItem.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 9..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "CartItem.h"
#import "PhotomonInfo.h"
#import "Common.h"

@implementation CartItem

- (id)init {
    if (self = [super init]) {
        _totalCnt = @"";
        _cart_index = @"";
        _cart_print = @"";
        _price = @"";
        _pkgcnt = @"";
        _thumb_url = @"";
        _printingChk = @"";
        _orderno = @"";
        _intnum = @"";
        _seq = @"";
        _g_size = @"";
        _g_class = @"";
        _basketname = @"";
        _recvname = @"";
        _recvamt = @"";

        _unit_types = [[NSMutableArray alloc] init];
        _unit_counts = [[NSMutableArray alloc] init];
        _price_old = [[NSMutableArray alloc] init];
        _price_base = [[NSMutableArray alloc] init];
        _price_org = [[NSMutableArray alloc] init];
        
        _is_selected = FALSE;
        //_unit_price = 0;
        //_size_type = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

// .... 기본
- (int)getPrice {
    return [_price intValue];
}

- (int)getSumPrice {
    int price = [_price intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

// ..... 사진인화
- (int)getSumPricePrint {
#if 0 // 2017.07.19. 사진인화 10원 이벤트를 계기로, 사진인화의 가격은 xml정보값을 그대로 가져오는 방식으로 바꿈.
    int total_price = 0;
    for (int i = 0; i < _unit_types.count; i++) {
        int unit_price = [[Common info].photoprint getDiscountPrice:_unit_types[i]];
        int unit_count = [_unit_counts[i] intValue];
        total_price += (unit_price * unit_count);
    }
    return total_price;
#else
    return [_price intValue];
#endif
}

- (int)getSumPricePrintOriginal {
    int total_price = 0;
    for (int i = 0; i < _unit_types.count; i++) {
        int unit_price = [[Common info].photoprint getOriginalPrice:_unit_types[i]];
        int unit_count = [_unit_counts[i] intValue];
        total_price += (unit_price * unit_count);
    }
    return total_price;
}

// ..... 포토북
- (int)getSumPricePhotobook {
    int price_base = [_price_base[0] intValue];
    int total_price = [self getUnitPricePhotobook:price_base] * [_pkgcnt intValue];
    return total_price;
}

- (int)getSumPricePhotobookOriginal {
    int price_base = [_price_org[0] intValue];
    int total_price = [self getUnitPricePhotobook:price_base] * [_pkgcnt intValue];
    return total_price;
}

- (int)getUnitPricePhotobook:(int)price_base {
    int total_price = 0;
    BOOL isUV = ([_seq isEqualToString:@"221"] || [_seq isEqualToString:@"223"] || [_seq isEqualToString:@"225"]);// || [_seq isEqualToString:@"268"]);
    //BOOL isUV = [_seq isEqualToString:@"221"];
    if (_price_base.count > 0) {
        int unit_price = price_base; // .................................... 기본 원가.
        if (isUV) {
            unit_price += 5000;                     // ..................... UV면 + 5000
        }
        
        int min_pagecount = 21;
        // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
		// SJYANG
		if( [_intnum isEqualToString:@"362"] ){ // 프리미엄 포토북은 min_pagecount 가 20p
			min_pagecount = 20;
		}
        else if ([_seq isEqualToString:@"268"]) { // 인스타북은 41p부터
            min_pagecount = 41;
        }
        else if ([_seq isEqualToString:@"267"]) {
            min_pagecount = 21;
        }
        else if ([_seq isEqualToString:@"269"]) { // 손글씨포토북은 커버포함 16p 고정
            min_pagecount = 14;
        }
        else if ([_seq isEqualToString:@"270"]) { // 손글씨포토북은 커버포함 16p 고정
            min_pagecount = 22;
        }

        if ([_seq isEqualToString:@"180"]) { // 스키니북
            min_pagecount = 23;
        }
        if ([_intnum isEqualToString:@"120"]) { // 카달로그
            min_pagecount = 8;
        }

        int added_pagecount = [_unit_counts[0] intValue] - min_pagecount; // .......... 추가된 페이지당 +1000(UV) or +500(기본)
        NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        NSLog(@"price : _seq : %@, %@", _seq, _intnum);
        NSLog(@"price : unit_price : %d", unit_price);
        NSLog(@"price : pages : %d", [_unit_counts[0] intValue]);

        int priceperpage = isUV ? 1000 : 500;

		// SJYANG : 2016.06.03
		if( [_intnum isEqualToString:@"362"] ){ // 프리미엄 포토북은 2P 당 2,000원
            priceperpage = 1000;
		}

        if ([_seq isEqualToString:@"268"] || [_seq isEqualToString:@"267"]) { // 인스타북은 단위페이지 가격이 250원
            priceperpage = 250;
        }
		// SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
        else if ([_seq isEqualToString:@"269"] || [_seq isEqualToString:@"270"]) { // 손글씨포토북은 고정이며 단위 페이지 가격을 0원로 처리
            priceperpage = 0;
        }
		// SJYANG : 카달로그 PTODO(처리 필요)

        if (_intnum != nil && [_intnum isEqualToString:@"120"]) { // 카달로그
			if(added_pagecount == 0) total_price = 7600;
			else if(added_pagecount == 4) total_price = 10600;
			else if(added_pagecount == 8) total_price = 12800;
			else if(added_pagecount == 12) total_price = 15000;
			else if(added_pagecount >= 16) total_price = 17200;
		}
		else {
	        total_price += (unit_price + priceperpage * added_pagecount);
		}
    }
    return total_price;
}

// .... 달력
- (int)getSumPriceCalendar {
    int price = [_unit_counts[0] intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

- (int)getSumPriceCalendarOriginal {
    int price = [_unit_types[0] intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

// .... 폴라로이드
- (int)getSumPricePolaroid {
    int price = [_unit_counts[0] intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

- (int)getSumPricePolaroidOriginal {
    int price = [_unit_types[0] intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

// .... 포토카드
- (int)getSumPriceCard {
    int price = [_price intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

- (int)getSumPriceCardOriginal {
    int price = [_price intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

// .... 액자
- (int)getSumPriceFrame {
    int price = [_unit_counts[0] intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

- (int)getSumPriceFrameOriginal {
    int price = [_unit_types[0] intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

// .... 기프트
- (int)getSumPriceGift {
    int price = [_unit_counts[0] intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

- (int)getSumPriceGiftOriginal {
    int price = [_unit_types[0] intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

- (int)getSumPriceBaby {
    int price = [_price intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

- (int)getSumPriceBabyOriginal {
    int price = [_price intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

// .... 증명사진인화
- (int)getSumPriceIDPhotos {
    int price = [_price intValue];
    int total_price = price * [_pkgcnt intValue];
    return total_price;
}

@end
