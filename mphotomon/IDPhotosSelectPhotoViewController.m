//
//  IDPhotosSelectPhotoViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "IDPhotosSelectPhotoViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "IDPhotosSelectItemViewController.h"
#import "PhAssetUtility.h"

@interface IDPhotosSelectPhotoViewController ()

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation IDPhotosSelectPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
	[Analysis log:@"IDPhotosSelectPhotoViewController"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"IDPhotosSelectPhotoViewController" ScreenClass:[self.classForCoder description]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    [self loadData];
}

- (void)loadData {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.photos = tempArray;

    @autoreleasepool {
        [self.photos removeAllObjects];

		PHFetchOptions *albumFetchOption = [[PHFetchOptions alloc]init];
		albumFetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
		albumFetchOption.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];

		PHFetchResult *loftAssetResult = [PHAsset fetchAssetsInAssetCollection:_assetGroup options:albumFetchOption];
		[loftAssetResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
			if (![self.photos containsObject:asset]) {
				[self.photos addObject:asset];
			}
			[_collection_view reloadData];
		}];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photos count];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:@"IDPhotosSelectItemSegue" sender:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    PHAsset *asset = self.photos[indexPath.row];

	UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
	[[PHAssetUtility info] getThumbnailInfoForAsset:asset withImageView:imageview];

	return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat spacing = 5.0;
    CGFloat width = (collectionView.bounds.size.width - spacing*4) / 3;
    
    // page_width : page_height = width : h(?)
    CGFloat height = width * 1;
    
    return CGSizeMake(width, height);
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"IDPhotosSelectItemSegue"]) {
        IDPhotosSelectItemViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
			vc.idx = (int)indexPath.row;
			vc.photos = _photos;
        }
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
