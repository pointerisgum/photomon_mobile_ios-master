//
//  Instagram.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 3. 14..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "Instagram.h"
#import "Common.h"
#import "oAuthViewController.h"

@implementation InstaPhoto

- (id)init {
    if (self = [super init]) {
        [self clear];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void)clear {
    _thumb_url = @"";
    _image_url = @"";
    _image_id = @"";
    _key = @"";
    _thumb = nil;
    _image_path = @"";
}

- (BOOL)download:(NSString *)localpathname {
    NSURL *url = [NSURL URLWithString:_image_url];
    if ([[Common info] downloadImage:url ToFile:localpathname]) {
        _image_path = localpathname;
        //NSLog(@"%@ downloaded..", localpathname);
        return YES;
    }
    return NO;
}

@end


@implementation Instagram

// thread safe singleton
+ (Instagram *)info {
    static dispatch_once_t pred;
    static Instagram *instagram_info = nil;
    dispatch_once(&pred, ^{
        instagram_info = [[Instagram alloc] init];
        instagram_info.images = [[NSMutableArray alloc] init];
        instagram_info.sel_images = [[NSMutableArray alloc] init];
        instagram_info.max_id = @"";
    });
    return instagram_info;
}

- (NSString *)getAccessToken {
    return [[Common info] getUserDefaultKey:@"InstagramAccessToken"];
}

- (void)resetAccessToken {
    [[Common info] setUserDefaultKey:@"InstagramAccessToken" Value:@""];
}

- (BOOL)isSessionValid {
    NSString *access_token = [self getAccessToken];
    if (access_token != nil && access_token.length > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)evaluateAuthResponse:(NSString *)response {
    if ([response hasPrefix:INSTAGRAM_REDIRECT_URL]) {
        
        NSString *removedRedirectURI = [response stringByReplacingOccurrencesOfString:INSTAGRAM_REDIRECT_URL withString:@""];
        
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

- (void)login:(UIViewController *)viewController {
    oAuthViewController *vc = [viewController.storyboard instantiateViewControllerWithIdentifier:@"oAuthPage"];
    vc.delegate = (id<oAuthDelegate>)viewController;
    vc.oauth_url = [NSString stringWithFormat:INSTAGRAM_OAUTH_URL, INSTAGRAM_APP_ID, INSTAGRAM_REDIRECT_URL];
    [viewController presentViewController:vc animated:YES completion:nil];
}

- (void)logout {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [[storage cookies] enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {
        [storage deleteCookie:cookie];
    }];
    [[Common info] setUserDefaultKey:@"InstagramAccessToken" Value:@""];
}

- (void)reset {
    [_images removeAllObjects];
    [_sel_images removeAllObjects];
    _max_id = @"";
}

- (BOOL)fetchMediaRecent:(int)count {

    NSString *max_id_prev = _max_id;
    
    NSString *access_token = [self getAccessToken];
    if (access_token.length > 0) {
        
        NSString *url = [NSString stringWithFormat:INSTAGRAM_MEDIA_RECENT, access_token, count];
        if (_max_id.length > 0) {
            url = [NSString stringWithFormat:@"%@&max_id=%@", url, _max_id];
        }
        
        NSData *response_data = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url]];
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
            
            for (NSDictionary	 *dics in [json_data objectForKey:@"data"]) {
                NSDictionary *image_info = [dics objectForKey:@"images"];
                if (image_info != nil) {
                    NSString *thumb_url = [[image_info objectForKey:@"thumbnail"] objectForKey:@"url"];
                    NSString *image_url = [[image_info objectForKey:@"standard_resolution"] objectForKey:@"url"];
                    if (thumb_url != nil && image_url != nil) {
                        InstaPhoto *photo = [[InstaPhoto alloc] init];
                        photo.image_id = [dics objectForKey:@"id"];
                        photo.thumb_url = thumb_url;
                        photo.image_url = image_url;
                        photo.key = [[Common info] extractFilenameFromUrl:[NSURL URLWithString:thumb_url]];
                        photo.image_path = @"";
                        [_images addObject:photo];
                        //NSLog(@"-> %@", image_url);
                        
                        _max_id = photo.image_id;
                    }
                }
            }
        }
        else {
            NSLog(@"");
        }
    }
    return ([_max_id isEqualToString:max_id_prev] == NO);
}

- (BOOL)downloadPhotos {
    NSString *docPath = [[Common info] documentPath];
    NSString *baseFolder = [NSString stringWithFormat:@"%@/instagram", docPath];

    if (![[Common info] isDirExist:baseFolder]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager createDirectoryAtPath:baseFolder withIntermediateDirectories:YES attributes:nil error:NULL] != YES) {
            return NO;
        }
    }
    
    for (InstaPhoto *photo in _images) {
        NSURL *url = [NSURL URLWithString:photo.image_url];
        NSString *filename = [[Common info] extractFilenameFromUrl:url];
        NSString *localpathname = [NSString stringWithFormat:@"%@/%@", baseFolder, filename];
        
        [photo download:localpathname];
    }
    return YES;
}

- (InstaPhoto *)getPhoto:(InstaPhoto *)selected From:(NSMutableArray *)array {
    for (InstaPhoto *photo in array) {
        if ([selected.key isEqual:photo.key]) {
            return photo;
        }
    }
    return nil;
}

- (int)getPhotoIndex:(InstaPhoto *)selected From:(NSMutableArray *)array {
    for (int i = 0; i < array.count; i++) {
        InstaPhoto *photo = array[i];
        if ([selected.key isEqual:photo.key]) {
            return i;
        }
    }
    return -1;
}

- (BOOL)isSelectedThumb:(InstaPhoto *)selected {
    return ([self getPhoto:selected From:_sel_images] != nil);
}

- (void)add:(InstaPhoto *)selected {
    InstaPhoto *photo = [[InstaPhoto alloc] init];
    photo.thumb_url = selected.thumb_url;
    photo.image_url = selected.image_url;
    photo.key = selected.key;
    photo.thumb = selected.thumb;
    photo.image_path = selected.image_path;
    [_sel_images addObject:photo];
}

- (void)remove:(InstaPhoto *)selected {
    int index = [self getPhotoIndex:selected From:_sel_images];
    if (index >= 0) {
        [_sel_images removeObjectAtIndex:index];
    }
}

- (void)selectAll {
    [self removeAll];
    _sel_images = [_images mutableCopy];
}

- (void)removeAll {
    [_sel_images removeAllObjects];
}

- (int)selectedCount {
    return (int)_sel_images.count;
}

- (int)totalCount {
    return (int)_images.count;
}

@end

