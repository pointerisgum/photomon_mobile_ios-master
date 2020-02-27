//
//  OrderListTableViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 7..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "OrderListTableViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface OrderListTableViewController ()

@end

@implementation OrderListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (![[PhotomonInfo sharedInfo] loadOrderList]) {
        [[PhotomonInfo sharedInfo] alertMsg:@"주문내역을 가져올 수 없습니다.\n잠시후, 다시 시도해 보세요."];
        [self dismissViewControllerAnimated:YES completion:nil];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [PhotomonInfo sharedInfo].orderList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell" forIndexPath:indexPath];
    
    UILabel *datelabel = (UILabel *)[cell viewWithTag:100];
    UILabel *titlelabel = (UILabel *)[cell viewWithTag:101];
    UILabel *pricelabel = (UILabel *)[cell viewWithTag:102];
    UILabel *statelabel = (UILabel *)[cell viewWithTag:103];
    
    OrderItem *item = [PhotomonInfo sharedInfo].orderList[indexPath.row];
    datelabel.text = [NSString stringWithFormat:@"%@ (%@)", item.senddate, item.tuid];
    titlelabel.text = item.orderstr;
    pricelabel.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[item.total_price intValue]]];
    statelabel.text = item.state;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderItem *item = [PhotomonInfo sharedInfo].orderList[indexPath.row];
    [[PhotomonInfo sharedInfo] loadOrderItem:item.tuid];
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
@end
