//
//  CardDesignViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 10..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "CardDesignViewController.h"
#import "CardDetailViewController.h"
#import "Common.h"
#import "FrameWebViewController.h"
#import "WebpageViewController.h"

@interface CardDesignViewController ()

@end

@implementation CardDesignViewController

static NSString * const reuseIdentifier = @"CardDesignCell";

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.leftBarButtonItem=nil;

	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"보관함" style:UIBarButtonItemStylePlain target:self action:@selector(goStorage)];
    self.navigationItem.rightBarButtonItem = rightButton;

	[self loadCardTheme];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goStorage {
    [self.navigationController popToViewController:self animated:NO];
    [self performSegueWithIdentifier:@"PhotobookStorageSegue" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CardDetailSegue"]) {
        CardDetailViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            vc.selected_theme = [Common info].photobook_theme.themes[indexPath.row];
            [vc updateTheme];
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Theme *theme = [Common info].photobook_theme.themes[indexPath.row];

    BOOL bOpen = NO;
    if (theme != nil && theme.openurl != nil && ![theme.openurl isEqualToString:@""]) {
        bOpen = YES;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:theme.openurl]];
    }
    if (theme != nil && theme.webviewurl != nil && ![theme.webviewurl isEqualToString:@""]) {
        bOpen = YES;
        FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
        frameWebView.webviewUrl = theme.webviewurl;
        [self presentViewController:frameWebView animated:YES completion:nil];
    }
    if(!bOpen)
        [self performSegueWithIdentifier:@"CardDetailSegue" sender:self];

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [Common info].photobook_theme.themes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    Theme *theme = [Common info].photobook_theme.themes[indexPath.row];
    if (theme) {
        NSString *url = [Common makeURLString:theme.main_thumb host:[Common info].photobook_theme.thumb_url];
        
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
	NSLog(@"_collection_view.bounds.size.width : %f", _collection_view.bounds.size.width);
    CGFloat height = width / 1.4f; // 1.4 : 1 = width : height -> height = width*1 / 1.4
    
    return CGSizeMake(width, height + 40);
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadCardTheme {
    [[Common info].photobook_theme.themes removeAllObjects];
    if ([[Common info].photobook_theme loadTheme:PRODUCT_CARD]) {
		int theme_count = (int)[Common info].photobook_theme.themes.count;
		for (int i = theme_count-1; i >= 0; i--) {
			Theme *theme = [Common info].photobook_theme.themes[i];
			
			BOOL bok = NO;
            if ([_product_code isEqualToString:@"376001"] && [theme.theme1_id isEqualToString:@"card_christmas"]) {
                bok = YES;
            }
            else if ([_product_code isEqualToString:@"377001"] && [theme.theme1_id isEqualToString:@"card_newyear"]) {
                bok = YES;
            }
            else if ([_product_code isEqualToString:@"434001"] && [theme.theme1_id isEqualToString:@"card_anniversary"]) {
                bok = YES;
            }
            else if ([_product_code isEqualToString:@"378015"] && [theme.theme1_id isEqualToString:@"card_thanks"]) {
                bok = YES;
            }
//            if ([_product_id isEqualToString:theme.theme1_id]){
//                bok = YES;
//            }
			
			if (!bok) {
				[[Common info].photobook_theme.themes removeObjectAtIndex:i];
			}
		}
	}
    [_collection_view reloadData];
}

- (IBAction)popupMore:(id)sender {
    NSString *intnum = @"";
    NSString *seqnum = @"";
    if (_product_code.length == 6) {
        intnum = [_product_code substringWithRange:NSMakeRange(0, 3)];
        seqnum = [_product_code substringWithRange:NSMakeRange(3, 3)];
    }
    
    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, seqnum];
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}


@end
