//
//  SelectPhotoViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 1..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "SelectPhotoViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "Instagram.h"
#import "PHAssetUtility.h"
#import "MonthlyBaby.h"
#import "MonthlyUploadPopup.h"
#import "MonthlyUploadDonePopup.h"

@interface SelectPhotoViewController () <MonthlyAfterUploadActionDelegate>

@end

@implementation SelectPhotoViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    // collection_view의 상단 마진이 자동으로 생기는 현상을 없애는 코드. 버그인듯.
    // 스토리보드에서 컨트롤러를 선택하고, Adjust Scrollview insets을 uncheck해도 같은 효과
    // self.automaticallyAdjustsScrollViewInsets = NO;
    
	_image_manager = [[PHCachingImageManager alloc] init];

    if (_is_singlemode) {
        _selthumb_view.hidden = YES;
        _bottom_view.hidden = YES;
        _selthumb_view_constraint_h.constant = 0.0f;
        _bottom_view_constraint_h.constant = 0.0f;
    }
    
    _asset_array = [[NSMutableArray alloc] init];

    PHFetchOptions *albumFetchOption = [[PHFetchOptions alloc]init];
    albumFetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
	albumFetchOption.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];

	PHFetchResult *loftAssetResult = [PHAsset fetchAssetsInAssetCollection:_selected_group options:albumFetchOption];
	[loftAssetResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
		if (![_asset_array containsObject:asset]) {
			[_asset_array addObject:asset];
		}
		[_collection_view reloadData];
		[_selthumb_view reloadData];
		[self resetTitle];
	}];
    
    _thread = nil;
    _wait_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _wait_indicator.backgroundColor = [UIColor colorWithRed:128.0f/255.0f green:128.0f/255.0f blue:128.0f/255.0f alpha:0.5f];
    _wait_indicator.frame = self.view.frame;
    _wait_indicator.center = self.view.center;
    [self.view addSubview:_wait_indicator];
}

