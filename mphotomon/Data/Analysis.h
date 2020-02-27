//
//  Analysis.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 21..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdSupport/AdSupport.h>
#import <IgaworksCore/IgaworksCore.h>
#import <IgaworksCommerce/IgaworksCommerce.h>
#import <AdBrix/AdBrix.h>


@interface Analysis : NSObject

+ (void)regist;
+ (void)setuserid:(NSString *)userid;
+ (void)log:(NSString *)comment;
+ (void)firAnalyticsWithScreenName:(NSString *)sName ScreenClass:(NSString*)sClass;
+ (void)buy:(NSString *)price;
+ (void)commerce;

@end
