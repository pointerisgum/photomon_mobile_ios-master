//
//  IDPhotosProduct.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 16..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>

//
@interface IDPhotosProductUnit : NSObject

@property (strong, nonatomic) NSString *item_product_code;
@property (strong, nonatomic) NSString *item_product_name;
@property (strong, nonatomic) NSString *item_product_cm;
@property (strong, nonatomic) NSString *item_product_count;
@property (strong, nonatomic) NSString *item_product_price;
@property (strong, nonatomic) NSString *item_product_image;
@property (strong, nonatomic) NSString *item_size_str;

@end

//
//
@interface IDPhotosProduct : NSObject

@property (strong, nonatomic) NSString *thumb_url;
@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) IDPhotosProductUnit *product;
@property (strong, nonatomic) NSString *product_id;

- (BOOL)loadProduct;

@end
