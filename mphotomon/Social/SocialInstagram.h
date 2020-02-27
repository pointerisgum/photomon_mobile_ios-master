//
//  SocialInstagram.h
//  PHOTOMON
//
//  Created by 곽세욱 on 05/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "SocialBase.h"

NS_ASSUME_NONNULL_BEGIN

@import FBSDKCoreKit;

@interface SocialInstagram : SocialBase
+(SocialInstagram *) inst;
@property (strong, nonatomic) NSString *lastFeedID;

@property (assign) int thisTimeFetchingCount;

@end

NS_ASSUME_NONNULL_END
