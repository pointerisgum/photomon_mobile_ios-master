//
//  GuideSelPhotoViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 22..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "GuideSelPhotoViewController.h"

@interface GuideSelPhotoViewController ()

@end

@implementation GuideSelPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Guide" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    Theme *theme = [Common info].photobook_theme.themes[indexPath.row];
    if (theme) {
        NSString *fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, theme.main_thumb];
        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"theme's thumbnail_image is not downloaded.");
            }
        }];
        
        NSString *price = [[Common info] toCurrencyString:[theme.price intValue]];
        NSString *discount = [[Common info] toCurrencyString:[theme.discount intValue]];
        
        UILabel *label1 = (UILabel *)[cell viewWithTag:102];
        label1.text = theme.theme_name;
        UILabel *label2 = (UILabel *)[cell viewWithTag:103];
        label2.text = [NSString stringWithFormat:@"%@원", price];
        UILabel *label3 = (UILabel *)[cell viewWithTag:104];
        label3.text = [NSString stringWithFormat:@"%@원", discount];
        
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 1.4f; // 1.4 : 1 = width : height -> height = width*1 / 1.4
    
    return CGSizeMake(width, height + 40);
}

@end
