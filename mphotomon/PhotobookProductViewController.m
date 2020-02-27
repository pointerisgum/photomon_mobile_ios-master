//
//  PhotobookProductViewController.m
//
//
//  Created by photoMac on 2015. 9. 16..
//
//

#import "PhotobookProductViewController.h"
#import "PhotobookDesignViewController.h"
#import "PhotobookTypeViewController.h"
#import "WebpageViewController.h"
#import "Common.h"
#import "FrameWebViewController.h"
#import "MonthlyBaby/MonthlyBabyWebViewController.h"
#import "DdukddakWebViewController.h"
#import "MainTabBar.h"

@interface PhotobookProductViewController () <MainTabBarDelegate>
@property (weak, nonatomic) IBOutlet UIView *tapBaseView;
@property (strong, nonatomic) MainTabBar *tabBar;

@end

@implementation PhotobookProductViewController

// 딥링크 관련 코드
static int deeplink_idx = -1; 
static UIImageView* deeplink_imageview;

static NSString * const reuseIdentifier = @"PhotobookProductCell";

- (void)didTouchTabBarWithNaviIndex:(int)index {
    
    [self dismissViewControllerAnimated:false completion:^{
        [Common info].mainTabBarOffset = [self.tabBar collectionViewOffset];
        [[Common info].main_controller moveToTargetTabBar:index];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int index = 1;
    
    if (self.product_type == PRODUCT_CALENDAR) {
        index = 3;
    }
    
    self.tabBar = [[MainTabBar alloc]initWithTargetFrame:self.tapBaseView.bounds naviIndex:index delegate:self];
    
    [self.tapBaseView addSubview:self.tabBar];
    
    // 딥링크 관련 코드 ----------------------------------
    deeplink_idx = -1; 
    deeplink_imageview = nil;

	// 구닥북 연동 관련
	if([Common info].deeplink_url != nil) {
		// 2019.01.02
//        [self.view setHidden:YES];
//        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        _spinner.center = CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height / 2.0f);
//        CGAffineTransform transform = CGAffineTransformMakeScale(2.0f, 2.0f);
//        _spinner.transform = transform;
//        [self.view addSubview:_spinner];
//        [_spinner startAnimating];
	}

    [[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-dismiss-notification" 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"mobile_photobookmain"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_designphotobook"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_premiumphotobook"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_writingphotobook"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_instaphotobook"].location != NSNotFound ||
             [[Common info].deeplink_url rangeOfString:@"mobile_gudakbook"].location != NSNotFound // HSJ. 180827. 구닥북 딥링크 추가
            || [[Common info].deeplink_url rangeOfString:@"mobile_skinnyphotobook"].location != NSNotFound
            || [[Common info].deeplink_url rangeOfString:@"mobile_cataloga4photobook"].location != NSNotFound) {

			if ( [[Common info].deeplink_url rangeOfString:@"mobile_photobookmain"].location != NSNotFound ) {
				[self.navigationController setNavigationBarHidden:NO animated:NO];
				[Common info].deeplink_url= nil;
			}
			else {
				// 구닥북 링크 관련
				//[self.navigationController setNavigationBarHidden:YES animated:YES];
				[self.navigationController setNavigationBarHidden:YES animated:NO];

                //cmh : 앱 이 두번 실행 되는 듯한 문제 해결
                //딥링크시 메인에다가도 스크리을 씌우다. //임시용
//                deeplink_imageview = [[Common info] showDeepLinkLaunchScreen:self.view];
			}
		}
    }
    // 딥링크 관련 코드 ----------------------------------

    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidLayoutSubviews {
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBar updateCollectionViewOffset];

	if([Common info].deeplink_url == nil || [Common info].deeplink_url.length == 0) {
		[self.view setHidden:NO];
	}

    [Common info].photobook_root_controller = nil;
    //[Common info].photobook_root_controller = self;

    // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
    _photobook_type = 0;
    _bookbar.hidden = YES;
    _buttonbar_constraint.constant = 0;

    [Common info].photobook_product_root_controller = self;
    
    [self loadPhotobookProduct];

    // 딥링크 관련 코드
    if([Common info].deeplink_url != nil) {
        if ([[Common info].deeplink_url rangeOfString:@"mobile_premiumphotobook"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"362141"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_writingphotobook"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"300269"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_designphotobook"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"300221"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_instaphotobook"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"300268"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_gudakbook"].location != NSNotFound) {   // HSJ. 180827. 구닥북 딥링크 추가
            int idx = [self getIdxOfProduct:@"300478"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_skinnyphotobook"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"300180"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_cataloga4photobook"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"300180"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_tb_land"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"277007"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_tb_port"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"447002"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_tb_square"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"449001"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_tb_big"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"450001"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_tb_mini"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"448001"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_tb_wide"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"238008"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_wall"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"392001"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_sheet"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"391001"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_poster"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"393001"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_woodstand"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"369001"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_brasezel"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"455001"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_dc_single"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"368001"];
            if(idx != -1) deeplink_idx = idx;
        }
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_calendar_dc_port"].location != NSNotFound) {
            int idx = [self getIdxOfProduct:@"368112"];
            if(idx != -1) deeplink_idx = idx;
        }

        if(deeplink_idx > -1) {
            [UIView setAnimationsEnabled:NO];
            [self performSegueWithIdentifier:@"PhotobookDesignSegue" sender:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

				// 구닥북 연동 관련
				if(_spinner != nil) [_spinner removeFromSuperview];

                [UIView setAnimationsEnabled:YES];
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            });
        }
    }
}

