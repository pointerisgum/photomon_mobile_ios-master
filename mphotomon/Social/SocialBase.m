//
//  SocialBase.m
//  PHOTOMON
//
//  Created by 곽세욱 on 05/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "SocialBase.h"
#import "Common.h"

#import "SocialInstagram.h"
#import "SocialGooglePhoto.h"
#import "SocialFacebook.h"
#import "SocialKakao.h"

@implementation SocialManager
+ (SocialManager *) inst {
	static dispatch_once_t pred;
	static SocialManager *man = nil;
	dispatch_once(&pred, ^{
		man = [[SocialManager alloc] init];
	});
	return man;
}

- (BOOL)isSessionValid:(int)snsType{
	if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] isSessionValid];
	}
	else if(snsType == PHOTO_POSITION_GOOGLEPHOTO) {
		return [[SocialGooglePhoto inst] isSessionValid];
	}
    else if(snsType == PHOTO_POSITION_FACEBOOK) {
        return [[SocialFacebook inst] isSessionValid];
    }
	else if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] isSessionValid];
	}
	else if(snsType == PHOTO_POSITION_KAKAOSTORY) {
		return [[SocialKakao inst] isSessionValid];
	}
	return NO;
}

- (NSString *)getAccessToken:(int)snsType; {
	if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] getAccessToken];
	}
	else if(snsType == PHOTO_POSITION_GOOGLEPHOTO) {
		return [[SocialGooglePhoto inst] getAccessToken];
	}
    else if(snsType == PHOTO_POSITION_FACEBOOK) {
        return [[SocialFacebook inst] getAccessToken];
    }
	else if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] getAccessToken];
	}
	else if(snsType == PHOTO_POSITION_KAKAOSTORY) {
		return [[SocialKakao inst] getAccessToken];
	}
	return @"";
}

- (void)resetAccessToken:(int)snsType{
	if(snsType == PHOTO_POSITION_INSTAGRAM) {
		[[SocialInstagram inst] resetAccessToken];
	}
	else if(snsType == PHOTO_POSITION_GOOGLEPHOTO) {
		[[SocialGooglePhoto inst] resetAccessToken];
	}
    else if(snsType == PHOTO_POSITION_FACEBOOK) {
        [[SocialFacebook inst] resetAccessToken];
    }
	else if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] resetAccessToken];
	}
	else if(snsType == PHOTO_POSITION_KAKAOSTORY) {
		return [[SocialKakao inst] resetAccessToken];
	}
}

- (BOOL)evaluateAuthResponse:(int)snsType response:(NSString *)response {
	if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] evaluateAuthResponse:response];
	}
	else if(snsType == PHOTO_POSITION_GOOGLEPHOTO) {
		return [[SocialGooglePhoto inst] evaluateAuthResponse:response];
    }
    else if(snsType == PHOTO_POSITION_FACEBOOK) {
        return [[SocialFacebook inst] evaluateAuthResponse:response];
    }
	else if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] evaluateAuthResponse:response];
	}
	else if(snsType == PHOTO_POSITION_KAKAOSTORY) {
		return [[SocialKakao inst] evaluateAuthResponse:response];
	}
	return NO;
}

- (NSString *)oAuthURL:(int)snsType{
	if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] oAuthURL];
	}
	else if(snsType == PHOTO_POSITION_GOOGLEPHOTO) {
		return [[SocialGooglePhoto inst] oAuthURL];
	}
    else if(snsType == PHOTO_POSITION_FACEBOOK) {
        return [[SocialFacebook inst] oAuthURL];
    }
	else if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] oAuthURL];
	}
	else if(snsType == PHOTO_POSITION_KAKAOSTORY) {
		return [[SocialKakao inst] oAuthURL];
	}
	return @"";
}

- (void)logout:(int)snsType{
	if(snsType == PHOTO_POSITION_INSTAGRAM) {
		[[SocialInstagram inst] logout];
	}
	else if(snsType == PHOTO_POSITION_GOOGLEPHOTO) {
		return [[SocialGooglePhoto inst] logout];
	}
    else if(snsType == PHOTO_POSITION_FACEBOOK) {
        [[SocialFacebook inst] logout];
    }
	else if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] logout];
	}
	else if(snsType == PHOTO_POSITION_KAKAOSTORY) {
		return [[SocialKakao inst] logout];
	}
}

- (BOOL)fetchMediaRecent:(int)snsType{
	if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] fetchMediaRecent];
	}
	else if(snsType == PHOTO_POSITION_GOOGLEPHOTO) {
		return [[SocialGooglePhoto inst] fetchMediaRecent];
	}
    else if(snsType == PHOTO_POSITION_FACEBOOK) {
        return [[SocialFacebook inst] fetchMediaRecent];
    }
	else if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] fetchMediaRecent];
	}
	else if(snsType == PHOTO_POSITION_KAKAOSTORY) {
		return [[SocialKakao inst] fetchMediaRecent];
	}
	return NO;
}

- (void)initialize:(int)snsType{
	if (snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] initialize];
	}
	else if(snsType == PHOTO_POSITION_GOOGLEPHOTO) {
		return [[SocialGooglePhoto inst] initialize];
	}
    else if(snsType == PHOTO_POSITION_FACEBOOK) {
        return [[SocialFacebook inst] initialize];
    }
	else if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] initialize];
	}
	else if(snsType == PHOTO_POSITION_KAKAOSTORY) {
		return [[SocialKakao inst] initialize];
	}
}

- (void)initializeAll{
	[self initialize:PHOTO_POSITION_GOOGLEPHOTO];
	[self initialize:PHOTO_POSITION_INSTAGRAM];
    [self initialize:PHOTO_POSITION_FACEBOOK];
	[self initialize:PHOTO_POSITION_INSTAGRAM];
	[self initialize:PHOTO_POSITION_KAKAOSTORY];
}

- (NSArray *)getScopes:(int)snsType {
	if (snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] getScopes];
	}
	else if(snsType == PHOTO_POSITION_GOOGLEPHOTO) {
		return [[SocialGooglePhoto inst] getScopes];
	}
	else if(snsType == PHOTO_POSITION_FACEBOOK) {
		return [[SocialFacebook inst] getScopes];
	}
	else if(snsType == PHOTO_POSITION_INSTAGRAM) {
		return [[SocialInstagram inst] getScopes];
	}
	else if(snsType == PHOTO_POSITION_KAKAOSTORY) {
		return [[SocialKakao inst] getScopes];
	}
	
	return @[];
}

@end

@implementation SocialBase // 빈 클래스
- (BOOL)isSessionValid{
	return false;
}

- (NSString *)getAccessToken{
	return @"";
}
- (void)resetAccessToken {
	
}
- (BOOL)evaluateAuthResponse:(NSString *)response {
	return NO;
}
- (NSString *)oAuthURL {
	return @"";
}
- (void)logout{
	
}
- (BOOL)fetchMediaRecent{
	return NO;
}
- (void)initialize{
}

- (NSArray *)getScopes {
	return @[];
}
@end
