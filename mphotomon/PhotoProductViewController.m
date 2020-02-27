//
//  PhotoProductViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import "PhotoProductViewController.h"
#import "IDPhotosProductListViewController.h"
#import "DesignPhotoDesignViewController.h"
#import "DesignPhotoDetailViewController.h"
#import "GiftMagnetProductViewController.h"
#import "PolaroidDetailViewController.h"
#import "SingleCardDetailViewController.h"
#import "ProductTableViewController.h"
#import "WebpageViewController.h"
#import "Common.h"
#import "FrameWebViewController.h"
#import "MainTabBar.h"

@interface PhotoProduct ()
@end
@implementation PhotoProduct
@end


@interface PhotoProductViewController () <MainTabBarDelegate>

@property (weak, nonatomic) IBOutlet UIView *naviBaseview;
@property (strong, nonatomic) MainTabBar *tabBar;

@end

@implementation PhotoProductViewController

// 딥링크 관련 코드
int deeplink_idx = -1; 
UIImageView* deeplink_imageview;

- (void)didTouchTabBarWithNaviIndex:(int)index {
    
    [self dismissViewControllerAnimated:false completion:^{
        [Common info].mainTabBarOffset = [self.tabBar collectionViewOffset];
        [[Common info].main_controller moveToTargetTabBar:index];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar = [[MainTabBar alloc]initWithTargetFrame:self.naviBaseview.bounds naviIndex:2 delegate:self];
    
    [self.naviBaseview addSubview:self.tabBar];
	// 딥링크 관련 코드 ----------------------------------
	[[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-dismiss-notification" 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
		[self dismissViewControllerAnimated:NO completion:nil];
    }];
    if([Common info].deeplink_url != nil) {
            if (
                [[Common info].deeplink_url rangeOfString:@"mobile_printmain"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_print"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_designphoto"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_idphoto"].location != NSNotFound ||
                [[Common info].deeplink_url containsString:@"mobile_photobooth"] ||
                [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidmain"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_polaroidmain"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"_mobile_polaroid"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_polaroid"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"_mobile_squaresetpolaroid"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_squaresetpolaroid"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidsetpolaroid"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_polaroidsetpolaroid"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"_mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"_mobile_woodpolaroid"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_woodpolaroid"].location != NSNotFound
                
            ) {
			if ( [[Common info].deeplink_url rangeOfString:@"mobile_printmain"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidmain"].location != NSNotFound ||
                [[Common info].deeplink_url rangeOfString:@"mobile_polaroidmain"].location != NSNotFound
                ) {
				[self.navigationController setNavigationBarHidden:NO animated:NO];
				[Common info].deeplink_url= nil;
			}
			else {
				[self.navigationController setNavigationBarHidden:YES animated:YES];
				deeplink_imageview = [[Common info] showDeepLinkLaunchScreen:self.view]; 
			}
		}
    }
	// 딥링크 관련 코드 ----------------------------------

	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"보관함" style:UIBarButtonItemStylePlain target:self action:@selector(goStorage)];
    self.navigationItem.rightBarButtonItem = rightButton;

    [self loadPhotoProduct];
    [[Common info].photobook_theme loadTheme:PRODUCT_DESIGNPHOTO];
}

- (void)viewDidLayoutSubviews {
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBar updateCollectionViewOffset];

    [Common info].photobook_product_root_controller = self;
    
    // 딥링크 관련 코드
    if([Common info].deeplink_url != nil) {
		if ([[Common info].deeplink_url rangeOfString:@"mobile_print"].location != NSNotFound) {
			[UIView setAnimationsEnabled:NO];
			[self performSegueWithIdentifier:@"PhotoPrintsSegue" sender:self];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				if(deeplink_imageview != nil) [deeplink_imageview removeFromSuperview];			
				[UIView setAnimationsEnabled:YES];
				[self.navigationController setNavigationBarHidden:NO animated:NO];
			});
		}
	    else if ([[Common info].deeplink_url rangeOfString:@"mobile_idphoto"].location != NSNotFound) {
			[UIView setAnimationsEnabled:NO];
			[self performSegueWithIdentifier:@"IDPhotosSegue" sender:self];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				if(deeplink_imageview != nil) [deeplink_imageview removeFromSuperview];			
				[UIView setAnimationsEnabled:YES];
				[self.navigationController setNavigationBarHidden:NO animated:NO];
			});
		}
	    else if ([[Common info].deeplink_url rangeOfString:@"mobile_designphoto"].location != NSNotFound
                 ) {
			[UIView setAnimationsEnabled:NO];
			[self performSegueWithIdentifier:@"DesignPhotoDesignSegue" sender:self];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				if(deeplink_imageview != nil) [deeplink_imageview removeFromSuperview];			
				[UIView setAnimationsEnabled:YES];
				[self.navigationController setNavigationBarHidden:NO animated:NO];
			});
		}
        else if ([[Common info].deeplink_url rangeOfString:@"mobile_miniwallet"].location != NSNotFound
                 || [[Common info].deeplink_url rangeOfString:@"mobile_divisionphoto"].location != NSNotFound
                 || [[Common info].deeplink_url containsString:@"mobile_photobooth"]
                 ) {
            [UIView setAnimationsEnabled:NO];
            [self performSegueWithIdentifier:@"DesignPhotoDetailSegue" sender:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if(deeplink_imageview != nil) [deeplink_imageview removeFromSuperview];
                [UIView setAnimationsEnabled:YES];
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            });
        }
        else if (
                 [[Common info].deeplink_url rangeOfString:@"_mobile_polaroid"].location != NSNotFound ||
                 [[Common info].deeplink_url rangeOfString:@"mobile_polaroid"].location != NSNotFound ||
                 [[Common info].deeplink_url rangeOfString:@"_mobile_squaresetpolaroid"].location != NSNotFound ||
                 [[Common info].deeplink_url rangeOfString:@"mobile_squaresetpolaroid"].location != NSNotFound ||
                 [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidsetpolaroid"].location != NSNotFound ||
                 [[Common info].deeplink_url rangeOfString:@"mobile_polaroidsetpolaroid"].location != NSNotFound ||
                 [[Common info].deeplink_url rangeOfString:@"_mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
                 [[Common info].deeplink_url rangeOfString:@"mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
                 [[Common info].deeplink_url rangeOfString:@"_mobile_woodpolaroid"].location != NSNotFound ||
                 [[Common info].deeplink_url rangeOfString:@"mobile_woodpolaroid"].location != NSNotFound) {
            [UIView setAnimationsEnabled:NO];
            [self performSegueWithIdentifier:@"PolaroidDetailSegue" sender:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if(deeplink_imageview != nil) [deeplink_imageview removeFromSuperview];
                [UIView setAnimationsEnabled:YES];
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            });
        }
    }
}

