//
//  PhotobookTheme.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 16..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PhotobookTheme.h"
#import "Common.h"

@implementation BookInfo
- (id)init {
    if (self = [super init]) {
        _booksize = @"";
        _covertype = @"";
        _productcode = @"";
        _productoption1 = @"";
        _productoption2 = @"";
        _price = @"";
        _discount = @"";
        _cm = @"";
        _minpictures = @"";
        _minpages = @"";
        _maxpages = @"";
        _addpageprice = @"";
        _coverpaper = @"";
        _pagepaper = @"";
        
        // calendar info
        _pagecountinfo = @"";
        _startyear = @"";
        _startmonth = @"";
        
        // frame info
        _use = @"";
        _material = @"";
        _component = @"";

        _bind = @"";
    }
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end

@implementation StartYear
- (id)init {
    if (self = [super init]) {
		_yyyymm = @"";
		_year = 0;
		_month = 0;
		_datetext = @"";
    }
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end

@implementation SelectOption
- (id)init {
    if (self = [super init]) {
        _comment = @"";
        _price = @"";
    }
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end

@implementation Theme
- (id)init {
    if (self = [super init]) {
        _theme1_id = @"";
        _theme2_id = @"";
        _productcode = @"";
        _main_thumb = @"";
        _theme_name = @"";
        _price = @"";
        _discount = @"";
        _preview_thumbs = [[NSMutableArray alloc] init];
        _book_sizes = [[NSMutableArray alloc] init];
        _cover_types = [[NSMutableArray alloc] init];
        _book_infos = [[NSMutableArray alloc] init];
        _start_years = [[NSMutableArray alloc] init];
        _sel_coatings = [[NSMutableArray alloc] init];
        _sel_options = [[NSMutableArray alloc] init];
        _sel_options2 = [[NSMutableArray alloc] init];
        _sel_types = [[NSMutableArray alloc] init];
        _sel_covertypes = [[NSMutableArray alloc] init];
        _autoselect = @""; // 마그넷 : autoselect
    }
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end

//
@implementation PhotobookTheme

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
    _product_type = -1;
	// 신규 달력 포맷 : TODO : CHECK
	/*
	if ([Common info].photobook.product_type == PRODUCT_CALENDAR)
	    _thumb_url = URL_CALENDAR_THUMB_PATH;
	else
	    _thumb_url = URL_PRODUCT_THUMB_PATH;
	*/
    _thumb_url = URL_PRODUCT_THUMB_PATH;
    _themes = [[NSMutableArray alloc] init];
    //_depth_list = [[NSMutableArray alloc] init];
    //_depth_list_str = [[NSMutableArray alloc] init];
}

- (BOOL)loadTheme:(int)type URL:(NSString *)url {
    [self clear];
    
    _product_type = type;
	// 신규 달력 포맷
	if (_product_type == PRODUCT_CALENDAR)
	    _thumb_url = URL_CALENDAR_THUMB_PATH;
    else
	    _thumb_url = URL_PRODUCT_THUMB_PATH;
	
	NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> photobook(calendar) theme info xml: %@", data);
        
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if ([Parser parse]) {
            return TRUE;
        }
        NSLog(@"parse error: %@", [Parser parserError]);
    }
    return FALSE;
}

- (BOOL)loadTheme:(int)type {

    NSString *url = URL_PHOTOBOOK_THEME;
    if (type == PRODUCT_CALENDAR) {
        url = URL_CALENDAR_THEME;
    }
    else if (type == PRODUCT_POLAROID) {
        url = URL_POLAROID_THEME;
    }
    else if (type == PRODUCT_DESIGNPHOTO) {
        url = URL_DESIGNPHOTO_THEME;
    }
    else if (type == PRODUCT_FRAME) {
        url = URL_FRAME_THEME;
    }
    else if (type == PRODUCT_MUG || type == PRODUCT_POSTCARD || type == PRODUCT_PHONECASE || type == PRODUCT_MAGNET) {
        url = URL_GIFT_THEME;
    }
    else if (type == PRODUCT_BABY) {
        url = URL_BABY_THEME;
    }
    else if (type == PRODUCT_CARD) {
        url = URL_CARD_THEME;
    }
    else if (type == PRODUCT_NAMESTICKER || type == PRODUCT_PAPERSLOGAN || type == PRODUCT_DIVISIONSTICKER) {
        url = URL_FANCY_THEME;
    }
    else if (type == PRODUCT_POSTER) {
        url = URL_POSTER_THEME;
    }
	
	return [self loadTheme:type URL:url];
}

- (BOOL)loadPhotobookStyle:(int)type {
    [self clear];
    
    _product_type = type;
    
    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR)
        _thumb_url = URL_CALENDAR_THUMB_PATH;
    else
        _thumb_url = URL_PRODUCT_THUMB_PATH;
    
    NSString *url = URL_PHOTOBOOK_V2_STYLE;
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> photobook(calendar) theme info xml: %@", data);
        
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if ([Parser parse]) {
            return TRUE;
        }
        NSLog(@"parse error: %@", [Parser parserError]);
    }
    return FALSE;
}

