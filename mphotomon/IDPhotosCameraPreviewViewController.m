//
//  IDPhotosCameraPreviewViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 17..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "IDPhotosCameraPreviewViewController.h"
#import "IDPhotosCameraImageListViewController.h"
#import "IDPhotosEditorViewController.h"
#import "UIView+Toast.h"
#import "UIImage+Filtering.h"
#import "UIImage+Rotating.h"
#import "ImageFilter.h"
#import <math.h>
#import "QuartzCore/QuartzCore.h"

@implementation NSArray (Reverse)

- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end

@implementation NSMutableArray (Reverse)

- (void)reverse {
    if ([self count] <= 1)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];

        i++;
        j--;
    }
}

@end

@interface IDPhotosCameraPreviewViewController ()

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation IDPhotosCameraPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	NSString *docPath = [[Common info] documentPath];  // 도큐먼트 폴더 찾기
	NSString *baseFolder = [NSString stringWithFormat:@"%@/idphotos/camera", docPath];

	NSError *error = nil;
	_image_paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:baseFolder error: &error];
	_image_paths = [_image_paths reversedArray];

	self.navigationItem.leftBarButtonItem=nil;
	self.navigationItem.hidesBackButton = YES;

	_left_arrow.layer.zPosition = 9999;
	_right_arrow.layer.zPosition = 9999;
	
	[Analysis log:@"IDPhotosCameraPreviewViewController"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"IDPhotosCameraPreviewViewController" ScreenClass:[self.classForCoder description]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	//[_collection_view reloadData];
}

- (void)viewWillLayoutSubviews {
	_constraints_btn_1_width.constant = self.view.bounds.size.width / 3.0f - 1;
	_constraints_btn_2_width.constant = self.view.bounds.size.width / 3.0f;
	_constraints_btn_3_width.constant = self.view.bounds.size.width - (_constraints_btn_1_width.constant + _constraints_btn_2_width.constant);

	float space = [UIApplication sharedApplication].statusBarFrame.size.height + [self statusBarHeight] + _bottom_btn_1.frame.size.height;
	_constraints_left_arrow_bottom_space.constant = (self.view.bounds.size.height - space) / 2.0f - _left_arrow.frame.size.height / 2.0f + _bottom_btn_1.frame.size.height;
	_constraints_right_arrow_bottom_space.constant = (self.view.bounds.size.height - space) / 2.0f - _right_arrow.frame.size.height / 2.0f + _bottom_btn_1.frame.size.height;
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
	return [_image_paths count];
	//return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

	UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];

	NSString* each_image_path = [NSString stringWithFormat:@"%@/idphotos/camera/%@", [[Common info] documentPath], (NSString*)[_image_paths objectAtIndex:indexPath.row]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:each_image_path]) {
		NSData *imageData = [NSData dataWithContentsOfFile:each_image_path];            
		imageview.image = [UIImage imageWithData:imageData];
	}
	//imageview.image = [UIImage imageNamed:@"main_polaroid.jpg"];

	float width = self.view.bounds.size.width - 17.0f * 1.5f * 2.0f;
	float height = width / imageview.image.size.width * imageview.image.size.height;
	if( height > self.view.bounds.size.height * 0.7f ) {
		height = self.view.bounds.size.height * 0.7f;
		width = height / imageview.image.size.height * imageview.image.size.width;
	}

	//[imageview setFrame:CGRectMake((self.view.bounds.size.width - width) / 2.0f, (self.view.bounds.size.height / 2.0) / 2.0f - height/2.0f, width, height)];
	[imageview setFrame:CGRectMake((collectionView.bounds.size.width - width) / 2.0f, (collectionView.bounds.size.height - height) / 2.0f, width, height)];
	
	return cell;
}

#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	/*
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = width;
	*/

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
	if( _idx==_image_paths.count-1 )
		_right_arrow.hidden = YES;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
	[self performSegueWithIdentifier:@"IDPhotosEditorSegue" sender:self];
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)list:(id)sender {
	[self performSegueWithIdentifier:@"IDPhotosCameraImageListSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"IDPhotosEditorSegue"]) {
        IDPhotosEditorViewController *vc = [segue destinationViewController];
        if (vc) {
			NSString* current_image_path = [NSString stringWithFormat:@"%@/idphotos/camera/%@", [[Common info] documentPath], (NSString*)[_image_paths objectAtIndex:_idx]];
			if ([[NSFileManager defaultManager] fileExistsAtPath:current_image_path]) {
				NSData *imageData = [NSData dataWithContentsOfFile:current_image_path];
				vc.fromCamera = YES;
				vc.original_image = [UIImage imageWithData:imageData];
			}
        }
    }
    else if ([segue.identifier isEqualToString:@"IDPhotosCameraImageListSegue"]) {
        IDPhotosCameraImageListViewController *vc = [segue destinationViewController];
        if (vc) {
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
