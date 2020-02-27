//
//  Common.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 3..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "Define.h"
#import "Analysis.h"
#import "Connection.h"
#import "LoginUserInfo.h"
#import "Photoprint.h"
#import "MainViewController.h"
#import "PhotobookProductViewController.h"
#import "PhotobookDesignViewController.h"
#import "CardProductViewController.h"
#import "CardDesignViewController.h"
#import "GiftProductViewController.h"
#import "BabyProductViewController.h"
#import "FancyProductViewController.h"
#import "PhotoPool.h"
#import "LayoutPool.h"
#import "BackgroundPool.h"
#import "Photobook.h"
#import "PhotobookProduct.h"
#import "PhotobookTheme.h"
#import "IDPhotos.h"
#import <sys/sysctl.h>
#import "GoodsFanbookDesignViewController.h"
#import "GoodsPosterDesignViewController.h"
#import "GoodsPaperSloganDesignViewController.h"
#import "GoodsProductViewController.h"
#import "AlertView.h"
#import "User.h"

#define YELLOW_COLOR                    [UIColor colorWithRed:255.0/255.0 green:202.0/255.0 blue:0/255 alpha:1.0]
#define GRAY_COLOR                      [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 alpha:1.0]

@interface Common : NSObject

@property (strong, nonatomic) MainViewController *main_controller;
@property (strong, nonatomic) PhotobookProductViewController *photobook_product_root_controller;
@property (strong, nonatomic) PhotobookDesignViewController *photobook_root_controller;
@property (strong, nonatomic) CardProductViewController *card_product_root_controller;
@property (strong, nonatomic) CardDesignViewController *card_root_controller;
@property (strong, nonatomic) GiftProductViewController *gift_root_controller;
@property (strong, nonatomic) BabyProductViewController *baby_root_controller;
@property (strong, nonatomic) FancyProductViewController *fancy_root_controller;
@property (strong, nonatomic) GoodsFanbookDesignViewController *fanbook_root_controller;
@property (strong, nonatomic) GoodsPosterDesignViewController *poster_root_controller;
@property (strong, nonatomic) GoodsPaperSloganDesignViewController *paperslogan_root_controller;
@property (strong, nonatomic) GoodsProductViewController *goods_root_controller;

@property (strong, nonatomic) Connection *connection;
@property (strong, nonatomic) LoginUserInfo *login_info;
@property (strong, nonatomic) User *user;

@property (strong, nonatomic) Photoprint *photoprint;

@property (strong, nonatomic) PhotoPool *photo_pool;
@property (strong, nonatomic) LayoutPool *layout_pool;
@property (strong, nonatomic) BackgroundPool *background_pool;
@property (strong, nonatomic) Photobook *photobook;
@property (strong, nonatomic) PhotobookTheme *photobook_theme;
@property (strong, nonatomic) PhotobookProduct *photobook_product;

//@property (strong, nonatomic) IDPhotosProduct *idphotos_product;
@property (strong, nonatomic) IDPhotos *idphotos;
@property (nonatomic) BOOL is_navi_double_back;

@property (strong, nonatomic) NSString *deeplink_url;
@property (nonatomic) BOOL inner_deeplink;
@property (strong, nonatomic) NSString *dimension_type;
@property (strong, nonatomic) NSString *device_uuid;

@property (nonatomic) BOOL login_status_changed;
@property (nonatomic) BOOL conn_link_init;
@property (nonatomic) BOOL dynamic_link_init;
@property (assign, nonatomic) CGPoint mainTabBarOffset;

@property (strong, nonatomic) NSString *nonMemberEmail;
@property (strong, nonatomic) NSString *nonMemberName;

+ (Common *)info;
- (void)alert:(id)sender Msg:(NSString *)msg;
- (void)alert:(id)sender Title:(NSString*)tle Msg:(NSString *)msg completion:(void(^)(void))completion;
- (void)alert:(id)sender Title:(NSString*)tle Msg:(NSString *)msg okCompletion:(void(^)(void))completion cancelCompletion:(void(^)(void))cancelCompletion okTitle:(NSString *)ok cancelTitle:(NSString *)cancel;

