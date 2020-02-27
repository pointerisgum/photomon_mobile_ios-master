//
//  ThumbCollectionViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 9. 2..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "ThumbCollectionViewController.h"
#import "PhotobookEditTableViewController.h"
#import "Common.h"
#import "UIView+Toast.h"

@interface ThumbCollectionViewController ()

@end

@implementation ThumbCollectionViewController

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

- (void)viewWillAppear:(BOOL)animated {
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
    int count = (int)[[Common info].photo_pool totalCount];
    if (count > 0) {
        if (_count_max > 0) {
            [self setTitle: [NSString stringWithFormat:@"사진 선택 (%d/%d)", count, _count_max]];
        }
        else {
            [self setTitle: [NSString stringWithFormat:@"%d 장 선택", count]];
        }
    }
    else {
        [self setTitle: @"사진 선택"];
    }
}

- (IBAction)deselectAll:(id)sender {
    [[Common info].photo_pool removeAll];
    [_collection_view reloadData];
    [_selthumb_view reloadData];
    [self resetTitle];
}

- (IBAction)selectAll:(id)sender {
    [_wait_indicator startAnimating];
    _next_button.enabled = NO;
    
    if (_thread) {
        [_thread cancel];
        _thread = nil;
    }
    
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(doingThread) object:nil];
    [_thread start];
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

- (void)doingThread {
    [[Common info].photo_pool removeAll];

    int count = 0;
    for (PHAsset *asset in _asset_array) {
        if ([[Common info].photo_pool isPrintable:asset]) {
            [[Common info].photo_pool add:asset];
            NSString *count_str = [NSString stringWithFormat:@"%d", ++count];
            [self performSelectorOnMainThread:@selector(setTitleThread:) withObject:count_str waitUntilDone:YES];
        }
        if ([[NSThread currentThread] isCancelled]) {
            [[Common info].photo_pool removeAll];
            break;
        }
        if (count >= 500) { // 1200개를 넘으면 메모리 경고.. 일단 500개 제한.. 추후 살펴볼 것. (maxphoto 참고해도 될 듯)
            break;
        }
    }
    [self performSelectorOnMainThread:@selector(doneThread) withObject:nil waitUntilDone:NO];
}

- (void)setTitleThread:(NSString *)count {
    if (_count_max > 0) {
        [self setTitle: [NSString stringWithFormat:@"사진 선택 (%@/%d)", count, _count_max]];
    }
    else {
        [self setTitle: [NSString stringWithFormat:@"%@ 장 선택", count]];
    }
}

- (void)doneThread {
    [_wait_indicator stopAnimating];
    _next_button.enabled = YES;
    
    [_collection_view reloadData];
    [_selthumb_view reloadData];
    [self resetTitle];
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    int count = (int)[[Common info].photo_pool totalCount];
    if (count < 1) {
        [[Common info] alert:self Msg:@"사진을 선택하세요."];
        return NO;
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
/*    PhotobookEditTableViewController *vc = [segue destinationViewController];
    if (vc) {
        vc.is_new = YES;
    }
    [self setTitle: @"사진 선택"];*/
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
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoMiniCell" forIndexPath:indexPath];
        
        Photo *photo = [Common info].photo_pool.sel_photos[indexPath.row];

        UIImageView *imageview = (UIImageView *)[cell viewWithTag:200];
		[[PHAssetUtility info] getThumbnailInfoForAsset:photo.asset withImageView:imageview];

		/*
		UIImageView *imageview = (UIImageView *)[cell viewWithTag:200];
        imageview.image = [UIImage imageWithCGImage:[photo.asset thumbnail]];
		*/
        
        return cell;
    }

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCustomCell" forIndexPath:indexPath];
    PHAsset *asset = _asset_array[indexPath.row];
    if (asset) {
        UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
		[[PHAssetUtility info] getThumbnailInfoForAsset:photo.asset withImageView:imageview];

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
    }
    
    PHAsset *asset = _asset_array[indexPath.row];
    if ([[Common info].photo_pool isPrintable:asset]) {
        if ([[Common info].photo_pool isSelected:asset]) {
            [[Common info].photo_pool remove:asset];
        }
        else {
            [[Common info].photo_pool add:asset];
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

- (IBAction)done:(id)sender {
    if ([[Common info].photo_pool totalCount] <= 0) {
        [self.view makeToast:@"선택한 사진이 없습니다."];
        return;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate selectPhotoDone:_is_singlemode];    
}

@end