- (void)changeConstraintMultiplier:(NSLayoutConstraint *)oldConstraint newValue:(CGFloat)newvalue {
    NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem
                                                                     attribute:oldConstraint.firstAttribute
                                                                     relatedBy:oldConstraint.relation
                                                                        toItem:oldConstraint.secondItem
                                                                     attribute:oldConstraint.secondAttribute
                                                                    multiplier:newvalue
                                                                      constant:oldConstraint.constant];

    [self.view removeConstraint:oldConstraint];
    [self.view addConstraint:newConstraint];
    [self.view layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([Common info].photobook.product_type == PRODUCT_BABY) {
        _select_toggle.hidden = YES;
        _deselect_toggle.hidden = YES;

        NSLayoutConstraint *oldConstraint;

        oldConstraint = _constraint_select_width;
        NSLayoutConstraint *newConstraint1 = [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem
                                                                          attribute:oldConstraint.firstAttribute
                                                                          relatedBy:oldConstraint.relation
                                                                             toItem:oldConstraint.secondItem
                                                                          attribute:oldConstraint.secondAttribute
                                                                         multiplier:0
                                                                           constant:oldConstraint.constant];
        oldConstraint = _constraint_select_width;
        NSLayoutConstraint *newConstraint2 = [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem
                                                                          attribute:oldConstraint.firstAttribute
                                                                          relatedBy:oldConstraint.relation
                                                                             toItem:oldConstraint.secondItem
                                                                          attribute:oldConstraint.secondAttribute
                                                                         multiplier:0
                                                                           constant:oldConstraint.constant];
        oldConstraint = _constraint_done_width;
        NSLayoutConstraint *newConstraint3 = [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem
                                                                          attribute:oldConstraint.firstAttribute
                                                                          relatedBy:oldConstraint.relation
                                                                             toItem:oldConstraint.secondItem
                                                                          attribute:oldConstraint.secondAttribute
                                                                         multiplier:1
                                                                           constant:oldConstraint.constant];
        oldConstraint = _constraint_done_centerx;
        NSLayoutConstraint *newConstraint4 = [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem
                                                                          attribute:oldConstraint.firstAttribute
                                                                          relatedBy:oldConstraint.relation
                                                                             toItem:oldConstraint.secondItem
                                                                          attribute:oldConstraint.secondAttribute
                                                                         multiplier:1
                                                                           constant:oldConstraint.constant];

        @try {
            [_select_toggle.superview removeConstraint:_constraint_select_width];
            [_deselect_toggle.superview removeConstraint:_constraint_deselect_width];
            [_done_button.superview removeConstraint:_constraint_done_width];
            [_done_button.superview removeConstraint:_constraint_done_centerx];
        }
        @catch (NSException *e) {
            [_select_toggle.superview.superview removeConstraint:_constraint_select_width];
            [_deselect_toggle.superview.superview removeConstraint:_constraint_deselect_width];
            [_done_button.superview.superview removeConstraint:_constraint_done_width];
            [_done_button.superview.superview removeConstraint:_constraint_done_centerx];
        }

        [self.view addConstraint:newConstraint1];
        [self.view addConstraint:newConstraint2];
        [self.view addConstraint:newConstraint3];
        [self.view addConstraint:newConstraint4];
    }

    [_collection_view reloadData];
    [_selthumb_view reloadData];
    [self resetTitle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (![parent isEqual:self.parentViewController]) {
        if (_next_button.enabled == NO) {
            if (_thread) {
                [_thread cancel];
            }
        }
    }
}

- (void)resetTitle {
    int count = (int)[[Common info].photo_pool totalCount] + [Instagram info].selectedCount;
    if (count > 0) {
        if (_min_pictures > 0) {
            [self setTitle: [NSString stringWithFormat:@"사진 선택 (%d/%d)", count, _min_pictures]];
        }
        else {
            [self setTitle: [NSString stringWithFormat:@"%d 장 선택", count]];
        }
    }
    else {
        [self setTitle: @"사진 선택"];
    }
}

- (void)doingThread {
    [[Common info].photo_pool removeAll];
    [[Instagram info] removeAll];
    
    int count = 0;
    for (PHAsset *asset in _asset_array) {
        if ([[Common info].photo_pool isPrintable:asset]) {
            [[Common info].photo_pool add:asset Param:_param];
            NSString *count_str = [NSString stringWithFormat:@"%d", ++count];
            [self performSelectorOnMainThread:@selector(setTitleThread:) withObject:count_str waitUntilDone:YES];
        }
        if ([[NSThread currentThread] isCancelled]) {
            [[Common info].photo_pool removeAll];
            [[Instagram info] removeAll];
            break;
        }
        
        int count_max = _min_pictures;

        if (_param.length > 0) {
            int temp = [_param intValue];
            if (temp > 0) {
                count_max = temp;
            }
        }

        if (count >= count_max) { // minPictures개수만큼만 추가한다. 포토북의 경우는 _param 참고(248장)... 1200개를 넘으면 메모리 경고
            break;
        }
    }
    [self performSelectorOnMainThread:@selector(doneThread) withObject:nil waitUntilDone:NO];
}

- (void)setTitleThread:(NSString *)count {
    if (_min_pictures > 0) {
        [self setTitle: [NSString stringWithFormat:@"사진 선택 (%@/%d)", count, _min_pictures]];
    }
    else {
        [self setTitle: [NSString stringWithFormat:@"%@ 장 선택", count]];
    }
}

- (void)doneThread {
    [_wait_indicator stopAnimating];
    _next_button.enabled = YES;
    _select_toggle.enabled = YES;
    
    [_collection_view reloadData];
    [_selthumb_view reloadData];
    [self resetTitle];
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
                [_collection_view reloadData];
                [_selthumb_view reloadData];
                [self resetTitle];
            }
        }
    }
}
/*
- (IBAction)selectToggle:(id)sender {
    if ([_select_toggle.titleLabel.text isEqualToString:@"전체선택"]) {
        [_select_toggle setTitle:@"선택해제" forState:UIControlStateNormal];
        _select_toggle.enabled = NO;
        _next_button.enabled = NO;
        [_wait_indicator startAnimating];
        
        if (_thread) {
            [_thread cancel];
            _thread = nil;
        }
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(doingThread) object:nil];
        [_thread start];
    }
    else {
        [_select_toggle setTitle:@"전체선택" forState:UIControlStateNormal];
        [[Common info].photo_pool removeAll];
        [_collection_view reloadData];
        [_selthumb_view reloadData];
        [self resetTitle];
    }
}
*/
- (IBAction)selectAll:(id)sender {
    _select_toggle.enabled = NO;
    _next_button.enabled = NO;
    [_wait_indicator startAnimating];
    
    if (_thread) {
        [_thread cancel];
        _thread = nil;
    }
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(doingThread) object:nil];
    [_thread start];
}