- (NSData *)downloadSyncWithURL:(NSURL *)url;
- (void)downloadAsyncWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, NSData *imageData))completionBlock;
- (BOOL)downloadImage:(NSURL *)url ToFile:(NSString *)pathname;
- (BOOL)downloadFile:(NSURL *)url ToFile:(NSString *)pathname;
- (BOOL)storeImage:(NSString *)imgnamed ToFile:(NSString *)pathname;

- (BOOL)isFileExist:(NSString *)pathname;
- (BOOL)isDirExist:(NSString *)path;
- (NSString *)sizeOfDirectory:(NSString *)path;
- (BOOL)removeAllFilesInDocument;
- (NSString *)extractFilenameFromUrl:(NSURL *)url;
- (NSString *)extractFilename:(NSString *)path;

- (void)setUserDefaultKey:(NSString *)key Value:(NSString *)value;
- (NSString *)getUserDefaultKey:(NSString *)key;

- (BOOL)checkGuideUserDefault:(NSString *)key;
- (void)setGuideUserDefault:(NSString *)key Value:(NSString *)value;
- (void)selectPhoto:(UIViewController *)viewController Singlemode:(BOOL)isSingleMode MinPictures:(int)minPictures Param:(NSString *)param;
- (void)selectPhoto:(UIViewController *)viewController Singlemode:(BOOL)isSingleMode MinPictures:(int)minPictures Param:(NSString *)param cancelOp:(void(^)(UIViewController *))cancelOp selectDoneOp:(void(^)(UIViewController *))selectDoneOp;

- (NSString *)logPhotoInfo:(PHAsset *)asset;
- (BOOL)isHorzDirection:(CGSize)destSize src:(CGSize)srcSize;
- (CGFloat)getScale:(CGSize)destSize src:(CGSize)srcSize isInnerFit:(BOOL)isInner;
- (CGRect)getScaledRect:(CGSize)destSize src:(CGSize)srcSize isInnerFit:(BOOL)isInner;
- (CGSize)getDimensions:(PHAsset *)asset;
- (CGSize)getDimensionsWithImageData:(PHAsset *)asset withImageData:(NSData *)imageData;
- (CGSize)getDimensionsByUIImage:(UIImage *)image;
- (CGSize)getRotatedSize:(CGSize)size Rotate:(int)angle;
- (CGRect)getDefaultCropRect:(CGRect)maskRect src:(CGSize)imageSize;
- (BOOL)isLowResolution:(Layer *)layer;

- (BOOL)isDigit:(NSString *)num_string;
- (NSString *)timeString;
- (NSString *)timeStringEx;
- (NSString *)timeStringForTitle;
- (NSString *)documentPath;
- (NSString *)toCurrencyString:(int)number;
- (NSString *)createProductId:(NSString *)product_code;

//- (void)appendNotUse:(NSMutableString *)data;
- (void)appendLengthOnly:(int)len to:(NSMutableData *)data;
- (void)appendInteger:(int)variable to:(NSMutableData *)data;
- (void)appendFloat:(float)variable to:(NSMutableData *)data;
- (void)appendBoolean:(BOOL)variable to:(NSMutableData *)data;
- (void)appendString:(NSString *)variable to:(NSMutableData *)data;
- (void)appendCGRect:(CGRect)variable to:(NSMutableData *)data;

- (NSString *)readString:(NSData *)data From:(int *)offset;
- (CGRect)readCGRect:(NSData *)data From:(int *)offset;
- (UIImageView *)showDeepLinkLaunchScreen:(UIView *)refview;
- (NSString *)getPlatformType;
- (NSString *)logToDevServer:(NSString *)logdata;

- (NSString *)checkEucKr:(NSString *)text;
- (NSString *)getDeviceUUID;

- (BOOL)isGudakBook:(NSString *)productCode;

- (NSString *)makeMD5Hash:(NSString *)src;

+ (NSString *)makeURLString:(NSString *)fileName host:(NSString *)host;

//+ (NSURL *)buildQueryURL:(NSString *)baseURL, ...;
+ (NSURL *)buildQueryURL:(NSString *)baseURL query:(NSArray *)query;
+ (NSString *)extractFileNameFromUrlString:(NSString *)urlString;
+ (NSString *)extractExtensionFromFilename:(NSString *)filename;
@end
