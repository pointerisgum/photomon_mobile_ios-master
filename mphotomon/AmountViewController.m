//
//  AmountViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 15..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "AmountViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface AmountViewController ()

@end

@implementation AmountViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _count_array = [[NSMutableArray alloc] init];
    if (_type == 0) {
        [[PhotomonInfo sharedInfo] loadCartPreviewItemList:_type Param:_param];
        
        for (int i = 0; i < [PhotomonInfo sharedInfo].cartPreviewItemList.count; i++) {
            CartPreviewItem *item = [PhotomonInfo sharedInfo].cartPreviewItemList[i];
            [_count_array addObject: item.previewCnt];
        }
    }
    else {
        [_count_array addObject:_cart_item.pkgcnt];
    }
    _batch_count.text = @"1";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)getItemIndex:(id)sender {
    // iOS 7 이상은 super's super. 이전에는 그냥 super.
    if ([sender superview] != nil && [[sender superview] superview] != nil) {
        UITableViewCell *cell = (UITableViewCell*)[[sender superview] superview];
        if (cell != nil) {
            NSIndexPath *indexPath = [_table_view indexPathForCell:cell];
            if (indexPath) {
                return (int)indexPath.row;
            }
        }
    }
    return -1;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_type == 0) {
        return [PhotomonInfo sharedInfo].cartPreviewItemList.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AmountCell" forIndexPath:indexPath];

    UILabel *label_size = (UILabel *)[cell viewWithTag:101];
    UILabel *label_price = (UILabel *)[cell viewWithTag:102];
    UILabel *label_count = (UILabel *)[cell viewWithTag:103];
    
    if (_type == 0) {
        CartPreviewItem *item = [PhotomonInfo sharedInfo].cartPreviewItemList[indexPath.row];
        if (item != nil) {
            NSString *url = [item.previewImg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
                if (succeeded) {
                    UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                    imageview.image = [UIImage imageWithData:imageData];
                }
                else {
                    NSLog(@"preview_image is not downloaded.");
                }
            }];
            
            label_size.text = [NSString stringWithFormat:@"%@ (%@장)", item.previewSize, _count_array[indexPath.row]];

            int unit_price = [[Common info].photoprint getDiscountPrice:item.previewSize];
            int total_price = unit_price * [_count_array[indexPath.row] intValue];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:total_price]];

            label_count.text = [NSString stringWithFormat:@"%@", _count_array[indexPath.row]];
        }
    }
    else if (_type == 300) {
        NSString *url = [_cart_item.thumb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"preview_image is not downloaded.");
            }
        }];
        
        label_size.text = [NSString stringWithFormat:@"%@권", _count_array[indexPath.row]];

        int price_base = [_cart_item.price_base[0] intValue];
        int unit_price = [_cart_item getUnitPricePhotobook:price_base];
        int total_price = unit_price * [_count_array[indexPath.row] intValue];
        label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:total_price]];
        
        label_count.text = [NSString stringWithFormat:@"%@", _count_array[indexPath.row]];
    }
    else if (_type == 277 || _type == 367 || _type == 368 || _type == 369 || _type == 391 || _type == 392) {
        NSString *url = [_cart_item.thumb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"preview_image is not downloaded.");
            }
        }];

        label_size.text = [NSString stringWithFormat:@"%@권", _count_array[indexPath.row]];
        
        int unit_price = [_cart_item.unit_counts[0] intValue];
        int total_price = unit_price * [_count_array[indexPath.row] intValue];
        label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:total_price]];
        
        label_count.text = [NSString stringWithFormat:@"%@", _count_array[indexPath.row]];
    }
    else if (_type == 347 || _type == 142 || _type == 359) {
        NSString *url = [_cart_item.thumb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"preview_image is not downloaded.");
            }
        }];
        
        label_size.text = [NSString stringWithFormat:@"%@세트", _count_array[indexPath.row]];
        
        int unit_price = [_cart_item.price intValue];
        int total_price = unit_price * [_count_array[indexPath.row] intValue];
        label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:total_price]];
        
        label_count.text = [NSString stringWithFormat:@"%@", _count_array[indexPath.row]];
    }
    else if (_type == 239) {
        NSString *url = [_cart_item.thumb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"preview_image is not downloaded.");
            }
        }];
        
        label_size.text = [NSString stringWithFormat:@"%@장", _count_array[indexPath.row]];
        
        int unit_price = [_cart_item.price intValue];
        int total_price = unit_price * [_count_array[indexPath.row] intValue];
        label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:total_price]];
        
        label_count.text = [NSString stringWithFormat:@"%@", _count_array[indexPath.row]];
    }
    else if (_type == 350 || _type == 351 || _type == 356) {
        NSString *url = [_cart_item.thumb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"preview_image is not downloaded.");
            }
        }];
        
        label_size.text = [NSString stringWithFormat:@"%@개", _count_array[indexPath.row]];
        
        int unit_price = [_cart_item.price intValue];
        int total_price = unit_price * [_count_array[indexPath.row] intValue];
        label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:total_price]];
        
        label_count.text = [NSString stringWithFormat:@"%@", _count_array[indexPath.row]];
    }
    else if (_type == 357) {
        NSString *url = [_cart_item.thumb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"preview_image is not downloaded.");
            }
        }];
        
        label_size.text = [NSString stringWithFormat:@"%@개", _count_array[indexPath.row]];
        
        int unit_price = [_cart_item.price intValue];
        int total_price = unit_price * [_count_array[indexPath.row] intValue];
        label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:total_price]];
        
        label_count.text = [NSString stringWithFormat:@"%@", _count_array[indexPath.row]];
    }
    else if (_type == 360 || _type == 363) {
        NSString *url = [_cart_item.thumb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"preview_image is not downloaded.");
            }
        }];
        
        label_size.text = [NSString stringWithFormat:@"%@개", _count_array[indexPath.row]];
        
        int unit_price = [_cart_item.price intValue];
        int total_price = unit_price * [_count_array[indexPath.row] intValue];
        label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:total_price]];
        
        label_count.text = [NSString stringWithFormat:@"%@", _count_array[indexPath.row]];
    }
    else if (_type == 366) {
        NSString *url = [_cart_item.thumb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"preview_image is not downloaded.");
            }
        }];
        
        label_size.text = [NSString stringWithFormat:@"%@개", _count_array[indexPath.row]];
        
        int unit_price = [_cart_item.price intValue];
        int total_price = unit_price * [_count_array[indexPath.row] intValue];
        label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:total_price]];
        
        label_count.text = [NSString stringWithFormat:@"%@", _count_array[indexPath.row]];
    }
    else if (_type == 376 || _type == 377) {
        NSString *url = [_cart_item.thumb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"preview_image is not downloaded.");
            }
        }];
        
        label_size.text = [NSString stringWithFormat:@"%@개", _count_array[indexPath.row]];
        
        int unit_price = [_cart_item.price intValue];
        int total_price = unit_price * [_count_array[indexPath.row] intValue];
        label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:total_price]];
        
        label_count.text = [NSString stringWithFormat:@"%@", _count_array[indexPath.row]];
    }
    
    return cell;
}

