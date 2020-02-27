//
//  PrintTotalOptionViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 8. 19..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PrintTotalOptionViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "UIView+Toast.h"

@interface PrintTotalOptionViewController ()

@end

@implementation PrintTotalOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _selected_row = 0;
    _image_h = 202;
    
    _full_type = @"인화지풀";
    _border_type = @"무테";
    _surface_type = @"유광";
    _revise_type = @"밝기보정";
    _date_type = @"적용 안함";
    
    _is_includeLargeTypePrint = [[Common info].photoprint isInclueLargeTypePrint];
    if (_is_includeLargeTypePrint) {
        [self.view makeToast:@"대형인화(8x10, A4)가 포함된 경우,\n'유광' 옵션만 가능합니다."];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [_tableview reloadData];
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TotalOptionCell" forIndexPath:indexPath];
    
    UILabel *title = (UILabel *)[cell viewWithTag:100];
    UISegmentedControl *seg = (UISegmentedControl *)[cell viewWithTag:101];
    UIButton *button = (UIButton *)[cell viewWithTag:102];
    [button setImage:[UIImage imageNamed:@"option_expand.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"option_collapse.png"] forState:UIControlStateSelected];
    button.selected = (_selected_row == indexPath.row);

    UIImageView *imageview = (UIImageView *)[cell viewWithTag:103];
    imageview.hidden = (_selected_row != indexPath.row);
    _image_h = imageview.frame.size.height;

    switch (indexPath.row) {
        case 0:
            title.text = @"인화형태";
            [seg setTitle:@"인화지풀" forSegmentAtIndex:0];
            [seg setTitle:@"이미지풀" forSegmentAtIndex:1];
            seg.selectedSegmentIndex = [_full_type isEqualToString:@"인화지풀"] ? 0 : 1;
            [imageview setImage:[UIImage imageNamed:@"option_detail_01.jpg"]];
            break;
        case 1:
            title.text = @"인화테두리";
            [seg setTitle:@"무테" forSegmentAtIndex:0];
            [seg setTitle:@"유테" forSegmentAtIndex:1];
            seg.selectedSegmentIndex = [_border_type isEqualToString:@"무테"] ? 0 : 1;
            [imageview setImage:[UIImage imageNamed:@"option_detail_02.jpg"]];
            break;
        case 2:
            title.text = @"인화지타입";
            [seg setTitle:@"유광" forSegmentAtIndex:0];
            [seg setTitle:@"무광" forSegmentAtIndex:1];
            if (_is_includeLargeTypePrint) {
                seg.selectedSegmentIndex = 0;
                seg.enabled = NO;
            }
            else {
                seg.selectedSegmentIndex = [_surface_type isEqualToString:@"유광"] ? 0 : 1;
            }
            [imageview setImage:[UIImage imageNamed:@"option_detail_03.jpg"]];
            break;
        case 3:
            title.text = @"자동보정";
            [seg setTitle:@"밝기보정" forSegmentAtIndex:0];
            [seg setTitle:@"무보정" forSegmentAtIndex:1];
            seg.selectedSegmentIndex = [_revise_type isEqualToString:@"밝기보정"] ? 0 : 1;
            [imageview setImage:[UIImage imageNamed:@"option_detail_04.jpg"]];
            break;
        case 4:
            title.text = @"촬영일자";
            [seg setTitle:@"적용 안함" forSegmentAtIndex:0];
            [seg setTitle:@"적용" forSegmentAtIndex:1];
            seg.selectedSegmentIndex = [_date_type isEqualToString:@"적용 안함"] ? 0 : 1;
            [imageview setImage:[UIImage imageNamed:@"option_detail_05_temp"]];
            
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selected_row) {
        return _image_h + 60;//262;
    }
    return 60;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UITableViewCell *)getSelectedCell:(id)sender {
    // iOS 7 이상은 super's super. 이전에는 그냥 super.
    if ([sender superview] != nil && [[sender superview] superview] != nil) {
        UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
        return cell;
    }
    return nil;
}

- (IBAction)clickOption:(id)sender {
    UITableViewCell *cell = [self getSelectedCell:sender];
    UISegmentedControl *seg = (UISegmentedControl *)[cell viewWithTag:101];
    NSIndexPath *indexPath = [_tableview indexPathForCell:cell];
    switch (indexPath.row) {
        case 0:
            _full_type = (seg.selectedSegmentIndex == 0) ? @"인화지풀" : @"이미지풀";
            break;
        case 1:
            _border_type = (seg.selectedSegmentIndex == 0) ? @"무테" : @"유테";
            break;
        case 2:
            _surface_type = (seg.selectedSegmentIndex == 0) ? @"유광" : @"무광";
            break;
        case 3:
            _revise_type = (seg.selectedSegmentIndex == 0) ? @"밝기보정" : @"무보정";
            break;
        case 4:
            _date_type = (seg.selectedSegmentIndex == 0) ? @"적용 안함" : @"적용";
            
            if ([_date_type isEqualToString:@"적용"]) {
                [self.view makeToast:@"촬영일자를 사진에 추가 합니다.\n단, 촬영일자가 없는 사진은 추가하지 않습니다."];
            }
            break;
        default:
            break;
    }
}

- (IBAction)clickDetail:(id)sender {
    UITableViewCell *cell = [self getSelectedCell:sender];
    UIButton *button = (UIButton *)[cell viewWithTag:102];
    button.selected = !button.selected;
    
    NSIndexPath *indexPath = [_tableview indexPathForCell:cell];
    _selected_row = button.selected ? (int)indexPath.row : -1;
    
    [_tableview reloadData];
}

- (IBAction)done:(id)sender {
    for (id key in [Common info].photoprint.print_items) {
        PrintItem *item = [[Common info].photoprint.print_items objectForKey:key];
        if (item != nil) {
            item.full_type = _full_type;
            item.border_type = _border_type;
            item.light_type = _surface_type;
            item.revise_type = _revise_type;
            item.date_type = _date_type;
            
            if ([_full_type isEqualToString:@"인화지풀"]) {
                item.trim_info = @"null^";//[[Common info].photoprint getDefaultTrimInfo:item]; // 기본 트리밍값 세팅
            }
            else {
                item.trim_info = @"null^";
            }
        }
    }
    NSLog(@"> selected option: %@, %@, %@, %@, %@", _full_type, _border_type, _surface_type, _revise_type, _date_type);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
