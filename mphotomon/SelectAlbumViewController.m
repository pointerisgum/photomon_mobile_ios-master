//
//  SelectAlbumViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 1..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "SelectAlbumViewController.h"
#import "GuideViewController.h"
#import "SelectPhotoViewController.h"
#import "Common.h"
#import "InstagramViewController.h"
#import "UIView+Toast.h"
#import "PHAssetUtility.h"

@interface SelectAlbumViewController ()

@end

@implementation SelectAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // collection_view의 상단 마진이 자동으로 생기는 현상을 없애는 코드. 버그인듯.
    // 스토리보드에서 컨트롤러를 선택하고, Adjust Scrollview insets을 uncheck해도 같은 효과
    // self.automaticallyAdjustsScrollViewInsets = NO;
    
    _is_first = TRUE;

    if (_is_singlemode) {
        _selthumb_view.hidden = YES;
        _selthumb_view_constraint_h.constant = 0.0f;
    }
    
    // 포토북만 인스타그램 사진을 허용.
    if ([Common info].photobook.product_type != PRODUCT_PHOTOBOOK) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [[Instagram info] reset];
    [[Common info].photo_pool removeAll];
    
    _group_array = [[PHAssetUtility info] getUserAlbums];
    

    // cmh : 구닥켐 제일 위로 올림
    for (int i = 0 ; i < self.group_array.count; i++) {
        PHAssetCollection *ac = self.group_array[i];
        NSLog(@"self.group_array : %@", self.group_array[i]);
        NSLog(@"ac : %@", ac.localizedTitle);
        
        if ([ac.localizedTitle isEqualToString:@"GUDAK CAM"]) {
            id object = self.group_array[i];
            [self.group_array removeObjectAtIndex:i];
            [self.group_array insertObject:object atIndex:0];
        }
    }

}

- (void)viewWillAppear:(BOOL)animated {
    if (_is_first) {
        _is_first = FALSE;

        if (!_is_singlemode) {
            [self popupGuidePage:GUIDE_PHOTO_SELECT];
        }
    }
    [_selthumb_view reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popupGuidePage:(NSString *)guide_id {
    if ([[Common info] checkGuideUserDefault:guide_id]) {
        GuideViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GuidePage"];
        if (vc) {
            vc.guide_id = guide_id;
            vc.delegate = nil;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[Common info].photo_pool totalCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectAlbumMiniCell" forIndexPath:indexPath];
    Photo *photo = [Common info].photo_pool.sel_photos[indexPath.row];

    UIImageView *imageview = (UIImageView *)[cell viewWithTag:200];

	[[PHAssetUtility info] getThumbnailInfoForAsset:photo.asset withImageView:imageview];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _group_array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectAlbumMainCell" forIndexPath:indexPath];

    PHAssetCollection *collection = _group_array[indexPath.row];

	UIImageView *imageview = (UIImageView *)[cell viewWithTag:202];
    UILabel *namelabel = (UILabel *)[cell viewWithTag:200];
    UILabel *countlabel = (UILabel *)[cell viewWithTag:201];

	[[PHAssetUtility info] getThumbnailInfoForCollection:collection withImageView:imageview withNameLabel:namelabel withCountLabel:countlabel];

    return cell;
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"SelectInstagramPhotoSegue"]) {
        if (![[Instagram info] isSessionValid]) {
            [[Instagram info] login:self];
            return NO;
        }
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"SelectLocalPhotoSegue"]) {
        SelectPhotoViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [_table_view indexPathForSelectedRow];
            vc.selected_group = _group_array[indexPath.row];
            vc.is_singlemode = _is_singlemode;
            vc.min_pictures = _min_pictures;
            vc.param = _param;
            vc.delegate = _delegate;
        }
    }
    else if ([segue.identifier isEqualToString:@"SelectInstagramPhotoSegue"]) {
        InstagramViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_singlemode = _is_singlemode;
            vc.min_pictures = _min_pictures;
            vc.param = _param;
            vc.delegate = _delegate;
        }
    }
}

- (IBAction)clickDelete:(id)sender {
    if ([sender superview] != nil) {
        // iOS 7 이상은 super's super. 이전에는 그냥 super.
        if ([[sender superview] superview] != nil) {
            UICollectionViewCell *cell = (UICollectionViewCell*)[[sender superview] superview];
            if (cell != nil) {
                NSIndexPath *indexPath = [_selthumb_view indexPathForCell:cell];
                if (indexPath) {
                    [[Common info].photo_pool removeAtIndex:indexPath.row];
                }
                [_selthumb_view reloadData];
            }
        }
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate selectPhotoCancel:_is_singlemode];
    }];
}

#pragma mark - oAuthDelegate methods

- (void)oAuthDone:(BOOL)result {
    if (result) {
        [self.view makeToast:@"로그인되었습니다."];
    }
    else {
        [self.view makeToast:@"로그인되지 않았습니다."];
    }
}

@end
