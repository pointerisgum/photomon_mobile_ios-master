//
//  SocialBase.h
//  PHOTOMON
//
//  Created by 곽세욱 on 05/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocialManager : NSObject // Wrapper

+ (SocialManager *)inst;

- (BOOL)isSessionValid:(int)snsType;
- (NSString *)getAccessToken:(int)snsType;
- (void)resetAccessToken:(int)snsType;
- (BOOL)evaluateAuthResponse:(int)snsType response:(NSString *)response;
- (NSString *)oAuthURL:(int)snsType;
- (void)logout:(int)snsType;
- (BOOL)fetchMediaRecent:(int)snsType;
- (void)initialize:(int)snsType;
- (void)initializeAll;
- (NSArray *)getScopes:(int)snsType;
@end

@interface SocialBase : NSObject

- (BOOL)isSessionValid;
- (NSString *)getAccessToken;
- (void)resetAccessToken;
- (BOOL)evaluateAuthResponse:(NSString *)response;
- (NSString *)oAuthURL;
- (void)logout;
- (BOOL)fetchMediaRecent;
- (void)initialize;
- (NSArray *)getScopes;
@end

NS_ASSUME_NONNULL_END
