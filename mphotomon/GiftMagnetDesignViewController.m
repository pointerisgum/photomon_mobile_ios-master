//
//  GiftMagnetDesignViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 18..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "GiftMagnetDesignViewController.h"
#import "GiftMagnetDetailViewController.h"
#import "WebpageViewController.h"
#import "Common.h"
#import "FrameWebViewController.h"

@interface GiftMagnetDesignViewController ()

@end

@implementation GiftMagnetDesignViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	// 딥링크 관련 코드
    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"mobile_magnet"].location != NSNotFound ) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
        }
    }

	_autoselect_mode = NO;
	_autoselect_idx = 0;
	_autoselect_done = NO;
	_theme_loaded = NO;

    [Analysis log:@"GiftMagnetDesign"];
    
    //[Common info].photobook_root_controller = self;

	// 마그넷 : autoselect
	[[Common info].photobook_theme.themes removeAllObjects];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	// 마그넷 : autoselect
	if(_autoselect_done && _autoselect_mode) {
		UINavigationController *navigationController = self.navigationController;
		[navigationController popViewControllerAnimated:YES];
		return;
	}

	if(!_theme_loaded) {
		[self loadGiftTheme];
		_theme_loaded = YES;
	}

    [Analysis firAnalyticsWithScreenName:@"GiftMagnetDesign" ScreenClass:[self.classForCoder description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadGiftTheme {
    [[Common info].photobook_theme.themes removeAllObjects];
    if ([[Common info].photobook_theme loadTheme:_product_type]) {
        if (_product_type == PRODUCT_MAGNET) {
            int theme_count = (int)[Common info].photobook_theme.themes.count;
            for (int i = theme_count-1; i >= 0; i--) {
                Theme *theme = [Common info].photobook_theme.themes[i];
				NSString *tproductcode = @"";
				if (theme.book_infos.count > 0) tproductcode = ((BookInfo *)theme.book_infos[0]).productcode;

                if (!([theme.theme1_id isEqualToString:@"magnet"] && [[tproductcode substringWithRange:NSMakeRange(0, 3)] isEqualToString:[_product_code substringWithRange:NSMakeRange(0, 3)]])) {
                    [[Common info].photobook_theme.themes removeObjectAtIndex:i];
                }
            }
        }
    }

	// 마그넷 : autoselect
	for (int i = 0; i < [Common info].photobook_theme.themes.count; i++) {
	    Theme *theme = [Common info].photobook_theme.themes[i];
		if ([theme.autoselect isEqualToString:@"true"]) {
			_autoselect_mode = YES;
			_autoselect_idx = i;
			_autoselect_done = YES;
			[self performSegueWithIdentifier:@"GiftMagnetDetailSegue" sender:self];
			break;
		}
	}

	[_collection_view reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"GiftMagnetDetailSegue"]) {
        GiftMagnetDetailViewController *vc = [segue destinationViewController];
        if (vc) {
			// 마그넷 : autoselect
			if(_autoselect_mode == YES) {
				vc.selected_theme = [Common info].photobook_theme.themes[_autoselect_idx];
				[vc updateTheme];
			}
			else {
				NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
				vc.selected_theme = [Common info].photobook_theme.themes[indexPath.row];
				[vc updateTheme];
			}
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [Common info].photobook_theme.themes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GiftMagnetCell" forIndexPath:indexPath];
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
        if (_product_type == PRODUCT_MAGNET) {
            UILabel *label2 = (UILabel *)[cell viewWithTag:103];
            label2.text = [NSString stringWithFormat:@"%@원", price];
            
            UILabel *label3 = (UILabel *)[cell viewWithTag:104];
            label3.text = [NSString stringWithFormat:@"%@원", discount];
        }
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

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
    if(!bOpen){
        
        if (_product_type == PRODUCT_MAGNET) {
            [self performSegueWithIdentifier:@"GiftMagnetDetailSegue" sender:self];
        }
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 1.52f; // 1.4 : 1 = width : height -> height = width*1 / 1.4
    
    return CGSizeMake(width, height + 40);
}

- (IBAction)popupMore:(id)sender {
    NSString *url;

	UICollectionViewCell* cell ;
	UIButton* button = (UIButton*)sender;
	NSIndexPath *indexPath;

	@try {
		cell = (UICollectionViewCell*)[[button superview]superview];
		indexPath = [_collection_view indexPathForCell:cell];
	} 
	@catch (NSException *e) {
		@try {
			cell = (UICollectionViewCell*)[[[button superview]superview]superview];
			indexPath = [_collection_view indexPathForCell:cell];
		}
		@catch (NSException *e) {
			cell = (UICollectionViewCell*)[button superview];
			indexPath = [_collection_view indexPathForCell:cell];
		}
	}

	Theme *theme = [Common info].photobook_theme.themes[indexPath.row];
	BookInfo *book_info = theme.book_infos[0];
	NSString* productcode = book_info.productcode;
	NSString *intnum = @"";
	NSString *seqnum = @"";
	if (productcode.length == 6) {
		intnum = [productcode substringWithRange:NSMakeRange(0, 3)];
		seqnum = [productcode substringWithRange:NSMakeRange(3, 3)];
	}
	url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, seqnum];

	WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self.navigationController popToViewController:self animated:NO];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
