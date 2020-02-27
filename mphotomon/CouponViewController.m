//
//  CouponViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 10..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "CouponViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface CouponViewController ()

@end

@implementation CouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[PhotomonInfo sharedInfo] loadCouponList:[Common info].user.mUserid Intnum:_sel_intnum Seqnum:_sel_seqnum CartIdx:_sel_cartidx];

    if (_sender == nil) {
        NSLog(@"쿠폰 관리 모드");
    }
    else {
        NSLog(@"쿠폰 사용 모드");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isEqualIntnum:(NSString *)intnums {
    NSArray *row_array = [intnums componentsSeparatedByString:@"^"];
    for (NSString *intnum in row_array) {
        if ([intnum isEqualToString:@""]) {
            break;
        }
        if ([_sel_intnum isEqualToString:intnum]) {
            return TRUE;
        }
    }
    return FALSE;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [PhotomonInfo sharedInfo].couponList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponCell" forIndexPath:indexPath];

    UILabel *titlelabel = (UILabel *)[cell viewWithTag:100];
    UILabel *couponlabel = (UILabel *)[cell viewWithTag:101];
    UILabel *datelabel = (UILabel *)[cell viewWithTag:102];
    
    CouponItem *item = [PhotomonInfo sharedInfo].couponList[indexPath.row];
    titlelabel.text = item.couponname;
    couponlabel.text = [NSString stringWithFormat:@"쿠폰번호:%@", item.code];
    datelabel.text = [NSString stringWithFormat:@"유효기간:%@", item.enddate];

    if (_sender != nil) {
        for (CouponItem *use_coupon in _sender.useCoupon) {
            if ([use_coupon.code isEqualToString:item.code]) {
                couponlabel.textColor = [UIColor redColor];
            }
        }
    }

    //if (![_sel_intnum isEqualToString:item.intnum]) {
    if (![self isEqualIntnum:item.intnum]) {
        titlelabel.textColor = [UIColor lightGrayColor];
    }
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_sender != nil && _sel_intnum.length > 0) {
        CouponItem *item = [PhotomonInfo sharedInfo].couponList[indexPath.row];
        if (item != nil) {
            for (CouponItem *use_coupon in _sender.useCoupon) {
                if ([use_coupon.code isEqualToString:item.code]) {
                    [[PhotomonInfo sharedInfo] alertMsg:@"이미 선택한 쿠폰입니다.\n다시 선택해 주세요."];
                    return;
                }
            }

            //if ([_sel_intnum isEqualToString:item.intnum]) {
            if ([self isEqualIntnum:item.intnum]) {
                NSString *msg = @"사용할 수 있는 쿠폰입니다.\n사용 하시겠습니까?";
                if ([_sel_intnum isEqualToString:@"300"] || [_sel_intnum isEqualToString:@"277"] || [_sel_intnum isEqualToString:@"367"] || [_sel_intnum isEqualToString:@"368"] || [_sel_intnum isEqualToString:@"369"] || [_sel_intnum isEqualToString:@"391"] || [_sel_intnum isEqualToString:@"392"] || [_sel_intnum isEqualToString:@"393"]) {
                    msg = @"사용할 수 있는 쿠폰입니다. 사용 하시겠습니까?\n포토북(달력) 이용권/쿠폰 사용시 정상가에서 적용됩니다.";
                }
                //MAcheck
                [[Common info] alert:self Title:msg Msg:@"" okCompletion:^{
                    if (self.sel_index >= 0 && self.sel_index < self.sender.useCoupon.count) {
                        CouponItem *coupon_item = self.sender.useCoupon[self.sel_index];
                        coupon_item.couponname = item.couponname;
                        coupon_item.enddate = item.enddate;
                        coupon_item.code = item.code;
                        coupon_item.intnum = self.sel_intnum;//item.intnum;
                        coupon_item.discount = item.discount;
                        coupon_item.coupontype = item.coupontype;
                    }
                    
                    [self dismissViewControllerAnimated:YES completion:nil];

                } cancelCompletion:^{
                    
                } okTitle:@"네" cancelTitle:@"아니오"];
            }
            else {
                [[PhotomonInfo sharedInfo] alertMsg:@"사용할 수 없는 쿠폰입니다.\n다시 선택해 주세요."];
            }
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)regist:(id)sender {
    //NSString *msg = [[PhotomonInfo sharedInfo] registCoupon:_couponText.text ID:[PhotomonInfo sharedInfo].loginInfo.userID];
    NSString *msg = [[PhotomonInfo sharedInfo] registCoupon:_couponText.text ID:[Common info].user.mUserid];
    [[PhotomonInfo sharedInfo] alertMsg:msg];
}

@end
