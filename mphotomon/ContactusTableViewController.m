//
//  ContactusTableViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 13..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "ContactusTableViewController.h"
#import "ContactusViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"

@interface ContactusTableViewController ()

@end

@implementation ContactusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _selected_row = -1;
    _text_h = 0;
    
    [[PhotomonInfo sharedInfo] loadContactList:[Common info].user.mUserid];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)getSelectedCell:(id)sender {
    // iOS 7 이상은 super's super. 이전에는 그냥 super.
    if ([sender superview] != nil && [[sender superview] superview] != nil) {
        UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
        return cell;
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [PhotomonInfo sharedInfo].contactArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactusCell" forIndexPath:indexPath];

    UILabel *title_label = (UILabel *)[cell viewWithTag:100];
    UILabel *date_label = (UILabel *)[cell viewWithTag:101];
    UITextView *text_view = (UITextView *)[cell viewWithTag:102];
    UIButton *button = (UIButton *)[cell viewWithTag:103];
    UIImageView *reply_icon = (UIImageView *)[cell viewWithTag:104];

    button.selected = (_selected_row == indexPath.row);
    
    ContactusListItem *item = [PhotomonInfo sharedInfo].contactArray[indexPath.row];
    if ([item.re_step intValue] <= 0) {
        reply_icon.hidden = YES;
        title_label.text = item.subject;
        date_label.text = [NSString stringWithFormat:@"[%@] %@", item.idx, item.writedate];
    }
    else {
        reply_icon.hidden = NO;
        title_label.text = [NSString stringWithFormat:@"       %@", item.subject];
        date_label.text = [NSString stringWithFormat:@"        %@", item.writedate];
    }

    if (_selected_row == indexPath.row) {
        [text_view setText:item.body];
        
        CGRect new_frame = text_view.frame;
        new_frame.size = [text_view sizeThatFits:CGSizeMake(text_view.frame.size.width, 1000)];
        text_view.frame = new_frame;

        text_view.hidden = NO;
        _text_h = text_view.frame.size.height;
    }
    else {
        [text_view setText:item.body];
        
        text_view.hidden = YES;
        _text_h = 0;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selected_row) {
        return _text_h + 66;
    }
    return 66;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ContactusViewController *vc = [segue destinationViewController];
    if (vc) {
        vc.parent_controller = self;
    }

    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)clickDetail:(id)sender {
    UITableViewCell *cell = [self getSelectedCell:sender];
    UIButton *button = (UIButton *)[cell viewWithTag:103];
    button.selected = !button.selected;
    
    NSIndexPath *indexPath = [_table_view indexPathForCell:cell];
    _selected_row = button.selected ? (int)indexPath.row : -1;
    
    ContactusListItem *item = [PhotomonInfo sharedInfo].contactArray[indexPath.row];
    if (item && item.body.length <= 0) {
        item.body = [[PhotomonInfo sharedInfo] loadContactPost:item.idx];
    }
    [_table_view reloadData];
}

- (IBAction)clickCall:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:02-548-4684"]];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