// 딥링크 관련 코드
- (int)getIdxOfProduct:(NSString *)productCode {
    int idx = 0;
    for( int i = 0 ; i < [Common info].photobook_product.products.count ; i++ )
    {
        Product* product = [Common info].photobook_product.products[i];
        if ( [product.productcode isEqualToString:productCode] )
            return(idx);
        idx++;
    }
    return(-1);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPhotobookProduct {
    [[Common info].photobook_product.products removeAllObjects];
    [[Common info].photobook_product loadProduct:_product_type];
    [_collection_view reloadData];
}

- (void)goStorage {
    [self.navigationController popToViewController:self animated:NO];
    [self performSegueWithIdentifier:@"PhotobookStorageSegue" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PhotobookDesignSegue"]) {
        PhotobookDesignViewController *vc = (PhotobookDesignViewController *)[segue destinationViewController];
        //vc.hideTapBar = true;
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];

            // 딥링크 관련 코드
            long idx = indexPath.row;
            if([Common info].deeplink_url != nil && deeplink_idx > -1) idx = deeplink_idx;
            Product *product = [Common info].photobook_product.products[idx];

            vc.product_type = _product_type;
            if ([product.id isEqualToString:@"photobook"])
                vc.photobook_type = 0;
            else if ([product.id isEqualToString:@"insta"])
                vc.photobook_type = 1;
            else if ([product.id isEqualToString:@"analogue"])
                vc.photobook_type = 2;
            else if ([product.id isEqualToString:@"premium"])
                vc.photobook_type = 3;
			// SJYANG : 스키니북/카달로그북 추가
            else if ([product.id isEqualToString:@"skinny"])
                vc.photobook_type = 4;
            else if ([product.id isEqualToString:@"catalog"])
                vc.photobook_type = 5;
            // cmh : 구닥북 추가
            else if ([product.id isEqualToString:@"gudak"])
                vc.photobook_type = 6;
            vc.product_code = product.productcode;
            vc.product_id = product.id;
            //vc.producttype_xml = product.producttype;
            [Common info].photobook.ProductTypeXML = product.producttype;
        }
    }
    // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
    else if ([segue.identifier isEqualToString:@"PhotobookTypeSegue"]) {
        PhotobookTypeViewController *vc = (PhotobookTypeViewController *)[segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];

            // 딥링크 관련 코드
            long idx = indexPath.row;
            if([Common info].deeplink_url != nil && deeplink_idx > -1) idx = deeplink_idx;
            Product *product = [Common info].photobook_product.products[idx];

            vc.product_type = PRODUCT_PHOTOBOOK;
            vc.product_code = product.productcode;
            [Common info].photobook.ProductTypeXML = @"";
        }
    }
    else if ([segue.identifier isEqualToString:@"MonthlyBabySegue"]) {
        MonthlyBabyWebViewController *vc = (MonthlyBabyWebViewController *)[segue destinationViewController];
        if (vc) {
			vc.url = URL_MONTHLY_BABY_MAIN_URL;
            [Common info].photobook.ProductTypeXML = @"";
        }
//        PhotobookTypeViewController *vc = (PhotobookTypeViewController *)[segue destinationViewController];
//        if (vc) {
//            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
//
//            // 딥링크 관련 코드
//            long idx = indexPath.row;
//            if([Common info].deeplink_url != nil && deeplink_idx > -1) idx = deeplink_idx;
//            Product *product = [Common info].photobook_product.products[idx];
//
//            vc.product_type = PRODUCT_MONTHLYBABY;
//            vc.product_code = product.productcode;
//        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [Common info].photobook_product.products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;

    Product *product = [Common info].photobook_product.products[indexPath.row];
    if (product) {

		// 썸네일 fullurl
        NSString *fullpath = @"";
		if([product.thumb containsString:@"://"])                              
			fullpath = product.thumb;
		else
			fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_product.thumb_url, product.thumb];

		NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];

                // SJYANG
                UIButton *detail_btn = (UIButton *)[cell viewWithTag:101];
                CGRect frame = detail_btn.frame;
                frame.origin.x = imageview.frame.origin.x + imageview.frame.size.width - frame.size.width;
                frame.origin.y = imageview.frame.origin.y + imageview.frame.size.height - frame.size.height;
                detail_btn.frame = frame;
            }
            else {
                NSLog(@"product's thumbnail_image is not downloaded.");
            }
        }];
        
        NSString *price = [[Common info] toCurrencyString:[product.minprice intValue]];
        NSString *discount = [[Common info] toCurrencyString:[product.discountminprice intValue]];
        
        UILabel *label1 = (UILabel *)[cell viewWithTag:102];
        label1.text = product.productname;
        NSLog(@"%@", product.productname);

        UILabel *label2 = (UILabel *)[cell viewWithTag:103];
        label2.text = [NSString stringWithFormat:@"%@원", price];
        
        UILabel *label3 = (UILabel *)[cell viewWithTag:104];
        label3.text = [NSString stringWithFormat:@"%@원", discount];
        
        if ([price isEqualToString:discount]) {
            UILabel *label_price = (UILabel *)[cell viewWithTag:103];
            UILabel *label_strikeout = (UILabel *)[cell viewWithTag:105];
            label_price.hidden = YES;
            label_strikeout.hidden = YES;
        }
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Product *product = [Common info].photobook_product.products[indexPath.row];
    
    //openurl,webviewurl 처리 추가.
    BOOL bOpen = NO;
    if (product.openurl != nil && ![product.openurl isEqualToString:@""]) {
        bOpen = YES;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:product.openurl]];
    }
    if (product.webviewurl != nil && ![product.webviewurl isEqualToString:@""]) {
        if (![product.productcode isEqualToString:@"300502"]){
            bOpen = YES;
            FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
            frameWebView.webviewUrl = product.webviewurl;
            [self presentViewController:frameWebView animated:YES completion:nil];
        }
    }
    
    /**
     *  인스타북 : 제품 유형 -> 디자인 선택
     *  손글씨포토북 : 제품 유형 -> 디자인 선택
     *  포토북 및 기타 : 디자인 선택
     *  구닥북 : 디자인 선택
     */
    
    if(!bOpen){
        if (_product_type == PRODUCT_PHOTOBOOK) {
            
            // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
            if ([product.productcode isEqualToString:@"300268"] || [product.productcode isEqualToString:@"300269"]) {
                [self performSegueWithIdentifier:@"PhotobookTypeSegue" sender:self];        // 제품 유형
            } else if ([product.productcode isEqualToString:@"300502"]){
                [self performSegueWithIdentifier:@"MonthlyBabySegue" sender:self];
            } else if ([product.productcode isEqualToString:@"439002"]){
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Ddukddak" bundle:nil];
                DdukddakWebViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ddukddakWebViewController"];
                if (vc) {
                    vc.isIntro = YES;
                                   //vc.url = @"http://m.photomon.com/images/main_json/appevent/720x588_photomon_montly_0821.jpg";
                                   /*vc.selected_theme = [self findTheme:product.pid theme2ID:@"DefaultTheme"];
                                   [vc updateTheme];*/
                }
                [self.navigationController pushViewController:vc animated:YES];

                
                //[self performSegueWithIdentifier:@"MonthlyBabySegue" sender:self];
            } else {
                [self performSegueWithIdentifier:@"PhotobookDesignSegue" sender:self];      // 디자인 선택
            }
            
        }
        else if(_product_type == PRODUCT_CALENDAR) {
            [self performSegueWithIdentifier:@"PhotobookDesignSegue" sender:self];          // 디자인 선택
        }
    }
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 1.52f; // 1.4 : 1 = width : height -> height = width*1 / 1.4

    return CGSizeMake(width, height + 40);
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)popupMore:(id)sender {
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

    NSString *intnum = @"";
    NSString *seqnum = @"";
    Product* product = [Common info].photobook_product.products[indexPath.row];
    NSString *product_code = product.productcode;
    if (product_code.length == 6) {
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
    }

    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, seqnum];
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
