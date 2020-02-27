//
//  Analysis.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 21..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "Analysis.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "Firebase.h"


@implementation Analysis

+ (void)regist {
    // SJYANG : DEPRECATED
    //[IgaworksCore igaworksCoreWithAppKey:@"432411855" andHashKey:@"1c5b310043574d30" andIsUseIgaworksRewardServer:NO];
    [IgaworksCore igaworksCoreWithAppKey:@"432411855" andHashKey:@"1c5b310043574d30"];
    [IgaworksCore setLogLevel:IgaworksCoreLogInfo];
    
    if (NSClassFromString(@"ASIdentifierManager")) {
        NSUUID *ifa =[[ASIdentifierManager sharedManager]advertisingIdentifier];
        BOOL isAppleAdvertisingTrackingEnalbed = [[ASIdentifierManager sharedManager]isAdvertisingTrackingEnabled];
        [IgaworksCore setAppleAdvertisingIdentifier:[ifa UUIDString] isAppleAdvertisingTrackingEnabled:isAppleAdvertisingTrackingEnalbed];
        
        NSLog(@"[ifa UUIDString] %@", [ifa UUIDString]);
    }
    
#if 0 // 최초 실행 체크
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefault stringForKey:@"com.igaworks.AppLaunchCount"];
    if (value == nil || [value intValue] <= 1) {
        // 최초 이용 활동 [New User Funnel] - 사용자가 앱을 설치하고 최초로 하는 모든 활동 기록
        [AdBrix firstTimeExperience:@"firstTimeExperience"];
    }
#endif
    [AdBrix firstTimeExperience:@"firstTimeExperience"];
}

+ (void)setuserid:(NSString *)userid {
    [IgaworksCore setUserId:userid];
}

+ (void)log:(NSString *)comment {
    // 앱 유지 활동 [In-app Activities] - 최초 이외의 모든 활동
    [AdBrix retention:comment];
}

+ (void)firAnalyticsWithScreenName:(NSString *)sName ScreenClass:(NSString*)sClass {
    [FIRAnalytics setScreenName:sName screenClass:sClass];
}


+ (void)buy:(NSString *)price {
    // 매출 분석 [In-app Purchase] - 앱 이용 중 구매하는 활동
    //[AdBrix buy:price];
}

+ (void)commerce {
    NSString *resultJson = @"[";
    for (int i = 0; i < [PhotomonInfo sharedInfo].payList.count; i++) {
        
        CartItem *item = [PhotomonInfo sharedInfo].payList[i];
        
        NSString *item_type = item.cart_print;
        NSString *category = @"";
        int unit_price = 0;
        if ([item.intnum isEqualToString:@"0"]) { // 사진인화
            item_type = @"사진인화";
            category = @"photomon.photoprint";
            unit_price = [item getSumPricePrint];
            //[AdBrix buy:@"사진인화"];
        }
        // SJYANG
        // 362 : 프리미엄북
        else if ([item.intnum isEqualToString:@"300"] || [item.intnum isEqualToString:@"362"] || [item.intnum isEqualToString:@"120"]) { // 포토북
            category = @"photomon.photobook";
            unit_price = [item getSumPricePhotobookOriginal];
            //[AdBrix buy:@"포토북"];
        }
        else if ([item.intnum isEqualToString:@"277"] || [item.intnum isEqualToString:@"367"] || [item.intnum isEqualToString:@"368"] || [item.intnum isEqualToString:@"369"] || [item.intnum isEqualToString:@"391"] || [item.intnum isEqualToString:@"392"] || [item.intnum isEqualToString:@"393"]) { // 달력
            category = @"photomon.calendar";
            unit_price = [item getSumPriceCalendarOriginal];
            //[AdBrix buy:@"달력"];
        }
        else if ([item.intnum isEqualToString:@"346"]) { // 수능스티커
            category = @"photomon.sticker";
            unit_price = [item getPrice];
            //[AdBrix buy:@"수능스티커"];
        }
        else if ([item.intnum isEqualToString:@"347"]) { // 폴라로이드
            category = @"photomon.polaroid";
            unit_price = [item getSumPricePolaroid];
            //[AdBrix buy:@"폴라로이드"];
        }
        else if ([item.intnum isEqualToString:@"376"] || [item.intnum isEqualToString:@"377"]) { // 포토카드
            category = @"photomon.card";
            unit_price = [item getSumPriceCard];
            //[AdBrix buy:@"포토카드"];
        }
        else if ([item.intnum isEqualToString:@"142"]) { // 마끈집게세트(폴라로이드옵션)
            category = @"photomon.polaroid.extra";
            unit_price = [item getSumPrice];
            //[AdBrix buy:@"마끈집게세트"];
        }
        else if ([item.intnum isEqualToString:@"350"] || [item.intnum isEqualToString:@"351"] || [item.intnum isEqualToString:@"356"]) { // 사진액자
            category = @"photomon.photoframe";
            unit_price = [item getSumPriceFrame];
            //[AdBrix buy:@"사진액자"];
        }
        else if ([item.intnum isEqualToString:@"357"]) { // 포토머그
            category = @"photomon.giftmug";
            unit_price = [item getSumPriceGift];
            //[AdBrix buy:@"포토머그"];
        }
        else if ([item.intnum isEqualToString:@"360"] || [item.intnum isEqualToString:@"363"]) { // 폰케이스
            category = @"photomon.giftphonecase";
            unit_price = [item getSumPriceGift];
            //[AdBrix buy:@"포토머그"];
        }
        else if ([item.intnum isEqualToString:@"366"]) { // 포토몬베이비
            category = @"photomon.baby";
            unit_price = [item getSumPriceBaby];
            //[AdBrix buy:@"포토몬베이비"];
        }

        NSMutableDictionary *representation = [NSMutableDictionary dictionaryWithCapacity:7];
        representation[@"orderId"] = item.cart_index;
        representation[@"productId"] = [NSString stringWithFormat:@"%@x%@", item.intnum, item.seq];
        representation[@"productName"] = item_type;
		// SJYANG : IGAWorks 옵션 수정
        //representation[@"quantity"] = item.pkgcnt;
        representation[@"quantity"] = @"1";
        representation[@"price"] = @(unit_price);
        representation[@"currency"] = @"KRW";
        representation[@"category"] = category;
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:representation
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (jsonData == nil) {
            resultJson = @"";
            break;
        }
        
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        resultJson = [NSString stringWithFormat:@"%@%@", resultJson, json];
        
        if (i < [PhotomonInfo sharedInfo].payList.count-1) {
            resultJson = [NSString stringWithFormat:@"%@,\n", resultJson];
        }
    }
    
    if (resultJson.length > 0) {
        resultJson = [NSString stringWithFormat:@"%@]", resultJson];
        NSLog(@"%@", resultJson);
        
        [IgaworksCommerce purchase:resultJson];
    }
}

@end

