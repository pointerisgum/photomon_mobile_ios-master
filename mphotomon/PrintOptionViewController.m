//
//  PrintOptionViewController.m
//  photoprint
//
//  Created by photoMac on 2015. 7. 3..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "PrintOptionViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "PHAssetUtility.h"
#import "GuideViewController.h"

@interface PrintOptionViewController ()<GuideDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *ivDate;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong) PHCachingImageManager *imageManager;

@end

@implementation PrintOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[Common info] checkGuideUserDefault:GUIDE_SINGLE_OPTION]) {
        GuideViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GuidePage"];
        if (vc) {
            vc.guide_id = GUIDE_SINGLE_OPTION;
            vc.delegate = self;
            [self addChildViewController:vc];
            [self.view addSubview:vc.view];
//            [self presentViewController:vc animated:YES completion:nil];
        }
    }
    
    [Analysis log:@"PhotoPrintOptionAndTrimming"];
    
    if (_photoItem) {
        _paperView = [[UIScrollView alloc] init];
        _paperView.backgroundColor = [UIColor whiteColor];
        _paperView.bounces = NO;
        _paperView.clipsToBounds = NO;
        //_paperView.layer.borderColor = [UIColor colorWithRed:1.0f/255.0f green:255.0f/255.0f blue:1.0f/255.0f alpha:0.8f].CGColor;
        _paperView.layer.borderColor = [UIColor greenColor].CGColor;
        _paperView.layer.borderWidth = 1.0f;
        _paperView.delegate = self;
        
        _photoView = [[UIImageView alloc] init];
        _photoView.backgroundColor = [UIColor redColor];
        _photoView.image = [_photoItem.photoItem getOriginal];

        [_backView addSubview:_paperView];
        [_paperView addSubview:_photoView];
#if 0
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapPiece:)];
        tapGesture.numberOfTapsRequired = 1;
        [_paperView addGestureRecognizer:tapGesture];
        
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        swipeGesture.numberOfTouchesRequired = 1;
        swipeGesture.delegate = self;
        [self.view addGestureRecognizer:swipeLeft];
