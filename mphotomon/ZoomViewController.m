//
//  ZoomViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 17..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "ZoomViewController.h"

@interface ZoomViewController ()

@end

@implementation ZoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //_thumbs = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
	if ([Common info].photobook.product_type == PRODUCT_BABY) {
		_page_control.hidden = YES;
	}
}

- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_selected_theme) {
        _page_control.numberOfPages = _selected_theme.preview_thumbs.count;
		if ([Common info].photobook.product_type == PRODUCT_BABY) {
			if(_page_control.numberOfPages > 1 )
				_page_control.hidden = NO;
		}
        return _selected_theme.preview_thumbs.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZoomCell" forIndexPath:indexPath];
    
    if (_selected_theme != nil) {


		// 썸네일 fullurl
		/*
        NSString *fullpath = @"";
        if (_product_type == PRODUCT_PHOTOBOOK) {
            NSString *thumbname = _selected_theme.preview_thumbs[indexPath.row];
            if ([_option_str isEqualToString:@"6x8"]) {
                thumbname = [thumbname stringByReplacingOccurrencesOfString:@"preview_e_" withString:@"big_preview_h_"];
            }
            else if ([_option_str isEqualToString:@"8x6"]) {
                thumbname = [thumbname stringByReplacingOccurrencesOfString:@"preview_e_" withString:@"big_preview_w_"];
            }
            else {
                thumbname = [thumbname stringByReplacingOccurrencesOfString:@"preview_e_" withString:@"big_preview_e_"];
            }
            fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, thumbname];
        }
        else if (_product_type == PRODUCT_FRAME) {
            if (indexPath.row == 0) {
                NSString *thumbname = [NSString stringWithFormat:@"big_preview_%@_%@_full_%02d.jpg", _selected_theme.theme2_id, _option_str, (int)indexPath.row+1];
                fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, thumbname];
            }
            else {
                fullpath = [NSString stringWithFormat:@"%@big_%@", [Common info].photobook_theme.thumb_url, _selected_theme.preview_thumbs[indexPath.row]];
            }
        }
        else {
            fullpath = [NSString stringWithFormat:@"%@big_%@", [Common info].photobook_theme.thumb_url, _selected_theme.preview_thumbs[indexPath.row]];
        }
		*/
        NSString *fullpath = @"";
		if([_selected_theme.preview_thumbs[indexPath.row] containsString:@"://"])                              
			fullpath = _selected_theme.preview_thumbs[indexPath.row];
		else
            fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, _selected_theme.preview_thumbs[indexPath.row]];


        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
                if (imageview.image == nil) {
                    imageview.image = [UIImage imageNamed:@"photobook_emptyphoto.png"];
                }
            }
            else {
                NSLog(@"zoomview's thumbnail_image is not downloaded.");
            }
        }];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = _collection_view.bounds.size.width;
    CGFloat height = _collection_view.bounds.size.height-20;
    
    return CGSizeMake(width, height);
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _collection_view.frame.size.width;
    int page = floor((_collection_view.contentOffset.x - pageWidth/2) / pageWidth) + 1;
    
    _page_control.currentPage = page;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
