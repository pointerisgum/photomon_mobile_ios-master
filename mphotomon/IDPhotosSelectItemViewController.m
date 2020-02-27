//
//  IDPhotosSelectItemViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 17..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "IDPhotosSelectItemViewController.h"
#import "IDPhotosEditorViewController.h"
#import "QuartzCore/QuartzCore.h"
#import "IDPhotosEditorViewController.h"
#import "PHAssetUtility.h"

@interface IDPhotosSelectItemViewController ()

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation IDPhotosSelectItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(done:)];

	_collection_view.hidden = YES;
	_left_arrow.layer.zPosition = 9999;
	_right_arrow.layer.zPosition = 9999;
	
	_photoPosition = PHOTO_POSITION_LOCAL;
	
	[Analysis log:@"IDPhotosSelectItemViewController"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Analysis firAnalyticsWithScreenName:@"IDPhotosSelectItemViewController" ScreenClass:[self.classForCoder description]];
	
	PhotoItem *photoItem = [[PhotoContainer inst] getSelectedItem:0];
	
	_photoPosition = photoItem.positionType;
	_idx = [[PhotoContainer inst] getCachedIndex:_photoPosition key:photoItem.key];
	
	[_collection_view reloadData];
	long section = [self numberOfSectionsInCollectionView:_collection_view] - 1;
	//long row = [_collection_view numberOfRowsInSection:section] - 1;
	if (section >= 0 && _idx >= 0) {
		NSIndexPath *ip = [NSIndexPath indexPathForRow:_idx
											 inSection:section];
		[_collection_view scrollToItemAtIndexPath:ip
							  atScrollPosition:UICollectionViewScrollPositionRight
									  animated:NO];
	}
	_collection_view.hidden = NO;
}

- (void)viewWillLayoutSubviews {
	float space = [UIApplication sharedApplication].statusBarFrame.size.height + [self statusBarHeight];
	_constraints_left_arrow_bottom_space.constant = (self.view.bounds.size.height - space) / 2.0f - _left_arrow.frame.size.height / 2.0f;
	_constraints_right_arrow_bottom_space.constant = (self.view.bounds.size.height - space) / 2.0f - _right_arrow.frame.size.height / 2.0f;
}

- (float)statusBarHeight
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [[PhotoContainer inst] cachedCount:_photoPosition];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

	UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
	
	PhotoItem *photoItem = [[PhotoContainer inst] getCachedItem:_photoPosition index:indexPath.row];
	
	imageview.image = [photoItem getOriginal];

//    PHAsset *asset = _photos[indexPath.row];
//
//	PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//	options.networkAccessAllowed = YES;
//	options.synchronous = YES;
//
//	[[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
//		imageview.image = [UIImage imageWithData:imageData];
//	}];

	// 원본
	/*
	float width = collectionView.bounds.size.width - 17.0f * 1.5f * 2.0f;
	float height = width / imageview.image.size.width * imageview.image.size.height;
	if( height > collectionView.bounds.size.height * 0.7f ) {
		height = collectionView.bounds.size.height * 0.7f;
		width = height / imageview.image.size.height * imageview.image.size.width;
	}
	*/

	// 양성진 수정/추가
	// 하자보수 이슈 : 증명사진의 오류에 대해서 : 사진선택 화면에서 사진확인 화면으로 이동시 아무런 동작이 없을때에도 
	// 사진의 scale 이 엄청 확대되어 나옵니다. 사용자 터치시 zoom in-out 동작 을 하지 않은 상태에서도 오류가 발생하는 
	// 것입니다.
	float width = collectionView.bounds.size.width;
	float height = width / imageview.image.size.width * imageview.image.size.height;

	imageview.image = [self imageWithImage:imageview.image convertToSize:CGSizeMake(width, height)];
	[imageview setFrame:CGRectMake((collectionView.bounds.size.width - width) / 2.0f, (collectionView.bounds.size.height - height) / 2.0f, width, height)];

	return cell;
}

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return destImage;
}

#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat width = collectionView.bounds.size.width;
 	CGFloat height = collectionView.bounds.size.height;
    
    return CGSizeMake(width, height);
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	_idx = floor(_collection_view.contentOffset.x / _collection_view.bounds.size.width);

	_left_arrow.hidden = NO;
	_right_arrow.hidden = NO;

	if( _idx==0 )
		_left_arrow.hidden = YES;
	if( _idx==_photos.count-1 )
		_right_arrow.hidden = YES;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
	[self performSegueWithIdentifier:@"IDPhotosEditorSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"IDPhotosEditorSegue"]) {
        IDPhotosEditorViewController *vc = [segue destinationViewController];
        if (vc) {
//			PHAsset* asset = _photos[_idx];
//
//			PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//			options.networkAccessAllowed = YES;
//			options.synchronous = YES;
//
//			__block NSData *org_data = nil;
//            // HEIF Fix
//		    if([[PHAssetUtility info] isHEIF:asset]) {
//                org_data = [[PHAssetUtility info] getJpegImageDataForAsset:asset];
//            }
//			else {
//				[[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
//					org_data = [imageData copy];
//				}];
//			}
			
			PhotoItem *photoItem = [[PhotoContainer inst] getCachedItem:_photoPosition index:_idx];

			vc.original_image = [photoItem getOriginal];
			vc.fromCamera = NO;
        }
    }
}

// Resize a UIImage. From http://stackoverflow.com/questions/2658738/the-simplest-way-to-resize-an-uiimage
- (UIImage *)resize:(UIImage *)image to:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
