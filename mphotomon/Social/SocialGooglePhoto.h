//
//  SocialGooglePhoto.h
//  PHOTOMON
//
//  Created by 곽세욱 on 06/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "SocialBase.h"

NS_ASSUME_NONNULL_BEGIN

@import GoogleSignIn;

@interface SocialGooglePhoto : SocialBase

+(SocialGooglePhoto *) inst;
@property (strong, nonatomic) NSString *lastFeedID;

@end

NS_ASSUME_NONNULL_END