- (IBAction)deselectAll:(id)sender {
    [[Common info].photo_pool removeAll];
    [[Instagram info] removeAll];
    [_collection_view reloadData];
    [_selthumb_view reloadData];
    [self resetTitle];
}

- (IBAction)done:(id)sender {
    int total_count = (int)[[Common info].photo_pool totalCount] + (int)[[Instagram info] selectedCount];
    if (total_count <= 0) {
        [self.view makeToast:@"선택한 사진이 없습니다."];
        return;
    }
	
	[self dismissViewControllerAnimated:YES completion:^{
		[self.delegate selectPhotoDone:_is_singlemode];
	}];
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    int count = (int)[[Common info].photo_pool totalCount] + [[Instagram info] selectedCount];
    if (count < 1) {
        [[Common info] alert:self Msg:@"사진을 선택하세요."];
        return NO;
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _selthumb_view) {
        return [[Common info].photo_pool totalCount];
    }
    return _asset_array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _selthumb_view) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectPhotoMiniCell" forIndexPath:indexPath];
        
        Photo *photo = [Common info].photo_pool.sel_photos[indexPath.row];

        UIImageView *imageview = (UIImageView *)[cell viewWithTag:200];
		[[PHAssetUtility info] getThumbnailInfoForAsset:photo.asset withImageView:imageview];
        
        return cell;
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectPhotoMainCell" forIndexPath:indexPath];
    PHAsset *asset = _asset_array[indexPath.row];
    if (asset) {
        UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
		[[PHAssetUtility info] getThumbnailInfoForAsset:asset withImageView:imageview];
        
        UIImageView *checkview = (UIImageView *)[cell viewWithTag:101];
        if (checkview != nil) {
            checkview.hidden = ![[Common info].photo_pool isSelected:asset];
            imageview.alpha = checkview.hidden ? 1.0f : 0.5f;
        }
        
        UIImageView *warningview = (UIImageView *)[cell viewWithTag:102];
        if (warningview != nil) {
            warningview.hidden = [[Common info].photo_pool isPrintable:asset];
        }
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _selthumb_view) {
        [collectionView reloadData];
        return;
    }
    
    if (_is_singlemode) {
        [[Common info].photo_pool removeAll];
        [[Instagram info] removeAll];
    }

    if ([Common info].photobook.product_type == PRODUCT_BABY && [Common info].photobook.minpictures == 1) {
        [[Common info].photo_pool removeAll];
        [[Instagram info] removeAll];
    }
    if ([Common info].photobook.product_type == PRODUCT_PHONECASE && [Common info].photobook.minpictures == 1) {
        [[Common info].photo_pool removeAll];
        [[Instagram info] removeAll];
    }
    
    PHAsset *asset = _asset_array[indexPath.row];
    if ([[Common info].photo_pool isPrintable:asset]) {
        if ([[Common info].photo_pool isSelected:asset]) {
            [[Common info].photo_pool remove:asset];
        }
        else {
            if ([Common info].photobook.product_type == PRODUCT_BABY && [Common info].photobook.minpictures == 3) {
                if((int)[Common info].photo_pool.sel_photos.count < 3 ) {
                    [[Common info].photo_pool add:asset Param:_param];
                }
            }
            else if ([Common info].photobook.product_type == PRODUCT_PHONECASE) {
                if((int)[Common info].photo_pool.sel_photos.count < [Common info].photobook.minpictures ) {
                    [[Common info].photo_pool add:asset Param:_param];
                }
            }
			if ([[Common info].photobook.ProductCode isEqualToString:@"300502"]) {
				if ([[Common info].photo_pool totalCount] + [MonthlyBaby inst].currentUploadCount < [MonthlyBaby inst].maxUploadCountTotal){
					[[Common info].photo_pool add:asset Param:_param];
				} else {
					[self.view makeToast:@"더이상 업로드 할 수 없습니다."];
				}
			}
            else {
                [[Common info].photo_pool add:asset Param:_param];
            }
        }
        [self resetTitle];
        [_collection_view reloadData];
        
        if (!_is_singlemode) {
            [_selthumb_view reloadData];
        }
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _selthumb_view) {
        return CGSizeMake(80, 80);
    }
    CGFloat spacing = 5.0;
    CGFloat size = (collectionView.bounds.size.width - spacing*4) / 3;
    return CGSizeMake(size, size);
}

@end
