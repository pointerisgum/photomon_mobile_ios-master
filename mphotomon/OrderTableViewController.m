//
//  OrderTableViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 7..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "OrderTableViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface OrderTableViewController ()

@end

@implementation OrderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    OrderItemEx *item = [PhotomonInfo sharedInfo].orderItemSel;
    if (item != nil) {
        _tuidLabel.text = item.tuid;
        _senddateLabel.text = item.senddate;
        _orderstateLabel.text = item.state;
        _usernameLabel.text = item.username;
        _totalpriceLabel.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item.total_price intValue]]];
        _originalpriceLabel.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item.orginal_price intValue]]];
        _deliveryLabel.text = [NSString stringWithFormat:@"%@/%@", item.delivery_info, item.ship_info];
        if ([item.acc_info isEqualToString:@"1"]) {
            _payinfoLabel.text = @"무통장";
        }
        else if ([item.acc_info isEqualToString:@"2"]) {
            _payinfoLabel.text = @"카드결제";
        }
        else if ([item.acc_info isEqualToString:@"4"]) {
            _payinfoLabel.text = @"핸드폰결제";
        }
        else {
            _payinfoLabel.text = @"";
        }
        _addressLabel.text = [NSString stringWithFormat:@"%@ %@", item.address1, item.address2];
        _etcLabel.text = @"";
    }
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
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
