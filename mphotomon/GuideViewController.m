//
//  GuideViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 22..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "GuideViewController.h"
#import "Common.h"

@interface GuideViewController ()

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [_checkDontShow setImage:[UIImage imageNamed:@"common_check_off.png"] forState:UIControlStateNormal];
    [_checkDontShow setImage:[UIImage imageNamed:@"common_check_on.png"] forState:UIControlStateSelected];
    _checkDontShow.selected = NO;
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
    if ([_guide_id isEqualToString:GUIDE_PHOTO_SELECT]) {
        _page_control.numberOfPages = 1;
        return 1;
    }
    else if ([_guide_id isEqualToString:GUIDE_PHOTOBOOK_EDIT]) {
        _page_control.numberOfPages = 4;
        return 4;
    }
    else if ([_guide_id isEqualToString:GUIDE_CALENDAR_EDIT]) {
        _page_control.numberOfPages = 4;
        return 4;
    }
    else if ([_guide_id isEqualToString:GUIDE_POLAROID_EDIT]) {
        _page_control.numberOfPages = 2;
        return 2;
    }
    else if ([_guide_id isEqualToString:GUIDE_IDPHOTOS_CAMERA]) {
        _page_control.numberOfPages = 3;
        return 3;
    }
    else if ([_guide_id isEqualToString:GUIDE_FRAME_EDIT]) {
        _page_control.numberOfPages = 2;
        return 2;
    }
    else if ([_guide_id isEqualToString:GUIDE_SINGLE_OPTION]) {
        _page_control.numberOfPages = 1;
        return 1;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GuideCell" forIndexPath:indexPath];

    UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
    if ([_guide_id isEqualToString:GUIDE_PHOTO_SELECT]) {
        imageview.image = [UIImage imageNamed:@"appguide_photo_01.jpg"];
    }
    else if ([_guide_id isEqualToString:GUIDE_PHOTOBOOK_EDIT]) {
        NSString *image_name = [NSString stringWithFormat:@"appguide_photobook_%02d.jpg", (int)indexPath.row+1];
        imageview.image = [UIImage imageNamed:image_name];
    }
    else if ([_guide_id isEqualToString:GUIDE_CALENDAR_EDIT]) {
        NSString *image_name = [NSString stringWithFormat:@"appguide_calendar_%02d.jpg", (int)indexPath.row+1];
        imageview.image = [UIImage imageNamed:image_name];
    }
    else if ([_guide_id isEqualToString:GUIDE_POLAROID_EDIT]) {
        NSString *image_name = [NSString stringWithFormat:@"appguide_polaroid_%02d.jpg", (int)indexPath.row+1];
        imageview.image = [UIImage imageNamed:image_name];
    }
    else if ([_guide_id isEqualToString:GUIDE_IDPHOTOS_CAMERA]) {
        NSString *image_name = [NSString stringWithFormat:@"appguide_identity_step_%02d.png", (int)indexPath.row+1];
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        imageview.image = [UIImage imageNamed:image_name];
    }
    else if ([_guide_id isEqualToString:GUIDE_FRAME_EDIT]) {
        NSString *image_name = [NSString stringWithFormat:@"appguide_frame_%02d.jpg", (int)indexPath.row+1];
        imageview.image = [UIImage imageNamed:image_name];
    }
    else if ([_guide_id isEqualToString:GUIDE_SINGLE_OPTION]) {
        imageview.image = [UIImage imageNamed:@"option_guide"];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _collection_view.bounds.size;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _collection_view.frame.size.width;
    int page = floor((_collection_view.contentOffset.x - pageWidth/2) / pageWidth) + 1;
    
    _page_control.currentPage = page;
}


- (IBAction)clickDontShow:(id)sender {
    _checkDontShow.selected = !_checkDontShow.selected;
}

- (IBAction)close:(id)sender {
    NSString *is_show = _checkDontShow.selected ? @"N" : @"Y";
    [[Common info] setGuideUserDefault:_guide_id Value:is_show];

    if ([_guide_id isEqualToString:GUIDE_SINGLE_OPTION]) {
        [self.view removeFromSuperview];
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate != nil) {
            [self.delegate closeGuide];
        }
    }];
}

@end
