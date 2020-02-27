//
//  AlbumCollectionViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 2..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "AlbumCollectionViewController.h"
#import "ThumbCollectionViewController.h"
#import "GuideViewController.h"
#import "Common.h"

@interface AlbumCollectionViewController ()

@end

@implementation AlbumCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // collection_view의 상단 마진이 자동으로 생기는 현상을 없애는 코드. 버그인듯.
    // 스토리보드에서 컨트롤러를 선택하고, Adjust Scrollview insets을 uncheck해도 같은 효과
    // self.automaticallyAdjustsScrollViewInsets = NO;

    _is_first = TRUE;
    self.navigationItem.rightBarButtonItem = nil; // 스토리보드를 위한 더미 버튼이라 보일 필요가 없다.
    
    if (_is_singlemode) {
        _selthumb_view.hidden = YES;
        _selthumb_view_constraint_h.constant = 0.0f;
    }
    
	_group_array = [[PHAssetUtility info] getUserAlbums];
	[_collection_view reloadData];
	[_selthumb_view reloadData];
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
    if (collectionView == _selthumb_view) {
        return [[Common info].photo_pool totalCount];
    }
    return _group_array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _selthumb_view) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumMiniCell" forIndexPath:indexPath];
        Photo *photo = [Common info].photo_pool.sel_photos[indexPath.row];

        UIImageView *imageview = (UIImageView *)[cell viewWithTag:200];

		[[PHAssetUtility info] getThumbnailInfoForAsset:photo.asset withImageView:imageview];
        
        return cell;
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCustomCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1;
    PHAssetCollection *collection = _group_array[indexPath.row];
    
	UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
    UILabel *namelabel = (UILabel *)[cell viewWithTag:101];
    UILabel *countlabel = (UILabel *)[cell viewWithTag:102];

	[[PHAssetUtility info] getThumbnailInfoForCollection:collection withImageView:imageview withNameLabel:namelabel withCountLabel:countlabel];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _selthumb_view) {
        return CGSizeMake(80, 80);
    }
    CGFloat spacing = 5.0;
    CGFloat size = (_collection_view.bounds.size.width - spacing*3) / 2;
    return CGSizeMake(size, size + 20);
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ThumbCollectionViewController *vc = [segue destinationViewController];
    if (vc) {
        NSIndexPath *indexPath = [[self.collection_view indexPathsForSelectedItems] lastObject];
        vc.selected_group = _group_array[indexPath.row];
        vc.is_singlemode = _is_singlemode;
        vc.count_max = _count_max;
        vc.delegate = _delegate;
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
    [self.delegate selectPhotoCancel:_is_singlemode];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
