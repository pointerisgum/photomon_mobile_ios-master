//
//  PhotoCollectionViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 6. 26..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PhotoCollectionViewController.h"
#import "Common.h"
#import "PHAssetUtility.h"

@interface PhotoCollectionViewController ()

@end

@implementation PhotoCollectionViewController

static NSString * const reuseIdentifier = @"PhotoCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
	_image_manager = [[PHCachingImageManager alloc] init];
    _thread = nil;

    // asset url이 어플 실행 중에는 유일하고 계속 유지된다는 가정.. 검증 필요..
    _assetArray = [[NSMutableArray alloc] init];

    PHFetchOptions *albumFetchOption = [[PHFetchOptions alloc]init];
    albumFetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
	albumFetchOption.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];

	PHFetchResult *loftAssetResult = [PHAsset fetchAssetsInAssetCollection:_selectedGroup options:albumFetchOption];
	[loftAssetResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
		if (![_assetArray containsObject:asset]) {
			[_assetArray addObject:asset];
		}
        [_collection_view reloadData];
	}];
    [self resetTitle];
    
    _wait_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _wait_indicator.backgroundColor = [UIColor colorWithRed:128.0f/255.0f green:128.0f/255.0f blue:128.0f/255.0f alpha:0.5f];
    _wait_indicator.frame = self.view.frame;
    _wait_indicator.center = self.view.center;
    [self.view addSubview:_wait_indicator];
}

- (void)viewWillAppear:(BOOL)animated {
    [_collection_view reloadData];
    [self resetTitle];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetTitle {
    int count = (int)[Common info].photoprint.print_items.count;
    if (count > 0) {
        [self setTitle: [NSString stringWithFormat:@"%ld 장 선택", (long)count]];
    }
    else {
        [self setTitle: @"사진 선택"];
    }
}

- (void)doingThread {
    int count = 0;
    [[Common info].photoprint.print_items removeAllObjects];
    for (PHAsset *asset in _assetArray) {
        if ([[Common info].photoprint isPrintablePhoto:asset]) {
            [[Common info].photoprint addPhoto:asset];
            NSString *count_str = [NSString stringWithFormat:@"%d", ++count];
            [self performSelectorOnMainThread:@selector(setTitleThread:) withObject:count_str waitUntilDone:YES];
        }
        if ([[NSThread currentThread] isCancelled]) {
            [[Common info].photoprint.print_items removeAllObjects];
            break;
        }
        if (count >= 1024) { // 1200개를 넘으면 메모리 경고..
            break;
        }
    }
    [self performSelectorOnMainThread:@selector(doneThread) withObject:nil waitUntilDone:NO];
}

- (void)setTitleThread:(NSString *)count {
    [self setTitle: [NSString stringWithFormat:@"%@ 장 선택", count]];
}

- (void)doneThread {
    [_wait_indicator stopAnimating];
    _next_button.enabled = YES;
    _select_toggle.enabled = YES;
    
    [_collection_view reloadData];
    [self resetTitle];
}
/*
- (IBAction)selectToggle:(id)sender {
    if ([_select_toggle.titleLabel.text isEqualToString:@"전체선택"]) {
        [_select_toggle setTitle:@"선택해제" forState:UIControlStateNormal];
        [_wait_indicator startAnimating];
        _select_toggle.enabled = NO;
        _next_button.enabled = NO;
        
        if (_thread) {
            [_thread cancel];
            _thread = nil;
        }
        _thread = [[NSThread alloc] initWithTarget:self selector:@selector(doingThread) object:nil];
        [_thread start];
    }
    else {
        [_select_toggle setTitle:@"전체선택" forState:UIControlStateNormal];
        [[PhotomonInfo sharedInfo].selectedPhotos removeAllObjects];
        [_collection_view reloadData];
        [self resetTitle];
    }
}
*/
- (IBAction)deselectAll:(id)sender {
    [[Common info].photoprint.print_items removeAllObjects];
    [_collection_view reloadData];
    [self resetTitle];
}

- (IBAction)selectAll:(id)sender {
    [_wait_indicator startAnimating];
    _select_toggle.enabled = NO;
    _next_button.enabled = NO;
    
    if (_thread) {
        [_thread cancel];
        _thread = nil;
    }
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(doingThread) object:nil];
    [_thread start];
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    int count = (int)[Common info].photoprint.print_items.count;
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
    [self setTitle: @"사진 선택"];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _assetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    PHAsset *asset = _assetArray[indexPath.row];
    if (asset) {
        UIImageView *imageview = (UIImageView *)[cell viewWithTag:300];
		[[PHAssetUtility info] getThumbnailInfoForAsset:asset withImageView:imageview];
        
        UIImageView *checkview = (UIImageView *)[cell viewWithTag:301];
        if (checkview != nil) {
            checkview.hidden = ![[Common info].photoprint isSelectedPhoto:asset];
        }
        
        UIImageView *warningview = (UIImageView *)[cell viewWithTag:302];
        if (warningview != nil) {
            warningview.hidden = [[Common info].photoprint isPrintablePhoto:asset];
        }
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = _assetArray[indexPath.row];
    if ([[Common info].photoprint isPrintablePhoto:asset]) {
        if ([[Common info].photoprint isSelectedPhoto:asset]) {
            [[Common info].photoprint removePhoto:asset];
        }
        else {
            [[Common info].photoprint addPhoto:asset];
        }
        [self resetTitle];
        [collectionView reloadData];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat spacing = 5.0;
    CGFloat size = (collectionView.bounds.size.width - spacing*4) / 3;
    return CGSizeMake(size, size);
}

@end
