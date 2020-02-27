//
//  PhotobookTheme.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 16..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StartYear : NSObject
@property (strong, nonatomic) NSString *yyyymm;
@property (assign) int year;
@property (assign) int month;
@property (strong, nonatomic) NSString *datetext;
@end

@interface BookInfo : NSObject
@property (strong, nonatomic) NSString *booksize;
@property (strong, nonatomic) NSString *covertype;
@property (strong, nonatomic) NSString *productcode;
@property (strong, nonatomic) NSString *productoption1;
@property (strong, nonatomic) NSString *productoption2;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *discount;
@property (strong, nonatomic) NSString *cm;
@property (strong, nonatomic) NSString *minpictures;
@property (strong, nonatomic) NSString *minpages;
@property (strong, nonatomic) NSString *maxpages;
@property (strong, nonatomic) NSString *addpageprice;
@property (strong, nonatomic) NSString *coverpaper;
@property (strong, nonatomic) NSString *pagepaper;
// calendar info
@property (strong, nonatomic) NSString *pagecountinfo;
@property (strong, nonatomic) NSString *startyear;
@property (strong, nonatomic) NSString *startmonth;
@property (strong, nonatomic) NSString *monthcount;

@property (strong, nonatomic) NSString *isdouble;
@property (strong, nonatomic) NSString *showspring;
@property (strong, nonatomic) NSString *totalpagecount;

// frame info
@property (strong, nonatomic) NSString *use;
@property (strong, nonatomic) NSString *material;
@property (strong, nonatomic) NSString *component;

@property (strong, nonatomic) NSString *bind;
@property (strong, nonatomic) NSString *cardType;

@end

//
@interface SelectOption : NSObject
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *guideinfo;  // 메탈액자가 option에 guideinfo, guideinfo_silver가 있어서 추가.
@property (strong, nonatomic) NSString *guideinfo_silver;  // 메탈액자가 option에 guideinfo, guideinfo_silver가 있어서 추가.
@end

//
@interface Theme : NSObject
@property (strong, nonatomic) NSString *theme1_id;
@property (strong, nonatomic) NSString *theme2_id;
@property (strong, nonatomic) NSString *productcode;
@property (strong, nonatomic) NSString *main_thumb;
@property (strong, nonatomic) NSString *theme_name;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *discount;
@property (strong, nonatomic) NSString *openurl;
@property (strong, nonatomic) NSString *webviewurl;
@property (strong, nonatomic) NSString *autoselect;
@property (strong, nonatomic) NSString *depth1_key;
@property (strong, nonatomic) NSString *depth2_key;
@property (strong, nonatomic) NSString *depth1_str;
@property (strong, nonatomic) NSString *depth2_str;
@property (strong, nonatomic) NSString *b_new;
@property (strong, nonatomic) NSString *b_best;
@property (strong, nonatomic) NSString *element_content;



@property (strong, nonatomic) NSMutableArray *preview_thumbs;
@property (strong, nonatomic) NSMutableArray *book_sizes;
@property (strong, nonatomic) NSMutableArray *cover_types;
@property (strong, nonatomic) NSMutableArray *book_infos;
@property (strong, nonatomic) NSMutableArray *start_years;
// polaroid info
@property (strong, nonatomic) NSMutableArray *sel_coatings;
@property (strong, nonatomic) NSMutableArray *sel_options;  // 액자도 사용.
@property (strong, nonatomic) NSMutableArray *sel_options2;
@property (strong, nonatomic) NSMutableArray *sel_types;
@property (strong, nonatomic) NSMutableArray *sel_covertypes;
@end

//
//
@interface PhotobookTheme : NSObject <NSXMLParserDelegate>

@property (assign) int product_type;
@property (strong, nonatomic) NSString *current_element;
@property (strong, nonatomic) Theme *selected_theme;
@property (strong, nonatomic) NSString *thumb_url;
@property (strong, nonatomic) NSMutableArray *themes;
@property (strong, nonatomic) NSMutableArray *depth_list;
@property (strong, nonatomic) NSMutableArray *depth_list_str;

- (BOOL)loadTheme:(int)type;
- (BOOL)loadTheme:(int)type URL:(NSString *)url;
- (BOOL)loadPhotobookStyle:(int)type;
- (BOOL)loadPhotobookStyleFromUrl:(int)type fromUrl:(NSString *)url;
- (BOOL)loadPhotobookTheme:(int)type paramDepth1Key:(NSString*)depth1 paramDepth2Key:(NSString*)depth2 paramProductType:(NSString*)producttype selectedTheme:(Theme*)selectedtheme;
- (BOOL)loadPhotobookTheme:(int)type selectedTheme:(Theme*)selectedtheme
    themeUrl:(NSString*)themeUrl;

@end