#endif
        // init control value.
        _printAmount.text = _photoItem.order_count;
        [_printSize setTitle:_photoItem.size_type forState:UIControlStateNormal];
        _printFullType.selectedSegmentIndex = [_photoItem.full_type isEqualToString:@"인화지풀"] ? 0 : 1;
        _printBorder.selectedSegmentIndex = [_photoItem.border_type isEqualToString:@"무테"] ? 0 : 1;
        _printSurfaceType.selectedSegmentIndex = [_photoItem.light_type isEqualToString:@"유광"] ? 0 : 1;
        _printRevise.selectedSegmentIndex = [_photoItem.revise_type isEqualToString:@"밝기보정"] ? 0 : 1;
        
        // border setting
        _printAmount.layer.borderColor = [UIColor colorWithRed:250.0f/255.0f green:162.0f/255.0f blue:13.0f/255.0f alpha:0.5f].CGColor;
        _printAmount.layer.borderWidth = 1.5;
        _printAmount.layer.zPosition = -1;
        
        _printSize.layer.borderColor = [UIColor colorWithRed:250.0f/255.0f green:162.0f/255.0f blue:13.0f/255.0f alpha:0.5f].CGColor;
        _printSize.layer.borderWidth = 1.5;
        _printSize.layer.zPosition = -1;

        _currentPrintSize = _photoItem.size_type;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [Analysis firAnalyticsWithScreenName:@"PhotoPrintOptionAndTrimming" ScreenClass:[self.classForCoder description]];
    if (_photoItem) {
        _dateLabel = nil;
        [self updatePreview:YES];
    }
}
/*
- (void)singleTapPiece:(id)sender {
    NSLog(@"touched");
}
*/
- (void)updatePreview:(BOOL)is_load {
    //(_printFullType.selectedSegmentIndex == 0); // 인화지풀
    CGSize paperSize = [[Common info].photoprint getPaperSize:_currentPrintSize PhotoSize:_photoView.image.size];

    // trimming scene's view_hierachy: backView > paperView > photoView
    CGRect smallerRect = CGRectMake(_backView.bounds.origin.x+10, _backView.bounds.origin.y+10, _backView.bounds.size.width - 20, _backView.bounds.size.height - 20);
    
    CGRect backRect = CGRectInset(smallerRect, 35, 35);
    
    // 1. 배경 영역에 내접하는 인화지 영역 생성
    CGRect scaledPaperRect = [[Common info] getScaledRect:backRect.size src:paperSize isInnerFit:YES];
    scaledPaperRect.origin.x += backRect.origin.x;
    scaledPaperRect.origin.y += backRect.origin.y;
    [_paperView setFrame:scaledPaperRect];

    // 2. 인화지 영역에 내접/외접하는 사진 영역 생성
    CGSize photoSize = _photoView.image.size;
    if (_printFullType.selectedSegmentIndex == 0) { // 인화지풀 (scroll)
        CGRect scaledImageRect = [[Common info] getScaledRect:scaledPaperRect.size src:photoSize isInnerFit:NO];
        CGPoint offset = CGPointMake(-scaledImageRect.origin.x, -scaledImageRect.origin.y);

        if (is_load) {
            if (_photoItem.scroll_offset.x != CGFLOAT_MAX && _photoItem.scroll_offset.y != CGFLOAT_MAX) {
                offset = _photoItem.scroll_offset;
            }
        }

        scaledImageRect.origin = CGPointZero;
        [_photoView setFrame:scaledImageRect];
        [_paperView setContentSize:CGSizeMake(_photoView.frame.size.width, _photoView.frame.size.height)];
        [_paperView setContentOffset:offset];
    }
    else {                                          // 이미지풀 (no scroll) - 이미지가 잘리지 않고 전부 나오도록.
        CGRect scaledImageRect = [[Common info] getScaledRect:scaledPaperRect.size src:photoSize isInnerFit:YES];
        [_photoView setFrame:scaledImageRect];
        [_paperView setContentSize:CGSizeMake(_photoView.frame.size.width, _photoView.frame.size.height)];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateDateLabel];
    });
    
}

