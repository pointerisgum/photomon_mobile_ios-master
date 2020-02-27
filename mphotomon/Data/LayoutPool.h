//
//  LayoutPool.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 30..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//
@interface Layout : NSObject

@property (strong, nonatomic) NSString *parentElement;
@property (strong, nonatomic) NSString *theme_id;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *idx;
@property (assign) int imgcnt;
@property (assign) int width;
@property (assign) int height;
@property (strong, nonatomic) NSString *thumbnail;
@property (strong, nonatomic) NSString *skinfilename;
@property (strong, nonatomic) NSString *commonlayouttype;
@property (strong, nonatomic) NSString *productcode;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSMutableArray *layers;

- (Layout *)copy;
@end

//
@interface LayoutPool : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) NSString *parentElement;
@property (strong, nonatomic) NSString *thumb_url;
@property (strong, nonatomic) NSString *sel_type;
@property (strong, nonatomic) NSString *sel_theme; // theme id
@property (strong, nonatomic) NSString *calendarcommonlayouttype;
@property (strong, nonatomic) NSMutableArray *layouts;
@property (assign) BOOL is_found;
@property (assign) BOOL is_matched_theme;


- (BOOL)loadLayouts:(NSString *)booksize Theme:(NSString *)theme_id ProductType:(int)product_type;
- (BOOL)loadLayouts:(NSString *)info Theme:(NSString *)theme_id ProductType:(int)product_type CalendarCommonLayoutType:(NSString *)calendarcommonlayouttype;
- (BOOL)loadPhotobookV2Layouts:(NSString *)info Theme:(NSString *)theme_id ProductType:(int)product_type productOption1:(NSString*)productoption1 layoutType:(NSString*)layouttype;
- (Layout *)getDefaultLayout;
- (Layout *)getDefaultLayout:(int)product_type;
- (void)loginfo;
@end



