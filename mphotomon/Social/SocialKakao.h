//
//  SocialKakao.h
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 6..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "SocialBase.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface SocialKakao : SocialBase
+(SocialKakao *) inst;
@property (strong, nonatomic) NSString *lastFeedID;
@property (assign) int thisTimeFetchingCount;

@end

NS_ASSUME_NONNULL_END
