//
//  Instagram.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 3. 14..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define INSTAGRAM_APP_ID @"9400452476794609aaa4e1e315cd0178"
#define INSTAGRAM_SECRET_KEY @"28bfce5036dd4c9783c73798eb4349ba"
#define INSTAGRAM_REDIRECT_URL @"http://www.photomon.com/naver/instagram_oauth.asp"

#define INSTAGRAM_OAUTH_URL @"https://instagram.com/oauth/authorize/?display=touch&client_id=%@&redirect_uri=%@&response_type=token"
#define INSTAGRAM_MEDIA_RECENT @"https://api.instagram.com/v1/users/self/media/recent?access_token=%@&count=%d"
#define INSTAGRAM_COUNT_PER_PAGE 24

//
@interface InstaPhoto : NSObject

@property (strong, nonatomic) NSString *thumb_url;
@property (strong, nonatomic) NSString *image_url;
@property (strong, nonatomic) NSString *image_id;
@property (strong, nonatomic) NSString *key; // thumbnail filename
@property (strong, nonatomic) UIImage *thumb;
@property (strong, nonatomic) NSString *image_path;

- (BOOL)download:(NSString *)localpath;
@end

//
//
@interface Instagram : NSObject

@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableArray *sel_images;
@property (strong, nonatomic) NSString *max_id;

+ (Instagram *)info;

- (BOOL)isSessionValid;
- (NSString *)getAccessToken;
- (void)resetAccessToken;
- (BOOL)evaluateAuthResponse:(NSString *)response;
- (void)login:(UIViewController *)viewController;
- (void)logout;
- (void)reset;
- (BOOL)fetchMediaRecent:(int)count;
- (BOOL)downloadPhotos;

- (BOOL)isSelectedThumb:(InstaPhoto *)selected;
- (void)add:(InstaPhoto *)selected;
- (void)remove:(InstaPhoto *)selected;
- (void)selectAll;
- (void)removeAll;
- (int)selectedCount;
- (int)totalCount;

@end
