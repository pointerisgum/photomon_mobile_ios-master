//
//  PhotobookProduct.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 16..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>

//
@interface Product : NSObject

@property (assign, nonatomic) int photobook_type;
@property (strong, nonatomic) NSString *idx;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *thumb;
@property (strong, nonatomic) NSString *productcode;
@property (strong, nonatomic) NSString *productname;
@property (strong, nonatomic) NSString *minprice;
@property (strong, nonatomic) NSString *discountminprice;
@property (strong, nonatomic) NSString *openurl;
@property (strong, nonatomic) NSString *webviewurl;
@property (strong, nonatomic) NSString *producttype;
@end

//
//
@interface PhotobookProduct : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic) NSString *thumb_url;
@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) NSString *baseproductcode;

- (BOOL)loadProduct:(int)producttype;
- (BOOL)loadProductSub:(NSString *)productcode;

@end
