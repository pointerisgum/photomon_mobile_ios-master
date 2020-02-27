//
//  IDPhotosCameraImageListViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "IDPhotosCameraImageListViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "IDPhotosEditorViewController.h"

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

@interface IDPhotosCameraImageListViewController ()

@end

static NSString * const reuseIdentifier = @"Cell";

@implementation IDPhotosCameraImageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	NSString *docPath = [[Common info] documentPath];  // 도큐먼트 폴더 찾기
	NSString *baseFolder = [NSString stringWithFormat:@"%@/idphotos/camera", docPath];

	NSError *error = nil;
	_image_paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:baseFolder error: &error];
	_image_paths = [_image_paths reversedArray];

	/*
	self.navigationItem.leftBarButtonItem = nil;
	*/
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem=nil;
	self.navigationItem.hidesBackButton = YES;
	[Analysis log:@"IDPhotosCameraImageListViewController"];


}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"IDPhotosCameraImageListViewController" ScreenClass:[self.classForCoder description]];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [_image_paths count];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	[self performSegueWithIdentifier:@"IDPhotosEditorSegue" sender:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

	UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];

	NSString* each_image_path = [NSString stringWithFormat:@"%@/idphotos/camera/%@", [[Common info] documentPath], (NSString*)[_image_paths objectAtIndex:indexPath.row]];
	if ([[NSFileManager defaultManager] fileExistsAtPath:each_image_path]) {
		NSData *imageData = [NSData dataWithContentsOfFile:each_image_path];            
		imageview.image = [UIImage imageWithData:imageData];

		imageview.contentMode = UIViewContentModeScaleAspectFill; 
		imageview.clipsToBounds = YES;
	}

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
    if ([segue.identifier isEqualToString:@"IDPhotosEditorSegue"]) {
        IDPhotosEditorViewController *vc = [segue destinationViewController];
        if (vc) {
			vc.fromCamera = YES;
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
			NSString* current_image_path = [NSString stringWithFormat:@"%@/idphotos/camera/%@", [[Common info] documentPath], (NSString*)[_image_paths objectAtIndex:indexPath.row]];
			if ([[NSFileManager defaultManager] fileExistsAtPath:current_image_path]) {
				NSData *imageData = [NSData dataWithContentsOfFile:current_image_path];            
				vc.original_image = [UIImage imageWithData:imageData];
			}
        }
    }
}

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
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
