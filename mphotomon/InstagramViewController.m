//
//  InstagramViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 3. 15..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "InstagramViewController.h"
#import "Instagram.h"
#import "Common.h"
#import "UIView+Toast.h"

@interface InstagramViewController ()

@end

@implementation InstagramViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!_is_singlemode) {
        if (_param.length <= 0) {
            [self.view makeToast:[NSString stringWithFormat:@"최대 %d장까지 선택 가능합니다.", _min_pictures]];
        }
        else {
            [self.view makeToast:[NSString stringWithFormat:@"%d장 ~ %@장까지 선택 가능합니다", _min_pictures, _param]];
        }
    }
    
    if ([Instagram info].images.count <= 0) {
        [[Instagram info] fetchMediaRecent:INSTAGRAM_COUNT_PER_PAGE];
    }
    [self resetTitle];
    
    _load_complete = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)resetTitle {
    int count = (int)[[Common info].photo_pool totalCount] + [Instagram info].selectedCount;
    if (count > 0) {
        if (_min_pictures > 0) {
            [self setTitle: [NSString stringWithFormat:@"인스타그램 (%d/%d)", count, _min_pictures]];
        }
        else {
            [self setTitle: [NSString stringWithFormat:@"%d 장 선택", count]];
        }
    }
    else {
        [self setTitle: @"인스타그램"];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[Instagram info] totalCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"InstagramPhotoCell" forIndexPath:indexPath];
    
    InstaPhoto *photo = [Instagram info].images[indexPath.row];
    if (photo.thumb_url != nil && photo.thumb_url.length > 0) {
        UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
        if (imageview != nil) {
            if (photo.thumb != nil) {
                imageview.image = photo.thumb;
            }
            else {
                UIImage *thumb_img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumb_url]]];
                if (thumb_img != nil) {
                    imageview.image = photo.thumb = thumb_img;
                }
            }
        }
        UIImageView *checkview = (UIImageView *)[cell viewWithTag:101];
        if (checkview != nil) {
            checkview.hidden = ![[Instagram info] isSelectedThumb:photo];
            imageview.alpha = checkview.hidden ? 1.0f : 0.5f;
        }
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;

    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"InstagramHeader" forIndexPath:indexPath];
 
        reusableview = headerView;
    }
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"InstagramFooter" forIndexPath:indexPath];
        
        UIButton *more_button = (UIButton *)[footerview viewWithTag:200];
        if (more_button != nil) {
            more_button.enabled = !_load_complete;
        }
        
        reusableview = footerview;
    }
    
    return reusableview;
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

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    if (_is_singlemode) {
        [[Common info].photo_pool removeAll];
        [[Instagram info] removeAll];
    }
    
    InstaPhoto *photo = [Instagram info].images[indexPath.row];
    if ([[Instagram info] isSelectedThumb:photo]) {
        [[Instagram info] remove:photo];
    }
    else {
        [[Instagram info] add:photo];
    }
    [_collection_view reloadData];
    [self resetTitle];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat spacing = 5.0;
    CGFloat size = (collectionView.bounds.size.width - spacing*4) / 3;
    return CGSizeMake(size, size);
}


- (IBAction)more:(id)sender {
    _load_complete = ![[Instagram info] fetchMediaRecent:INSTAGRAM_COUNT_PER_PAGE];
    [_collection_view reloadData];
}

- (IBAction)deselectAll:(id)sender {
    [[Common info].photo_pool removeAll];
    [[Instagram info] removeAll];
    [_collection_view reloadData];
    [self resetTitle];
}

- (IBAction)selectAll:(id)sender {
    [[Instagram info] selectAll];
    [_collection_view reloadData];
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

@end
