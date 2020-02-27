//
//  LayoutPool.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 30..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "LayoutPool.h"
#import "Common.h"

@implementation Layout

// SJYANG : 2017.12.09 : 사진을 넣는 공간(+)이 한 페이지에 20개 이상 생겨버리는 버그
BOOL found_and_added = FALSE;

- (id)init {
    if (self = [super init]) {
        _theme_id = @"";
        _type = @"";
        _idx = @"";
        _imgcnt = 0;
        _width = 0;
        _height = 0;
        _thumbnail = @"";
        _skinfilename = @"";
        _commonlayouttype = @"";
        _image = nil;
        _layers = [[NSMutableArray alloc] init];
		// SJYANG : 2017.12.09 : 사진을 넣는 공간(+)이 한 페이지에 20개 이상 생겨버리는 버그
		found_and_added = FALSE;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (Layout *)copy {
    Layout *layout = [[Layout alloc] init];
    layout.parentElement = _parentElement;
    layout.theme_id = _theme_id;
    layout.type = _type;
    layout.idx = _idx;
    layout.imgcnt = _imgcnt;
    layout.width = _width;
    layout.height = _height;
    layout.thumbnail = _thumbnail;
    layout.skinfilename = _skinfilename;
    layout.commonlayouttype = _commonlayouttype;
    layout.image = nil;
    layout.productcode = _productcode;
    for (Layer *layer in _layers) {
        Layer *copylayer = [layer copy];
        [layout.layers addObject:copylayer];
    }
    return layout;
}

@end

///
@implementation LayoutPool

- (id)init {
    if (self = [super init]) {
        _layouts = nil;
        [self clear];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void)clear {
	// 신규 달력 포맷 : TODO : CHECK
	/*
	if ([Common info] != nil && [Common info].photobook != nil && [Common info].photobook.product_type == PRODUCT_CALENDAR)
	    _thumb_url = URL_CALENDAR_THUMB_PATH;
	else
	    _thumb_url = URL_PRODUCT_THUMB_PATH;
	*/
    _thumb_url = URL_PRODUCT_THUMB_PATH;
    _sel_type = @"";
    _sel_theme = @"";
    _calendarcommonlayouttype = @"";
    _is_found = FALSE;
    _is_matched_theme = FALSE;

    if (_layouts != nil) {
        [_layouts removeAllObjects];
    }
    else {
        _layouts = [[NSMutableArray alloc] init];
    }
}

- (BOOL)loadLayouts:(NSString *)info Theme:(NSString *)theme_id ProductType:(int)product_type {
	return [self loadLayouts:info Theme:theme_id ProductType:product_type CalendarCommonLayoutType:nil];
}

- (BOOL)loadLayouts:(NSString *)info Theme:(NSString *)theme_id ProductType:(int)product_type CalendarCommonLayoutType:(NSString *)calendarcommonlayouttype {
	NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    [self clear];
    
    NSString *productCode = [Common info].photobook.ProductCode;

	// 신규 달력 포맷
	if (product_type == PRODUCT_CALENDAR)
	    _thumb_url = URL_CALENDAR_THUMB_PATH;
    else if (
             [productCode isEqualToString:@"434001"]
             || [productCode isEqualToString:@"347063"]
             || [productCode isEqualToString:@"347064"]
             || [productCode isEqualToString:@"436001"]
             || product_type == PRODUCT_DIVISIONSTICKER
        ){
        _thumb_url = [NSString stringWithFormat:URL_SINGLESTORE_SKIN_PATH, [Common info].connection.tplServerInfo];
        }
    else
	    _thumb_url = URL_PRODUCT_THUMB_PATH;

    NSString *url = @"";
    if (product_type == PRODUCT_PHOTOBOOK) {
        _sel_type = [NSString stringWithFormat:@"booksize_%@",info];

        // SJYANG : 2016.06.03 : 프리미엄북 CASE 처리
        if ([theme_id isEqualToString:@"GrainGray"] || [theme_id isEqualToString:@"GrainOlive"] || [theme_id isEqualToString:@"Camel"]) {
            _sel_type = @"booksize_8x8_premium";
        }
        
        // hsj. 180824 : 구닥북 레이아웃 처리
        if ([theme_id isEqualToString:@"Basic"] || [theme_id isEqualToString:@"Photo"]) {
            _sel_type = @"booksize_8x6_gudak";
        }

        if ([productCode isEqualToString:@"300480"] ||
                [productCode isEqualToString:@"300481"]) {
            _sel_type = [_sel_type stringByAppendingString:@"_fanbook"];
        } else if ([productCode isEqualToString:@"300482"] ||
                [productCode isEqualToString:@"300483"]) {
            _sel_type = [_sel_type stringByAppendingString:@"_soft_fanbook"];
        }
        
        _sel_theme = theme_id;
        url = URL_PHOTOBOOK_LAYOUT;
    }
    else if (product_type == PRODUCT_CALENDAR) {
        _sel_type = @""; // 277 -> calendartype_dc_normal.. 추후 종류가 늘어나면 수정할 것. (현재는 사용안함)
        _sel_theme = theme_id;
        url = URL_CALENDAR_LAYOUT;
		_calendarcommonlayouttype = calendarcommonlayouttype;
    }
    else if (product_type == PRODUCT_POLAROID) {
        _sel_type = @""; 
        _sel_theme = theme_id;
        url = URL_POLAROID_LAYOUT;
    }
    else if (product_type == PRODUCT_DESIGNPHOTO) {
        _sel_type = @""; 
        _sel_theme = theme_id;
        url = URL_DESIGNPHOTO_LAYOUT;
    }
    else if (product_type == PRODUCT_SINGLECARD) {
        _sel_type = @"";
        _sel_theme = theme_id;
        url = URL_SINGLECARD_LAYOUT;
    }
    else if (product_type == PRODUCT_MAGNET) {
        _sel_type = @"";
        _sel_theme = theme_id;
        url = URL_GIFT_LAYOUT;
    }
    else if (product_type == PRODUCT_POSTER) {
        _sel_type = @"";
        _sel_theme = theme_id;
        url = URL_POSTER_LAYOUT;
    }
    else if (product_type == PRODUCT_PAPERSLOGAN || product_type == PRODUCT_DIVISIONSTICKER) {
        _sel_type = @"";
        _sel_theme = theme_id;
        url = URL_FANCY_LAYOUT;
    }
    else if (product_type == PRODUCT_TRANSPARENTCARD) {
        _sel_type = @"";
        _sel_theme = theme_id;
        url = URL_TRANSPARENTCARD_LAYOUT;
    }
    else {
        NSAssert(NO, @"layout type is wrong..");
        return FALSE;
    }
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        //NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        //NSLog(@">> photobook layout info xml: %@", data);
        
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if (![Parser parse]) {
            NSLog(@"parse error: %@", [Parser parserError]);
            return FALSE;
        }
    }
    return TRUE;
}
- (BOOL)loadPhotobookV2Layouts:(NSString *)info Theme:(NSString *)theme_id ProductType:(int)product_type productOption1:(NSString*)productoption1 layoutType:(NSString*)layouttype {
    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    [self clear];
    
    NSString *productCode = [Common info].photobook.ProductCode;
    
    // 신규 달력 포맷
    if(product_type == PRODUCT_PHOTOBOOK){
        _thumb_url = [NSString stringWithFormat:URL_PHOTOBOOK_V2_SKIN_PATH, [Common info].connection.tplServerInfo];
    }
    else
        _thumb_url = URL_PRODUCT_THUMB_PATH;
    
    NSString *url = @"";
    if (product_type == PRODUCT_PHOTOBOOK) {
        _sel_type = [NSString stringWithFormat:@"booksize_%@",info];
        
        // SJYANG : 2016.06.03 : 프리미엄북 CASE 처리
        if ([theme_id isEqualToString:@"GrainGray"] || [theme_id isEqualToString:@"GrainOlive"] || [theme_id isEqualToString:@"Camel"]) {
            _sel_type = @"booksize_8x8_premium";
        }
        
        // hsj. 180824 : 구닥북 레이아웃 처리
        if ([theme_id isEqualToString:@"Basic"] || [theme_id isEqualToString:@"Photo"]) {
            _sel_type = @"booksize_8x6_gudak";
        }
        
        if ([productCode isEqualToString:@"300480"] ||
            [productCode isEqualToString:@"300481"]) {
            _sel_type = [_sel_type stringByAppendingString:@"_fanbook"];
        } else if ([productCode isEqualToString:@"300482"] ||
                   [productCode isEqualToString:@"300483"]) {
            _sel_type = [_sel_type stringByAppendingString:@"_soft_fanbook"];
        }
        
        _sel_theme = theme_id;
        
        //url = URL_PHOTOBOOK_LAYOUT;
        url = [NSString stringWithFormat:URL_PHOTOBOOK_V2_LAYOUT, productoption1, layouttype];
        
    }
    else {
        NSAssert(NO, @"layout type is wrong..");
        return FALSE;
    }
    
    //NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> photobook layout info xml: %@", data);
        
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if (![Parser parse]) {
            NSLog(@"parse error: %@", [Parser parserError]);
            return FALSE;
        }
    }
    return TRUE;
}

- (Layout *)getDefaultLayout {
    Layout *sel_layout = nil;
    for (Layout *layout in _layouts) {
        if ([layout.type isEqualToString:@"page"]) {
            if (sel_layout == nil) {
                sel_layout = layout; // 처음 발견한 레이아웃 KEEP (혹시라도 2구짜리 레이아웃이 없을때 사용할 목적)
            }

            if ([layout.idx isEqualToString:@"0"] || layout.imgcnt == 2) {
                sel_layout = layout; // 처음 발견한 2구짜리 레이아웃 선택. (0번째 or 2구 -> 혹시 못찾는 경우 대비 and대신 or로)
                break;
            }
        }
    }
    return (sel_layout != nil) ? [sel_layout copy] : nil;
}

- (Layout *)getDefaultLayout:(int)product_type {
    Layout *sel_layout = nil;
    NSString *product_code = [Common info].photobook.ProductCode;
    for (Layout *layout in _layouts) {
        if(!(
             (product_type == PRODUCT_DIVISIONSTICKER && [layout.parentElement isEqualToString:@"fancytype_divisionsticker"])
             && layout.productcode == product_code
             )){
            continue;
        }
        if ([layout.type isEqualToString:@"page"]) {
            if (sel_layout == nil) {
                sel_layout = layout; // 처음 발견한 레이아웃 KEEP (혹시라도 2구짜리 레이아웃이 없을때 사용할 목적)
            }
            
            if ([layout.idx isEqualToString:@"0"] || layout.imgcnt == 2) {
                sel_layout = layout; // 처음 발견한 2구짜리 레이아웃 선택. (0번째 or 2구 -> 혹시 못찾는 경우 대비 and대신 or로)
                break;
            }
        }
    }
    return (sel_layout != nil) ? [sel_layout copy] : nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	NSString *intnum = @"";
	@try {
		NSString *product_code = [Common info].photobook.ProductCode;
		intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
	}
	@catch(NSException *exception) {}
	
    static NSString *cur_theme_id = @"";

    if ([elementName rangeOfString:@"booksize_" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = [elementName isEqualToString:_sel_type];
        if (_is_found) {
            _is_matched_theme = TRUE;
            cur_theme_id = @"common";  // background와 다르게 common이 없으므로, theme가 지정안되었으면 common으로 간주.
        }
    }
    else if ([intnum isEqualToString:@"277"] && [elementName rangeOfString:@"calendartype_dc_normal" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([intnum isEqualToString:@"367"] && [elementName rangeOfString:@"calendartype_wc_small" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([intnum isEqualToString:@"368"] && [elementName rangeOfString:@"calendartype_dc_mini" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([intnum isEqualToString:@"369"] && [elementName rangeOfString:@"calendartype_st" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([intnum isEqualToString:@"391"] && [elementName rangeOfString:@"calendartype_wc_sheet" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([intnum isEqualToString:@"392"] && [elementName rangeOfString:@"calendartype_wc_big" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([intnum isEqualToString:@"393"] && [elementName rangeOfString:@"calendartype_poster_sco" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }	
	// 마그넷 : 레이아웃 변경 S ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    else if ([intnum isEqualToString:@"400"] && [elementName rangeOfString:@"gifttype_magnet_square" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([intnum isEqualToString:@"401"] && [elementName rangeOfString:@"gifttype_magnet_rect" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([intnum isEqualToString:@"402"] && [elementName rangeOfString:@"gifttype_magnet_retro" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([intnum isEqualToString:@"403"] && [elementName rangeOfString:@"gifttype_magnet_photobooth" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([intnum isEqualToString:@"403"] && [elementName rangeOfString:@"gifttype_magnet_photobooth" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([intnum isEqualToString:@"404"] && [elementName rangeOfString:@"gifttype_magnet_heart" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
	// 마그넷 : 레이아웃 변경 E ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    else if ([intnum isEqualToString:@"347"] && [elementName rangeOfString:@"polaroidtype_" options:NSCaseInsensitiveSearch].location != NSNotFound) {
         cur_theme_id = [attributeDict objectForKey:@"id"];
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([[Common info].photobook.ProductCode isEqualToString:@"347037"] && [elementName rangeOfString:@"designphototype_life4cut" options:NSCaseInsensitiveSearch].location != NSNotFound) {
		NSLog(@"여기까지..........");
        _is_found = TRUE;
        _is_matched_theme = TRUE;
        _parentElement = @"DesignPhototype_Life4Cut";
    }
    else if ([[Common info].photobook.ProductCode isEqualToString:@"347036"] && [elementName rangeOfString:@"designphototype_photocard" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        NSLog(@"여기까지..........");
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([elementName isEqualToString:@"postertype_poster"]) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
    }
    else if ([intnum isEqualToString:@"414"] && [elementName isEqualToString:@"fancytype_paperslogan"]) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
        _parentElement = @"fancytype_paperslogan";
    }
    else if ([[Common info].photobook.ProductCode isEqualToString:@"347062"] && [elementName isEqualToString:@"DesignPhototype_transparentcard"]) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
        _parentElement = @"DesignPhototype_transparentcard";
    }
    else if ([[Common info].photobook.ProductCode isEqualToString:@"347063"] && [elementName isEqualToString:@"DesignPhototype_wallet"]) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
        _parentElement = @"DesignPhototype_wallet";
    }
    else if ([[Common info].photobook.ProductCode isEqualToString:@"347064"] && [elementName isEqualToString:@"DesignPhototype_division"]) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
        _parentElement = @"DesignPhototype_division";
    }
    else if ( [[Common info].photobook.ProductCode isEqualToString:@"347037"] && [elementName isEqualToString:@"DesignPhototype_Life4Cut"]) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
        _parentElement = @"DesignPhototype_Life4Cut";
    }
    else if ([intnum isEqualToString:@"433"] && [elementName isEqualToString:@"fancytype_divisionsticker"]) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
        _parentElement = @"fancytype_divisionsticker";
    }
    else if ([elementName isEqualToString:@"PhotobookLayout"]) {
        _is_found = TRUE;
        _is_matched_theme = TRUE;
        _parentElement = @"PhotobookLayout";
    }
    else if ([elementName isEqualToString:@"theme1"]) {
        // pass... no op.
    }
    else if ([elementName isEqualToString:@"theme2"]) {
        if (_is_found) {
            cur_theme_id = [attributeDict objectForKey:@"id"];
            _is_matched_theme = ([cur_theme_id hasPrefix:@"common"] || [cur_theme_id isEqualToString:_sel_theme]);
        }
    }
    else if ([elementName isEqualToString:@"layoutinfo"]) {
		// SJYANG : 2017.12.09 : 사진을 넣는 공간(+)이 한 페이지에 20개 이상 생겨버리는 버그
		found_and_added = FALSE;

        if (_is_found && _is_matched_theme) {			
            Layout *layout = [[Layout alloc] init];
            layout.parentElement = _parentElement;
            layout.theme_id = cur_theme_id;
            layout.type = [attributeDict objectForKey:@"layouttype"];
            //NSLog(@"layout.type : %@", layout.type);
            layout.idx = [attributeDict objectForKey:@"idx"];
            layout.imgcnt = [[attributeDict objectForKey:@"imgcnt"] intValue];
	        @try {
				layout.width = [[attributeDict objectForKey:@"width"] intValue];
				layout.height = [[attributeDict objectForKey:@"height"] intValue];
			}
			@catch(NSException *exception) {}
            
            //productcode add
            @try {
                layout.productcode = [attributeDict objectForKey:@"productcode"];
            }
            @catch(NSException *exception) {}
            layout.thumbnail = [attributeDict objectForKey:@"thumbnail"];
            layout.skinfilename = [attributeDict objectForKey:@"skinfilename"];
            layout.commonlayouttype = [attributeDict objectForKey:@"commonlayouttype"];

			BOOL badd = YES;
			if ([Common info].photobook != nil && [Common info].photobook.product_type == PRODUCT_CALENDAR) {
				badd = NO;

				NSLog(@"layout.commonlayouttype : %@", layout.commonlayouttype);
				NSLog(@"[Common info].layout_pool.calendarcommonlayouttype : %@", [Common info].layout_pool.calendarcommonlayouttype);

				if(layout.commonlayouttype == nil || [layout.commonlayouttype isEqualToString:@""])
					layout.commonlayouttype = @"ca";

				if([Common info].layout_pool.calendarcommonlayouttype != nil && [layout.commonlayouttype isEqualToString:[Common info].layout_pool.calendarcommonlayouttype])
					badd = YES;
				if([[Common info].layout_pool.calendarcommonlayouttype isEqualToString:@"all"])
					badd = YES;
			}
			// TODO : 반드시 수정 필요
			// 스탠딩폴라
			if ([Common info].photobook.product_type == PRODUCT_POLAROID) {
				badd = NO;
				if([[Common info].photobook.ProductCode isEqualToString:@"347055"] && [cur_theme_id isEqualToString:@"347055"]) {
					if([layout.type isEqualToString:@"page_circle"]) {
						badd = YES;
					}
				}
				if([[Common info].photobook.ProductCode isEqualToString:@"347056"] && [cur_theme_id isEqualToString:@"347056"]) {
					if([layout.type isEqualToString:@"page_square"]) {
						badd = YES;
					}
				}
				if([[Common info].photobook.ProductCode isEqualToString:@"347057"] && [cur_theme_id isEqualToString:@"347057"]) {
					if([layout.type isEqualToString:@"page_circle"] || [layout.type isEqualToString:@"page_square"]) {
						badd = YES;
					}
				}
			}
			// 마그넷
			if ([Common info].photobook.product_type == PRODUCT_MAGNET) {
				NSString *layouttype_productcode = [attributeDict objectForKey:@"layouttype_productcode"];
				badd = NO;
				if([[Common info].photobook.ProductCode isEqualToString:layouttype_productcode]) {
					badd = YES;
				}
			}

			// 디자인포토(네컷인화)
			if ([Common info].photobook.product_type == PRODUCT_DESIGNPHOTO) {
                badd = NO;
                if([[Common info].photobook.ProductCode isEqualToString:@"347037"]) {
                    NSString *cuts = [Common info].photobook.AddVal9;
                    if ([layout.skinfilename rangeOfString:cuts].location != NSNotFound){
                        badd = YES;
                    }
                } else {
                    badd = YES;
                }
			}
			
			if(badd == YES) {
				[_layouts addObject:layout];
				NSLog(@"레이아웃 추가");

				// SJYANG : 2017.12.09 : 사진을 넣는 공간(+)이 한 페이지에 20개 이상 생겨버리는 버그
				found_and_added = TRUE;
			}
			else {
				// SJYANG : 2017.12.09 : 사진을 넣는 공간(+)이 한 페이지에 20개 이상 생겨버리는 버그
				found_and_added = FALSE;
			}
        }
    }
    else if ([elementName isEqualToString:@"imageinfo"]) {
        if (_is_found && _is_matched_theme) {
			BOOL badd = YES;
			// SJYANG : 2017.12.09 : 사진을 넣는 공간(+)이 한 페이지에 20개 이상 생겨버리는 버그
			if ([Common info].photobook.product_type == PRODUCT_CALENDAR) {
				if(!found_and_added) badd = NO;
			}
			if ([Common info].photobook.product_type == PRODUCT_POLAROID) {
				badd = NO;
				if([[Common info].photobook.ProductCode isEqualToString:@"347055"] && [cur_theme_id isEqualToString:@"347055"]) badd = YES;
				if([[Common info].photobook.ProductCode isEqualToString:@"347056"] && [cur_theme_id isEqualToString:@"347056"]) badd = YES;
				if([[Common info].photobook.ProductCode isEqualToString:@"347057"] && [cur_theme_id isEqualToString:@"347057"]) badd = YES;
			}
			if ([Common info].photobook.product_type == PRODUCT_DESIGNPHOTO) {
				badd = YES;
			}

			if(badd == YES)
			{
				Layout *layout = [_layouts lastObject];
				if (layout != nil) {
					Layer *layer = [[Layer alloc] init];
					layer.AreaType = 0;
					layer.MaskX = [[attributeDict objectForKey:@"x"] intValue];
					layer.MaskY = [[attributeDict objectForKey:@"y"] intValue];
					layer.MaskW = [[attributeDict objectForKey:@"width"] intValue];
					layer.MaskH = [[attributeDict objectForKey:@"height"] intValue];
					layer.MaskR = [[attributeDict objectForKey:@"angle"] intValue];
					layer.FrameFilename = [attributeDict objectForKey:@"diagramfilename"];
					[layout.layers addObject:layer];
				}
			}
        }
    }
    else if ([elementName isEqualToString:@"iconinfo"]) {
        if (_is_found && _is_matched_theme) {
			BOOL badd = YES;
			// SJYANG : 2017.12.09 : 사진을 넣는 공간(+)이 한 페이지에 20개 이상 생겨버리는 버그
			if ([Common info].photobook.product_type == PRODUCT_CALENDAR) {
				if(!found_and_added) badd = NO;
			}
			if ([Common info].photobook.product_type == PRODUCT_POLAROID) {
				badd = NO;
				if([[Common info].photobook.ProductCode isEqualToString:@"347055"] && [cur_theme_id isEqualToString:@"347055"]) badd = YES;
				if([[Common info].photobook.ProductCode isEqualToString:@"347056"] && [cur_theme_id isEqualToString:@"347056"]) badd = YES;
				if([[Common info].photobook.ProductCode isEqualToString:@"347057"] && [cur_theme_id isEqualToString:@"347057"]) badd = YES;
			}
			if ([Common info].photobook.product_type == PRODUCT_DESIGNPHOTO) {
				badd = YES;
			}

			if(badd == YES)
			{
				Layout *layout = [_layouts lastObject];
				if (layout != nil) {
					Layer *layer = [[Layer alloc] init];
					layer.AreaType = 1;
					layer.MaskX = [[attributeDict objectForKey:@"x"] intValue];
					layer.MaskY = [[attributeDict objectForKey:@"y"] intValue];
					layer.MaskW = [[attributeDict objectForKey:@"width"] intValue];
					layer.MaskH = [[attributeDict objectForKey:@"height"] intValue];
					layer.MaskR = [[attributeDict objectForKey:@"angle"] intValue];
					layer.Filename = [attributeDict objectForKey:@"filename"];
					layer.ImageFilename = layer.Filename;
					layer.ImageEditname = layer.Filename;
					layer.Alpha = 255.0;
					layer.FrameAlpha = 255.0;
					layer.MaskAlpha = 255.0;
					[layout.layers addObject:layer];
				}
			}
        }
    }
    else if ([elementName isEqualToString:@"textinfo"]) {
        if (_is_found && _is_matched_theme) {
			BOOL badd = YES;
			// SJYANG : 2017.12.09 : 사진을 넣는 공간(+)이 한 페이지에 20개 이상 생겨버리는 버그
			if ([Common info].photobook.product_type == PRODUCT_CALENDAR) {
				if(!found_and_added) badd = NO;
			}
			if ([Common info].photobook.product_type == PRODUCT_POLAROID) {
				badd = NO;
				if([[Common info].photobook.ProductCode isEqualToString:@"347055"] && [cur_theme_id isEqualToString:@"347055"]) badd = YES;
				if([[Common info].photobook.ProductCode isEqualToString:@"347056"] && [cur_theme_id isEqualToString:@"347056"]) badd = YES;
				if([[Common info].photobook.ProductCode isEqualToString:@"347057"] && [cur_theme_id isEqualToString:@"347057"]) badd = YES;
			}
			if ([Common info].photobook.product_type == PRODUCT_DESIGNPHOTO) {
				badd = YES;
			}

			if(badd == YES)
			{
				Layout *layout = [_layouts lastObject];
				if (layout != nil) {
					Layer *layer = [[Layer alloc] init];
					layer.AreaType = 2;
					layer.MaskX = [[attributeDict objectForKey:@"x"] intValue];
					layer.MaskY = [[attributeDict objectForKey:@"y"] intValue];
					layer.MaskW = [[attributeDict objectForKey:@"width"] intValue];
					layer.MaskH = [[attributeDict objectForKey:@"height"] intValue];
					layer.MaskR = [[attributeDict objectForKey:@"angle"] intValue];
					[layout.layers addObject:layer];
					
					layer.Gid = [attributeDict objectForKey:@"gid"];
					layer.TextFontname = [attributeDict objectForKey:@"fontname"];
                    layer.TextFontsize = [[attributeDict objectForKey:@"fontsize"] intValue] == 0 ? [[attributeDict objectForKey:@"fonsize"] intValue] : [[attributeDict objectForKey:@"fontsize"] intValue];
					layer.TextItalic = [[attributeDict objectForKey:@"italic"] boolValue];
					layer.TextBold = [[attributeDict objectForKey:@"bold"] boolValue];
                    @try {
                        layer.Grouping = [attributeDict objectForKey:@"grouping"];
                    }
                    @catch(NSException *exception) {
                        layer.Grouping = @"";
                    }
                    
					NSString *color = [attributeDict objectForKey:@"color"];

					layer.TextFontcolor = 0;
					layer.text_color = [UIColor blackColor];
					
					if (color.length > 0) {
						layer.TextFontcolor = 0;
						NSArray *row_array = [color componentsSeparatedByString:@","];
						if (row_array.count >= 4) {
							CGFloat a = [row_array[0] floatValue];
							CGFloat r = [row_array[1] floatValue];
							CGFloat g = [row_array[2] floatValue];
							CGFloat b = [row_array[3] floatValue];
							layer.text_color = [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a/255.0f];
						}
					}
					layer.Halign = [attributeDict objectForKey:@"halign"];
				}
			}
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)value {
    //    if ([_parsingElement isEqualToString:@"cartSession"]) {
    //    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //    _parsingElement = @"";
    if([elementName rangeOfString:@"calendartype_" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _is_found = FALSE;
        _is_matched_theme = FALSE;
    }else if ([elementName isEqualToString:@"DesignPhototype_transparentcard"] ||
              [elementName isEqualToString:@"DesignPhototype_wallet"]  ||
              [elementName isEqualToString:@"DesignPhototype_division"]  ||
              [elementName isEqualToString:@"DesignPhototype_Life4Cut"]  ||
              [elementName isEqualToString:@"fancytype_divisionsticker"] ||
              [elementName isEqualToString:@"fancytype_paperslogan"]
              ) {
        _is_found = FALSE;
        _is_matched_theme = FALSE;
        
    }
   
	// SJYANG : 2017.12.09 : 사진을 넣는 공간(+)이 한 페이지에 20개 이상 생겨버리는 버그
    if ([elementName isEqualToString:@"layoutinfo"]) {
        found_and_added = FALSE;
	}
    
}

- (void)loginfo {
    NSLog(@"layout pool info >>> %@", _sel_type);
    for (Layout *layout in _layouts) {
        NSLog(@">>[%@] %@,%@,%d,%@", layout.theme_id, layout.type, layout.idx, layout.imgcnt, layout.thumbnail);
/*
        for (Layer *layer in layout.layers) {
            if (layer.AreaType == 0) {
                NSLog(@"    image_rect:%d,%d,%d,%d", layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
            }
            else {
                NSLog(@"    text_rect:%d,%d,%d,%d", layer.MaskX, layer.MaskY, layer.MaskW, layer.MaskH);
            }
        }*/
    }
}

@end
