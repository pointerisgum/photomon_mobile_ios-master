//
//  IDPhotosProduct.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 16..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "IDPhotosProduct.h"
#import "Common.h"

@implementation IDPhotosProductUnit
- (id)init {
    if (self = [super init]) {
		_item_product_code = @"";
		_item_product_name = @"";
		_item_product_cm = @"";
		_item_product_count = @"";
		_item_product_price = @"";
		_item_product_image = @"";
		_item_size_str = @"";
    }
    return self;
}
- (void)dealloc {
}
@end

@implementation IDPhotosProduct

- (id)init {
    if (self = [super init]) {
        [self clear];
    }
    return self;
}

- (void)dealloc {
}

- (void)clear {
    _products = [[NSMutableArray alloc] init];
    _thumb_url = URL_IDPHOTOS_THUMB_PATH;
	_product = nil;
	_product_id = @"";
}

- (BOOL)loadProduct {
    [self clear];

    NSString *url = URL_IDPHOTOS_PRODUCT;

    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(url, nil)]];
    if (ret_val != nil) {
        NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];

        NSArray *row_array = [data componentsSeparatedByString:@"|"];
		int cnt = 0;
        for (NSString *line in row_array) {
			@try {
				if( cnt==1 ) {
					[Common info].idphotos.upload_url = line;
				}
				else if( cnt > 1 ) {
					NSArray *col_array = [line componentsSeparatedByString:@";"];

					if( [col_array count] > 5 ) {
						IDPhotosProductUnit *product = [[IDPhotosProductUnit alloc] init];

						product.item_product_code = col_array[5];
						product.item_product_name = col_array[6];
						product.item_product_cm = col_array[7];
						product.item_product_count = col_array[8];
						product.item_product_price = col_array[9];
						product.item_product_image = col_array[13];
						product.item_size_str = col_array[14];

						[_products addObject:product];
					}
				}
				cnt++;
			}
			@catch (NSException *e) {
			}
        }

		return TRUE;
	}
    return FALSE;
}

@end
