//
//  CartTableViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 2..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "CartTableViewController.h"
#import "AmountViewController.h"
#import "PreViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface CartTableViewController ()

@end

@implementation CartTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"CartList"];

    if (![[PhotomonInfo sharedInfo] loadCartSession] || ![[PhotomonInfo sharedInfo] loadCartList]) {
        [[PhotomonInfo sharedInfo] alertMsg:@"장바구니를 가져올 수 없습니다.\n잠시후, 다시 시도해 보세요."];
        [self dismissViewControllerAnimated:YES completion:nil];
    }

    _normal_image = [UIImage imageNamed:@"common_check_off.png"];
    _press_image = [UIImage imageNamed:@"common_check_on.png"];
    [_checkall_button setImage:_normal_image forState:UIControlStateNormal];
    [_checkall_button setImage:_press_image forState:UIControlStateSelected];
    _checkall_button.selected = NO;
    
    [self updateInfo];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"CartList" ScreenClass:[self.classForCoder description]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateInfo];
    [_table_view reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)updateInfo {
    int total_count = 0;
    int total_price = 0;
    for (CartItem *item in [PhotomonInfo sharedInfo].cartList) {
        if (item.is_selected) {
            total_count++;
            NSLog(@"item.intnum : %@", item.intnum);
            if ([item.intnum isEqualToString:@"0"]) { // 사진인화
                total_price += [item getSumPricePrint];
            }
            // SJYANG
            else if ([item.intnum isEqualToString:@"300"] || [item.intnum isEqualToString:@"362"] || [item.intnum isEqualToString:@"120"]) { // 포토북
                total_price += [item getSumPricePhotobook];
            }
			// SJYANG : 2018 달력
			else if ([item.intnum isEqualToString:@"277"] || [item.intnum isEqualToString:@"367"] || [item.intnum isEqualToString:@"368"] || [item.intnum isEqualToString:@"369"] || [item.intnum isEqualToString:@"391"] || [item.intnum isEqualToString:@"392"] || [item.intnum isEqualToString:@"393"]) { // 달력
                total_price += [item getSumPriceCalendar];
            }
            else if ([item.intnum isEqualToString:@"346"]) { // 수능스티커
                total_price += [item getPrice];
            }
            else if ([item.intnum isEqualToString:@"347"]) { // 폴라로이드
                total_price += [item getSumPrice];
            }
            else if ([item.intnum isEqualToString:@"142"]) { // 마끈집게세트(폴라로이드옵션)
                total_price += [item getSumPrice];
            }
            else if ([item.intnum isEqualToString:@"350"] || [item.intnum isEqualToString:@"351"] || [item.intnum isEqualToString:@"356"]) { // 액자
                total_price += [item getSumPrice];
            }
            else if ([item.intnum isEqualToString:@"357"]) { // 머그컵
                total_price += [item getSumPrice];
            }
            else if ([item.intnum isEqualToString:@"360"] || [item.intnum isEqualToString:@"363"]) { // 폰케이스
                total_price += [item getSumPrice];
            }
            else if ([item.intnum isEqualToString:@"17"]) { // 선물박스(포토엽서옵션)
                total_price += [item getSumPrice];
            }
            else if ([item.intnum isEqualToString:@"359"]) { // 포토엽서
                total_price += [item getSumPrice];
            }
            else if ([item.intnum isEqualToString:@"239"]) { // 증명사진인화
                total_price += [item getSumPrice];
            }
            else if ([item.intnum isEqualToString:@"366"]) { // 베이비
                total_price += [item getSumPrice];
            }
            else if ([item.intnum isEqualToString:@"376"] || [item.intnum isEqualToString:@"377"]) { // 포토카드
                total_price += [item getSumPrice];
            }
        }
    }
    _selcount_label.text = [NSString stringWithFormat:@"%d/%lu", total_count, (unsigned long)[PhotomonInfo sharedInfo].cartList.count];
    //_totalprice_label.text = [NSString stringWithFormat:@"%d원", total_price];
    _totalprice_label.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:total_price]];
    _checkall_button.selected = (total_count > 0 && total_count >= [PhotomonInfo sharedInfo].cartList.count);
    return total_count;
}

