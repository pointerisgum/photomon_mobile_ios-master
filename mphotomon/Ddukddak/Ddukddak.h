//
//  Ddukddak.h
//  PHOTOMON
//
//  Created by 곽세욱 on 03/10/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Common.h"

NS_ASSUME_NONNULL_BEGIN

@interface DdukddakOptionDetail : NSObject
@property (strong, nonatomic) NSString *thumb;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *sendValue;
@end

@interface DdukddakOption : NSObject
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSMutableArray<DdukddakOptionDetail *> *details;
@end

@interface DdukddakLayoutCount : NSObject
@property (assign) NSInteger pageCount;
@property (assign) NSInteger layoutCount;
@end

@interface DdukddakAddCartReturn : NSObject
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *msg;
@property (strong, nonatomic) NSString *moveURL;
@end

@interface Ddukddak : NSObject

@property (assign) NSInteger price;
@property (strong, nonatomic) NSString *mainImg;
@property (strong, nonatomic) NSString *photobookDesignListURL;
@property (strong, nonatomic) NSString *layflatDesignListURL;
@property (strong, nonatomic) NSString *themeInfoURL;
@property (strong, nonatomic) NSString *layoutCountURL;
@property (strong, nonatomic) NSString *addCartURL;

@property (strong, nonatomic) DdukddakOption *arrange;
@property (strong, nonatomic) DdukddakOption *size;
@property (strong, nonatomic) DdukddakOption *deco;

@property (strong, nonatomic) NSMutableArray<DdukddakLayoutCount *> *layoutCounts; // 0 : small, 1 : medium, 2 : large

@property (assign) NSInteger productSelectedIdx;    //상품선택(포토북,레이플랫북) 선택인덱스
@property (assign) NSInteger arrangeSelectedIdx;    //사진정리방식 선택인덱스
@property (assign) NSInteger sizeSelectedIdx;       //사진사이즈 선택인덱스
@property (assign) NSInteger decoSelectedIdx;       //스티커&장식 선택인덱스

@property (strong, nonatomic) Theme *selectedTheme; //selectedTheme

@property (strong, nonatomic) NSString *selSize;
@property (strong, nonatomic) NSString *selCover;
@property (strong, nonatomic) NSString *selCoating;
@property (assign) NSInteger totSaveCount;

+(Ddukddak *)inst;
+(void) ShowDraft:(UIViewController *)rootView BID:(NSString *)url;
+(BOOL) LoadProduct;
-(BOOL) loadProduct;
+(void) LoadTheme;
-(void) loadTheme;

+(void) LoadLayoutCounts:(NSInteger)totalSaveCount;
-(void) loadLayoutCounts:(NSInteger)totalSaveCount;
+(DdukddakAddCartReturn *) AddToCart;
-(DdukddakAddCartReturn *) addToCart;

@end

NS_ASSUME_NONNULL_END
