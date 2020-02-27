//
//  BabyProductViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "BabyProductViewController.h"
#import "BabyDetailViewController.h"
#import "WebpageViewController.h"
#import "Common.h"
#import "FrameWebViewController.h"
#import "MainTabBar.h"

@interface BabyProductViewController ()<MainTabBarDelegate>
@property (weak, nonatomic) IBOutlet UIView *tabBaseview;
@property (strong, nonatomic) MainTabBar *tabBar;

@end

@implementation BabyProductViewController

- (void)didTouchTabBarWithNaviIndex:(int)index {
    
    [self dismissViewControllerAnimated:false completion:^{
        [Common info].mainTabBarOffset = [self.tabBar collectionViewOffset];
        [[Common info].main_controller moveToTargetTabBar:index];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar = [[MainTabBar alloc]initWithTargetFrame:self.tabBaseview.bounds naviIndex:7 delegate:self];
    
    [self.tabBaseview addSubview:self.tabBar];
    

	// 딥링크 관련 코드 ----------------------------------
	[[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-dismiss-notification" 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
		[self dismissViewControllerAnimated:NO completion:nil];
    }];
    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"mobile_baby"].location != NSNotFound ) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
		}
    }
	// 딥링크 관련 코드 ----------------------------------

    [Analysis log:@"BabyDesign"];
	_product_type = PRODUCT_BABY;
	
    [self loadBabyTheme];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Analysis firAnalyticsWithScreenName:@"BabyDesign" ScreenClass:[self.classForCoder description]];
}

- (void)viewDidLayoutSubviews {
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBar updateCollectionViewOffset];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadBabyTheme {
    [[Common info].photobook_theme.themes removeAllObjects];
    [[Common info].photobook_theme loadTheme:PRODUCT_BABY];
    [_collection_view reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"BabyDetailSegue"]) {
        BabyDetailViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            vc.selected_theme = [Common info].photobook_theme.themes[indexPath.row];
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BabyCell" forIndexPath:indexPath];
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
        [self performSegueWithIdentifier:@"BabyDetailSegue" sender:self];

    
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

- (IBAction)cancel:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
