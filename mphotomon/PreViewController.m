//
//  PreViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 16..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PreViewController.h"
#import "PhotomonInfo.h"

@interface PreViewController ()

@end

@implementation PreViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (_param.length <= 0) {
        [[PhotomonInfo sharedInfo] alertMsg:@"미리보기를 제공하지 않습니다."];
        [self.navigationController popViewControllerAnimated:YES];
    }

    //self.view.backgroundColor = [UIColor redColor];
    [[PhotomonInfo sharedInfo] loadCartPreviewItemList:_type Param:_param];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
	//NSLog(@"[PhotomonInfo sharedInfo].cartPreviewItemList.count : %d", [PhotomonInfo sharedInfo].cartPreviewItemList.count);
    return [PhotomonInfo sharedInfo].cartPreviewItemList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PreviewCell" forIndexPath:indexPath];

	//NSLog(@"indexPath.row : %d", indexPath.row);

    CartPreviewItem *item = [PhotomonInfo sharedInfo].cartPreviewItemList[indexPath.row];
    if (item != nil) {
        NSString *url = [item.previewImg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[PhotomonInfo sharedInfo] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                UIImage *image = [UIImage imageWithData:imageData];
#if 1
                imageview.image = image;
#else
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGImageRef contextImage = CGBitmapContextCreateImage(context);
                UIImage *resultingImage = [UIImage imageWithCGImage:contextImage];
                imageview.image = resultingImage;
                CGImageRelease(contextImage);
#endif
            }
            else {
                NSLog(@"preview_image is not downloaded.");
            }
        }];
		NSLog(@"item.oriFileName : %@", item.oriFileName);
        if (_type == 0) {
	        _print_filename.text = item.oriFileName;
            _print_size.text = [NSString stringWithFormat:@"사이즈: %@ / 수량: %@",item.previewSize, item.previewCnt];
            _print_prop.text = item.optionSTR;
            cell.layer.borderColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.0f].CGColor;
            cell.layer.borderWidth = 0.0f;
        }
        else if (_type == 300) {// || _type == 277 || _type == 347) {
	        _print_filename.text = item.oriFileName;
            _print_size.text = item.optionSTR;
            _print_prop.text = @"";
            cell.layer.borderColor = [UIColor colorWithRed:189.0f/255.0f green:189.0f/255.0f blue:189.0f/255.0f alpha:0.5f].CGColor;
            cell.layer.borderWidth = 1.0f;
        }
        else if (_type == 376 || _type == 377) {
	        _print_filename.text = @"";
            _print_size.text = @"";
            _print_prop.text = @"";
            cell.layer.borderColor = [UIColor colorWithRed:189.0f/255.0f green:189.0f/255.0f blue:189.0f/255.0f alpha:0.5f].CGColor;
            cell.layer.borderWidth = 1.0f;
        }
        else {
	        _print_filename.text = item.oriFileName;
            _print_size.text = item.optionSTR;
            _print_prop.text = @"";
        }
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
/*
    if (_type == 300) {
        if (_thumb_size.width != 0 && _thumb_size.height != 0) {
            CGFloat width = collectionView.bounds.size.width;
            CGFloat height = (width * _thumb_size.height) / _thumb_size.width;
            return CGSizeMake(width, height);
        }
    }*/
	return _collection_view.bounds.size;
}

- (IBAction)done:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
