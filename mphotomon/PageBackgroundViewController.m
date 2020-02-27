//
//  PageBackgroundViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 1. 18..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "PageBackgroundViewController.h"
#import "UIView+Toast.h"

@interface PageBackgroundViewController ()

@end

@implementation PageBackgroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _selected_background = -1;
    _backgrounds = [[NSMutableArray alloc] init];
    
    [self onfilter1:nil];
    
    for (Background *background in [Common info].background_pool.backgrounds) {
        NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].background_pool.thumb_url, background.thumbnail];
        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                background.image = [UIImage imageWithData:imageData];
                [_collection_view reloadData];
            }
            else {
                NSLog(@"background's thumbnail_image is not downloaded.");
            }
        }];
    }
    
    // 나중에 새로 정리할 것... 시작
    int color_design = 0;
    int skin_design = 0;
    for (Background *background in [Common info].background_pool.backgrounds) {
        if ([background.page_type isEqualToString:_sel_pagetype]) {
            if ([_sel_pagetype isEqualToString:@"cover"]) {       // cover일 경우, 모두 추가
                if ([background.theme_id hasPrefix:@"common"]) { //if (background.skinfilename.length <= 0) {
                    color_design++;
                }
                else {
                    skin_design++;
                }
            }
            else if ([_sel_pagetype isEqualToString:@"prolog"]) { // prolog일 경우, 레이어 갯수가 일치하는 경우만 추가.
                if ([background.theme_id hasPrefix:@"common"]) { //if (background.skinfilename.length <= 0) {
                    color_design++;
                }
                else {
                    skin_design++;
                }
            }
            else if ([_sel_pagetype isEqualToString:@"page"]) {   // page일 경우,
                if ([background.theme_id hasPrefix:@"common"]) { //if (background.skinfilename.length <= 0) {
                    color_design++;
                }
                else {
                    skin_design++;
                }
            }
        }
    }
    if (color_design <= 0 || skin_design <= 0) {
        _buttonbar.hidden = YES;
        _buttonbar_constraint.constant = 0;
    }
    // 나중에 새로 정리할 것... 끝
}

- (void)viewDidAppear:(BOOL)animated {
    //[self updateBackgrounds];
}

- (void)updateBackgrounds {
    _selected_background = -1;
    [_backgrounds removeAllObjects];
    
    if (_sel_pagetype.length > 0) {
        for (Background *background in [Common info].background_pool.backgrounds) {
            if ([background.page_type isEqualToString:_sel_pagetype]) {
                if ([_sel_pagetype isEqualToString:@"cover"]) {       // cover일 경우, 모두 추가
                    if (_filter == 1) {
                        if ([background.theme_id hasPrefix:@"common"]) { //if (background.skinfilename.length <= 0) {
                            [_backgrounds addObject:background];
                        }
                    }
                    else {
                        if (![background.theme_id hasPrefix:@"common"]) { //if (background.skinfilename.length > 0) {
                            [_backgrounds addObject:background];
                        }
                    }
                }
                else if ([_sel_pagetype isEqualToString:@"prolog"]) { // prolog일 경우, 레이어 갯수가 일치하는 경우만 추가.
                    if (_filter == 1) {
                        if ([background.theme_id hasPrefix:@"common"]) { //if (background.skinfilename.length <= 0) {
                            [_backgrounds addObject:background];
                        }
                    }
                    else {
                        if (![background.theme_id hasPrefix:@"common"]) { //if (background.skinfilename.length > 0) {
                            [_backgrounds addObject:background];
                        }
                    }
                }
                else if ([_sel_pagetype isEqualToString:@"page"]) {   // page일 경우,
                    if (_filter == 1) {
                        if ([background.theme_id hasPrefix:@"common"]) { //if (background.skinfilename.length <= 0) {
                            [_backgrounds addObject:background];
                        }
                    }
                    else {
                        if (![background.theme_id hasPrefix:@"common"]) { //if (background.skinfilename.length > 0) {
                            [_backgrounds addObject:background];
                        }
                    }
                }
            }
        }
        NSLog(@"backgrounds count: %d", (int)_backgrounds.count);
        if (_backgrounds.count <= 0) {
            [self.view makeToast:@"사용 가능한 디자인이 없습니다."];
        }
        [_collection_view reloadData];
    }
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
    return _backgrounds.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PageBackgroundCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    Background *background = _backgrounds[indexPath.row];
    if (background) {
        if (background.image != nil) {
            UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
            imageview.image = background.image;
        }
        
        UIImageView *selimageview = (UIImageView *)[cell viewWithTag:101];
        selimageview.hidden = (indexPath.row != _selected_background);
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Background *background = _backgrounds[indexPath.row];
    if (background != nil && _selected_background != (int)indexPath.row) {
        _selected_background = (int)indexPath.row;
        [_collection_view reloadData];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat spacing = 10.0;
    CGFloat size = (collectionView.bounds.size.width - spacing*3) / 2;
    return CGSizeMake(size, size/2);
}


- (IBAction)onfilter1:(id)sender {
    [_button1 setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [_button2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    if (_filter != 1) {
        _filter = 1;
        [self updateBackgrounds];
    }
}

- (IBAction)onfilter2:(id)sender {
    [_button2 setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [_button1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    if (_filter != 2) {
        _filter = 2;
        [self updateBackgrounds];
    }
}

- (IBAction)done:(id)sender {
    if (_selected_background < 0) {
        [[Common info] alert:self Msg:@"페이지 레이아웃을 선택해 주세요."];
    }
    else {
        Background *background = _backgrounds[_selected_background];
        if (background != nil) {
            [self.delegate changeBackground:background];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