+(CGSize)imageWithImage: (CGRect)sourceImageRect scaledToWidth: (float) i_width
{
    float oldWidth = sourceImageRect.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImageRect.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    return CGSizeMake(newWidth, newHeight);
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

- (void)updateDateLabel {
    
    if ([_photoItem.date_type isEqualToString:@"적용 안함"]) {
        _ivDate.highlighted = false;
        _dateLabel.hidden = true;
        [_dateLabel removeFromSuperview];
        _dateLabel = nil;
        
    } else {
        
        if (self.imageManager == nil) {
            self.imageManager = [[PHCachingImageManager alloc]init];
        }
		
		[self.dateLabel removeFromSuperview];
		self.dateLabel = nil;
		
		self.ivDate.highlighted = true;
		
		// 여백 제외한 순수 이미지 사이즈
		CGSize newImageSize = [PrintOptionViewController imageWithImage:CGRectMake(0, 0, self.photoView.image.size.width, self.photoView.image.size.height) scaledToWidth:self.paperView.frame.size.width];
		
		
		if (self.dateLabel == nil) {
			
			// 개별 옵션 화면
			// 이미지풀
			if (self.printFullType.selectedSegmentIndex == 1) {
				
				if (newImageSize.width < newImageSize.height) {
					// 세로일경우
					CGFloat letftMargin = self.photoView.frame.size.width - newImageSize.width;
					self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(letftMargin
																			  ,CGRectGetMaxY(self.photoView.frame) - 38
																			  , newImageSize.width - 18
																			  , 15.0f)];
					
				} else {
					
					// 가로일경우
					CGFloat topMargin = self.photoView.frame.size.height - newImageSize.height;
					self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.photoView.frame.size.width - 125.0f
																			  ,topMargin + newImageSize.height - 23.0
																			  , 113.0f
																			  , 15.0f)];
					
				}
				[self.photoView addSubview:self.dateLabel];
			}
			else {
				// 인화지풀
				self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.paperView.frame.origin.x + self.paperView.frame.size.width -123.0f
																		  ,self.paperView.frame.origin.y  + self.paperView.frame.size.height - 38.0f
																		  , 108.0f
																		  , 38.0f)];
				[self.backView addSubview:_dateLabel];
			}
			
			self.dateLabel.font = [UIFont systemFontOfSize:10.0];
			self.dateLabel.textColor = [UIColor whiteColor];
			self.dateLabel.font = [UIFont systemFontOfSize:9.0f];
			self.dateLabel.textAlignment = NSTextAlignmentRight;
			
		}
        
		
		if (_photoItem.photoItem.positionType == PHOTO_POSITION_LOCAL) {
			LocalItem *localItem = (LocalItem *)_photoItem.photoItem;
			[self.imageManager requestImageDataForAsset:localItem.photo.asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
				NSDictionary *metadata = [self metadataFromImageData:imageData];
				NSDictionary *exifDictionary = metadata[(NSString*)kCGImagePropertyExifDictionary];
				if(exifDictionary){
					NSLog(@"EXIF: %@", exifDictionary.description);

					if (![exifDictionary objectForKey:@"DateTimeOriginal"]) {
						[self.dateLabel removeFromSuperview];
						self.dateLabel = nil;
						[self.view makeToast:@"촬영일자가 없는 사진은 촬영일을 넣을 수 없습니다."];
						self.photoItem.date_type = @"적용 안함";
						self.ivDate.highlighted = false;
						return;
					} else {

						[self.dateLabel removeFromSuperview];
						self.dateLabel = nil;

						self.ivDate.highlighted = true;

						// 여백 제외한 순수 이미지 사이즈
						CGSize newImageSize = [PrintOptionViewController imageWithImage:CGRectMake(0, 0, self.photoView.image.size.width, self.photoView.image.size.height) scaledToWidth:self.paperView.frame.size.width];


						if (self.dateLabel == nil) {

							// 개별 옵션 화면
							// 이미지풀
							if (self.printFullType.selectedSegmentIndex == 1) {

								if (newImageSize.width < newImageSize.height) {
									// 세로일경우
									CGFloat letftMargin = self.photoView.frame.size.width - newImageSize.width;
									self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(letftMargin
																						  ,CGRectGetMaxY(self.photoView.frame) - 38
																						  , newImageSize.width - 18
																						  , 15.0f)];

								} else {

									// 가로일경우
									CGFloat topMargin = self.photoView.frame.size.height - newImageSize.height;
									self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.photoView.frame.size.width - 125.0f
																						  ,topMargin + newImageSize.height - 23.0
																						  , 113.0f
																						  , 15.0f)];

								}
								[self.photoView addSubview:self.dateLabel];
							}
							else {
								// 인화지풀
								self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.paperView.frame.origin.x + self.paperView.frame.size.width -123.0f
																					  ,self.paperView.frame.origin.y  + self.paperView.frame.size.height - 38.0f
																					  , 108.0f
																					  , 38.0f)];
								[self.backView addSubview:_dateLabel];
							}

							self.dateLabel.font = [UIFont systemFontOfSize:10.0];
							self.dateLabel.textColor = [UIColor whiteColor];
							self.dateLabel.font = [UIFont systemFontOfSize:9.0f];
							self.dateLabel.textAlignment = NSTextAlignmentRight;

						}

						NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
						formatter.dateFormat = @"yyyy.MM.dd";

						self.dateLabel.text = [formatter stringFromDate:localItem.photo.asset.creationDate];
						self.dateLabel.hidden = false;
					}
				} else {
					[self.dateLabel removeFromSuperview];
					self.dateLabel = nil;
					[self.view makeToast:@"촬영일자가 없는 사진은 촬영일을 넣을 수 없습니다."];
					self.photoItem.date_type = @"적용 안함";
					self.ivDate.highlighted = false;
				}

			}];
		}
		else {
			SocialItem *socialItem = (SocialItem *)_photoItem.photoItem;
			NSDictionary *metadata = [self metadataFromImageData:[NSData dataWithContentsOfURL:[NSURL URLWithString:socialItem.mainURL]]];
			
			NSDictionary *exifDictionary = metadata[(NSString*)kCGImagePropertyExifDictionary];
			if(exifDictionary){

				NSLog(@"exifDic: %@", exifDictionary);
				NSLog(@"%@", [exifDictionary objectForKey:@"DateTimeOriginal"]);

				if (![exifDictionary objectForKey:@"DateTimeOriginal"]) {
					[self.dateLabel removeFromSuperview];
					self.dateLabel = nil;
					[self.view makeToast:@"촬영일자가 없는 사진은 촬영일을 넣을 수 없습니다."];
					self.photoItem.date_type = @"적용 안함";
					self.ivDate.highlighted = false;
					return;
				} else {
					NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
					formatter.dateFormat = @"yyyy.MM.dd";

					self.dateLabel.text = [_photoItem.photoItem getCreationDate:@"yyyy.MM.dd"];
					self.dateLabel.hidden = false;
				}
			} else {
				[self.dateLabel removeFromSuperview];
				self.dateLabel = nil;
				[self.view makeToast:@"촬영일자가 없는 사진은 촬영일을 넣을 수 없습니다."];
				self.photoItem.date_type = @"적용 안함";
				self.ivDate.highlighted = false;
			}
		}
    }
        
}

