//
//  BackgroundPool.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 1. 18..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//
@interface Background : NSObject

@property (strong, nonatomic) NSString *theme_id;
@property (strong, nonatomic) NSString *page_type;
@property (assign) int idx;
@property (strong, nonatomic) NSString *thumbnail;
@property (strong, nonatomic) NSString *skinfilename;
@property (assign) int alpha;
@property (assign) int red;
@property (assign) int green;
@property (assign) int blue;
@property (strong, nonatomic) UIImage *image;
@end

//
@interface BackgroundPool : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) NSString *thumb_url;
@property (strong, nonatomic) NSString *sel_type; // size
@property (strong, nonatomic) NSString *sel_theme; // theme id
@property (strong, nonatomic) NSMutableArray *backgrounds;

- (BOOL)loadBackgrounds:(NSString *)booksize Theme:(NSString *)theme_id ProductType:(int)product_type;
- (BOOL)loadPhotobookV2Backgrounds:(NSString *)info Theme:(NSString *)theme_id ProductType:(int)product_type productOption1:(NSString *)productoption1 depth1_key:(NSString *)depth1 depth2_key:(NSString *)depth2 productType:(NSString *)producttype backgroundType:(NSString *)backgroundtype;
- (void)loginfo;
@end