- (BOOL)loadPhotobookStyleFromUrl:(int)type fromUrl:(NSString *)url {
    [self clear];
    
    _product_type = type;
    
    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR)
        _thumb_url = URL_CALENDAR_THUMB_PATH;
    else
        _thumb_url = URL_PRODUCT_THUMB_PATH;
    
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> loadPhotobookStyleFromUrl theme info xml: %@", data);
        
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if ([Parser parse]) {
            return TRUE;
        }
        NSLog(@"parse error: %@", [Parser parserError]);
    }
    return FALSE;
}
- (BOOL)loadPhotobookTheme:(int)type paramDepth1Key:(NSString*)depth1 paramDepth2Key:(NSString*)depth2 paramProductType:(NSString*)producttype selectedTheme:(Theme*)selectedtheme{
    //[self clear];
    [selectedtheme.preview_thumbs removeAllObjects];
    [selectedtheme.sel_covertypes removeAllObjects];
    [selectedtheme.sel_coatings removeAllObjects];
    [selectedtheme.book_infos removeAllObjects];
    [selectedtheme.book_sizes removeAllObjects];
    
    _product_type = type;
    _selected_theme = selectedtheme;
    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR)
        _thumb_url = URL_CALENDAR_THUMB_PATH;
    else
        _thumb_url = URL_PRODUCT_THUMB_PATH;
    
    NSString *url = [NSString stringWithFormat:URL_PHOTOBOOK_V2_THEME, depth1, depth2, producttype];
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> photobook(calendar) theme info xml: %@", data);
        
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if ([Parser parse]) {
            return TRUE;
        }
        NSLog(@"parse error: %@", [Parser parserError]);
    }
    return FALSE;
}
- (BOOL)loadPhotobookTheme:(int)type selectedTheme:(Theme*)selectedtheme
 themeUrl:(NSString*)themeUrl{
    //[self clear];
    [selectedtheme.preview_thumbs removeAllObjects];
    [selectedtheme.sel_covertypes removeAllObjects];
    [selectedtheme.sel_coatings removeAllObjects];
    [selectedtheme.book_infos removeAllObjects];
    [selectedtheme.book_sizes removeAllObjects];
    
    _product_type = type;
    _selected_theme = selectedtheme;
    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR)
        _thumb_url = URL_CALENDAR_THUMB_PATH;
    else
        _thumb_url = URL_PRODUCT_THUMB_PATH;
    
    //NSString *url = [NSString stringWithFormat:themeUrl, depth1, depth2, producttype];
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(themeUrl, nil)]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> photobook(calendar) theme info xml: %@", data);
        
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if ([Parser parse]) {
            return TRUE;
        }
        NSLog(@"parse error: %@", [Parser parserError]);
    }
    return FALSE;
}
- (BOOL)loadPhotobookCody:(int)type {
    [self clear];
    
    _product_type = type;
    
    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR)
        _thumb_url = URL_CALENDAR_THUMB_PATH;
    else
        _thumb_url = URL_PRODUCT_THUMB_PATH;
    
    NSString *url = URL_PHOTOBOOK_V2_CODY;
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> photobook(calendar) theme info xml: %@", data);
        
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if ([Parser parse]) {
            return TRUE;
        }
        NSLog(@"parse error: %@", [Parser parserError]);
    }
    return FALSE;
}
- (BOOL)loadPhotobookBackground:(int)type {
    [self clear];
    
    _product_type = type;
    
    // 신규 달력 포맷
    if (_product_type == PRODUCT_CALENDAR)
        _thumb_url = URL_CALENDAR_THUMB_PATH;
    else
        _thumb_url = URL_PRODUCT_THUMB_PATH;
    
    NSString *url = URL_PHOTOBOOK_V2_BG;
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> photobook(calendar) theme info xml: %@", data);
        
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if ([Parser parse]) {
            return TRUE;
        }
        NSLog(@"parse error: %@", [Parser parserError]);
    }
    return FALSE;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    static NSString *theme1_id = @"";
    static NSString *select_id = @"";
    static NSString *productcode = @"";
    static NSString *depth1 = @"";
    static NSString *depth1_str = @"";
    
    _current_element = [elementName copy];
    
    if ([elementName isEqualToString:@"style"]) {
        _depth_list = [[[attributeDict objectForKey:@"depth1list"] componentsSeparatedByString:@","] mutableCopy];

        _depth_list_str = [[[attributeDict objectForKey:@"depth1list_kor"] componentsSeparatedByString:@","] mutableCopy];
        
    }
    else if ([elementName isEqualToString:@"theme1"]) {
        theme1_id = [attributeDict objectForKey:@"id"];
        productcode = [attributeDict objectForKey:@"productcode"];
        depth1 = [attributeDict objectForKey:@"depth1"];
        depth1_str = [attributeDict objectForKey:@"depth1_kor"];
    }
    else if ([elementName isEqualToString:@"theme2"]) {
        NSString *theme2_id = [attributeDict objectForKey:@"id"];
        
        Theme *theme;
        if(_selected_theme){
            _selected_theme.theme1_id = theme1_id;
            _selected_theme.theme2_id = theme2_id;
            _selected_theme.theme_name = _selected_theme.depth2_str;
            //theme.element_content = [attributeDict objectForKey:@""];
        }
        else{
            theme = [[Theme alloc] init];
            theme.theme1_id = theme1_id;
            theme.theme2_id = theme2_id;
            theme.productcode = productcode;
            theme.main_thumb = [attributeDict objectForKey:@"thumb"];
            theme.theme_name = [attributeDict objectForKey:@"themename"];
            theme.price = [attributeDict objectForKey:@"minprice"];
            theme.discount = [attributeDict objectForKey:@"discountminprice"];
            theme.openurl = [attributeDict objectForKey:@"openurl"];
            theme.webviewurl = [attributeDict objectForKey:@"webviewurl"];
            theme.autoselect = [attributeDict objectForKey:@"autoselect"]; // 마그넷 : autoselect
            theme.depth1_key = depth1;
            theme.depth2_key = [attributeDict objectForKey:@"depth2"];
            theme.depth1_str = depth1_str;
            theme.depth2_str = [attributeDict objectForKey:@"depth2_kor"];
            theme.b_new = [attributeDict objectForKey:@"new"];
            theme.b_best = [attributeDict objectForKey:@"best"];
            //theme.element_content = [attributeDict objectForKey:@""];
            [_themes addObject:theme];
        }
        
        

    }
    else if ([elementName isEqualToString:@"previewthumb"]) {
        Theme *theme = [_themes lastObject];
        
        NSString *filename = [attributeDict objectForKey:@"filename"];
        
        if(_selected_theme){
            [_selected_theme.preview_thumbs addObject:filename];
        }
        else{
            [theme.preview_thumbs addObject:filename];
        }
    }
    else if ([elementName isEqualToString:@"size"]) {
        Theme *theme = [_themes lastObject];
        
        NSString *value = [attributeDict objectForKey:@"value"];
        
        if(_selected_theme){
            [_selected_theme.book_sizes addObject:value];
        }
        else{
            [theme.book_sizes addObject:value];
        }
    }
    else if ([elementName isEqualToString:@"covertype"]) {
        Theme *theme = [_themes lastObject];
        
        NSString *value = [attributeDict objectForKey:@"value"];
        
        if(_selected_theme){
            [_selected_theme.cover_types addObject:value];
        }
        else{
            [theme.cover_types addObject:value];
        }
    }
	// 신규 달력 포맷 : 시작년월
    else if ([elementName isEqualToString:@"date"]) {
        Theme *theme = [_themes lastObject];
        
        StartYear *start_year = [[StartYear alloc] init];
        [theme.start_years addObject:start_year];

        start_year.yyyymm = [attributeDict objectForKey:@"yyyymm"];
        start_year.year = [[attributeDict objectForKey:@"year"] intValue];
        start_year.month = [[attributeDict objectForKey:@"month"] intValue];
        start_year.datetext = [attributeDict objectForKey:@"datetext"];
	}
    else if ([elementName isEqualToString:@"info"]) {
        Theme *theme = [_themes lastObject];

        BookInfo *bookinfo = [[BookInfo alloc] init];
        
        if(_selected_theme){
            [_selected_theme.book_infos addObject:bookinfo];
        }
        else{
            [theme.book_infos addObject:bookinfo];
        }
        
        bookinfo.booksize = [attributeDict objectForKey:@"booksize"];
        bookinfo.covertype = [attributeDict objectForKey:@"covertype"];
        bookinfo.productcode = [attributeDict objectForKey:@"productcode"];

        // SJYANG : 프리미엄포토북(제니스북)의 경우 XML DATA 가 8x8 로 잘못 들어가 있어서, 8x8_premium_mobile 로 강제적용
        if ([theme.theme1_id isEqualToString:@"premium"])
            bookinfo.productoption1 = @"8x8_premium_mobile";
        else
            bookinfo.productoption1 = [attributeDict objectForKey:@"productoption1"];

        bookinfo.productoption2 = [attributeDict objectForKey:@"productoption2"];
        bookinfo.price = [attributeDict objectForKey:@"price"];
        bookinfo.discount = [attributeDict objectForKey:@"discountprice"];
        bookinfo.cm = [attributeDict objectForKey:@"cm"];
        bookinfo.minpictures = [attributeDict objectForKey:@"minpictures"];
        bookinfo.minpages = [attributeDict objectForKey:@"minpages"];
        bookinfo.maxpages = [attributeDict objectForKey:@"maxpages"];
        bookinfo.addpageprice = [attributeDict objectForKey:@"addpageprice"];
        bookinfo.coverpaper = [attributeDict objectForKey:@"coverpaper"];
        bookinfo.pagepaper = [attributeDict objectForKey:@"pagepaper"];

        // calendar info
        bookinfo.pagecountinfo = [attributeDict objectForKey:@"pagecountinfo"];
        bookinfo.startyear = [attributeDict objectForKey:@"startyear"];
        bookinfo.startmonth = [attributeDict objectForKey:@"startmonth"];
		bookinfo.monthcount = [attributeDict objectForKey:@"monthcount"];
		bookinfo.isdouble = [attributeDict objectForKey:@"isdouble"];
		bookinfo.showspring = [attributeDict objectForKey:@"showspring"];
		bookinfo.totalpagecount = [attributeDict objectForKey:@"totalpagecount"];

        // frame info
        bookinfo.use = [attributeDict objectForKey:@"use"];
        bookinfo.material = [attributeDict objectForKey:@"material"];
        bookinfo.component = [attributeDict objectForKey:@"component"];

        bookinfo.bind = [attributeDict objectForKey:@"bind"];
        bookinfo.cardType = attributeDict[@"type1"];
    }
    else if ([elementName isEqualToString:@"select"]) {
        select_id = [attributeDict objectForKey:@"id"];
    }
    else if ([elementName isEqualToString:@"optionInfo"]) {
        select_id = [attributeDict objectForKey:@"id"];
    }
    else if ([elementName isEqualToString:@"option"]) {
        if( _product_type == PRODUCT_PHONECASE ) {
            if ([select_id isEqualToString:@"model"]) {
                Theme *theme = [_themes lastObject];

                SelectOption *sel_item = [[SelectOption alloc] init];
                [theme.sel_options addObject:sel_item];
                sel_item.comment = [attributeDict objectForKey:@"value"];
                sel_item.price = [attributeDict objectForKey:@"price"];
            }
            else if ([select_id isEqualToString:@"option"]) {
                Theme *theme = [_themes lastObject];
                
                SelectOption *sel_item = [[SelectOption alloc] init];
                [theme.sel_options2 addObject:sel_item];
                sel_item.comment = [attributeDict objectForKey:@"value"];
                sel_item.price = [attributeDict objectForKey:@"price"];
            }
        }
        else {
            if ([select_id isEqualToString:@"coating"] || [select_id isEqualToString:@"pagecount"] || [select_id isEqualToString:@"style"]) {
                Theme *theme = [_themes lastObject];
                
                SelectOption *sel_item = [[SelectOption alloc] init];
                
                if(_selected_theme){
                    [_selected_theme.sel_coatings addObject:sel_item];
                }
                else{
                    [theme.sel_coatings addObject:sel_item];
                }
                sel_item.comment = [attributeDict objectForKey:@"value"];
                sel_item.price = [attributeDict objectForKey:@"price"];
            }
            else if ([select_id isEqualToString:@"option"] || [select_id isEqualToString:@"option1"]) {
                Theme *theme = [_themes lastObject];
                
                SelectOption *sel_item = [[SelectOption alloc] init];
                
                if(_selected_theme){
                    [_selected_theme.sel_options addObject:sel_item];
                }
                else{
                    [theme.sel_options addObject:sel_item];
                }
                sel_item.comment = [attributeDict objectForKey:@"value"];
                sel_item.price = [attributeDict objectForKey:@"price"];
                if (_product_type == PRODUCT_FRAME) {
                    sel_item.guideinfo = [attributeDict objectForKey:@"guideinfo"];
                    sel_item.guideinfo_silver = [attributeDict objectForKey:@"guideinfo_silver"];
                }
            }
            // cmh 2018.07.02 추가 - 포토카드 때문에 추가함
            else if ([select_id isEqualToString:@"option2"]) {
                Theme *theme = [_themes lastObject];

                SelectOption *sel_item = [[SelectOption alloc] init];
                [theme.sel_options2 addObject:sel_item];
                sel_item.comment = [attributeDict objectForKey:@"value"];
                sel_item.price = [attributeDict objectForKey:@"price"];
            }
            // cmh 2018.07.02 추가 끝 - 포토카드 때문에 추가함
            else if ([select_id isEqualToString:@"scodix"]) {
                Theme *theme = [_themes lastObject];

                SelectOption *sel_item = [[SelectOption alloc] init];
                [theme.sel_options2 addObject:sel_item];
                sel_item.comment = [attributeDict objectForKey:@"value"];
                sel_item.price = [attributeDict objectForKey:@"price"];
            }
            else if ([select_id isEqualToString:@"type1"]) {
                Theme *theme = [_themes lastObject];

                [theme.sel_types addObject:attributeDict[@"value"]];
            }
            // codenist 2019.07.13 추가 - 포토부스 때문에 추가함
            else if ([select_id isEqualToString:@"design"]) {
                Theme *theme = [_themes lastObject];
                
                SelectOption *sel_item = [[SelectOption alloc] init];
                [theme.sel_options2 addObject:sel_item];
                sel_item.comment = [attributeDict objectForKey:@"caption"];
                sel_item.price = [attributeDict objectForKey:@"value"];
            }
            // codenist 2019.07.14 추가 - 메탈액자 때문에 추가함
            else if ([select_id isEqualToString:@"material"]) {
                Theme *theme = [_themes lastObject];
                
                SelectOption *sel_item = [[SelectOption alloc] init];
                [theme.sel_options2 addObject:sel_item];
                sel_item.comment = [attributeDict objectForKey:@"value"];
                sel_item.price = [attributeDict objectForKey:@"price"];
            }
            // codenist 2019.07.14 추가 - 포토북 신규 커버타입
            else if ([select_id isEqualToString:@"covertype"]) {
                Theme *theme = [_themes lastObject];
                
                SelectOption *sel_item = [[SelectOption alloc] init];
                if(_selected_theme){
                    [_selected_theme.sel_covertypes addObject:sel_item];
                }
                else{
                    [theme.sel_covertypes addObject:sel_item];
                }
                sel_item.comment = [attributeDict objectForKey:@"value"];
               
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)value {
    //    if ([_parsingElement isEqualToString:@"cartSession"]) {
    //    }
    if ([_current_element isEqualToString:@"theme2"]) {
        if([value containsString:@"://"]){
            Theme *theme = [_themes lastObject];
            theme.element_content = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //    _parsingElement = @"";
    
}

@end
