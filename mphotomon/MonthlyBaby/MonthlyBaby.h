//
//  MonthlyBaby.h
//  PHOTOMON
//
//  Created by 곽세욱 on 08/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonthlyBabyWebViewController.h"
#import "PhotoBook.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MonthlyAfterUploadActionDelegate <NSObject>
- (void) saveMidTerm;
- (void) orderNow;
- (void) selectPhotos;
@end

@protocol MonthlySelectAddProductDoneDelegate <NSObject>
- (void) selectAddProductDone;
@end

@protocol MonthlySelectOrderCountDoneDelegate <NSObject>
- (void) selectOrderCountDone;
@end

@protocol MonthlyConfirmOrderDelegate <NSObject>
- (void) confirmOrder:(BOOL)isSuccess url:(NSString *)url;
@end

@interface MonthlyAddProductInfo : NSObject
@property (strong, nonatomic) NSString *intnum;
@property (strong, nonatomic) NSString *seq;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *pkgname;
@property (strong, nonatomic) NSString *seloption;
@property (strong, nonatomic) NSString *thumb;
@end

@interface MonthlyBaby : NSObject

+ (MonthlyBaby *)inst;

@property (strong, nonatomic) MonthlyBabyWebViewController *mainWebView;

@property (strong, nonatomic) NSString *uploadURL;

@property (strong, nonatomic) NSString *deadline;
@property (assign) int maxUploadCountPerBook;
@property (assign) int maxUploadCountTotal;
@property (assign) int currentUploadCount;

@property (strong, nonatomic) NSString *mainTitle;
@property (strong, nonatomic) NSString *subTitle;
@property (assign) BOOL isSeperated; // YES : 2권 제작, NO : 1권제작
@property (assign) BOOL markDate; // YES : 표시, NO : 안표시

//커버 정보는 여기에 추가하자.
@property (strong, nonatomic) NSString *coverImageKey;
@property (strong, nonatomic) NSString *trimInfo;
@property (assign) float trimTop;
@property (assign) float trimLeft;
@property (assign) float trimWidth;
@property (assign) float trimHeight;

@property (assign) int orderingType; // 0 : 스타일, 1 : 스토리
@property (assign) int designTheme; // 0 : 심플, 1 : 디자인&패턴, 2 : 컬러
@property (assign) int orderBookCount; //
@property (strong, nonatomic) NSMutableArray *selectedAddProduct; // MonthlyAddProductInfo를 추가.
@property (strong, nonatomic) NSMutableArray *addProducts;

- (BOOL) loadBaseData;
- (BOOL) loadData:(NSString *)getcode;
- (void) initialize;

- (void) uploadImage:(PhotoItem *)item url:(NSURL *)url params:(NSDictionary *)params delegate:(nonnull id)delegate;

- (void) sendToServer:(NSURL *)url params:(NSDictionary *)params imageData:(nullable NSData *)imageData filename:(NSString *)filename delegate:(nonnull id)delegate;
- (void) sendToServer:(NSURL *)url params:(NSDictionary *)params delegate:(nonnull id)delegate;
@end

NS_ASSUME_NONNULL_END
