//
//  BackgroundPool.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 1. 18..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "BackgroundPool.h"
#import "Common.h"

@implementation Background

- (id)init {
    if (self = [super init]) {
        _theme_id = @"";
        _page_type = @"";
        _idx = 0;
        _thumbnail = @"";
        _skinfilename = @"";
        _alpha = 255;
        _red = 255;
        _green = 255;
        _blue = 255;
        _image = nil;
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end

@implementation BackgroundPool

- (id)init {
    if (self = [super init]) {
        _backgrounds = nil;
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
	if ([Common info].photobook.product_type == PRODUCT_CALENDAR)
	    _thumb_url = URL_CALENDAR_THUMB_PATH;
	else
	    _thumb_url = URL_PRODUCT_THUMB_PATH;
	*/
    _thumb_url = URL_PRODUCT_THUMB_PATH;
    _sel_type = @"";
    _sel_theme = @"";
    if (_backgrounds != nil) {
        [_backgrounds removeAllObjects];
    }
    else {
        _backgrounds = [[NSMutableArray alloc] init];
    }
}

- (BOOL)loadBackgrounds:(NSString *)info Theme:(NSString *)theme_id ProductType:(int)product_type {
    [self clear];

	// 신규 달력 포맷
	if (product_type == PRODUCT_CALENDAR)
	    _thumb_url = URL_CALENDAR_THUMB_PATH;
	else
	    _thumb_url = URL_PRODUCT_THUMB_PATH;
	
    NSString *url = @"";
    if (product_type == PRODUCT_PHOTOBOOK) {
        _sel_type = [NSString stringWithFormat:@"booksize_%@",info];
        _sel_theme = theme_id;
        url = URL_PHOTOBOOK_BACKGROUND;
    }
    else {
        NSAssert(NO, @"background type is wrong..");
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
- (BOOL)loadPhotobookV2Backgrounds:(NSString *)info Theme:(NSString *)theme_id ProductType:(int)product_type productOption1:(NSString *)productoption1 depth1_key:(NSString *)depth1 depth2_key:(NSString *)depth2 productType:(NSString *)producttype backgroundType:(NSString *)backgroundtype{
    [self clear];
    
    // 신규 달력 포맷
    if (product_type == PRODUCT_CALENDAR)
        _thumb_url = URL_CALENDAR_THUMB_PATH;
    else
        _thumb_url = URL_PRODUCT_THUMB_PATH;
    
    NSString *url = @"";
    if (product_type == PRODUCT_PHOTOBOOK) {
        _sel_type = [NSString stringWithFormat:@"booksize_%@",info];
        _sel_theme = theme_id;
        //url = URL_PHOTOBOOK_BACKGROUND;
        url = [NSString stringWithFormat:URL_PHOTOBOOK_V2_BG, depth1, depth2, @"designphotobook", backgroundtype, productoption1];
    }
    else {
        NSAssert(NO, @"background type is wrong..");
        return FALSE;
    }
    
    //NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        NSLog(@">> photobook backgroundlayout info xml: %@", data);
        
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if (![Parser parse]) {
            NSLog(@"parse error: %@", [Parser parserError]);
            return FALSE;
        }
    }
    return TRUE;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    static BOOL is_found = FALSE;
    static BOOL is_matched_theme = FALSE;
    static NSString *cur_theme_id = @"";
    
    if ([elementName rangeOfString:@"booksize_" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        is_found = [elementName isEqualToString:_sel_type];
    }
    else if ([elementName isEqualToString:@"PhotobookBackground"]) {
        is_found = YES;
    }
    else if ([elementName isEqualToString:@"theme1"]) {
        // pass... no op.
    }
    else if ([elementName isEqualToString:@"theme2"]) {
        if (is_found) {
            cur_theme_id = [attributeDict objectForKey:@"id"];
            is_matched_theme = ([cur_theme_id hasPrefix:@"common"] || [cur_theme_id isEqualToString:_sel_theme]);
        }
    }
    else if ([elementName isEqualToString:@"pageinfo"]) {
        if (is_found && is_matched_theme) {
            Background *background = [[Background alloc] init];
            background.theme_id = cur_theme_id;
            background.page_type = [attributeDict objectForKey:@"type"];
            background.idx = [[attributeDict objectForKey:@"idx"] intValue];
            background.thumbnail = [attributeDict objectForKey:@"thumbnail"];
            background.skinfilename = [attributeDict objectForKey:@"skinfilename"];
            background.alpha = [[attributeDict objectForKey:@"a"] intValue];
            background.red = [[attributeDict objectForKey:@"r"] intValue];
            background.green = [[attributeDict objectForKey:@"g"] intValue];
            background.blue = [[attributeDict objectForKey:@"b"] intValue];
            [_backgrounds addObject:background];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)value {
    //    if ([_parsingElement isEqualToString:@"cartSession"]) {
    //    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //    _parsingElement = @"";
}

- (void)loginfo {
    NSLog(@"background pool info >>> %@", _sel_type);
    for (Background *background in _backgrounds) {
        NSLog(@">>[%@] %@,%d,%@", background.theme_id, background.page_type, background.idx, background.thumbnail);
    }
}

@end
