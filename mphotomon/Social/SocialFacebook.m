//
//  SocialFacebook.m
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 5..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "SocialFacebook.h"
#import "Common.h"
#import "oAuthViewController.h"

@implementation SocialFacebook

static NSString *AppID = @"392211020936148";
static NSString *AppSecret = @"88cf866e98f3bfacdec11f0cf80a7ef1";
static NSString *Scope = @"user_photos";
static NSString *RecentMediaURL = @"https://photoslibrary.googleapis.com/v1/mediaItems:search?key=%@";
static int CountPerPage = 24;


+(SocialFacebook *) inst {
    static dispatch_once_t pred;
    static SocialFacebook *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[SocialFacebook alloc] init];
        instance.lastFeedID = @"";
    });
    return instance;
}

- (BOOL)isSessionValid{	
    if ([FBSDKAccessToken currentAccessToken]) {
        return YES;
    }
    return NO;
    
}

- (NSString *)getAccessToken{
	if ([self isSessionValid])
    	return [FBSDKAccessToken currentAccessToken].tokenString;
	
	return @"";
}

- (void)resetAccessToken {
}

- (BOOL)evaluateAuthResponse:(NSString *)response {
    return YES;
}

- (NSString *)oAuthURL {
	return @"";
}

- (void)logout{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [[storage cookies] enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        [storage deleteCookie:cookie];
    }];
    [[Common info] setUserDefaultKey:@"FacebookAccessToken" Value:@""];
    [[Common info] setUserDefaultKey:@"FacebookUserId" Value:@""];
}

- (BOOL)fetchMediaRecent{
    NSString *max_id_prev = _lastFeedID;
	
	//
//	me/photos?limit=2&type=uploaded
	NSMutableDictionary *params = [NSMutableDictionary new];
	[params setValue:@"images" forKey:@"fields"];
	[params setValue:@"uploaded" forKey:@"type"];
	[params setValue:[NSString stringWithFormat:@"%d", CountPerPage] forKey:@"limit"];
	
	if (_lastFeedID.length > 0) {
		[params setValue:_lastFeedID forKey:@"after"];
	}
	
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
								  initWithGraphPath:@"/me/photos"
								  parameters:params
								  HTTPMethod:@"GET"];
	
	_thisTimeFetchingCount = 0;
	
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	
	[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
										  id result,
										  NSError *error) {
		// Handle the result
		// data - NSArray<Dict>
		// data[i].images - NSArray
		// best worst를 찾자 - worst는 thumbnail, best 는 원본
		
		if (!error){
			NSDateFormatter *parseFormat = [[NSDateFormatter alloc] init];
			[parseFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss+SSSS"];
			
			NSDateFormatter *toFormat = [[NSDateFormatter alloc] init];
			[toFormat setDateFormat:@"yyyyMMdd"];
			
			for (NSDictionary *data in [result objectForKey:@"data"]) {
				// Find Best Worst
				int bestHeight = 0;
				int worstHeight = 10000;
				NSString *bestURL = @"";
				NSString *worstURL = @"";
				NSString *key = [data objectForKey:@"id"];
				for (NSDictionary *imageInfo in [data objectForKey:@"images"]) {
					NSString *height = [imageInfo objectForKey:@"height"];
					if (bestHeight < [height intValue])
					{
						bestHeight = [height intValue];
						bestURL = [imageInfo objectForKey:@"source"];
					}
					if (worstHeight > [height intValue])
					{
						worstHeight = [height intValue];
						worstURL = [imageInfo objectForKey:@"source"];
					}
				}
				
				NSDate* creationDate = [parseFormat dateFromString:[data objectForKey:@"created_time"]];
				NSString* filename = [Common extractFileNameFromUrlString:bestURL];
				
				[[PhotoContainer inst]cache:PHOTO_POSITION_FACEBOOK mainURL:bestURL thumbURL:worstURL key:key filename:filename creationDate:[toFormat stringFromDate:creationDate]];
				
				_thisTimeFetchingCount++;
			}
			
			NSDictionary *paging = [result objectForKey:@"paging"];
			NSDictionary *cursors = [paging objectForKey:@"cursors"];
			_lastFeedID = [cursors objectForKey:@"after"];
			//paging - dict
			//cursors - dict
			//after - nsstring 요걸 _lastFeedID에
		}
		
		dispatch_semaphore_signal(semaphore);
	}];
	
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	
    return _thisTimeFetchingCount >= CountPerPage;
}

- (void)initialize {
    _lastFeedID = @"";
}

- (NSArray *)getScopes {
	return @[Scope];
}
@end