- (IBAction)clickAddTotal:(id)sender {
    int cnt = [_batch_count.text intValue] + 1;
    if (_type == 376 || _type == 377) {
		if([_batch_count.text intValue] == 1) cnt = 2;
		else cnt = [_batch_count.text intValue] + 2;
	}
	if( cnt<=1 ) cnt = 1;

    _batch_count.text = [NSString stringWithFormat:@"%d", cnt];
    for (int i = 0; i < _count_array.count; i++) {
        _count_array[i] = _batch_count.text;
    }
    [_table_view reloadData];
}

- (IBAction)clickDelTotal:(id)sender {
    int cnt = [_batch_count.text intValue] - 1;
    if (_type == 376 || _type == 377) {
		if([_batch_count.text intValue] == 2) cnt = 1;
		else cnt = [_batch_count.text intValue] - 2;
	}
	if( cnt<=1 ) cnt = 1;

	if (cnt > 0) {
        _batch_count.text = [NSString stringWithFormat:@"%d", cnt];
        for (int i = 0; i < _count_array.count; i++) {
            _count_array[i] = _batch_count.text;
        }
        [_table_view reloadData];
    }
}

- (IBAction)clickAdd:(id)sender {
    int sel = [self getItemIndex:sender];
    if (sel >= 0) {
        int cnt = [_count_array[sel] intValue] + 1;
		if (_type == 376 || _type == 377) {
			if([_count_array[sel] intValue] == 1) cnt = 2;
			else cnt = [_count_array[sel] intValue] + 2;
		}
		if( cnt<=1 ) cnt = 1;

		_count_array[sel] = [NSString stringWithFormat:@"%d", cnt];
        [_table_view reloadData];
    }
}

- (IBAction)clickDel:(id)sender {
    int sel = [self getItemIndex:sender];
    if (sel >= 0) {
        int cnt = [_count_array[sel] intValue] - 1;
		if (_type == 376 || _type == 377) {
			if([_batch_count.text intValue] == 2) cnt = 1;
			else cnt = [_count_array[sel] intValue] - 2;
		}
		if( cnt<=1 ) cnt = 1;

		if (cnt > 0) {
            _count_array[sel] = [NSString stringWithFormat:@"%d", cnt];
            [_table_view reloadData];
        }
    }
}

