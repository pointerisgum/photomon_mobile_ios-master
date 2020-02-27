//
//  SocialInstagram.m
//  PHOTOMON
//
//  Created by 곽세욱 on 05/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "SocialInstagram.h"
#import "Common.h"

@implementation SocialInstagram

static NSString *ClientID = @"9400452476794609aaa4e1e315cd0178";
static NSString *oAuthURL = @"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token";
static NSString *RedirectURL = @"http://www.photomon.com/naver/instagram_oauth.asp";
static NSString *RecentMediaURL = @"https://api.instagram.com/v1/users/self/media/recent?access_token=%@&count=%d";
static int CountPerPage = 24;

+(SocialInstagram *) inst {
	static dispatch_once_t pred;
	static SocialInstagram *instance = nil;
	dispatch_once(&pred, ^{
		instance = [[SocialInstagram alloc] init];
		instance.lastFeedID = @"";
	});
	return instance;
}

- (BOOL)isSessionValid{
	if ([self getAccessToken].length > 0) {
		return YES;
	}
	return NO;
	
}

- (NSString *)getAccessToken{
	return [[Common info] getUserDefaultKey:@"InstagramAccessToken"];
}

- (void)resetAccessToken {
	[[Common info] setUserDefaultKey:@"InstagramAccessToken" Value:@""];
}

- (BOOL)evaluateAuthResponse:(NSString *)response {
	if ([response hasPrefix:RedirectURL]) {
		
		NSString *removedRedirectURI = [response stringByReplacingOccurrencesOfString:RedirectURL withString:@""];
		
		// uri와 토큰은 “#”문자열로 구분.
		NSArray *tokenArray = [removedRedirectURI componentsSeparatedByString:@"="];
		NSString *access_token = [tokenArray objectAtIndex:1];
		NSLog(@"access_token: %@", access_token);
		
		if (access_token != nil && access_token.length > 0) {
			[[Common info] setUserDefaultKey:@"InstagramAccessToken" Value:access_token];
			return YES;
		}
	}
	return NO;
}

- (NSString *)oAuthURL {
	return [NSString stringWithFormat:oAuthURL, ClientID, RedirectURL];
}

- (void)logout{
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	[[storage cookies] enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
		[storage deleteCookie:cookie];
	}];
	[[Common info] setUserDefaultKey:@"InstagramAccessToken" Value:@""];
}

- (BOOL)fetchMediaRecent{
	NSString *access_token = [self getAccessToken];
	if (access_token.length > 0) {
		
		NSString *urlString = [NSString stringWithFormat:RecentMediaURL, access_token, CountPerPage];
		
		if (_lastFeedID.length > 0){
			urlString = [urlString stringByAppendingFormat:@"&max_id=%@", _lastFeedID];
		}
		
//		urlString = [urlString stringByAppendingFormat:@"&max_timestamp=1564969800&min_timestamp=1564969780"];
		
		_thisTimeFetchingCount = 0;
		
		NSURL *url = [NSURL URLWithString:urlString];
		
		int cnt = 0;
		
		NSData *response_data = [[Common info] downloadSyncWithURL:url];
		
		if (response_data != nil) {
			
			NSError *error;
			NSDictionary *json_data = [NSJSONSerialization
									   JSONObjectWithData:response_data
									   options:kNilOptions
									   error:&error];
			if (error) {
				NSLog(@"error : %@", error.localizedDescription);
				return NO;
			}
			
			NSDateFormatter *toFormat = [[NSDateFormatter alloc] init];
			[toFormat setDateFormat:@"yyyyMMdd"];
			
			for (NSDictionary *dics in [json_data objectForKey:@"data"]) {
				NSString *idStr = [dics objectForKey:@"id"];
				
				NSDate *created_date = [NSDate dateWithTimeIntervalSince1970:[[dics objectForKey:@"created_time"] intValue]];
				NSString *creationDate = [toFormat stringFromDate:created_date];
				//
				NSDictionary *carousel = [dics objectForKey:@"carousel_media"]; // 여러개 인 경우만 있음
				if (carousel != nil) {
					
					int idx = 0;
					for (NSDictionary *carousel_dics in carousel) {
						NSDictionary *image_info = [carousel_dics objectForKey:@"images"];
						if (image_info != nil) {
							NSString *thumb_url = [[image_info objectForKey:@"thumbnail"] objectForKey:@"url"];
							NSString *image_url = [[image_info objectForKey:@"standard_resolution"] objectForKey:@"url"];
							NSString *key = [idStr stringByAppendingFormat:@"_%d", idx];
							NSString *filename = [Common extractFileNameFromUrlString:image_url];
							
							[[PhotoContainer inst]cache:PHOTO_POSITION_INSTAGRAM mainURL:image_url thumbURL:thumb_url key:key filename:filename creationDate:creationDate];
							
							idx++;
						}
					}
				} else {
					NSDictionary *image_info = [dics objectForKey:@"images"];
					if (image_info != nil) {
						NSString *thumb_url = [[image_info objectForKey:@"thumbnail"] objectForKey:@"url"];
						NSString *image_url = [[image_info objectForKey:@"standard_resolution"] objectForKey:@"url"];
						
						NSString *filename = [Common extractFileNameFromUrlString:image_url];
						
						[[PhotoContainer inst]cache:PHOTO_POSITION_INSTAGRAM mainURL:image_url thumbURL:thumb_url key:idStr filename:filename creationDate:creationDate];
					}
				}
				
				cnt++;
				_lastFeedID = idStr;
			}
		}
		else {
			NSLog(@"");
		}
		
		return cnt >= CountPerPage;
	}
	
	return NO;
}

- (void)initialize {
	_lastFeedID = @"";
}

- (NSArray *)getScopes {
	return @[];
}
@end
