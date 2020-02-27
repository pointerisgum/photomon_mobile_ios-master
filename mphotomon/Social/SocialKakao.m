//
//  SocialKakao.m
//  PHOTOMON
//
//  Created by Codenist on 2019. 8. 6..
//  Copyright © 2019년 maybeone. All rights reserved.
//

#import "SocialKakao.h"
#import "Common.h"
#import "oAuthViewController.h"

@implementation SocialKakao

static NSString *AppID =@"23028";
static NSString *AppKey =@"d04c1c4438c1dd8f373e275b0c3ba5af";
static NSString *oAuthURL = @"https://kauth.kakao.com/oauth/authorize?client_id=%@&redirect_uri=%@&response_type=code";
static NSString *oAuthGetTokenURL = @"https://kauth.kakao.com/oauth/token";
static NSString *RedirectURL = @"https://www.photomon.com/kakao/oauth.asp";
static NSString *RecentMediaURL = @"https://kapi.kakao.com/v1/api/story/mystories";
static int CountPerPage = 18;

+(SocialKakao *) inst {
    static dispatch_once_t pred;
    static SocialKakao *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[SocialKakao alloc] init];
		[instance resetAccessToken];
        instance.lastFeedID = @"";
    });
    return instance;
}

- (BOOL)isSessionValid{
    return [[KOSession sharedSession] isOpen];
}

- (NSString *)getAccessToken{
    return [[KOSession sharedSession].token accessToken];
}

- (void)resetAccessToken {
}

- (BOOL)evaluateAuthResponse:(NSString *)response {
	return YES;
}

- (NSString *)oAuthURL {
    //    return [NSString stringWithFormat:OAUTH_URL, APP_ID, PERMISSION_SCOPE, REDIRECT_URL];
    return [NSString stringWithFormat:oAuthURL, AppKey, RedirectURL];
}

- (void)logout{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [[storage cookies] enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        [storage deleteCookie:cookie];
    }];
    [[Common info] setUserDefaultKey:@"KakaoAccessToken" Value:@""];
}

- (BOOL)fetchMediaRecent{
	
	_thisTimeFetchingCount = 0;
	
	// 이 함수는 애초에 밖에서 비동기로 들어오기 때문에 여기서 동기로 강제 한다. semaphore이용.
	
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	
	[KOSessionTask storyGetMyStoriesTaskWithLastMyStoryId:_lastFeedID completionHandler:^(NSArray *myStories, NSError *error) {
		if (!error) {
			// 성공
			NSDateFormatter *parseFormat = [[NSDateFormatter alloc] init];
			[parseFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
			
			NSDateFormatter *toFormat = [[NSDateFormatter alloc] init];
			[toFormat setDateFormat:@"yyyyMMdd"];
			
			for (KOStoryMyStoryInfo *myStory in myStories) {
				NSLog(@"myStoryId=%@", myStory.ID);
				if (myStory.mediaType == KOStoryMediaTypePhoto){
					int idx = 0;
					for (KOStoryMyStoryImageInfo *imageInfo in myStory.media) {
						NSString *thumb_url = imageInfo.small;
						NSString *image_url = imageInfo.original;
						NSString *key = imageInfo.original;
						
						NSString *extention = [Common extractExtensionFromFilename:[Common extractFileNameFromUrlString:image_url]];
						NSDate* creationDate = [parseFormat dateFromString:myStory.createdAt];
						
						NSString *filename = [NSString stringWithFormat:@"%@_%d.%@", myStory.ID, idx, extention];
//						myStory.createdAt
						[[PhotoContainer inst]cache:PHOTO_POSITION_KAKAOSTORY mainURL:image_url thumbURL:thumb_url key:key filename:filename creationDate:[toFormat stringFromDate:creationDate]];
						idx++;
					}
					
				}
				self->_lastFeedID = myStory.ID;
				self->_thisTimeFetchingCount++;
			}
			
			//NSLog(@"%@", myStories);
		} else {
			// 실패
			NSLog(@"failed to get mystories.");
		}
		
		dispatch_semaphore_signal(semaphore);
	}];
	
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	
	return _thisTimeFetchingCount >= CountPerPage;
}

- (void)initialize {
    _lastFeedID = @"";
}
@end
