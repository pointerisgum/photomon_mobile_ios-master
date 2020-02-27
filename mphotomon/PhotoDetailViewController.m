//
//  PhotoDetailViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "PrintOptionViewController.h"
#import "PHAssetUtility.h"
#import "Common.h"

@interface PhotoDetailViewController ()
@property (strong) PHCachingImageManager *imageManager;

@end

@implementation PhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"PhotoPrintDetail"];

    _is_first = TRUE;

    _collection_view.allowsSelection = YES;
    _collection_view.allowsMultipleSelection = NO;

    _keyArray = [[NSMutableArray alloc] init];
    _keyArray = [[[Common info].photoprint.print_items allKeys] mutableCopy];

    // 사진 인화 옵션의 초기화.
    for (id key in [Common info].photoprint.print_items) {
        PrintItem *item = [[Common info].photoprint.print_items objectForKey:key];
        if (item != nil) {
            item.full_type = @"인화지풀";
            item.border_type = @"무테";
            item.light_type = @"유광";
            item.revise_type = @"밝기보정";
            item.date_type = @"적용 안함";
            item.trim_info = @"null^";//[[Common info].photoprint getDefaultTrimInfo:item]; // 기본 트리밍값 세팅
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.collection_view reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [Analysis firAnalyticsWithScreenName:@"PhotoPrintDetail" ScreenClass:[self.classForCoder description]];
    if (_is_first) {
        _is_first = FALSE;
        [self performSegueWithIdentifier:@"PrintTotalOptionSegue" sender:self];
    } else {
		[_collection_view reloadData];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    int count = (int)[Common info].photoprint.print_items.count;
    if (count < 1) {
        [[Common info] alert:self Msg:@"사진을 선택하세요."];
        return NO;
    }
    return YES;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {

}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PrintOptionSegue"]) {
        PrintOptionViewController *vc = [segue destinationViewController];
        if (vc) {
            NSArray *sel_items = [self.collection_view indexPathsForSelectedItems];
            if (sel_items != nil && sel_items.count > 0) {
                NSIndexPath *indexPath = (NSIndexPath *)sel_items[0];
                PrintItem *photo_item = [[Common info].photoprint.print_items objectForKey:_keyArray[indexPath.row]];
                if (photo_item) {
                    vc.photoItem = photo_item;
                }
            }
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _keyArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DetailCell" forIndexPath:indexPath];

    PrintItem *photo_item = [[Common info].photoprint.print_items objectForKey:_keyArray[indexPath.row]];
    if (photo_item != nil) {
        UIImageView *imageview = (UIImageView *)[cell viewWithTag:400];
        UILabel *label1 = (UILabel *)[cell viewWithTag:401];

        if (imageview != nil) {
			// SJYANG : 2017.11.07 : 일반사진인화 상품에서 수백장의 사진을 선택한 이후, 사진 리스트가 나오는 뷰에서 스크롤하면 많이 느려지는 문제 발생
//			UIImage* oriimage = [UIImage imageWithData:[[PHAssetUtility info] getImageDataForAsset:photo_item.asset]];
			UIImage* oriimage = [photo_item.photoItem getOriginal];
			/*
			UIImage* oriimage;
			{
				__block NSData *img_data;

				PHImageRequestOptions *inoptions = [[PHImageRequestOptions alloc] init];
				inoptions.networkAccessAllowed = YES;
				inoptions.synchronous = YES;
				inoptions.resizeMode = PHImageRequestOptionsResizeModeFast; // PHImageRequestOptionsResizeModeFast, PHImageRequestOptionsResizeModeNone, PHImageRequestOptionsResizeModeExact
				inoptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat; // PHImageRequestOptionsDeliveryModeFastFormat, PHImageRequestOptionsDeliveryModeOpportunistic, PHImageRequestOptionsDeliveryModeHighQualityFormat 

				@autoreleasepool {
					//[[PHImageManager defaultManager] requestImageForAsset:photo_item.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:inoptions resultHandler:^void(UIImage *image, NSDictionary *info) {
					[[PHImageManager defaultManager] requestImageForAsset:photo_item.asset targetSize:CGSizeMake(imageview.bounds.size.width, imageview.bounds.size.height) contentMode:PHImageContentModeDefault options:inoptions resultHandler:^void(UIImage *image, NSDictionary *info) {
						img_data = [[NSData dataWithData:UIImageJPEGRepresentation(image, 1)] copy];
					}];
				}

				oriimage = [UIImage imageWithData:img_data];
			}
			*/


			CGImageRef newCgIm = CGImageCreateCopy(oriimage.CGImage);
			UIImage *newimage = [UIImage imageWithCGImage:newCgIm scale:oriimage.scale orientation:oriimage.imageOrientation];


			CGSize frameSize = CGSizeMake(imageview.bounds.size.width, imageview.bounds.size.height);
			UIColor *fillColor = [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
			UIGraphicsBeginImageContextWithOptions(frameSize, YES, 0);
			CGContextRef context = UIGraphicsGetCurrentContext();
			[fillColor setFill];
			CGContextFillRect(context, CGRectMake(0, 0, frameSize.width, frameSize.height));

			//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			CGFloat x = 0, y = 0, w = 0, h = 0, bx = 0, by = 0, bw = 0, bh = 0;
            CGFloat lx = 0, ly = 0, lw = 0, lh = 0;
            
			//CGSize photoSize = [[Common info] getDimensions:photo_item.asset];
			CGSize photoSize = [[Common info] getDimensionsByUIImage:newimage];
			float photoSizeWidth = photoSize.width;
			float photoSizeHeight = photoSize.height;
			CGSize paperSize = [[Common info].photoprint getPaperSize:photo_item.size_type PhotoSize:photoSize];
			CGRect paperBorder;

			int nrotate = 0;
			UIImageOrientation norientation = [photo_item.photoItem getOrientation];
			switch (norientation) {
				case UIImageOrientationUp:    // 0도, 기본값.
				case UIImageOrientationUpMirrored:
					break;
				case UIImageOrientationDown:  // 180도
				case UIImageOrientationDownMirrored:
					nrotate = 1;
					break;
				case UIImageOrientationLeft:  // 90도
				case UIImageOrientationLeftMirrored:
					nrotate = 2;
					break;
				case UIImageOrientationRight: // -90도
				case UIImageOrientationRightMirrored:
					nrotate = 3;
					break;
			}

		    if ([photo_item.full_type isEqualToString:@"인화지풀"]) {
				CGFloat scaleFactor;
				if(photoSizeWidth >= photoSizeHeight) {
					scaleFactor = frameSize.width / photoSizeWidth;

					w = frameSize.width;
					h = photoSizeHeight * scaleFactor;
					x = 0.f;
					y = (frameSize.height - h) / 2.f;

					bw = w;
					bh = paperSize.height / paperSize.width * w;
					if( bh <= h ) {
						bx = 0.f;
						by = (frameSize.height - bh) / 2.f;
					}
					else {
						bh = h;
						bw = paperSize.width / paperSize.height * h;
						by = (frameSize.height - bh) / 2.f;
						bx = (frameSize.width - bw) / 2.f;
					}
				}
				else {
					scaleFactor = frameSize.height / photoSizeHeight;

					h = frameSize.height;
					w = photoSizeWidth * scaleFactor;
					y = 0.f;
					x = (frameSize.width - w) / 2.f;

					// bh = h 가 되어야 하는거 아닌가?
					/*
					bw = w;
					bh = paperSize.height / paperSize.width * w;
					*/
					bh = h;
					bw = paperSize.width / paperSize.height * h;
					if( bw <= w ) {
						bx = (frameSize.width - bw) / 2.f;
						by = (frameSize.height - bh) / 2.f;
					}
					else {
						// TODO
						/*
						bh = h;
						bw = paperSize.width / paperSize.height * h;
						by = (frameSize.height - bh) / 2.f;
						bx = (frameSize.width - bw) / 2.f;
						*/
						bw = w;
						bh = paperSize.height / paperSize.width * w;
						by = (frameSize.height - bh) / 2.f;
						bx = (frameSize.width - bw) / 2.f;
					}
				}

				if ([photo_item.trim_info isEqualToString:@"null^"]) {
					paperBorder = CGRectMake(bx + 1, by + 1, bw - 2, bh - 2);
				}
				else {
					NSString* trim_info = photo_item.trim_info;
					//trim_info = [trim_info stringByReplacingOccurrencesOfString:@"T_" withString:@""];
					//trim_info = [trim_info stringByReplacingOccurrencesOfString:@"L_" withString:@""];
					if(photoSizeWidth >= photoSizeHeight) {
						NSArray *arr = [trim_info componentsSeparatedByString:@","];
						int offset = [arr[0] intValue];
						offset = photo_item.offset;

						if (([trim_info hasPrefix:@"T_"] && (nrotate == 0 || nrotate == 1)) || ([trim_info hasPrefix:@"L_"] && (nrotate == 2 || nrotate == 3))) {
							//trim_info = [trim_info stringByReplacingOccurrencesOfString:@"T_" withString:@""];
							CGFloat realoffset = offset * (h / photoSizeHeight);
							paperBorder = CGRectMake(bx + 1, ((frameSize.height - h) / 2.f) + realoffset + 1, bw - 2, bh - 2);
						}
						else {
							//trim_info = [trim_info stringByReplacingOccurrencesOfString:@"L_" withString:@""];
							CGFloat realoffset = offset * (w / photoSizeWidth);
							paperBorder = CGRectMake(((frameSize.width - w) / 2.f) + realoffset + 1, by + 1, bw - 2, bh -2);
						}
					}
					else {
						NSArray *arr = [trim_info componentsSeparatedByString:@","];
						int offset = [arr[0] intValue];
						offset = photo_item.offset;

						if (([trim_info hasPrefix:@"T_"] && (nrotate == 0 || nrotate == 1)) || ([trim_info hasPrefix:@"L_"] && (nrotate == 2 || nrotate == 3))) {
							CGFloat realoffset = offset * (w / photoSizeWidth);
							paperBorder = CGRectMake(bx + 1, ((frameSize.height - h) / 2.f) + realoffset + 1, bw - 2, bh - 2);
						}
						else {
							CGFloat realoffset = offset * (h / photoSizeHeight);
							paperBorder = CGRectMake(((frameSize.width - w) / 2.f) + realoffset + 1, by + 1, bw - 2, bh - 2);
						}
					}
				}
			}
			else {
				CGFloat scaleFactor;
				if(photoSizeWidth >= photoSizeHeight) {
					scaleFactor = frameSize.width / paperSize.width;

					bw = frameSize.width;
					bh = paperSize.height * scaleFactor;
					bx = 0.f;
					by = (frameSize.height - bh) / 2.f;

					w = bw;
					h = photoSizeHeight / photoSizeWidth * w;
					if( h <= bh ) {
						x = 0.f;
						y = (frameSize.height - h) / 2.f;
					}
					else {
						h = bh;
						w = photoSizeWidth / photoSizeHeight * h;
						y = (frameSize.height - h) / 2.f;
						x = (frameSize.width - w) / 2.f;
					}
				}
				else {
					scaleFactor = frameSize.height / paperSize.height;

					bh = frameSize.height;
					bw = paperSize.width * scaleFactor;
					by = 0.f;
					bx = (frameSize.width - bw) / 2.f;


					h = bh;
					w = photoSizeWidth / photoSizeHeight * h;
					if( w <= bw ) {
						x = (frameSize.width - w) / 2.f;
						y = (frameSize.height - h) / 2.f;
					}
					else {
						/*
						h = bh;
						w = photoSizeWidth / photoSizeHeight * h;
						y = (frameSize.height - h) / 2.f;
						x = (frameSize.width - w) / 2.f;
						*/
						w = bw;
						h = photoSizeHeight / photoSizeWidth * w;
						y = (frameSize.height - h) / 2.f;
						x = (frameSize.width - w) / 2.f;
					}
				}

				paperBorder = CGRectMake(bx + 1, by + 1, bw - 2, bh - 2);
			}
            

		    if ([photo_item.full_type isEqualToString:@"인화지풀"]) {
				[newimage drawInRect:CGRectMake(x, y, w, h)];
                
                lx = paperBorder.origin.x + paperBorder.size.width - 50.0;
                ly = paperBorder.origin.y + paperBorder.size.height - 15;
                lw = 45;
                lh = 12;
                
                UILabel *dateLabel = (UILabel *)[cell viewWithTag:404];

                if ([photo_item.date_type isEqualToString:@"적용"]) {
                    
                    [self updateDateLabelWithItem:photo_item label:dateLabel optionLabel:label1 frame:CGRectMake(lx, ly, lw, lh)];
                    
                } else {
                    dateLabel.hidden = true;
                }
			}

			CGPathRef path = CGPathCreateWithRect(paperBorder, NULL);
		    if ([photo_item.full_type isEqualToString:@"인화지풀"])
				[[UIColor clearColor] setFill];
			else
				[[UIColor whiteColor] setFill];
			[[UIColor redColor] setStroke];
			CGContextAddPath(context, path);
			CGContextDrawPath(context, kCGPathFillStroke);
			CGPathRelease(path);

		    if ([photo_item.full_type isEqualToString:@"이미지풀"]) {
				[newimage drawInRect:CGRectMake(x, y, w, h)];

                UILabel *dateLabel = (UILabel *)[cell viewWithTag:404];

                if ([photo_item.date_type isEqualToString:@"적용"]) {
                    [self updateDateLabelWithItem:photo_item label:dateLabel optionLabel:label1 frame:CGRectMake(x, y+h-16, w-6, 10)];
                } else {
                    dateLabel.hidden = true;
                }
//
			}

			path = CGPathCreateWithRect(paperBorder, NULL);
			[[UIColor clearColor] setFill];
			[[UIColor redColor] setStroke];
			CGContextAddPath(context, path);
			CGContextDrawPath(context, kCGPathFillStroke);
			CGPathRelease(path);

			UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();

            imageview.image = image;
			//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        }
        
        [self updateOptionLabel:label1 item:photo_item];
  
        UILabel *label2 = (UILabel *)[cell viewWithTag:402];
        if (label2 != nil) {
            label2.text = [NSString stringWithFormat:@"%@ %@장", photo_item.size_type, photo_item.order_count];
        }
    }
    return cell;
}

-(NSDictionary*)metadataFromImageData:(NSData*)imageData{
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(imageData), NULL);
    if (imageSource) {
        NSDictionary *options = @{(NSString *)kCGImageSourceShouldCache : [NSNumber numberWithBool:NO]};
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
        if (imageProperties) {
            NSDictionary *metadata = (__bridge NSDictionary *)imageProperties;
            CFRelease(imageProperties);
            CFRelease(imageSource);
            return metadata;
        }
        CFRelease(imageSource);
    }
    
    NSLog(@"Can't read metadata");
    return nil;
}

- (void)updateOptionLabel:(UILabel *)optionLabel item:(PrintItem *)photo_item {
    if (optionLabel != nil) {
        optionLabel.text = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", photo_item.full_type, photo_item.border_type, photo_item.light_type, photo_item.revise_type, photo_item.date_type];
        optionLabel.adjustsFontSizeToFitWidth = true;
        
    }
}

- (void)updateDateLabelWithItem:(PrintItem *)item label:(UILabel *)dateLabel optionLabel:(UILabel *)optionLabel frame:(CGRect)frame {
    
    if (self.imageManager == nil) {
        self.imageManager = [[PHCachingImageManager alloc]init];
    }
	
	if (item.photoItem.positionType == PHOTO_POSITION_LOCAL) {
		LocalItem *localItem = (LocalItem *)item.photoItem;
		[self.imageManager requestImageDataForAsset:localItem.photo.asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
			NSDictionary *metadata = [self metadataFromImageData:imageData];
			NSDictionary *exifDictionary = metadata[(NSString*)kCGImagePropertyExifDictionary];
			if(exifDictionary){

				NSLog(@"exifDic: %@", exifDictionary);
				NSLog(@"%@", [exifDictionary objectForKey:@"DateTimeOriginal"]);

				if (![exifDictionary objectForKey:@"DateTimeOriginal"]) {
					dateLabel.hidden = true;
					item.date_type = @"적용 안함";

					[self updateOptionLabel:optionLabel item:item];

				} else {
					NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
					formatter.dateFormat = @"yyyy.MM.dd";

					dateLabel.text = [formatter stringFromDate:localItem.photo.asset.creationDate];
					dateLabel.frame = frame;
					dateLabel.hidden = false;
				}
			} else {
				dateLabel.hidden = true;
				item.date_type = @"적용 안함";

				[self updateOptionLabel:optionLabel item:item];
			}
		}];
	} else {
		SocialItem *socialItem = (SocialItem *)item.photoItem;
		NSDictionary *metadata = [self metadataFromImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:socialItem.mainURL]]];
		
		NSDictionary *exifDictionary = metadata[(NSString*)kCGImagePropertyExifDictionary];
		if(exifDictionary){

			NSLog(@"exifDic: %@", exifDictionary);
			NSLog(@"%@", [exifDictionary objectForKey:@"DateTimeOriginal"]);

			if (![exifDictionary objectForKey:@"DateTimeOriginal"]) {
				dateLabel.hidden = true;
				item.date_type = @"적용 안함";

				[self updateOptionLabel:optionLabel item:item];

			} else {
				NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
				formatter.dateFormat = @"yyyy.MM.dd";
				
				NSDate *date = [exifDictionary objectForKey:@"DateTimeOriginal"];

				dateLabel.text = [formatter stringFromDate:date];
				dateLabel.frame = frame;
				dateLabel.hidden = false;
			}
		} else {
			dateLabel.hidden = true;
			item.date_type = @"적용 안함";

			[self updateOptionLabel:optionLabel item:item];
		}
	}
}


#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat spacing = 5.0;
    CGFloat size = (_collection_view.bounds.size.width - spacing*3) / 2;
    return CGSizeMake(size, size + 50);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PrintItem *photo_item = [[Common info].photoprint.print_items objectForKey:_keyArray[indexPath.row]];
    if (photo_item != nil) {
        NSLog(@"selected: %@", photo_item.photoItem.key);
    }
}

- (IBAction)click_delbutton:(id)sender {
    if ([sender superview] != nil) {
        // iOS 7 이상은 super's super. 이전에는 그냥 super.
        if ([[sender superview] superview] != nil) {
            UICollectionViewCell *cell = (UICollectionViewCell*)[[sender superview] superview];
            if (cell != nil) {
                NSIndexPath *indexPath = [self.collection_view indexPathForCell:cell];
                if (indexPath) {
                    PrintItem *photo_item = [[Common info].photoprint.print_items objectForKey:_keyArray[indexPath.row]];
                    if (photo_item) {
						NSLog(@"selected: %@", photo_item.photoItem.key);
                    }
                }
                [[Common info].photoprint.print_items removeObjectForKey:_keyArray[indexPath.row]];
                [_keyArray removeObjectAtIndex:indexPath.row];
                [self.collection_view deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                [self.collection_view reloadData];
            }
        }
    }
}
@end
