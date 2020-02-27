//
//  AddressSearchTableViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 3..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "AddressSearchTableViewController.h"
#import "PhotomonInfo.h"

@interface AddressSearchTableViewController ()

@end

@implementation AddressSearchTableViewController

NSMutableDictionary *mAr;

- (void)viewDidLoad {
    [super viewDidLoad];
	mAr = [[NSMutableDictionary alloc] init];
    
    //_searchText.text = @"역삼";
    _searchText.text = @"";
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
    return [PhotomonInfo sharedInfo].addressArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchAddressCell" forIndexPath:indexPath];
    
    UILabel *addresslabel1 = (UILabel *)[cell viewWithTag:100];
    UILabel *addresslabel2 = (UILabel *)[cell viewWithTag:101];
    UILabel *addresslabel3 = (UILabel *)[cell viewWithTag:102];

    addresslabel1.text = [PhotomonInfo sharedInfo].postnumArray[indexPath.row];
    addresslabel2.text = [PhotomonInfo sharedInfo].addressArray[indexPath.row];
    addresslabel3.text = [PhotomonInfo sharedInfo].addressArray2[indexPath.row];

	float totalheight = 0;

	addresslabel2.numberOfLines = 0;
	[addresslabel2 setLineBreakMode:NSLineBreakByWordWrapping];
	addresslabel2.adjustsFontSizeToFitWidth=NO;

	{
		NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
		paragraph.lineBreakMode = addresslabel2.lineBreakMode;
		NSDictionary *attributes = @{NSFontAttributeName : addresslabel2.font, NSParagraphStyleAttributeName : paragraph};
		//CGSize constrainedSize = CGSizeMake(addresslabel2.bounds.size.width, NSIntegerMax);
		CGSize constrainedSize = CGSizeMake(_table_view.bounds.size.width - 65, NSIntegerMax);
		CGRect rect = [addresslabel2.text boundingRectWithSize:constrainedSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];

		{
			NSArray *constraints = [addresslabel2 constraints];
			long count = [constraints count];
			long index = 0;
			while (index < count) {
				NSLayoutConstraint *constraint = constraints[index];
				if ( [constraint.identifier isEqualToString:@"constraint_label2height"] ) {
					constraint.constant = rect.size.height + 2;
					totalheight += constraint.constant;
					//NSLog(@"FIND #1-1 : %ld : %f", indexPath.row, constraint.constant);
					break;
				}
				index++;
			}
		}
	}

	addresslabel3.numberOfLines = 0;
	[addresslabel3 setLineBreakMode:NSLineBreakByWordWrapping];
	addresslabel3.adjustsFontSizeToFitWidth=NO;

	{
		NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
		paragraph.lineBreakMode = addresslabel3.lineBreakMode;
		NSDictionary *attributes = @{NSFontAttributeName : addresslabel3.font, NSParagraphStyleAttributeName : paragraph};
		//CGSize constrainedSize = CGSizeMake(addresslabel3.bounds.size.width, NSIntegerMax);
		CGSize constrainedSize = CGSizeMake(_table_view.bounds.size.width - 65, NSIntegerMax);
		CGRect rect = [addresslabel3.text boundingRectWithSize:constrainedSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
		{
			NSArray *constraints = [addresslabel3 constraints];
			long count = [constraints count];
			long index = 0;
			while (index < count) {
				NSLayoutConstraint *constraint = constraints[index];
				if ( [constraint.identifier isEqualToString:@"constraint_label3height"] ) {
					constraint.constant = rect.size.height + 2;
					totalheight += constraint.constant;
					//NSLog(@"FIND #1-2 : %ld : %f", indexPath.row, constraint.constant);
					break;
				}
				index++;
			}
		}
	}

	//NSLog(@"FIND #1 : %ld : %f", indexPath.row, totalheight);
	[mAr setObject:@(totalheight) forKey:@(indexPath.row+1)]; 
	[_table_view endUpdates];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([mAr objectForKey:@(indexPath.row+1)]!=nil && mAr.count>=indexPath.row+1) {
		//NSLog(@"FIND : %ld : %@", indexPath.row, [mAr objectForKey:@(indexPath.row+1)]);
		@try {
			NSString* val = [mAr objectForKey:@(indexPath.row+1)];
			float f = [val floatValue];
			return(f);
		}
		@catch (NSException *e) {
			return 40;
		}
	}

	return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delivery_controller) {
        _delivery_controller.addressPostNum.text = [PhotomonInfo sharedInfo].postnumArray[indexPath.row];
        _delivery_controller.addressBasic.text = [PhotomonInfo sharedInfo].addressArray[indexPath.row];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickSearch:(id)sender {
    if ([_searchText.text isEqualToString:@""]) {
        [[PhotomonInfo sharedInfo] alertMsg:@"검색할 지역명을 입력하세요."];
        return;
    }
    else if ([_searchText.text isEqualToString:@"qqq"]) {
        _searchText.text = @"잠원동";
    }
    
    [[PhotomonInfo sharedInfo] loadAddressInfo:_searchText.text];
    //NSLog(@"Address Search Result: %lu", (unsigned long)[PhotomonInfo sharedInfo].addressArray.count);
    [_table_view reloadData];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
