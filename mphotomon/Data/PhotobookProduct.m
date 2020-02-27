//
//  PhotobookProduct.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 16..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PhotobookProduct.h"
#import "Common.h"

@implementation Product
- (id)init {
    if (self = [super init]) {
        _photobook_type = 0;
        _idx = @"";
        _id = @"";
        _thumb = @"";
        _productcode = @"";
        _productname = @"";
        _minprice = @"";
        _discountminprice = @"";
    }
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end

//
@implementation PhotobookProduct

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
    _products = [[NSMutableArray alloc] init];
	// 신규 달력 포맷 : TODO : CHECK
	/*
	if ([Common info].photobook.product_type == PRODUCT_CALENDAR)
	    _thumb_url = URL_CALENDAR_THUMB_PATH;
	else
	    _thumb_url = URL_PRODUCT_THUMB_PATH;
	*/
    _thumb_url = URL_PRODUCT_THUMB_PATH;
}

- (BOOL)loadProduct:(int)producttype {
    [self clear];
    
	_baseproductcode = nil;

    NSString *url = URL_PHOTOBOOK_PRODUCT;
	if(producttype == PRODUCT_CALENDAR) {
		url = URL_CALENDAR_PRODUCT;
	}
    
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

// SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
- (BOOL)loadProductSub:(NSString *)productcode {
    [self clear];
    
	_baseproductcode = productcode;

    NSString *url = URL_PHOTOBOOK_PRODUCT_SUB;
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        //NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
        //NSLog(@">> photobook(calendar) theme info xml: %@", data);
        
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
    
    
    if ([elementName isEqualToString:@"product"]) {
        NSLog(@"SEOJIN %@ : %@", [attributeDict objectForKey:@"idx"], [attributeDict objectForKey:@"productcode"]);
    }
    
    if ([elementName isEqualToString:@"product"]) {
        Product *product = [[Product alloc] init];
        //[_products addObject:product];

        product.idx = [attributeDict objectForKey:@"idx"];
        product.id = [attributeDict objectForKey:@"id"];
        product.thumb = [attributeDict objectForKey:@"thumb"];
        product.productcode = [attributeDict objectForKey:@"productcode"];
//        if ([product.productcode isEqualToString:@"300221"]) {
//            product.productcode = @"300201";
//        }
        product.productname = [attributeDict objectForKey:@"productname"];
        product.minprice = [attributeDict objectForKey:@"minprice"];
        product.discountminprice = [attributeDict objectForKey:@"discountminprice"];
        product.openurl = [attributeDict objectForKey:@"openurl"];
        product.webviewurl = [attributeDict objectForKey:@"webviewurl"];
        product.producttype = [attributeDict objectForKey:@"producttype"];

        NSLog(@"product.webviewurl : %@", product.webviewurl);
        
        if ([elementName isEqualToString:@"premium"])
            product.photobook_type = 3;
        else if ([elementName isEqualToString:@"analogue"])
            product.photobook_type = 2;
        else if ([elementName isEqualToString:@"photobook"])
            product.photobook_type = 0;
        else if ([elementName isEqualToString:@"insta"])
            product.photobook_type = 1;

		// SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
		BOOL b = YES;
		if(_baseproductcode!=nil) {
			if ([_baseproductcode isEqualToString:@"300269"] && ![product.id isEqualToString:@"analogue"])
				b = NO;
			else if ([_baseproductcode isEqualToString:@"300268"] && ![product.id isEqualToString:@"insta"])
				b = NO;
		}
		if (b) {
	        [_products addObject:product];
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

@end
