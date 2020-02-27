//
//  PayCheckViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 16..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PayCheckViewController.h"
#import "CouponViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@implementation DeliveryItem
- (id)init {
    if (self = [super init]) {
        _recvname = @"";
        _recvamt = @"";
    }
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end


//
@interface PayCheckViewController ()

@end

@implementation PayCheckViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"PayCheck"];

    // 쿠폰 슬롯.
    _useCoupon = [[NSMutableArray alloc] init];
    for (int i = 0; i < [PhotomonInfo sharedInfo].payList.count; i++) {
        CouponItem *couponItem = [[CouponItem alloc] init];
        [_useCoupon addObject:couponItem];
    }
    
    // 배송정보 슬롯.
    _deliveryInfo = [[NSMutableArray alloc] init];
    for (int i = 0; i < [PhotomonInfo sharedInfo].payList.count; i++) {
        CartItem *cart_item = [PhotomonInfo sharedInfo].payList[i];
        
        DeliveryItem *delivery_item = nil;
        for (int j = 0; j < _deliveryInfo.count; j++) {
            DeliveryItem *temp_delivery = _deliveryInfo[j];
            if ([temp_delivery.recvname isEqualToString:cart_item.recvname]) {
                if ([cart_item.recvamt intValue] < [temp_delivery.recvamt intValue]) { // 최소값 선택
                    temp_delivery.recvamt = cart_item.recvamt;
                }
                delivery_item = temp_delivery;
                break;
            }
        }
        if (delivery_item == nil) {
            DeliveryItem *new_delivery = [[DeliveryItem alloc] init];
            new_delivery.recvname = cart_item.recvname;
            new_delivery.recvamt = cart_item.recvamt;
            [_deliveryInfo addObject:new_delivery];
        }
    }
    for (DeliveryItem *delivery_item in _deliveryInfo) {
        NSLog(@"%@ 배송료: %@", delivery_item.recvname, delivery_item.recvamt);
    }

    [self updateInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [Analysis firAnalyticsWithScreenName:@"PayCheck" ScreenClass:[self.classForCoder description]];
    [self updateInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isUsedPhotobookCoupon {
    for (CouponItem *coupon_item in _useCoupon) {
        if (coupon_item.couponname.length > 0) {
            return TRUE;
        }
    }
    return FALSE;
}

- (int)getPhotomonDeliveryCost {
    int delivery_cost = 0;
    for (DeliveryItem *delivery_item in _deliveryInfo) {
        if ([delivery_item.recvname isEqualToString:@"포토몬"]) {
            
            int sum_price = 0;
            for (int i = 0; i < [PhotomonInfo sharedInfo].payList.count; i++) {
                CartItem *cart_item = [PhotomonInfo sharedInfo].payList[i];
                CouponItem *coupon_item = _useCoupon[i];
                if ([delivery_item.recvname isEqualToString:cart_item.recvname]) {
                    sum_price += [self getUnitPrice:cart_item ApplyCoupon:coupon_item];
                }
            }
            NSLog(@"%@ 가격합계: %d", delivery_item.recvname, sum_price);
            
            if (sum_price < [Common info].connection.delivery_free_cost) {
                delivery_cost += [delivery_item.recvamt intValue];
            }
            break;
        }
    }
    return delivery_cost;
}

- (int)getOuterDeliveryCost {
    int delivery_cost = 0;
    for (DeliveryItem *delivery_item in _deliveryInfo) {
        if (![delivery_item.recvname isEqualToString:@"포토몬"]) {
            
            int sum_price = 0;
            for (int i = 0; i < [PhotomonInfo sharedInfo].payList.count; i++) {
                CartItem *cart_item = [PhotomonInfo sharedInfo].payList[i];
                CouponItem *coupon_item = _useCoupon[i];
                if ([delivery_item.recvname isEqualToString:cart_item.recvname]) {
                    sum_price += [self getUnitPrice:cart_item ApplyCoupon:coupon_item];
                }
            }
            NSLog(@"%@ 가격합계: %d", delivery_item.recvname, sum_price);
            
            if (sum_price < [Common info].connection.delivery_free_cost) {
                delivery_cost += [delivery_item.recvamt intValue];
            }
        }
    }
    return delivery_cost;
}

- (int)getTotalPrice {
    int total_price = 0;
    for (int i = 0; i < [PhotomonInfo sharedInfo].payList.count; i++) {
        
        CartItem *item = [PhotomonInfo sharedInfo].payList[i];
        CouponItem *coupon_item = _useCoupon[i];
        
        total_price += [self getUnitPrice:item ApplyCoupon:coupon_item];
    }
    return total_price;
}

- (int)getUnitPrice:(CartItem *)item ApplyCoupon:(CouponItem *)coupon_item {
    int unit_price = 0;
    if ([item.intnum isEqualToString:@"0"]) {
        unit_price = [item getSumPricePrint];
    }
    // SJYANG
    else if ([item.intnum isEqualToString:@"300"] || [item.intnum isEqualToString:@"362"] || [item.intnum isEqualToString:@"120"]) {
        if (coupon_item) { // 쿠폰을 사용하면, 포토북이나 캘린더는 원가에서 할인해야 하므로 원가를 리턴한다.
            unit_price = ((coupon_item.couponname.length > 0) ? [item getSumPricePhotobookOriginal] : [item getSumPricePhotobook]);
        }
        else { // 무조건 원가를 리턴.
            unit_price = [item getSumPricePhotobookOriginal];
        }
    }
    else if ([item.intnum isEqualToString:@"277"] || [item.intnum isEqualToString:@"367"] || [item.intnum isEqualToString:@"368"] || [item.intnum isEqualToString:@"369"] || [item.intnum isEqualToString:@"391"] || [item.intnum isEqualToString:@"392"] || [item.intnum isEqualToString:@"393"]) {
        if (coupon_item) { // 쿠폰을 사용하면, 포토북이나 캘린더는 원가에서 할인해야 하므로 원가를 리턴한다.
            unit_price = ((coupon_item.couponname.length > 0) ? [item getSumPriceCalendarOriginal] : [item getSumPriceCalendar]);
        }
        else { // 무조건 원가를 리턴.
            unit_price = [item getSumPriceCalendarOriginal];
        }
    }
    else if ([item.intnum isEqualToString:@"346"]) {
        unit_price = [item getPrice];
    }
    else if ([item.intnum isEqualToString:@"347"]) {
        unit_price = [item getSumPricePolaroid];
    }
    else if ([item.intnum isEqualToString:@"376"] || [item.intnum isEqualToString:@"377"]) {
        unit_price = [item getSumPriceCard];
    }
    else if ([item.intnum isEqualToString:@"142"] || [item.intnum isEqualToString:@"17"]) {
        unit_price = [item getSumPrice];
    }
    else if ([item.intnum isEqualToString:@"350"] || [item.intnum isEqualToString:@"351"] || [item.intnum isEqualToString:@"356"]) {
        unit_price = [item getSumPriceFrame];
    }
    else if ([item.intnum isEqualToString:@"357"]) {
        unit_price = [item getSumPriceGift];
    }
    else if ([item.intnum isEqualToString:@"360"] || [item.intnum isEqualToString:@"363"]) {
        unit_price = [item getSumPriceGift];
    }
    else if ([item.intnum isEqualToString:@"359"]) {
        unit_price = [item getSumPriceGift];
    }
	else if ([item.intnum isEqualToString:@"239"]) { // 증명사진인화
        unit_price = [item getSumPriceIDPhotos];
	}
    else if ([item.intnum isEqualToString:@"366"]) {
        unit_price = [item getSumPriceBaby];
    }
    return unit_price;
}

- (int)getTotalCouponDC {
    int total_coupon_dc = 0;

    for (int i = 0; i < [PhotomonInfo sharedInfo].payList.count; i++) {
        CouponItem *coupon_item = _useCoupon[i];
        if (coupon_item.couponname.length > 0) {
            CartItem *item = [PhotomonInfo sharedInfo].payList[i];
            
            int unit_price = [self getUnitPrice:item ApplyCoupon:nil];
            int coupon_dc = [coupon_item.discount intValue];
            
            if (coupon_dc < 100) { //.......................... 100 미만은 %로 계산해야 함.
                float dc_rate = (float)coupon_dc / 100.0f;
                coupon_dc = (int)(unit_price * dc_rate);
            }
            if ((unit_price - coupon_dc) < 0) { //............. 할인가가 상품가를 넘지 못하게.
                coupon_dc = unit_price;
            }
            total_coupon_dc += coupon_dc;
        }
    }
    return total_coupon_dc;
}

- (void)updateInfo {
    int total_price = [self getTotalPrice];
    int coupon_dc = [self getTotalCouponDC];
    int delivery_cost = [self getPhotomonDeliveryCost];
    int out_delivery_cost = [self getOuterDeliveryCost];

    int price_sum = total_price - coupon_dc;
    if (price_sum < 0) price_sum = 0;

    _sum_label.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:total_price]];
    _coupon_label.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:coupon_dc]];
    _delivery_label.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:delivery_cost]];
    _out_delivery_label.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:out_delivery_cost]];
    _totalprice_label.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:(price_sum + delivery_cost + out_delivery_cost)]];

    [_table_view reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [PhotomonInfo sharedInfo].payList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PayCheckCell" forIndexPath:indexPath];
    
    UILabel *label_size = (UILabel *)[cell viewWithTag:101];
    UILabel *label_price = (UILabel *)[cell viewWithTag:102];
    UILabel *label_discount = (UILabel *)[cell viewWithTag:103];
    UIButton *coupon_button = (UIButton *)[cell viewWithTag:105];

    CartItem *item = [PhotomonInfo sharedInfo].payList[indexPath.row];
    if (item != nil) {
        NSString *url = [item.thumb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"cart's thumbnail_image is not downloaded.");
            }
        }];

        if ([item.intnum isEqualToString:@"0"]) {
            label_size.text = [NSString stringWithFormat:@"사진인화 (%@장)", item.totalCnt];
            //label_price.text = [NSString stringWithFormat:@"%d원", [item getSumPriceOriginal]];
            //label_discount.text = [NSString stringWithFormat:@"%d원", [item getSumPrice]];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPricePrintOriginal]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPricePrint]]];
        }
        // SJYANG
        else if ([item.intnum isEqualToString:@"300"] || [item.intnum isEqualToString:@"362"] || [item.intnum isEqualToString:@"120"]) {
            label_size.text = [NSString stringWithFormat:@"%@ (%@권)", item.cart_print, item.pkgcnt];
            //label_price.text = [NSString stringWithFormat:@"%d원", [item getSumPricePhotobookOriginal]];
            //label_discount.text = [NSString stringWithFormat:@"%d원", [item getSumPricePhotobook]];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPricePhotobookOriginal]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPricePhotobook]]];
        }
        else if ([item.intnum isEqualToString:@"277"] || [item.intnum isEqualToString:@"367"] || [item.intnum isEqualToString:@"368"] || [item.intnum isEqualToString:@"369"] || [item.intnum isEqualToString:@"391"] || [item.intnum isEqualToString:@"392"] || [item.intnum isEqualToString:@"393"]) {
            label_size.text = [NSString stringWithFormat:@"%@ (%@권)", item.cart_print, item.pkgcnt];
            //label_price.text = [NSString stringWithFormat:@"%d원", [item getSumPricePhotobookOriginal]];
            //label_discount.text = [NSString stringWithFormat:@"%d원", [item getSumPricePhotobook]];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceCalendarOriginal]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceCalendar]]];
        }
        else if ([item.intnum isEqualToString:@"346"]) {
            label_size.text = [NSString stringWithFormat:@"%@", item.cart_print];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getPrice]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getPrice]]];
        }
        else if ([item.intnum isEqualToString:@"347"]) {
            label_size.text = [NSString stringWithFormat:@"%@ (%@세트)", item.cart_print, item.pkgcnt];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPricePolaroidOriginal]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPricePolaroid]]];
        }
        else if ([item.intnum isEqualToString:@"142"] || [item.intnum isEqualToString:@"17"]) {
            label_size.text = [NSString stringWithFormat:@"%@ (%@세트)", item.cart_print, item.pkgcnt];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPrice]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPrice]]];
        }
        else if ([item.intnum isEqualToString:@"350"] || [item.intnum isEqualToString:@"351"] || [item.intnum isEqualToString:@"356"]) {
            label_size.text = [NSString stringWithFormat:@"%@ (%@개)", item.cart_print, item.pkgcnt];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceFrameOriginal]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceFrame]]];
        }
        else if ([item.intnum isEqualToString:@"357"]) {
            label_size.text = [NSString stringWithFormat:@"%@ (%@개)", item.cart_print, item.pkgcnt];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceGiftOriginal]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceGift]]];
        }
        else if ([item.intnum isEqualToString:@"360"] || [item.intnum isEqualToString:@"363"]) {
            label_size.text = [NSString stringWithFormat:@"%@ (%@개)", item.cart_print, item.pkgcnt];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceGiftOriginal]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceGift]]];
        }
        else if ([item.intnum isEqualToString:@"359"]) {
            label_size.text = [NSString stringWithFormat:@"%@ (%@세트)", item.cart_print, item.pkgcnt];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceGiftOriginal]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceGift]]];
        }
        else if ([item.intnum isEqualToString:@"239"]) {
            label_size.text = [NSString stringWithFormat:@"%@ (%@장)", item.cart_print, item.pkgcnt];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPrice]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPrice]]];
        }
        else if ([item.intnum isEqualToString:@"366"]) {
            label_size.text = [NSString stringWithFormat:@"%@ (%@장)", item.cart_print, item.pkgcnt];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceBabyOriginal]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceBaby]]];
        }
        else if ([item.intnum isEqualToString:@"376"] || [item.intnum isEqualToString:@"377"]) {
            label_size.text = [NSString stringWithFormat:@"%@ (%@장)", item.cart_print, item.pkgcnt];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceBabyOriginal]]];
            label_discount.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item getSumPriceBaby]]];
        }
        else {
            label_size.text = @"";
            label_price.text = @"";
            label_discount.text = @"";
        }
        
        //
        CouponItem *coupon_item = _useCoupon[indexPath.row];
        if (coupon_item.couponname.length > 0) {
            [coupon_button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
        else {
            [coupon_button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    int total_price = [self getTotalPrice];
    int coupon_dc = [self getTotalCouponDC];
    //int delivery_cost = (total_price < [Common info].connection.delivery_free_cost) ? 2500 : 0;
    int delivery_cost = [self getPhotomonDeliveryCost];
    int out_delivery_cost = [self getOuterDeliveryCost];
    
    int price_sum = total_price - coupon_dc;
    if (price_sum < 0) price_sum = 0;
    
    [PhotomonInfo sharedInfo].payment.delivery_type = @"3"; // 택배
    [PhotomonInfo sharedInfo].payment.delivery_cost = [NSString stringWithFormat:@"%d", delivery_cost + out_delivery_cost];
    [PhotomonInfo sharedInfo].payment.total_price = [NSString stringWithFormat:@"%d", price_sum];

    [PhotomonInfo sharedInfo].payment.p_oid = @"";
    [PhotomonInfo sharedInfo].payment.coupon_vals = @"";
    [PhotomonInfo sharedInfo].payment.coupon_amts = @"";
    [PhotomonInfo sharedInfo].payment.coupon_idxs = @"";

    NSString *cartIndices = @"";
    for (int i = 0; i < [PhotomonInfo sharedInfo].payList.count; i++) {
        CartItem *item = [PhotomonInfo sharedInfo].payList[i];
        if (i <= 0) {
            cartIndices = [NSString stringWithFormat:@"%@", item.cart_index];
        }
        else {
            cartIndices = [NSString stringWithFormat:@"%@,%@", cartIndices, item.cart_index];
        }
    }
    [PhotomonInfo sharedInfo].payment.cart_indices = cartIndices;
    
    NSString *goods = @"";
    for (int i = 0; i < [PhotomonInfo sharedInfo].payList.count; i++) {
        NSString *item_type = @"unknown";
        CartItem *item = [PhotomonInfo sharedInfo].payList[i];
        
        if ([item.intnum isEqualToString:@"0"]) {
            item_type = @"사진인화";
        }
        else {
            item_type = item.cart_print;
        }
        
        if (i <= 0) {
            goods = [NSString stringWithFormat:@"%@", item_type];
        }
        else {
            goods = [NSString stringWithFormat:@"%@/%@", goods, item_type];
        }
    }
    [PhotomonInfo sharedInfo].payment.goods = goods;
    
    NSString *couponVals = @"";
    NSString *couponAmts = @"";
    NSString *couponIdxs = @"";
    for (int i = 0; i < _useCoupon.count; i++) {
        CouponItem *coupon_item = _useCoupon[i];
        if (coupon_item.code.length > 0) {
            
            CartItem *cart_item = [PhotomonInfo sharedInfo].payList[i];
            
            int unit_price = [self getUnitPrice:cart_item ApplyCoupon:nil];
            int coupon_dc = [coupon_item.discount intValue];
            
            if (coupon_dc < 100) { //.......................... 100 미만은 %로 계산해야 함.
                float dc_rate = (float)coupon_dc / 100.0f;
                coupon_dc = (int)(unit_price * dc_rate);
            }
            if ((unit_price - coupon_dc) < 0) { //............. 할인가가 상품가를 넘지 못하게.
                coupon_dc = unit_price;
            }
            NSString *discount_str = [NSString stringWithFormat:@"%d", coupon_dc];
            
            if (couponVals.length <= 0) {
                couponVals = [NSString stringWithFormat:@"%@", coupon_item.code];
                couponAmts = [NSString stringWithFormat:@"%@", discount_str];
                couponIdxs = [NSString stringWithFormat:@"%@", cart_item.cart_index];
            }
            else {
                couponVals = [NSString stringWithFormat:@"%@|%@", couponVals, coupon_item.code];
                couponAmts = [NSString stringWithFormat:@"%@|%@", couponAmts, discount_str];
                couponIdxs = [NSString stringWithFormat:@"%@|%@", couponIdxs, cart_item.cart_index];
            }
        }
    }
    [PhotomonInfo sharedInfo].payment.coupon_vals = couponVals;
    [PhotomonInfo sharedInfo].payment.coupon_amts = couponAmts;
    [PhotomonInfo sharedInfo].payment.coupon_idxs = couponIdxs;
}

- (IBAction)clickCoupon:(id)sender {
    if ([sender superview] != nil) {
        // iOS 7 이상은 super's super. 이전에는 그냥 super.
        if ([[sender superview] superview] != nil) {
            UITableViewCell *cell = (UITableViewCell*)[[sender superview] superview];
            if (cell != nil) {
                NSIndexPath *indexPath = [self.table_view indexPathForCell:cell];
                if (indexPath) {
                    CartItem *item = [PhotomonInfo sharedInfo].payList[indexPath.row];
                    if (item) {
                        NSLog(@"selected item: intnum(%@), seqnum(%@), cartidx(%@)", item.intnum, item.seq, item.cart_index);
                        CouponViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CouponPage"];
                        vc.sender = self;
                        vc.sel_index = (int)indexPath.row;
                        vc.sel_intnum = item.intnum;
                        vc.sel_seqnum = item.seq;
                        vc.sel_cartidx = item.cart_index;
                        [self presentViewController:vc animated:YES completion:nil];
                    }
                }
            }
        }
    }
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