- (CartItem *)getSelCartItem:(id)sender {
    // iOS 7 이상은 super's super. 이전에는 그냥 super.
    if ([sender superview] != nil && [[sender superview] superview] != nil) {
        UITableViewCell *cell = (UITableViewCell*)[[sender superview] superview];
        if (cell != nil) {
            NSIndexPath *indexPath = [_table_view indexPathForCell:cell];
            if (indexPath) {
                CartItem *item = [PhotomonInfo sharedInfo].cartList[indexPath.row];
                if (item != nil) {
                    return item;
                }
            }
        }
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [PhotomonInfo sharedInfo].cartList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CartCell" forIndexPath:indexPath];

    CartItem *item = [PhotomonInfo sharedInfo].cartList[indexPath.row];
    if (item != nil) {
        NSString *url = [item.thumb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:501];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"cart's thumbnail_image is not downloaded.");
            }
        }];

        UILabel *label_print = (UILabel *)[cell viewWithTag:502];
        UILabel *label_amount = (UILabel *)[cell viewWithTag:503];
        UILabel *label_price = (UILabel *)[cell viewWithTag:504];
        
        if ([item.intnum isEqualToString:@"0"]) {
            label_print.text = @"사진인화";
            label_amount.text = [NSString stringWithFormat:@"사진%d장 인화%@장", (int)item.unit_types.count, item.totalCnt];
            //label_price.text = [NSString stringWithFormat:@"%d원", [item getSumPrice]];
            int sum_price = [item getSumPricePrint];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
            item.price = [NSString stringWithFormat:@"%d", sum_price];
        }
        // SJYANG
        else if ([item.intnum isEqualToString:@"300"] || [item.intnum isEqualToString:@"362"] || [item.intnum isEqualToString:@"120"]) {
            label_print.text = item.cart_print;
            label_amount.text = [NSString stringWithFormat:@"%@ %@권", item.g_size, item.pkgcnt];
            //label_price.text = [NSString stringWithFormat:@"%d원", [item getSumPricePhotobook]];
            int sum_price = [item getSumPricePhotobook];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
            item.price = [NSString stringWithFormat:@"%d", sum_price];
        }
        else if ([item.intnum isEqualToString:@"277"] || [item.intnum isEqualToString:@"367"] || [item.intnum isEqualToString:@"368"] || [item.intnum isEqualToString:@"369"] || [item.intnum isEqualToString:@"391"] || [item.intnum isEqualToString:@"392"] || [item.intnum isEqualToString:@"393"]) {
            label_print.text = item.cart_print;
            label_amount.text = [NSString stringWithFormat:@"%@ %@권", item.g_size, item.pkgcnt];
            int sum_price = [item getSumPriceCalendar];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
            item.price = [NSString stringWithFormat:@"%d", sum_price];
        }
        else if ([item.intnum isEqualToString:@"346"]) {
            label_print.text = item.cart_print;
            label_amount.text = @"1매";
            int sum_price = [item getPrice];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
            item.price = [NSString stringWithFormat:@"%d", sum_price];
        }
        else if ([item.intnum isEqualToString:@"347"]) {
            label_print.text = item.cart_print;
            label_amount.text = [NSString stringWithFormat:@"%@세트", item.pkgcnt];
            int sum_price = [item getSumPrice];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
        }
        else if ([item.intnum isEqualToString:@"142"] || [item.intnum isEqualToString:@"17"]) {
            label_print.text = item.cart_print;
            label_amount.text = [NSString stringWithFormat:@"%@세트", item.pkgcnt];
            int sum_price = [item getSumPrice];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
        }
        else if ([item.intnum isEqualToString:@"350"] || [item.intnum isEqualToString:@"351"] || [item.intnum isEqualToString:@"356"] || [item.intnum isEqualToString:@"357"]) {
            label_print.text = item.cart_print;
            label_amount.text = [NSString stringWithFormat:@"%@개", item.pkgcnt];
            int sum_price = [item getSumPrice];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
        }
        else if ([item.intnum isEqualToString:@"360"]) {
            label_print.text = item.cart_print;
            label_amount.text = [NSString stringWithFormat:@"%@개", item.pkgcnt];
            int sum_price = [item getSumPrice];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
        }
        else if ([item.intnum isEqualToString:@"363"]) {
            label_print.text = item.cart_print;
            label_amount.text = [NSString stringWithFormat:@"%@개", item.pkgcnt];
            int sum_price = [item getSumPrice];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
        }
        else if ([item.intnum isEqualToString:@"359"]) {
            label_print.text = item.cart_print;
            label_amount.text = [NSString stringWithFormat:@"%@세트", item.pkgcnt];
            int sum_price = [item getSumPrice];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
        }
        else if ([item.intnum isEqualToString:@"239"]) {
            label_print.text = item.cart_print;
            label_amount.text = [NSString stringWithFormat:@"%@장", item.pkgcnt];
            int sum_price = [item getSumPrice];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
        }
        else if ([item.intnum isEqualToString:@"366"]) {
            label_print.text = item.cart_print;
            label_amount.text = [NSString stringWithFormat:@"%@개", item.pkgcnt];
            int sum_price = [item getSumPrice];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
        }
        else if ([item.intnum isEqualToString:@"376"] || [item.intnum isEqualToString:@"377"]) {
            label_print.text = [item.cart_print stringByReplacingOccurrencesOfString:@" (null) (null)" withString:@""];
            label_amount.text = [NSString stringWithFormat:@"%@개", item.pkgcnt];
            int sum_price = [item getSumPrice];
            label_price.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:sum_price]];
        }
        else {
            label_print.text = item.cart_print;
            label_amount.text = @"0";
            label_price.text = @"0";
            item.price = @"0";
        }
        
        // border setting
        UIButton *amount_button = (UIButton *)[cell viewWithTag:505];
        amount_button.layer.borderColor = [UIColor colorWithRed:250.0f/255.0f green:162.0f/255.0f blue:13.0f/255.0f alpha:0.5f].CGColor;
        amount_button.layer.borderWidth = 1.5;
        
        amount_button.hidden = ([item.intnum isEqualToString:@"346"] || [item.intnum isEqualToString:@"17"]);
        
        UIButton *check_button = (UIButton *)[cell viewWithTag:500];
        [check_button setImage:_normal_image forState:UIControlStateNormal];
        [check_button setImage:_press_image forState:UIControlStateSelected];
        check_button.selected = item.is_selected;
    }
    return cell;
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"OrderSegue"]) {
        int count = [self updateInfo];
        if (count < 1) {
            [[PhotomonInfo sharedInfo] alertMsg:@"주문할 항목을 선택하세요."];
            return NO;
        }
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AmountSegue"]) {
        AmountViewController *vc = [segue destinationViewController];
        if (vc) {
            if ([_sel_item.intnum isEqualToString:@"0"]) {
                vc.type = 0;
                vc.param = _sel_item.orderno;
                vc.cart_item = nil;
            }
            // SJYANG
            else if ([_sel_item.intnum isEqualToString:@"300"] || [_sel_item.intnum isEqualToString:@"362"] || [_sel_item.intnum isEqualToString:@"120"]) {
                vc.type = 300;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"277"]) {
                vc.type = 277;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"367"]) {
                vc.type = 367;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"368"]) {
                vc.type = 368;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"369"]) {
                vc.type = 369;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"391"]) {
                vc.type = 391;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"392"]) {
                vc.type = 392;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"393"]) {
                vc.type = 393;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"346"]) {
                vc.type = 346;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"347"]) {
                vc.type = 347;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"142"]) {
                vc.type = 142;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"350"] || [_sel_item.intnum isEqualToString:@"351"] || [_sel_item.intnum isEqualToString:@"356"]) {
                vc.type = 350;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"357"]) {
                vc.type = 357;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"376"]) {
                vc.type = 376;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"377"]) {
                vc.type = 377;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"360"]) {
                vc.type = 360;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"363"]) {
                vc.type = 363;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"17"]) {
                NSAssert(NO, @"선물용박스는 수량 변경 불가");
            }
            else if ([_sel_item.intnum isEqualToString:@"359"]) {
                vc.type = 359;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"239"]) {
                vc.type = 239;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else if ([_sel_item.intnum isEqualToString:@"366"]) {
                vc.type = 366;
                vc.param = _sel_item.cart_index;
                vc.cart_item = _sel_item;
            }
            else {
                vc.type = -1;
                vc.param = @"";
                vc.cart_item = nil;
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"PreviewSegue"]) {
        PreViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [self.table_view indexPathForSelectedRow];
            _sel_item = [PhotomonInfo sharedInfo].cartList[indexPath.row];
			[PhotomonInfo sharedInfo].cartItem = _sel_item;
            if ([_sel_item.intnum isEqualToString:@"0"]) {
                vc.type = 0;
                vc.param = _sel_item.orderno;
            }
            // SJYANG
            else if ([_sel_item.intnum isEqualToString:@"300"] || [_sel_item.intnum isEqualToString:@"362"] || [_sel_item.intnum isEqualToString:@"120"]) {
                vc.type = 300;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"277"]) {
                vc.type = 277;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"367"]) {
                vc.type = 367;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"368"]) {
                vc.type = 368;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"369"]) {
                vc.type = 369;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"391"]) {
                vc.type = 391;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"392"]) {
                vc.type = 392;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"393"]) {
                vc.type = 393;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"346"]) {
                vc.type = 346;
                vc.param = @"";
            }
            else if ([_sel_item.intnum isEqualToString:@"347"]) {
                vc.type = 347;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"142"]) {
                vc.type = 142;
                vc.param = @"";
            }
            else if ([_sel_item.intnum isEqualToString:@"350"] || [_sel_item.intnum isEqualToString:@"351"] || [_sel_item.intnum isEqualToString:@"356"]) {
                vc.type = 350;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"357"]) {
                vc.type = 357;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"360"]) {
                vc.type = 360;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"363"]) {
                vc.type = 363;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"17"]) {
                vc.type = 17;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"359"]) {
                vc.type = 359;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"239"]) {
                vc.type = 239;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"366"]) {
                vc.type = 366;
                vc.param = _sel_item.g_class;
            }
            else if ([_sel_item.intnum isEqualToString:@"376"] || [_sel_item.intnum isEqualToString:@"377"]) {
                vc.type = 376;
                vc.param = _sel_item.g_class;
            }
            else {
                vc.type = -1;
                vc.param = @"";
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"OrderSegue"]) {
        [[PhotomonInfo sharedInfo].payList removeAllObjects];
        for (CartItem *item in [PhotomonInfo sharedInfo].cartList) {
            if (item.is_selected) {
                [[PhotomonInfo sharedInfo].payList addObject:item];
            }
        }
    }
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickDelete:(id)sender {
    BOOL is_modified = FALSE;
    int max = (int)[PhotomonInfo sharedInfo].cartList.count - 1;
    for (int i = max; i >= 0; i--) {
        CartItem *item = [PhotomonInfo sharedInfo].cartList[i];
        if (item && item.is_selected) {
            [[PhotomonInfo sharedInfo] deleteCartItem:item.cart_index];
            [[PhotomonInfo sharedInfo].cartList removeObjectAtIndex:i];
            is_modified = TRUE;
        }
    }
    if (is_modified) {
        [[PhotomonInfo sharedInfo] loadCartList];
        [self updateInfo];
        [_table_view reloadData];
    }
}

- (IBAction)clickCheckAll:(id)sender {
    UIButton *checkbox = (UIButton *)sender;
    checkbox.selected = !checkbox.selected;
    for (CartItem *item in [PhotomonInfo sharedInfo].cartList) {
        item.is_selected = checkbox.selected;
    }
    [self updateInfo];
    [_table_view reloadData];
}

- (IBAction)clickCheck:(id)sender {
    _sel_item = [self getSelCartItem:sender];
    if (_sel_item != nil) {
        UIButton *checkbox = (UIButton *)sender;
        _sel_item.is_selected = !_sel_item.is_selected;
        checkbox.selected = _sel_item.is_selected;
        [self updateInfo];
    }
}

- (IBAction)clickAmount:(id)sender {
    _sel_item = [self getSelCartItem:sender];
}

- (IBAction)clickPreview:(id)sender {
    _sel_item = [self getSelCartItem:sender];
	[PhotomonInfo sharedInfo].cartItem = _sel_item;
}

@end