// 딥링크 관련 코드
- (int)getIdxOfProduct:(NSString *)productCode productID:(NSString *)productID {
    int idx = 0;
    for( int i = 0 ; i < _photo_products.count ; i++ )
    {
		PhotoProduct* product = _photo_products[i];
        if ( [product.productcode isEqualToString:productCode] )
        {
            if (productID == nil || [[product pid] isEqualToString:productID])
            {
                return(idx);
            }
        }
        idx++;
    }
    return(-1);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPhotoProduct {
    if (_photo_products != nil) {
        [_photo_products removeAllObjects];
    }
    _photo_products = [[NSMutableArray alloc] init];
    
    NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:NSLocalizedString(URL_PHOTO_PRODUCT, nil)]];
    if (ret_val != nil) {
        NSXMLParser *Parser = [[NSXMLParser alloc] initWithData:ret_val];
        Parser.delegate = self;
        if (![Parser parse]) {
            NSLog(@"parse error: %@", [Parser parserError]);
            return;
        }
    }
    [_collection_view reloadData];
}

- (void)goStorage {
    [self.navigationController popToViewController:self animated:NO];
    [self performSegueWithIdentifier:@"PhotobookStorageSegue" sender:self];
}

- (Theme *)findTheme:(NSString *)theme1ID theme2ID:(NSString *)theme2ID {
    Theme *ret = nil;
    for (Theme *theme in [Common info].photobook_theme.themes){
        if ([theme.theme1_id isEqualToString:theme1ID] && [theme.theme2_id isEqualToString:theme2ID]){
            ret = theme;
            break;
        }
    }
    return ret;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /*
    if ([segue.identifier isEqualToString:@"DesignPhotoDesignSegue"]) {
        DesignPhotoDesignViewController *vc = [segue destinationViewController];
        if (vc) {
        }
    }
    */
    if ([segue.identifier isEqualToString:@"DesignPhotoDetailSegue"]) {
        DesignPhotoDetailViewController *vc = [segue destinationViewController];
        if (vc) {
            
            if ([Common info].deeplink_url != nil) {
                if ([[Common info].deeplink_url rangeOfString:@"mobile_miniwallet"].location != NSNotFound) {
                    vc.selected_theme = [self findTheme:@"defaultdepth1" theme2ID:@"miniwallet"];
                    [vc updateTheme];
                } else if ([[Common info].deeplink_url rangeOfString:@"mobile_divisionphoto"].location != NSNotFound) {
                    vc.selected_theme = [self findTheme:@"defaultdepth1" theme2ID:@"division"];
                    [vc updateTheme];
                } else if ([[Common info].deeplink_url rangeOfString:@"mobile_photobooth"].location != NSNotFound) {
                    vc.selected_theme = [self findTheme:@"defaultdepth1" theme2ID:@"photobooth"];
                    [vc updateTheme];
                }
            } else {
                
                NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
                PhotoProduct *product = _photo_products[indexPath.row];
                
                if (product) {
                    
                    Theme *theme = [self findTheme:@"defaultdepth1" theme2ID:product.pid];
                    
                    if (theme != nil) {
                        vc.selected_theme = theme;
                        [vc updateTheme];
                    } else {
                        theme = [self findTheme:product.pid theme2ID:@"DefaultTheme"];
                        if (theme != nil) {
                            vc.selected_theme = theme;
                            [vc updateTheme];
                        }
                    }
                }
                
            }
            
        }
    }
    else if ([segue.identifier isEqualToString:@"PolaroidDetailSegue"]) {
        PolaroidDetailViewController *vc = [segue destinationViewController];
        if (vc) {
            if ([Common info].deeplink_url != nil){
                if ( [[Common info].deeplink_url rangeOfString:@"_mobile_squaresetpolaroid"].location != NSNotFound ||
                    [[Common info].deeplink_url rangeOfString:@"mobile_squaresetpolaroid"].location != NSNotFound ) {
                    int idx = [self getIdxOfProduct:@"347031" productID:@"SquarePhoto"];
                    if(idx != -1) deeplink_idx = idx;
                }
                else if (
                         [[Common info].deeplink_url rangeOfString:@"_mobile_polaroidsetpolaroid"].location != NSNotFound ||
                         [[Common info].deeplink_url rangeOfString:@"mobile_polaroidsetpolaroid"].location != NSNotFound ||
                         [[Common info].deeplink_url rangeOfString:@"_mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
                         [[Common info].deeplink_url rangeOfString:@"mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
                         [[Common info].deeplink_url rangeOfString:@"_mobile_polaroid"].location != NSNotFound ||
                         [[Common info].deeplink_url rangeOfString:@"mobile_polaroid"].location != NSNotFound
                         ) {
                    int idx = [self getIdxOfProduct:@"347031" productID:@"Polaroid"];
                    if(idx != -1) deeplink_idx = idx;
                }
                else if ( [[Common info].deeplink_url rangeOfString:@"_mobile_woodpolaroid"].location != NSNotFound ||
                    [[Common info].deeplink_url rangeOfString:@"mobile_woodpolaroid"].location != NSNotFound ) {
                    int idx = [self getIdxOfProduct:@"347034" productID:nil];
                    if(idx != -1) deeplink_idx = idx;
                }
                
                if(deeplink_idx > -1) {
                    PhotoProduct *product = _photo_products[deeplink_idx];
                    
                    if (product) {
                        Theme *theme = [self findTheme:@"defaultdepth1" theme2ID:product.pid];
                        
                        if (theme != nil) {
                            vc.selected_theme = theme;
                            if ([[Common info].deeplink_url rangeOfString:@"_mobile_polaroidsetpolaroid"].location != NSNotFound ||
                                [[Common info].deeplink_url rangeOfString:@"mobile_polaroidsetpolaroid"].location != NSNotFound ||
                                [[Common info].deeplink_url rangeOfString:@"_mobile_polaroid"].location != NSNotFound ||
                                [[Common info].deeplink_url rangeOfString:@"mobile_polaroid"].location != NSNotFound){
                                [vc updateTheme:0];
                            }
                            else if(    [[Common info].deeplink_url rangeOfString:@"_mobile_minipolaroidsetpolaroid"].location != NSNotFound ||
                                    [[Common info].deeplink_url rangeOfString:@"mobile_minipolaroidsetpolaroid"].location != NSNotFound) {
                                [vc updateTheme:1];
                            } else {
                             [vc updateTheme];
                            }
                        }
                    }
                }
            }
            else {
                NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
                PhotoProduct *product = _photo_products[indexPath.row];
                
                if (product) {
                    Theme *theme = [self findTheme:@"defaultdepth1" theme2ID:product.pid];
                    
                    if (theme != nil) {
                        vc.selected_theme = theme;
                        [vc updateTheme];
                    }
                }
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"MagnetProductSegue"]) {
        GiftMagnetProductViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.product_type = PRODUCT_MAGNET;
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photo_products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoProductCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    PhotoProduct *product = _photo_products[indexPath.row];

	if (product) {
		NSString *intnum = @"";
		NSString *seqnum = @"";

		NSString *product_code = product.productcode;
		if (product_code.length == 6) {
			intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
			seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
		}

		NSString *fullpath;
		// 신규 달력 포맷
		if ([Common info].photobook.product_type == PRODUCT_CALENDAR)
			fullpath = [NSString stringWithFormat:@"%@%@", URL_CALENDAR_PAGESKIN_PATH, product.thumb];
		else
			fullpath = [NSString stringWithFormat:@"%@%@", URL_PRODUCT_THUMB_PATH, product.thumb];
		NSLog(@"fullpath : %@", fullpath);
        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];

				/*
			    if ([intnum isEqualToString:@"000"]) {
					[imageview setImage:[UIImage imageNamed:@"design_print.jpg"]];
				}
				else if ([intnum isEqualToString:@"239"]) {
					[imageview setImage:[UIImage imageNamed:@"design_identity.jpg"]];
				}
				else if ([intnum isEqualToString:@"347"]) {
					[imageview setImage:[UIImage imageNamed:@"design_DesignPrint.jpg"]];
				}
				*/
				[imageview setImage:[UIImage imageWithData:imageData]];

                UIButton *detail_btn = (UIButton *)[cell viewWithTag:101];
                CGRect frame = detail_btn.frame;
                frame.origin.x = imageview.frame.origin.x + imageview.frame.size.width - frame.size.width;
                frame.origin.y = imageview.frame.origin.y + imageview.frame.size.height - frame.size.height;
                detail_btn.frame = frame;
            }
            else {
                NSLog(@"theme's thumbnail_image is not downloaded.");
            }
        }];

        UILabel *label1 = (UILabel *)[cell viewWithTag:102];
        UILabel *label2 = (UILabel *)[cell viewWithTag:103];
        UILabel *label3 = (UILabel *)[cell viewWithTag:104];
        
        label1.text = product.productname;
        if (![intnum isEqualToString:@"000"]) {
	        label2.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[product.price intValue]]];
	        label3.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[product.discount intValue]]];
		}

        if ([intnum isEqualToString:@"000"]) {
			NSArray *row_array = [[Common info].connection.info_print_sizeinfo componentsSeparatedByString:@"|"];
			for (NSString *line in row_array) {
				if ([line isEqualToString:@""]) break;

	            NSArray *col_array = [line componentsSeparatedByString:@":"];
				if ([col_array[0] isEqualToString:@"3x4"]) continue;

				product.discount = col_array[1];
				product.price = col_array[2];

		        label2.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[product.price intValue]]];
		        label3.text = [NSString stringWithFormat:@"%@원", [[Common info] toCurrencyString:[product.discount intValue]]];

				if (![product.price isEqualToString:@""]) break;
			}
        }

        if ([product.price isEqualToString:product.discount]) {
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
    PhotoProduct *product = _photo_products[indexPath.row];
    BOOL bOpen = NO;
    if (product != nil && product.openurl != nil && ![product.openurl isEqualToString:@""]) {
        bOpen = YES;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:product.openurl]];
    }
    if (product != nil && product.webviewurl != nil && ![product.webviewurl isEqualToString:@""]) {
        bOpen = YES;
        FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
        frameWebView.webviewUrl = product.webviewurl;
        [self presentViewController:frameWebView animated:YES completion:nil];
    }
    if(!bOpen){
        NSString *intnum = @"";
        NSString *seqnum = @"";
        
        NSString *product_code = product.productcode;
        if (product_code.length == 6) {
            intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
            seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
        }
        
        if ([intnum isEqualToString:@"000"]) {
            [self performSegueWithIdentifier:@"PhotoPrintsSegue" sender:self];
        }
        else if ([intnum isEqualToString:@"239"]) {
            [self performSegueWithIdentifier:@"IDPhotosSegue" sender:self];
        }
        else if ([intnum isEqualToString:@"400"]){
            // 마그넷
            [self performSegueWithIdentifier:@"MagnetProductSegue" sender:self];
        }
        else if ([intnum isEqualToString:@"347"]) {
            // 디자인 포토임
            if ([seqnum isEqualToString:@"031"] ||
                [seqnum isEqualToString:@"034"]
                ){
                //레트로, 스퀘어
                //우드스탠드 + 폴라로이드
                [self performSegueWithIdentifier:@"PolaroidDetailSegue" sender:self];
            }
            else if ([seqnum isEqualToString:@"036"]){
                //포토카드
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotoCard24" bundle:nil];
                SingleCardDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"designPhotoDetailViewController"];
                
                if (vc) {
                    vc.selected_theme = [self findTheme:product.pid theme2ID:@"DefaultTheme"];
                    [vc updateTheme];
                }
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if ([seqnum isEqualToString:@"060"]){
                //투명포토카드
                Theme *theme = [self findTheme:@"defaultdepth1" theme2ID:product.pid];
                
                FrameWebViewController *frameWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameWebView"];
                frameWebView.webviewUrl = theme.webviewurl;
                [self presentViewController:frameWebView animated:YES completion:nil];
            }
            else if ([seqnum isEqualToString:@"037"] ||
                     [seqnum isEqualToString:@"064"] //miniwallet and division productcode from product.xml
                     
                     ){
                [self performSegueWithIdentifier:@"DesignPhotoDetailSegue" sender:self];
            }
            else {
                //기타
                [self performSegueWithIdentifier:@"DesignPhotoDesignSegue" sender:self];
            }
        }
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 1.52f; // 1.4 : 1 = width : height -> height = width*1 / 1.4
    
    return CGSizeMake(width, height + 40);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"product"]) {
        
        PhotoProduct *product = [[PhotoProduct alloc] init];

        product.idx = [attributeDict objectForKey:@"idx"];
        product.pid = [attributeDict objectForKey:@"id"];
        product.thumb = [attributeDict objectForKey:@"thumb"];
        product.productname = [attributeDict objectForKey:@"productname"];
        product.productcode = [attributeDict objectForKey:@"productcode"];
        product.price = [attributeDict objectForKey:@"minprice"];
        product.discount = [attributeDict objectForKey:@"discountminprice"];
        product.openurl = [attributeDict objectForKey:@"openurl"];
        product.webviewurl = [attributeDict objectForKey:@"webviewurl"];
        
        [_photo_products addObject:product];
    }
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

    PhotoProduct *product = _photo_products[indexPath.row];

    NSString *intnum = @"";
    NSString *seqnum = @"";

    NSString *product_code = product.productcode;
    if (product_code.length == 6) {
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
    }

    if ([intnum isEqualToString:@"000"]) {
		[self popupDetailPage:@"0"];
	}
	else if ([intnum isEqualToString:@"239"]) {
		[self popupDetailPage:@"239"];
	}
	else if ([intnum isEqualToString:@"347"]) {
		[self popupDetailPage:@"347"];
	}
	/*
    NSString *intnum = @"";
    NSString *seqnum = @"";

    NSString *product_code = product.productcode;
    if (product_code.length == 6) {
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
    }

    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, seqnum];
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
	*/
}

- (void)popupDetailPage:(NSString *)intnum {
    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, @""];
    WebpageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
