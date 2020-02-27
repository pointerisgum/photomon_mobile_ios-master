//
//  AlbumSelectViewController.m
//  PHOTOMON
//
//  Created by 곽세욱 on 03/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "AlbumSelectViewController.h"
#import "PhotoSelectViewController.h"
#import "GuideViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "PHAssetUtility.h"
#import "PhotoContainer.h"
#import "MonthlyBaby.h"
#import "MonthlyUploadPopup.h"
#import "MonthlyUploadDonePopup.h"

@interface AlbumSelectViewController ()

@end

@implementation AlbumSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _isFirst = TRUE;
    
    if (_isSinglemode) {
        _selectListView.hidden = YES;
        _selectListViewHeight.constant = 0.0f;
    }
    
    // 포토북만 인스타그램 사진을 허용.
//    [[Instagram info] reset];
//    [[Common info].photo_pool removeAll];
//
    _groupArray = [[PHAssetUtility info] getUserAlbums];
    
    // cmh : 구닥켐 제일 위로 올림
    for (int i = 0 ; i < _groupArray.count; i++) {
        PHAssetCollection *ac = _groupArray[i];
        NSLog(@"self.group_array : %@", _groupArray[i]);
        NSLog(@"ac : %@", ac.localizedTitle);
        
        if ([ac.localizedTitle isEqualToString:@"GUDAK CAM"]) {
            id object = _groupArray[i];
            [_groupArray removeObjectAtIndex:i];
            [_groupArray insertObject:object atIndex:0];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    if (_isFirst) {
        _isFirst = FALSE;
        
        if (!_isSinglemode) {
            [self popupGuidePage:GUIDE_PHOTO_SELECT];
        }
    }
    [_selectListView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popupGuidePage:(NSString *)guide_id {
    if ([[Common info] checkGuideUserDefault:guide_id]) {
		UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GuideViewController *vc = [sb instantiateViewControllerWithIdentifier:@"GuidePage"];
        if (vc) {
            vc.guide_id = guide_id;
            vc.delegate = nil;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (void)setData:(id<SelectPhotoDelegate>)delegate positionType:(int)positionType  isSinglemode:(BOOL)isSinglemode minPictureCount:(int)minPictureCount param:(NSString *)param {
	_delegate = delegate;
	_positionType = positionType;
	_isSinglemode = isSinglemode;
	_minPictureCount = minPictureCount;
	_param = param;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	
	PhotoSelectViewController *vc = [segue destinationViewController];
	if (vc) {
		NSIndexPath *indexPath = [_albumListView indexPathForSelectedRow];
		PHAssetCollection *collection = _groupArray[indexPath.row];
		
		[vc setData:_delegate positionType:_positionType selectedGroup:collection isSinglemode:_isSinglemode minPictureCount:_minPictureCount param:_param];
		vc.selectDoneOp = _selectDoneOp;
	}
}

#pragma mark - SelectListView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [[PhotoContainer inst] selectCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectPhotoCell" forIndexPath:indexPath];
	PhotoItem *photoItem = [[PhotoContainer inst] getSelectedItem:(int)indexPath.row];
	
	if (photoItem) {
		UIImageView *imageview = (UIImageView *)[cell viewWithTag:200];
		imageview.image = [photoItem getThumbnail];
	}
	return cell;
}

#pragma mark - SelectListView Delegate

//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//	return CGSizeMake(80, 80);
//}

#pragma mark - albumListView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _groupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];
	
	PHAssetCollection *collection = _groupArray[indexPath.row];
	
	UIImageView *imageview = (UIImageView *)[cell viewWithTag:202];
	UILabel *namelabel = (UILabel *)[cell viewWithTag:200];
	UILabel *countlabel = (UILabel *)[cell viewWithTag:201];
	
	[[PHAssetUtility info] getThumbnailInfoForCollection:collection withImageView:imageview withNameLabel:namelabel withCountLabel:countlabel];
	
	return cell;
}

#pragma mark - albumListView Delegate

#pragma mark - UI Delegate

- (IBAction)clickDelete:(id)sender {
	if ([sender superview] != nil) {
		// iOS 7 이상은 super's super. 이전에는 그냥 super.
		if ([[sender superview] superview] != nil) {
			UICollectionViewCell *cell = (UICollectionViewCell*)[[sender superview] superview];
			if (cell != nil) {
				NSIndexPath *indexPath = [_selectListView indexPathForCell:cell];
				if (indexPath) {
					[[PhotoContainer inst] removeAtIndex:(int)indexPath.row];
				}
				[_selectListView reloadData];
			}
		}
	}
}

@end