- (NSString *)getCurrentTrimInfo {
	/*
    CGSize photoSizeT = [[Common info] getDimensions:_photoItem.asset];
    CGSize photoSize = CGSizeMake(photoSizeT.width * 2, photoSizeT.height * 2);
	*/
//    CGSize photoSize = [[Common info] getDimensions:_photoItem.asset];
	CGSize photoSize = [_photoItem.photoItem getDimension];
    CGSize paperSize = [[Common info].photoprint getPaperSize:_currentPrintSize PhotoSize:photoSize];
    
    CGFloat scaleFactor = [[Common info] getScale:paperSize src:photoSize isInnerFit:NO];
    
    // contentSize : scrollOffset = imageSize : imageOffset?;
    // imageOffset? = (scrollOffset * imageSize) / contentSize;
    NSString *trim_info = @"null^";
    if ([[Common info] isHorzDirection:photoSize src:paperSize]) { //photoSize.width > photoSize.height) {
        int offset = (int)(_paperView.contentOffset.x * photoSize.width) / _paperView.contentSize.width;
        int length = (int)(paperSize.width / scaleFactor);
		_photoItem.offset = offset;
        trim_info = [[Common info].photoprint makeTrimString:@"L" Size:photoSize Offset:offset Length:length Orientation:[_photoItem.photoItem getOrientation]];
        //offset += [[PhotomonInfo sharedInfo] checkValidateOffset:offset Length:length MaxSize:photoSize.width];
        //trim_info = [NSString stringWithFormat:@"L_%d,%d", offset, length];

		// 트리밍 오류 관련
		if( length > (int)photoSize.width ) {
			NSLog(@"!!! >>> ERROR2 : length : %d", length);
			NSLog(@"!!! >>> ERROR2 : (int)photoSize.width : %d", (int)photoSize.width);
			NSLog(@"!!! >>> ERROR2 : (int)photoSize.height : %d", (int)photoSize.height);
			return @"error2!!!";
		}

		/*
		// 트리밍 오류 관련
		if( length == 2287 || length == 897 ) {
			NSLog(@"!!! >>> ERROR2 : length : %d", length);
			NSLog(@"!!! >>> ERROR2 : (int)photoSize.width : %d", (int)photoSize.width);
			NSLog(@"!!! >>> ERROR2 : (int)photoSize.height : %d", (int)photoSize.height);
			return @"error1!!!";
		}
		*/
	}
    else {
        int offset = (int)(_paperView.contentOffset.y * photoSize.height) / _paperView.contentSize.height;
        int length = (int)(paperSize.height / scaleFactor);
		_photoItem.offset = offset;
		NSLog(@"_paperView.contentOffset.y : %f", _paperView.contentOffset.y);
		NSLog(@"photoSize.height : %f", photoSize.height);
		NSLog(@"_paperView.contentSize.height : %f", _paperView.contentSize.height);
        trim_info = [[Common info].photoprint makeTrimString:@"T" Size:photoSize Offset:offset Length:length Orientation:[_photoItem.photoItem getOrientation]];
        //offset += [[PhotomonInfo sharedInfo] checkValidateOffset:offset Length:length MaxSize:photoSize.height];
        //trim_info = [NSString stringWithFormat:@"T_%d,%d", offset, length];

		// 트리밍 오류 관련
		if( length > (int)photoSize.height ) {
			NSLog(@"!!! >>> ERROR2 : length : %d", length);
			NSLog(@"!!! >>> ERROR2 : (int)photoSize.width : %d", (int)photoSize.width);
			NSLog(@"!!! >>> ERROR2 : (int)photoSize.height : %d", (int)photoSize.height);
			return @"error2!!!";
		}

		/*
		// 트리밍 오류 관련
		if( length == 2287 || length == 897 ) {
			NSLog(@"!!! >>> ERROR2 : length : %d", length);
			NSLog(@"!!! >>> ERROR2 : (int)photoSize.width : %d", (int)photoSize.width);
			NSLog(@"!!! >>> ERROR2 : (int)photoSize.height : %d", (int)photoSize.height);
			return @"error1!!!";
		}
		*/
    }

	NSLog(@"now trim: %@ (paper:%dx%d, photo:%dx%d)", trim_info, (int)paperSize.width, (int)paperSize.height, (int)photoSize.width, (int)photoSize.height);
    _photoItem.scroll_offset = _paperView.contentOffset;
    return trim_info;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickMinus:(id)sender {
    int value = [_printAmount.text intValue];
    if (value > 1) {
        _printAmount.text = [NSString stringWithFormat:@"%d", value-1];
        //[self isAllCheckPrintAmount:_printAmount.text] ? [_printAmountAll setSelected:TRUE] : [_printAmountAll setSelected:FALSE];
    }
}

- (IBAction)clickPlus:(id)sender {
    int value = [_printAmount.text intValue];
    if (value > 0) {
        _printAmount.text = [NSString stringWithFormat:@"%d", value+1];
        //[self isAllCheckPrintAmount:_printAmount.text] ? [_printAmountAll setSelected:TRUE] : [_printAmountAll setSelected:FALSE];
    }
}

- (IBAction)clickPrintSize:(id)sender {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"사이즈 선택"
                                                                message:@"원하는 인화지 사이즈를 선택하세요."
                                                         preferredStyle:UIAlertControllerStyleActionSheet];

    for (int i = 0; i < [Common info].photoprint.types.count; i++) {
        NSString *size_caption = [NSString stringWithFormat:@"%@ (%@)", [Common info].photoprint.types[i], [Common info].photoprint.sizes[i]];
        UIAlertAction *alert_action = [UIAlertAction actionWithTitle:size_caption
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action)
                                       {
                                           NSString *selected_size = [Common info].photoprint.types[i];
                                           
                                           // 대형인화는 유광만 가능. 현재 옵션이 전체 유광이 아닌 경우에는 알려주고 전체 유광으로 변경한다.
                                           if ([selected_size isEqualToString:@"8x10"] || [selected_size isEqualToString:@"A4"]) {
                                               [self.view makeToast:@"대형인화(8x10, A4)가 포함된 경우,\n'유광' 옵션만 가능합니다."];
                                               [[Common info].photoprint resetSurfaceType];
                                           }
                                           
                                           _currentPrintSize = selected_size;
                                           [_printSize setTitle:selected_size forState:UIControlStateNormal];
                                           [_printSize setTitle:selected_size forState:UIControlStateSelected];
                                           
                                           [self updatePreview:NO];
                                           //[self isAllCheckPrintSize:selected_size] ? [_printSizeAll setSelected:TRUE] : [_printSizeAll setSelected:FALSE];
                                           
                                           [vc dismissViewControllerAnimated:YES completion:nil];
                                       }];
        [vc addAction:alert_action];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)changedFullType:(id)sender {
    //NSString *full_type = (_printFullType.selectedSegmentIndex == 0) ? @"인화지풀" : @"이미지풀";
    //[self isAllCheckPrintFullType:full_type] ? [_printFullTypeAll setSelected:TRUE] : [_printFullTypeAll setSelected:FALSE];
    [self updatePreview:NO];
}

