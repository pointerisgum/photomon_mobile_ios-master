//
//  SocialGooglePhoto.m
//  PHOTOMON
//
//  Created by 곽세욱 on 06/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "SocialGooglePhoto.h"
#import "Common.h"
#import "Firebase.h"

@implementation SocialGooglePhoto

static NSString *ClientID = GOOGLE_SIGNIN_CLIENT_ID;
static NSString *ApiKey = @"AIzaSyDsMIrBm-yQ9YVuy9s5gnKmZpLROPdjftg";
static NSString *Scope = @"https://www.googleapis.com/auth/photoslibrary";
static NSString *RecentMediaURL = @"https://photoslibrary.googleapis.com/v1/mediaItems:search?key=%@";
static int CountPerPage = 24;

+(SocialGooglePhoto *) inst {
	static dispatch_once_t pred;
	static SocialGooglePhoto *instance = nil;
	dispatch_once(&pred, ^{
		instance = [[SocialGooglePhoto alloc] init];
		[GIDSignIn sharedInstance].clientID = ClientID;
		instance.lastFeedID = @"";
	});
	return instance;
}

- (BOOL)isSessionValid{
	return [[GIDSignIn sharedInstance] hasAuthInKeychain];
//	NSString *access_token = [self getAccessToken];
//	if (access_token != nil && access_token.length > 0) {
//		return YES;
//	}
//	return NO;
	
}

- (NSString *)getAccessToken{
//	return [[Common info] getUserDefaultKey:@"GooglePhotoAccessToken"];
	GIDGoogleUser *user = [GIDSignIn sharedInstance].currentUser;
	if (user != nil) {
		GIDAuthentication *auth = user.authentication;
		if(auth != nil) {
			return auth.accessToken;
		}
	}
	
	return @"";
}

- (void)resetAccessToken {
	[[Common info] setUserDefaultKey:@"GooglePhotoAccessToken" Value:@""];
	[[GIDSignIn sharedInstance] signOut];
}

- (BOOL)evaluateAuthResponse:(NSString *)response {
	// response is Token
//	[[Common info] setUserDefaultKey:@"GooglePhotoAccessToken" Value:response];
	return YES;
}

- (NSString *)oAuthURL {
	//	return [NSString stringWithFormat:OAUTH_URL, APP_ID, PERMISSION_SCOPE, REDIRECT_URL];
	return @"";
//	return [NSString stringWithFormat:GOOGLEPHOTO_OAUTH_URL, GOOGLEPHOTO_PERMISSION_SCOPE, GOOGLEPHOTO_REDIRECT_URL, GOOGLEPHOTO_APP_ID];
}

- (void)logout{
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	[[storage cookies] enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
		[storage deleteCookie:cookie];
	}];
//	[[Common info] setUserDefaultKey:@"GooglePhotoAccessToken" Value:@""];
	[[GIDSignIn sharedInstance] signOut];
}

- (BOOL)fetchMediaRecent{
	int cnt = 0;
	
	NSString *access_token = [self getAccessToken];
	if (access_token.length > 0) {
		NSError *error;
		
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
		
		/// API KEY 가 필요함.
		NSString * urlString = [NSString stringWithFormat:RecentMediaURL, ApiKey];
		
		NSString *authorization = [NSString stringWithFormat:@"Bearer %@",access_token];
		[request setValue:authorization forHTTPHeaderField:@"Authorization"];
		
		NSURL *url = [NSURL URLWithString:urlString];
		
		[request setHTTPMethod:@"POST"];
		
		[request setURL:url];
		[request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		
		NSMutableArray* mediaTypes = [NSMutableArray new];
		[mediaTypes addObject:@"PHOTO"];
		
		NSMutableDictionary* mediaTypeFilter = [NSMutableDictionary new];
		[mediaTypeFilter setValue:mediaTypes forKey:@"mediaTypes"];
		
		NSMutableDictionary* filters = [NSMutableDictionary new];
		[filters setValue:mediaTypeFilter forKey:@"mediaTypeFilter"];
		
		NSMutableDictionary* bodyDict = [NSMutableDictionary new];
		[bodyDict setValue:filters forKey:@"filters"];
		[bodyDict setValue:[NSString stringWithFormat:@"%d", CountPerPage] forKey:@"pageSize"];
		if (_lastFeedID.length > 0) {
			[bodyDict setValue:_lastFeedID forKey:@"pageToken"];
		}
		
		NSData* postData = [NSJSONSerialization dataWithJSONObject:bodyDict options:NSUTF8StringEncoding error:nil];
		
		[request setHTTPBody:postData];
		
		NSData *finalDataToDisplay = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
		
		if (finalDataToDisplay != nil) {
			
			NSError *error;
			NSDictionary *json_data = [NSJSONSerialization
									   JSONObjectWithData:finalDataToDisplay
									   options:kNilOptions
									   error:&error];
			if (error) {
				NSLog(@"error : %@", error.localizedDescription);
				return NO;
			}
			
			NSDictionary *errData = [json_data objectForKey:@"error"];
			if (errData) {
				NSLog(@"error : %@", [errData objectForKey:@"message"]);
				return NO;
			}
			
			NSDateFormatter *parseFormat = [[NSDateFormatter alloc] init];
			[parseFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
			
			NSDateFormatter *toFormat = [[NSDateFormatter alloc] init];
			[toFormat setDateFormat:@"yyyyMMdd"];
			
			for (NSDictionary *dics in [json_data objectForKey:@"mediaItems"]) {
				NSString *base_url = [dics objectForKey:@"baseUrl"];
				
				NSDictionary *meta = [dics objectForKey:@"mediaMetadata"];
				
				NSString *widthStr = [meta objectForKey:@"width"];
				NSString *heightStr = [meta objectForKey:@"height"];
				
				int width = [widthStr intValue];
				int height = [heightStr intValue];
				
				int shortSide = MIN(width, height);
				float scaler = shortSide / 1.0 / MAX(shortSide / 10, 256);
				
				int thumbWidth = (int)(width / scaler);
				int thumbHeight = (int)(height / scaler);
				
				NSString *thumb_url = [base_url stringByAppendingFormat:@"=w%d-h%d", thumbWidth, thumbHeight]; // 최대한 작은 크기이지만 한변이 256 이상으로
				NSString *image_url = [base_url stringByAppendingFormat:@"=w%d-h%d", width, height];	// 원본 크기로
				NSString *key = [dics objectForKey:@"id"];
				
				NSString *filename = [dics objectForKey:@"filename"];
				NSDate* creationDate = [parseFormat dateFromString:[meta objectForKey:@"creationTime"]];
				
//				NSString *mimeType = [dics objectForKey:@"mineType"];
				
//				NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//				[dateFormat setDateFormat:@"yyyyMMdd"];
//
//				NSString *filename = [asset valueForKey:@"filename"];
//				NSString *creationDate = [dateFormat stringFromDate:[asset creationDate]];
				
				[[PhotoContainer inst]cache:PHOTO_POSITION_GOOGLEPHOTO mainURL:image_url thumbURL:thumb_url key:key filename:filename creationDate:[toFormat stringFromDate:creationDate]];
				cnt++;
			}
			
			_lastFeedID = [json_data objectForKey:@"nextPageToken"];
		}
		else {
			NSLog(@"");
		}
	}
	
	BOOL hasMorePhoto = cnt >= CountPerPage;
	return hasMorePhoto;
}

- (void)initialize {
	_lastFeedID = @"";
}

- (NSArray *)getScopes {
	return @[Scope];
}

@end
