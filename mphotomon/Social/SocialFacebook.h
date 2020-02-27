//
//  SocialFacebook.h
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 5..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "SocialBase.h"

NS_ASSUME_NONNULL_BEGIN

@import FBSDKCoreKit;
@import FBSDKShareKit;

@interface SocialFacebook : SocialBase
+(SocialFacebook *) inst;
@property (strong, nonatomic) NSString *lastFeedID;
@property (assign) int thisTimeFetchingCount;

@end

NS_ASSUME_NONNULL_END
