//
//  OrderDetailListTableViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 7..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "OrderDetailListTableViewController.h"
#import "PreViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface OrderDetailListTableViewController ()

@end

@implementation OrderDetailListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selOrderNum = @"";
    
    NSString *tuid = [PhotomonInfo sharedInfo].orderItemSel.tuid;
    [[PhotomonInfo sharedInfo] loadOrderDetailList:tuid];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [PhotomonInfo sharedInfo].orderDetailList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderDetailCell" forIndexPath:indexPath];

    UILabel *titlelabel = (UILabel *)[cell viewWithTag:101];
    UILabel *countlabel = (UILabel *)[cell viewWithTag:102];
    UILabel *pricelabel = (UILabel *)[cell viewWithTag:103];
    
    OrderDetailItem *item = [PhotomonInfo sharedInfo].orderDetailList[indexPath.row];
    titlelabel.text = item.orderstr;
    
    if (item.upload_count != nil && [item.upload_count intValue] > 0) {
        countlabel.text = [NSString stringWithFormat:@"사진%@장 인화%@장", item.upload_count, item.file_count];
    }
    else {
        countlabel.text = @"모바일 상품";
    }
#if 0
    NSString *temp = [item.orderstr stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSRange range = [temp rangeOfString:@"[모바일포토북]" options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        countlabel.text = @"모바일 포토북";
    }
    else {
        range = [temp rangeOfString:@"[모바일달력]" options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            countlabel.text = @"모바일 달력";
        }
        else {
            range = [temp rangeOfString:@"[모바일스퀘어포토]" options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                countlabel.text = @"모바일 스퀘어포토";
            }
            else {
                countlabel.text = [NSString stringWithFormat:@"사진%@장 인화%@장", item.file_count, item.upload_count];
            }
        }
    }
#endif
    NSString *total_price_str = [[Common info] toCurrencyString:[item.total_price intValue]];
    NSString *delivery_cost_str = [[Common info] toCurrencyString:[item.delivery_cost intValue]];
    pricelabel.text = [NSString stringWithFormat:@"%@원(배송료:%@원)", total_price_str, delivery_cost_str];
    
    NSString *url = [item.thumb_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
        if (succeeded) {
            UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
            imageview.image = [UIImage imageWithData:imageData];
        }
        else {
            NSLog(@"orderdetail's thumbnail_image is not downloaded.");
        }
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    OrderDetailItem *item = [PhotomonInfo sharedInfo].orderDetailList[indexPath.row];
    
    PreViewController *vc = [segue destinationViewController];
    if (item && vc) {
        if (item.upload_count != nil && [item.upload_count intValue] > 0) {
            vc.type = 0;
            vc.param = item.orderno;
        }
        else {
            vc.type = 0;
            vc.param = @"";
        }
        
#if 0
        NSString *temp = [item.orderstr stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSRange range = [temp rangeOfString:@"[모바일포토북]" options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            vc.type = 300;
            vc.param = @"";
        }
        else {
            range = [temp rangeOfString:@"[모바일달력]" options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                vc.type = 277;
                vc.param = @"";
            }
            else {
                range = [temp rangeOfString:@"[모바일스퀘어포토]" options:NSCaseInsensitiveSearch];
                if (range.location != NSNotFound) {
                    vc.type = 347;
                    vc.param = @"";
                }
                else {
                    range = [temp rangeOfString:@"[돌셀프데코]" options:NSCaseInsensitiveSearch];
                    if (range.location != NSNotFound) {
                        vc.type = 142;
                        vc.param = @"";
                    }
                    else {
                        vc.type = 0;
                        vc.param = item.orderno;
                    }
                }
            }
        }
#endif
    }
}


@end
