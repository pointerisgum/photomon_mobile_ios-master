//
//  PageEditCalendarViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 17..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "PageEditCalendarViewController.h"

@interface PageEditCalendarViewController ()

@end

@implementation PageEditCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selected_layout = -1;
    _layouts = [[NSMutableArray alloc] init];
    [self updateLayouts];
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)updateLayouts {
    _selected_layout = -1;
    [_layouts removeAllObjects];

    for (Layout *layout in [Common info].layout_pool.layouts) {
        if ([layout.type isEqualToString:_layouttype]) {
            [_layouts addObject:layout];
        }
    }
    if ([_layouttype isEqualToString:@"cover"]) {
        _title_bar.title = @"커버 변경";
    }
    else {
        _title_bar.title = @"레이아웃 변경";
    }
    [_collection_view reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _layouts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PageEditCalendarCell" forIndexPath:indexPath];
    //cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    //cell.layer.borderWidth = 1.0f;
    
    Layout *layout = _layouts[indexPath.row];
    if (layout) {
        if (layout.image == nil) {
            NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].layout_pool.thumb_url, layout.thumbnail];
            NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
                if (succeeded) {
                    layout.image = [UIImage imageWithData:imageData];
                    [_collection_view reloadData];
                }
                else {
                    NSLog(@"layout's thumbnail_image is not downloaded.");
                }
            }];
        }
        UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
        imageview.image = layout.image;
        
        UIImageView *selimageview = (UIImageView *)[cell viewWithTag:101];
        selimageview.hidden = (indexPath.row != _selected_layout);
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Layout *layout = _layouts[indexPath.row];
    if (layout != nil && _selected_layout != (int)indexPath.row) {
        _selected_layout = (int)indexPath.row;
        [_collection_view reloadData];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat spacing = 10.0;
    CGFloat size_w = (collectionView.bounds.size.width - spacing*3) / 2;
    CGFloat size_h = (size_w * 208) / 258; // 258:208 = w : h(?)
    return CGSizeMake(size_w, size_h);
}

- (IBAction)done:(id)sender {
    if (_selected_layout < 0) {
        [[Common info] alert:self Msg:@"페이지 레이아웃을 선택해 주세요."];
    }
    else {
        Layout *layout = _layouts[_selected_layout];
        if (layout != nil) {
            [self.delegate changeLayout:layout];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