- (IBAction)changedBorder:(id)sender {
    //NSString *border_type = (_printBorder.selectedSegmentIndex == 0) ? @"무테" : @"유테";
    //[self isAllCheckPrintBorder:border_type] ? [_printBorderAll setSelected:TRUE] : [_printBorderAll setSelected:FALSE];
}

- (IBAction)changedSurfaceType:(id)sender {
    //NSString *surface_type = (_printSurfaceType.selectedSegmentIndex == 0) ? @"유광" : @"무광";
    //[self isAllCheckPrintSurfaceType:surface_type] ? [_printSurfaceTypeAll setSelected:TRUE] : [_printSurfaceTypeAll setSelected:FALSE];
}

- (IBAction)changedRevise:(id)sender {
    //NSString *revise_type = (_printRevise.selectedSegmentIndex == 0) ? @"밝기보정" : @"무보정";
    //[self isAllCheckPrintRevise:revise_type] ? [_printReviseAll setSelected:TRUE] : [_printReviseAll setSelected:FALSE];
}

- (IBAction)done:(id)sender {
	_photoItem.order_count = _printAmount.text;
    _photoItem.size_type = _currentPrintSize; // _printSize.titleLabel.text;
    _photoItem.border_type = (_printBorder.selectedSegmentIndex == 0) ? @"무테" : @"유테";
    //_photoItem.light_type = (_printSurfaceType.selectedSegmentIndex == 0) ? @"유광" : @"무광";
    _photoItem.revise_type = (_printRevise.selectedSegmentIndex == 0) ? @"밝기보정" : @"무보정";
    
    if (_printFullType.selectedSegmentIndex == 0) {
        _photoItem.full_type = @"인화지풀";
        _photoItem.trim_info = [self getCurrentTrimInfo];
    }
    else {
        _photoItem.full_type = @"이미지풀";
        _photoItem.trim_info = @"null^";
    }

	// 트리밍 오류 관련
	if( [[self getCurrentTrimInfo] isEqualToString:@"error1!!!"] ) {
        _photoItem.trim_info = @"null^";

        [[Common info]alert:self Title:@"죄송합니다. 해당 사진은 모바일로 영역 선택을 하실 수 없습니다.\n해당 사진의 영역을 선택하시려면 PC 버전을 사용해 주시기 바랍니다." Msg:@"" completion:^{
            NSString *logstr = [NSString stringWithFormat:@"[TRIMMING_ERROR1] dimension_type : %@, platform : %@", [Common info].dimension_type, [[Common info] getPlatformType]];
            [[Common info] logToDevServer:logstr];
        }];

		return;
	}
	if( [[self getCurrentTrimInfo] isEqualToString:@"error2!!!"] ) {
        _photoItem.trim_info = @"null^";

        [[Common info]alert:self Title:@"사진 영역 선택에 오류가 있습니다.\n다시 한 번 사진 영역을 선택해 주세요." Msg:@"" completion:^{
            NSString *logstr = [NSString stringWithFormat:@"[TRIMMING_ERROR2] dimension_type : %@, platform : %@", [Common info].dimension_type, [[Common info] getPlatformType]];
            [[Common info] logToDevServer:logstr];
        }];
		return;
	}

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
//    NSLog(@"scrolled...");
}

- (IBAction)didTouchDateButton:(UIButton *)sender {
    self.ivDate.highlighted = !self.ivDate.isHighlighted;
    self.photoItem.date_type = self.ivDate.isHighlighted ? @"적용" : @"적용 안함";
    
    [self updateDateLabel];
}

@end

