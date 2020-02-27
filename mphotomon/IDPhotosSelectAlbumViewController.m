//
//  IDPhotosSelectAlbumViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "IDPhotosSelectAlbumViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "IDPhotosSelectPhotoViewController.h"
#import "PHAssetUtility.h"

@interface IDPhotosSelectAlbumViewController ()

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation IDPhotosSelectAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
	[Analysis log:@"IDPhotosSelectAlbumViewController"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"IDPhotosSelectAlbumViewController" ScreenClass:[self.classForCoder description]];
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
	self.assetGroups = [[PHAssetUtility info] getUserAlbums];
    [_collection_view reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.assetGroups count];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:@"IDPhotosSelectPhotoSegue" sender:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    PHAssetCollection *collection = self.assetGroups[indexPath.row];

	PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
	fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
	PHFetchResult *fetchResult = [PHAsset fetchKeyAssetsInAssetCollection:collection options:fetchOptions];
	PHAsset *asset = [fetchResult firstObject];

	UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
	[[PHAssetUtility info] getThumbnailInfoForAsset:asset withImageView:imageview];

	NSString* folder_name = collection.localizedTitle;
	if( [folder_name length] > 6 ) {
        folder_name = [NSString stringWithFormat:@"%@...", [folder_name substringToIndex : 6]];
	}

	UILabel *label1 = (UILabel *)[cell viewWithTag:101];
    label1.text = [NSString stringWithFormat:@"%@ (%ld)",folder_name, (long)[[PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions] count]];

	return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat spacing = 5.0;
    CGFloat width = (collectionView.bounds.size.width - spacing*4) / 3;
    
    CGFloat height = width * 1.2;
    
    return CGSizeMake(width, height);
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"IDPhotosSelectPhotoSegue"]) {
        IDPhotosSelectPhotoViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
			vc.assetGroup = [self.assetGroups objectAtIndex:indexPath.row];
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