- (IBAction)done:(id)sender {
    BOOL is_fail = FALSE;
    
    int total_price = 0;
    if (_type == 0) {
        BOOL is_modified = FALSE;
        for (int i = 0; i < [PhotomonInfo sharedInfo].cartPreviewItemList.count; i++) {
            CartPreviewItem *item = [PhotomonInfo sharedInfo].cartPreviewItemList[i];
            if (item != nil && ![item.previewCnt isEqualToString:_count_array[i]]) {
                
                if (![[PhotomonInfo sharedInfo] updateCartPreviewItemList:_type Param:_param Idx:item.idx Cnt:_count_array[i]]) {
                    is_fail = TRUE;
                    break;
                }
                is_modified = TRUE;
            }
            int unit_price = [[Common info].photoprint getDiscountPrice:item.previewSize];
            total_price += (unit_price * [_count_array[i] intValue]);
        }
        
        if (!is_fail && is_modified) {
            NSString *price_str = [NSString stringWithFormat:@"%d", total_price];
            if (![[PhotomonInfo sharedInfo] updateCartPreviewItemListPrice:_type Param:_param Price:price_str]) {
                is_fail = TRUE;
            }
        }
    }
    else {
        if (_type == 300) {
            if (_cart_item != nil && ![_cart_item.pkgcnt isEqualToString:_count_array[0]]) {
                int price_base = [_cart_item.price_base[0] intValue];
                int unit_price = [_cart_item getUnitPricePhotobook:price_base];
                total_price = unit_price * [_count_array[0] intValue];
            }
        }
        else if (_type == 277 || _type == 367 || _type == 368 || _type == 369 || _type == 391 || _type == 392) {
            if (_cart_item != nil && ![_cart_item.pkgcnt isEqualToString:_count_array[0]]) {
                int unit_price = [_cart_item.unit_counts[0] intValue]; // unit_counts: 달력에서는 할인 후 가격으로 사용.
                total_price = unit_price * [_count_array[0] intValue];
            }
        }
        else if (_type == 347 || _type == 142 || _type == 359) {
            if (_cart_item != nil && ![_cart_item.pkgcnt isEqualToString:_count_array[0]]) {
                int unit_price = [_cart_item.price intValue];
                total_price = unit_price * [_count_array[0] intValue];
            }
        }
        else if (_type == 350 || _type == 351 || _type == 356) {
            if (_cart_item != nil && ![_cart_item.pkgcnt isEqualToString:_count_array[0]]) {
                int unit_price = [_cart_item.price intValue];
                total_price = unit_price * [_count_array[0] intValue];
            }
        }
        else if (_type == 357) {
            if (_cart_item != nil && ![_cart_item.pkgcnt isEqualToString:_count_array[0]]) {
                int unit_price = [_cart_item.price intValue];
                total_price = unit_price * [_count_array[0] intValue];
            }
        }
        else if (_type == 360 || _type == 363) {
            if (_cart_item != nil && ![_cart_item.pkgcnt isEqualToString:_count_array[0]]) {
                int unit_price = [_cart_item.price intValue];
                total_price = unit_price * [_count_array[0] intValue];
            }
        }
        else if (_type == 239) {
            if (_cart_item != nil && ![_cart_item.pkgcnt isEqualToString:_count_array[0]]) {
                int unit_price = [_cart_item.price intValue];
                total_price = unit_price * [_count_array[0] intValue];
            }
        }
        else if (_type == 366) {
            if (_cart_item != nil && ![_cart_item.pkgcnt isEqualToString:_count_array[0]]) {
                int unit_price = [_cart_item.price intValue];
                total_price = unit_price * [_count_array[0] intValue];
            }
        }
        else if (_type == 376 || _type == 377) {
            if (_cart_item != nil && ![_cart_item.pkgcnt isEqualToString:_count_array[0]]) {
                int unit_price = [_cart_item.price intValue];
                total_price = unit_price * [_count_array[0] intValue];
            }
        }
        else {
            NSAssert(NO, @"AmountViewController.m: done: type mismatch");
        }
        _cart_item.pkgcnt = _count_array[0];
        _cart_item.price = [NSString stringWithFormat:@"%d", total_price];
        
        if (![[PhotomonInfo sharedInfo] updateCartPreviewItemList:_type Param:_param Idx:_cart_item.price Cnt:_cart_item.pkgcnt]) {
            is_fail = TRUE;
        }
    }

    if (is_fail) {
        [[Common info] alert:self Msg:@"인터넷 연결이 원할하지 않습니다.\n잠시 후에 다시 시도해 보세요."];
    }
    else {
        [[PhotomonInfo sharedInfo] loadCartList];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
