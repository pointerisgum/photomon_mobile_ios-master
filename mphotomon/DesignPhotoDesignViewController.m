//
//  DesignPhotoDesignViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 18..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "DesignPhotoDesignViewController.h"
#import "DesignPhotoDetailViewController.h"
#import "SingleCardDetailViewController.h"
#import "PolaroidDetailViewController.h"
#import "WebpageViewController.h"
#import "Common.h"
#import "FrameWebViewController.h"

@interface DesignPhotoDesignViewController ()

@end

@implementation DesignPhotoDesignViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.leftBarButtonItem = nil;

	// 딥링크 관련 코드
    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"mobile_designphoto"].location != NSNotFound ) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
        }
		else if ( (([[Common info].deeplink_url rangeOfString:@"_mobile_polaroid"].location != NSNotFound ||
			   [[Common info].deeplink_url rangeOfString:@"mobile_polaroid"].location != NSNotFound ||
			   [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidmain"].location != NSNotFound ||
			   [[Common info].deeplink_url rangeOfString:@"mobile_polaroidmain"].location != NSNotFound) &&
			   [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidsetpolaroid"].location == NSNotFound &&
			   [[Common info].deeplink_url rangeOfString:@"mobile_polaroidsetpolaroid"].location == NSNotFound)) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
		} else if (
            [[Common info].deeplink_url containsString:@"mobile_photobooth"]
                   ) {
            
        }
    }

    [Analysis log:@"DesignPhotoDesign"];
    
	_product_type = PRODUCT_DESIGNPHOTO;

	//[Common info].photobook_root_controller = self;
    [self loadTheme];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [Analysis firAnalyticsWithScreenName:@"DesignPhotoDesign" ScreenClass:[self.classForCoder description]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadTheme {
    [[Common info].photobook_theme.themes removeAllObjects];
    [[Common info].photobook_theme loadTheme:_product_type];
    [_collection_view reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DesignPhotoDetailSegue"]) {
        DesignPhotoDetailViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            vc.selected_theme = [Common info].photobook_theme.themes[indexPath.row];
            
            [vc updateTheme];
        }
    }
    else if ([segue.identifier isEqualToString:@"NewPolaroidDetailSegue"]) {
        PolaroidDetailViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];

            // 딥링크 관련 코드
            int idx = (int)indexPath.row;
            //if([Common info].deeplink_url != nil && deeplink_idx > -1) idx = deeplink_idx;
            vc.selected_theme = [Common info].photobook_theme.themes[idx];

            [vc updateTheme];
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DesignPhotoCell" forIndexPath:indexPath];
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

	    if ([price isEqualToString:discount]) {
			UILabel *tlabel = (UILabel *)[cell viewWithTag:105];
			label2.hidden = YES;
			tlabel.hidden = YES;
		}
		
		UILabel *label3 = (UILabel *)[cell viewWithTag:104];
		label3.text = [NSString stringWithFormat:@"%@원", discount];
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
        if(theme.book_infos.count > 0) {
            BookInfo *bookinfo = theme.book_infos[0];
            if ([bookinfo.productcode isEqualToString:@"347037"] || // 기존 네컷인화
                [bookinfo.productcode isEqualToString:@"347063"] || //미니지갑 사진 추가
                [bookinfo.productcode isEqualToString:@"347064"]  //분할사진 추가
                ) {
                [self performSegueWithIdentifier:@"DesignPhotoDetailSegue" sender:self];
            } else if ([bookinfo.productcode isEqualToString:@"347036"]) {
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotoCard24" bundle:nil];
                SingleCardDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"designPhotoDetailViewController"];
                
                if (vc) {
                    NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
                    vc.selected_theme = [Common info].photobook_theme.themes[indexPath.row];
                    [vc updateTheme];
                }
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [self performSegueWithIdentifier:@"NewPolaroidDetailSegue" sender:self];
            }
        }
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 1.52f; // 1.4 : 1 = width : height -> height = width*1 / 1.4

	// 폴라로이드 상품군을 포함하기 때문에 좀 더 height 를 줄임
    height = width / 2.65f;

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
