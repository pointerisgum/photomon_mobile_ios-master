//
//  CollageEditViewController.m
//  PHOTOMON
//
//  Created by ios_dev on 2016. 1. 26..
//  Copyright © 2016년 maybeone. All rights reserved.
//
// thumbRectForBounds:trackRect:value:


#import "CollageEditViewController.h"
#import "SelectAlbumViewController.h"
#import "GuideViewController.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "UIImage+Rotation.h"
#import "Collage.h"
#import "Util.h"
#import "FrameUploadViewController.h"
#import "Instagram.h"
#import "PHAssetUtility.h"

@interface CollageEditViewController ()

@end

@implementation CollageEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _is_first = YES;
    _thread = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];

    self.cellScrollView = [[UIScrollView alloc] init];
    self.cellImageView = [[UIImageView alloc] init];
    //self.cellBackView = [[UIImageView alloc] init];
    //self.cellBorderView = [[UIView alloc] init];

    [self.cellEditView addSubview:self.cellScrollView];
    [self.cellScrollView addSubview:self.cellImageView];
    //[self.cellEditView addSubview:self.cellBorderView];
    //[self.cellEditView addSubview:self.cellBackView];

    self.cellScrollView.backgroundColor = [UIColor clearColor];
    self.cellScrollView.bounces = NO;
    self.cellScrollView.clipsToBounds = NO;
    self.cellScrollView.userInteractionEnabled = YES;
    self.cellScrollView.scrollEnabled = YES;
    self.cellScrollView.minimumZoomScale = 1.f;
    self.cellScrollView.maximumZoomScale = 3.f;
    self.cellScrollView.delegate = self;
    self.cellScrollView.layer.borderWidth = 2.f;
    self.cellScrollView.layer.borderColor = [UIColor yellowColor].CGColor;
    
    self.editCell = nil;
    self.dummyCell = [[Cell alloc] init];
    self.dummyCell.hidden = YES;
    [self.view addSubview:self.dummyCell];

    _popupBorder.hidden = YES;
    _popupLayout.hidden = YES;
    
    for (int i = 100; i < 106; i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
#if 1
    [_slider_gap_thumb setThumbImage:[UIImage imageNamed:@"collage_dot_on.png"] forState:UIControlStateNormal];
    [_slider_round_thumb setThumbImage:[UIImage imageNamed:@"collage_dot_on.png"] forState:UIControlStateNormal];
    [_slider_color_thumb setThumbImage:[UIImage imageNamed:@"collage_dot_on.png"] forState:UIControlStateNormal];

    [_slider_gap_thumb setThumbImage:[UIImage imageNamed:@"collage_dot_on.png"] forState:UIControlStateHighlighted];
    [_slider_round_thumb setThumbImage:[UIImage imageNamed:@"collage_dot_on.png"] forState:UIControlStateHighlighted];
    [_slider_color_thumb setThumbImage:[UIImage imageNamed:@"collage_dot_on.png"] forState:UIControlStateHighlighted];
#endif
    _slider_color_thumb.minimumValue = 0;
    _slider_color_thumb.maximumValue = [_color_view maxValue]-1;

    _gap_label.text = @"0";
    _round_label.text = @"0";
    _color_label.text = @"";
    _color_value.hidden = YES;
    
    // backview는 dim 처리 문제가 있어서 안함, border는 뷰오더 문제로 스크롤뷰에 터치가 전달 안되는 문제가 있어 숨김.
    //self.cellBackView.hidden = YES;
    //self.cellBorderView.hidden = YES;
    
    self.deleteView.alpha = 0.f;
    [self.view bringSubviewToFront:self.deleteView];
    
    // Delegate 연결
    //
    self.collage.delegate = self;
    
    
    // Collage의 ratio를 설정한다.
    //
    // set inch info
    [self.collage setInchAndRatio:[Common info].photobook.ProductSize];
    //self.collage.ratio = CGSizeMake(1000.f, 1000.f);
    
    
    if (_guideImage && ![_guideImage isEqual:@""]) {
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:_guideImage] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImage *guideImage = [UIImage imageWithData:imageData];
                [self.collage setGuideInfo:guideImage];
            }
            else {
                NSLog(@"guideimage is setted but there is no image in url");
            }
        }];
    }

    // Border 테두리 설정
    //
    //self.cellBorderView.layer.masksToBounds = YES;
    //self.cellBorderView.layer.borderWidth = 2.f;
    //self.cellBorderView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // bring top
    for (int i = 200; i <= 202; i++) {
        UIView *view = (UIView *)[self.cellEditView viewWithTag:i];
        [self.cellEditView bringSubviewToFront:view];
    }
    UIView *undoall = (UIView *)[self.cellEditView viewWithTag:200];
    undoall.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    if (_is_first) {
        if ([self.collage cellCount] <= 0) {
            if (_is_collage) {
                NSString *max_count = [NSString stringWithFormat:@"%d", COLLAGE_CELL_MAX];
                [[Common info] selectPhoto:self Singlemode:NO MinPictures:[_book_info.minpictures intValue] Param:max_count];
            }
            else {
                self.toolbarView.hidden = YES;
                self.deleteView.hidden = YES;
                [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
            }
        }
        _is_first = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appWillResignActive:(NSNotification*)noti {
    if (self.navigationController.topViewController == self) {
        //[[Common info].photobook saveFile];
        NSLog(@"appWillResignActive... saved...");
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    _popupBorder.hidden = YES;
    _popupLayout.hidden = YES;
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        //self.deleteLabel.frame = CGRectMake(0.f, 100.f, 200, 50);
        //self.deleteLabel.frame = CGRectMake(0.f, size.height-self.deleteLabel.frame.size.height, size.width, self.deleteLabel.frame.size.height);
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}


// Template
//
- (void)saveTemplate:(NSString *)pathname {
    
    NSString *jsonTemplate = [self.collage representation];
    
    // Save
    //
    [jsonTemplate writeToFile:pathname
                   atomically:YES
                     encoding:NSUTF8StringEncoding
                        error:nil];
}


- (void)loadTemplate:(id)sender {
    // Load
    //
    NSString *json = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/save.json", _base_folder]
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *representation = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                   options:kNilOptions
                                                                     error:nil];
    if( representation ) {
        // Collage를 복원한다.
        //
        CGRect rect = self.collage.frame;
        [self.collage removeFromSuperview];
        self.collage = [[Collage alloc] initWithRepresentation:representation];
        self.collage.frame = rect;
        self.collage.delegate = self;
        [self.view insertSubview:self.collage atIndex:0];
        
        
        // UI 복원
        //
/*        self.cellPaddingSlider.value = self.collage.cellPadding;
        self.cellCornerRadius.value = self.collage.cellCornerRadius;
        self.layoutSegmentControl.selectedSegmentIndex = self.collage.layout;
        if( [self.collage.bgColor isEqual:[UIColor redColor]] )
            self.colorSegmentControl.selectedSegmentIndex = 0;
        else if( [self.collage.bgColor isEqual:[UIColor greenColor]] )
            self.colorSegmentControl.selectedSegmentIndex = 1;
        else
            self.colorSegmentControl.selectedSegmentIndex = 2;*/
    }
}

- (void)startFillPhotoThread {	
	if(!_no_hud) {
        _progressView = [[ProgressView alloc]initWithTitle:@"상품 구성 중"];
//
//        _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        _HUD.delegate = self;
//        _HUD.labelText = @"Loading ...";
//        [self.view addSubview:_HUD];
	}
    
    _cancel_button.enabled = NO;
    _done_button.enabled = NO;
    
    if (_thread) {
        [_thread cancel];
        _thread = nil;
    }
    
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(doingThread) object:nil];
    [_thread start];
}

- (void)doingThread {
    [self fillPhotos];
    [self performSelectorOnMainThread:@selector(doneThread) withObject:nil waitUntilDone:NO];
}

- (void)startAppendPhotoThread {	
    _cancel_button.enabled = NO;
    _done_button.enabled = NO;
    
    if (_thread) {
        [_thread cancel];
        _thread = nil;
    }
    
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(doingThreadAppendingPhoto) object:nil];
    [_thread start];
}

- (void)doingThreadAppendingPhoto {
    [self appendPhoto];
    [self performSelectorOnMainThread:@selector(doneThread) withObject:nil waitUntilDone:NO];
}

- (void)doneThread {
    _cancel_button.enabled = YES;
    _done_button.enabled = YES;
    
    [[Common info].photo_pool removeAll];
    [[Instagram info] removeAll];

	if(!_no_hud) {
        [_progressView endProgress];
//        [_HUD hide:YES afterDelay:0.1];
	}
}

- (void)updateHUD:(NSString *)msg Count:(int)count TotalCount:(int)total_count {
//    if (_HUD != nil && total_count > 0) {
	if (total_count > 0) {
        NSString *progress_str = [NSString stringWithFormat:@"%@ (%d/%d)", msg, count, total_count];
        if (total_count == 0) {
            progress_str = msg;
        }
        
        [_progressView manageProgress:(CGFloat)count/(CGFloat)total_count title:msg];
//        _HUD.progress = count/total_count;
//        _HUD.labelText = progress_str;
    }
}

- (void)fillPhotos {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *docPath = [[Common info] documentPath];  // 도큐먼트 폴더 찾기
    NSString *baseFolder = [NSString stringWithFormat:@"%@/collage", docPath];
    
    // 이전 폴더 삭제.
    [fileManager removeItemAtPath:baseFolder error:nil];
    
    [Common info].photobook.base_folder = _base_folder = baseFolder;
    
    if ([fileManager createDirectoryAtPath:baseFolder withIntermediateDirectories:YES attributes:nil error:NULL] == YES) {
        
        NSString *orgFolder = [NSString stringWithFormat:@"%@/org", baseFolder];
        NSString *editFolder = [NSString stringWithFormat:@"%@/edit", baseFolder];
        NSString *thumbFolder = [NSString stringWithFormat:@"%@/thumb", baseFolder];
        NSString *tempFolder = [NSString stringWithFormat:@"%@/temp", baseFolder];
        BOOL isOrgSuccess = [fileManager createDirectoryAtPath:orgFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        BOOL isEditSuccess = [fileManager createDirectoryAtPath:editFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        BOOL isThumbSuccess = [fileManager createDirectoryAtPath:thumbFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        BOOL isTempSuccess = [fileManager createDirectoryAtPath:tempFolder withIntermediateDirectories:YES attributes:nil error:NULL];
        
        if (isOrgSuccess && isEditSuccess && isThumbSuccess && isTempSuccess) {
//            int max_count = (int)[Common info].photo_pool.sel_photos.count;
			int max_count = (int)[[PhotoContainer inst] selectCount];
            if (max_count > COLLAGE_CELL_MAX) max_count = COLLAGE_CELL_MAX;
            
            // 1 step
            NSMutableArray *infolist = [[NSMutableArray alloc] init];
            NSMutableArray *filelist = [[NSMutableArray alloc] init];
            for (int i = 0; i < max_count; i++) {
                [self updateHUD:@"파일 준비 중..." Count:i+1 TotalCount:max_count];
				
				PhotoItem *photo = [[PhotoContainer inst] getSelectedItem:i];
//                Photo *photo = (Photo *)[Common info].photo_pool.sel_photos[i];
                if (photo) {
                    NSString *org_filename = @"";
                    CellPhotoInfo *info = [[CellPhotoInfo alloc] init];
                    [self addFile:photo PickIndex:i FileName:&org_filename Info:&info];
                    [filelist addObject:org_filename];
                    [infolist addObject:info];
                }
            }
            
            // 2 step
            NSMutableArray *imagelist = [[NSMutableArray alloc] init];
            for (int i = 0; i < max_count; i++) {
                [self updateHUD:@"액자 구성 중..." Count:i+1 TotalCount:max_count];
                
                NSString *org_filename = filelist[i];
                if (org_filename != nil) {
                    NSString *edit_pathname = [NSString stringWithFormat:@"%@/edit/_%@", _base_folder, org_filename];
                    
                    UIImage *image = [UIImage imageWithContentsOfFile:edit_pathname];
                    [imagelist addObject:image];
                }
            }
            
            // 사진을 추가한다.
            //  사진 경로는 사진 이름만 전달한다.(위에 설명되어 있음)
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateHUD:@"액자 구성 완료" Count:0 TotalCount:0];
                [self.collage insertPhotos:imagelist andPaths:filelist andPhotoInfos:infolist];
            });
            NSLog(@"액자 구성 완료");
        }
    }
    [[Common info].photo_pool removeAll];
    [[Instagram info] removeAll];
}

- (void)appendPhoto {
	PhotoItem *photo = [[PhotoContainer inst] getSelectedItem:0];
//    Photo *photo = [[Common info].photobook pickPhoto:0];
    if (photo) {
        NSString *org_filename = @"";
        CellPhotoInfo *info = [[CellPhotoInfo alloc] init];
        [self addFile:photo PickIndex:0 FileName:&org_filename Info:&info];
        if (org_filename != nil) {
            NSString *edit_pathname = [NSString stringWithFormat:@"%@/edit/_%@", _base_folder, org_filename];
            UIImage *image = [UIImage imageWithContentsOfFile:edit_pathname];
            if (image) {
                [self.collage insertPhotos:@[image] andPaths:@[org_filename] andPhotoInfos:@[info]];
            }
        }
    }
    [[Common info].photo_pool removeAll];
    [[Instagram info] removeAll];
	
//	if ([[PhotoContainer inst] selectCount] > 0){
//		PhotoItem *photoItem = [[PhotoContainer inst] getSelectedItem:0];
//		[[Common info].photobook addPhotoNew:photoItem Layer:_selected_layer PickIndex:0];
//		[_table_view reloadData];
//	}
	
	[[PhotoContainer inst] initialize];
}

- (BOOL)addFile:(PhotoItem *)item PickIndex:(int)pick_index FileName:(NSString **)ret_filename Info:(CellPhotoInfo **)info {
    if (item != nil) {
        
        NSString *time_str = [[Common info] timeStringEx];
        NSString *filename = [NSString stringWithFormat:@"%04d.jpg", pick_index];
        
        int randnum = arc4random() % 100;
        NSString *org_filename = [NSString stringWithFormat:@"%@_%03d_%@", time_str, randnum, filename];
        NSString *org_pathname = [NSString stringWithFormat:@"%@/org/%@", _base_folder, org_filename];

        // 원본 복사
		__block UIImageOrientation ph_orientation = UIImageOrientationUp;
		__block NSDictionary *ph_info = nil;
		__block NSData *org_data;

		PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
		options.networkAccessAllowed = YES;
		options.synchronous = YES;
		
		UIImage *org_image = nil;
		
		if (item.positionType == PHOTO_POSITION_LOCAL) {
			LocalItem *local = (LocalItem *)item;
			
			[[PHImageManager defaultManager] requestImageDataForAsset:local.photo.asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
				if(![[PHAssetUtility info] isHEIF:local.photo.asset])
					org_data = [imageData copy];
				ph_orientation = orientation;
				ph_info = info;
			}];
			// HEIF Fix
			if([[PHAssetUtility info] isHEIF:local.photo.asset]) {
				org_data = [[PHAssetUtility info] getJpegImageDataForAsset:local.photo.asset];
			}
			
			// 원본 크기
			(*info).ImageOriWidth = [[PHAssetUtility info] getPixelWidth:local.photo.asset];
			(*info).ImageOriHeight = [[PHAssetUtility info] getPixelHeight:local.photo.asset];
			
			[org_data writeToFile:org_pathname atomically:YES];
			
			org_image = [UIImage imageWithData:org_data];
		} else {
			SocialItem *socialItem = (SocialItem *)item;
			
			// url로부터 복사.
			if (![socialItem download:org_pathname]) {
				return NO;
			}
			
			// 원본이미지
			org_image = [UIImage imageWithContentsOfFile:org_pathname];
			
			// 원본 크기
			(*info).ImageOriWidth = org_image.size.width;
			(*info).ImageOriHeight = org_image.size.width;
		}

//        [[PHImageManager defaultManager] requestImageDataForAsset:photo.asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
//		    if(![[PHAssetUtility info] isHEIF:photo.asset])
//	            org_data = [imageData copy];
//            ph_orientation = orientation;
//            ph_info = info;
//        }];
//		// HEIF Fix
//	    if([[PHAssetUtility info] isHEIF:photo.asset]) {
//			org_data = [[PHAssetUtility info] getJpegImageDataForAsset:photo.asset];
//		}

        // 사진을 가져온다.
        //
#if 1
        // 원본 회전 정보
        CGFloat rotate = 0;
		switch (ph_orientation) {
			case UIImageOrientationUp:    // 0도, 기본값.
			case UIImageOrientationUpMirrored:
				break;
			case UIImageOrientationLeft:  // 90도
			case UIImageOrientationLeftMirrored:
				rotate = 90;
				break;
			case UIImageOrientationRight: // -90도
			case UIImageOrientationRightMirrored:
				rotate = -90;
				break;
			case UIImageOrientationDown:  // 180도
			case UIImageOrientationDownMirrored:
				rotate = 180;
				break;
			default:
				break;
		}
        
        CGFloat scale = 1.0f;
        int max_side = (int)MAX(org_image.size.width, org_image.size.height);
        if (max_side > IMAGE_EDIT_MAX) {
            scale = (CGFloat)IMAGE_EDIT_MAX / (CGFloat)max_side;
        }
        
        CGSize image_size = CGSizeMake(org_image.size.width * scale, org_image.size.height * scale);
        CGSize canvas_size = image_size;
        if (rotate == 90 || rotate == -90) {
            canvas_size = CGSizeMake(image_size.height, image_size.width);
        }
        
        
        UIGraphicsBeginImageContext(canvas_size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //CGContextSetRGBFillColor(context, 0, 0, 0, 1.0f);
        //CGContextFillRect(context, CGRectMake(0, 0, canvas_size.width, canvas_size.height));
        
        CGContextTranslateCTM(context, canvas_size.width/2, canvas_size.height/2);
        CGContextRotateCTM(context, rotate * M_PI/180);

        // mirrored image flip or flop............................................
		switch (ph_orientation) {
			case UIImageOrientationUpMirrored:
			case UIImageOrientationDownMirrored:
				CGContextScaleCTM(context, -1, 1);
				break;
			case UIImageOrientationLeftMirrored:
			case UIImageOrientationRightMirrored:
				CGContextScaleCTM(context, 1, -1);
				break;
			default:
				break;
		} // mirrored image flip or flop..........................................

        CGContextTranslateCTM(context, -image_size.width/2, -image_size.height/2);
        
        [org_image drawInRect:CGRectMake(0, 0, image_size.width, image_size.height)];
        
        UIImage *edit_image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGFloat compressionQuality = 0.5f;
        NSData *edit_data = UIImageJPEGRepresentation(edit_image, compressionQuality);
        [edit_data writeToFile:[NSString stringWithFormat:@"%@/edit/_%@", _base_folder, org_filename] atomically:YES];
        
        // 리턴 값.....
        
        // 편집용 이미지 장축 기록
        (*info).EditImageMaxSize = MAX((int)edit_image.size.width, (int)edit_image.size.height);
        
        //
        NSString *inch = [Common info].photobook.ProductSize;
        NSArray *tempArray = [inch componentsSeparatedByString:@"x"];
        (*info).inchWidth = [tempArray[0] intValue];
        (*info).inchHeight = [tempArray[1] intValue];
        
        *ret_filename = org_filename;
#endif
        
#if 0
        UIImage *image = [UIImage imageWithContentsOfFile:org_pathname];
        image = [UIImage imageWithCGImage:image.CGImage scale:1.0f orientation:UIImageOrientationUp]; // UIImageOrientationUp is initializer !!

        // 사진을 추가한다.
        //  사진 경로는 사진 이름만 전달한다.(위에 설명되어 있음)
        [self.collage insertPhotos:@[image] andPaths:@[org_filename]];
#endif
#if 0
        UIImage *org_image = [UIImage imageWithContentsOfFile:org_pathname];

        CGFloat scale = 1.0f;
        int min_side = (int)MIN(org_image.size.width, org_image.size.height);
        if (min_side > 480) {
            scale = (CGFloat)min_side / 480.0f;
        }
        // UIImageOrientationUp is initializer !!
        UIImage *edit_image = [UIImage imageWithCGImage:org_image.CGImage scale:scale orientation:UIImageOrientationUp];
        NSLog(@"edt:%.0fx%.0f", edit_image.size.width, edit_image.size.height);
        
        CGFloat compressionQuality = 0.5f;
        NSData *edit_data = UIImageJPEGRepresentation(edit_image, compressionQuality);
        [edit_data writeToFile:[NSString stringWithFormat:@"%@/edit/_%@", _base_folder, org_filename] atomically:YES];
#endif
        return TRUE;
    }
    return FALSE;
}

// 화면에 셀 편집할 영역을 잡는다.
//  기존의 셀 크기 비율은 유지하지만, 크기 자체는 동일하지 않는다.
//  화면 크기에 padding을 적용한 영역에서 aspectfit한 사이즈에서 셀 편집을 하도록 한다.
//
- (void)fitEditView:(Cell *)cell {
    // 스크롤뷰의 줌스케일을 초기화시켜놓고 작업해야 한다. ***********************
    self.cellScrollView.zoomScale = 1.0f;
    
    // 편집 될 영역을 설정한다.
    //
    float leftRightPadding = 20.f;
    float upDownPadding = 80.f;
    self.cellScrollView.frame = aspectFitRect(cell.frame.size,
                                              aspectFitRect(cell.photo.size,
                                                            CGRectInset(self.cellEditView.bounds,
                                                                        leftRightPadding,
                                                                        upDownPadding)));
    // CellImageView에도 동일한 이미지를 설정한다.
    //
    self.cellImageView.image = cell.photo;
    
    // CellImageView의 크기를 ScrollView에 aspectfill 되는 사이즈로 설정한다.
    //
    self.cellImageView.frame = aspectFillRect(cell.photo.size, self.cellScrollView.bounds);
    
    // ScrollView를 동일한 scale로 설정한다.
    //
    self.cellScrollView.zoomScale = cell.photoScale;
    
    // ScrollView의 자식은 x, y값을 바로 설정하면 안되고, scrollView의 contentOffset을 이용해서 설정해야 한다.
    //
    self.cellImageView.frame = CGRectMake(0.f,
                                          0.f,
                                          CGRectGetWidth(self.cellImageView.frame),
                                          CGRectGetHeight(self.cellImageView.frame));
    
    float x = CGRectGetWidth(self.cellImageView.frame) * cell.photoPosition.x;
    float y = CGRectGetHeight(self.cellImageView.frame) * cell.photoPosition.y;
    self.cellScrollView.contentOffset = CGPointMake(x - CGRectGetWidth(self.cellScrollView.frame) / 2.f,
                                                    y - CGRectGetHeight(self.cellScrollView.frame) / 2.f);
    
    // Scroll 되어야 하는 영역과 zoomScale을 설정한다.
    //
    self.cellScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.cellImageView.frame),
                                                 CGRectGetHeight(self.cellImageView.frame));
}

- (IBAction)undoAll:(id)sender {
}

- (IBAction)rotateLeft:(id)sender {
    Cell *cell = self.editCell;
    [cell rotatePhoto:cell.photo andRotate:-90];
    
    [self fitEditView:cell];
}

- (IBAction)rotateRight:(id)sender {
    Cell *cell = self.editCell;
    [cell rotatePhoto:cell.photo andRotate:90];
    
    [self fitEditView:cell];
}

- (IBAction)addPhoto:(id)sender {
    _popupBorder.hidden = YES;
    _popupLayout.hidden = YES;
   
    if ([self.collage cellCount] < COLLAGE_CELL_MAX) {
        [[Common info] selectPhoto:self Singlemode:YES MinPictures:0 Param:@""];
    }
    else {
        [self.view makeToast:[NSString stringWithFormat:@"최대 사진 수는 %d장 입니다.", COLLAGE_CELL_MAX]];
    }
}

- (IBAction)shuffle:(id)sender {
    _popupBorder.hidden = YES;
    _popupLayout.hidden = YES;
    
    [self.collage shuffle];
}

- (CGRect)popupRect:(UIView *)popupView Button:(UIButton *)button {
    CGRect button_rect = [_toolbarView convertRect:button.frame toView:self.view];
    CGRect popup_rect = popupView.frame;
    
    CGFloat popup_x = (button_rect.origin.x + button_rect.size.width/2) - popup_rect.size.width/2;
    if (popup_x + popup_rect.size.width > self.view.frame.size.width) {
        popup_x = (self.view.frame.size.width - popup_rect.size.width);
    }
    popup_rect.origin.x = popup_x;
    popup_rect.origin.y = button_rect.origin.y - popup_rect.size.height;
    
    return popup_rect;
}

- (IBAction)changeLayout:(id)sender {
    if (_popupLayout.hidden == NO) {
        _popupLayout.hidden = YES;
        _popupBorder.hidden = YES;
    }
    else {
        _popupBorder.hidden = YES;
        _popupLayout.hidden = NO;
        CGRect popup_rect = [self popupRect:_popupLayout Button:(UIButton *)sender];
        [_popupLayout setFrame:popup_rect];
    }
}

- (IBAction)changeBorder:(id)sender {
    if (_popupBorder.hidden == NO) {
        _popupLayout.hidden = YES;
        _popupBorder.hidden = YES;
    }
    else {
        _popupLayout.hidden = YES;
        _popupBorder.hidden = NO;
    }
}

- (IBAction)layout01:(id)sender {
    [self.collage setLayout:CollageLayout_1 animate:YES];
}

- (IBAction)layout02:(id)sender {
    [self.collage setLayout:CollageLayout_2 animate:YES];
}

- (IBAction)layout03:(id)sender {
    [self.collage setLayout:CollageLayout_3 animate:YES];
}

- (IBAction)layout04:(id)sender {
    [self.collage setLayout:CollageLayout_4 animate:YES];
}

- (IBAction)changedGap:(UISlider *)sender {
    _collage.cellPadding = sender.value;
    _gap_label.text = [NSString stringWithFormat:@"%d", (int)(sender.value * 50.0f)];
}

- (IBAction)changedRound:(UISlider *)sender {
    _collage.cellCornerRadius = sender.value;
    _round_label.text = [NSString stringWithFormat:@"%d", (int)(sender.value * 10.0f)];
}

- (IBAction)changedColor:(UISlider *)sender {
    int color_index = (int)sender.value;
    int color_value = [_color_view colorValue:color_index];
    _collage.bgColor = UIColorFromRGB(color_value);
    
    NSString *hex_value = [NSString stringWithFormat:@"#%06X", color_value];
    _color_value.text = hex_value;
    _color_value.hidden = NO;
}

- (IBAction)touchUpInsideColor:(id)sender {
    _color_value.hidden = YES;
}

- (IBAction)touchUpOutsideColor:(id)sender {
    _color_value.hidden = YES;
}
/*
- (CGRect)trackRectForBounds:(CGRect)bounds {
    NSLog(@"bounds:%.2f", bounds.size.width);
    return bounds;
}
*/
- (IBAction)exitCellEditMode:(id)sender {
    
    // PhotoImageView를 CellImageView에서 보여지는 영역과 똑같이 만든다.
    //
    [self.dummyCell copyCell:_editCell];
    self.dummyCell.hidden = NO;
    
    
    // ScrollView의 contentoffset과 zoomscale을 이용해서 dummyCell에 값을 설정한다.
    //
    CGPoint point = CGPointMake(self.cellScrollView.contentOffset.x + CGRectGetWidth(self.cellScrollView.frame) / 2.f,
                                self.cellScrollView.contentOffset.y + CGRectGetHeight(self.cellScrollView.frame) / 2.f);
    point.x /= CGRectGetWidth(self.cellImageView.frame);
    point.y /= CGRectGetHeight(self.cellImageView.frame);
    
    [self.dummyCell setPhotoPosition:point
                            andScale:self.cellScrollView.zoomScale];
    
    [UIView animateWithDuration:0.3f
                          delay:0.f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         
                         // Dummy cell을 원래 선택된 edit cell의 동일한 위치로 옮긴다.
                         //
                         self.dummyCell.frame = [self.view convertRect:_editCell.frame
                                                              fromView:_editCell.superview];
                         
                         
                         // Edit 화면은 사라진다.
                         //
                         self.cellEditView.alpha = 0.f;
                         
                     } completion:^(BOOL finished) {
                         
                         // 애니매이션이 끝나면 editCell에 dummyCell에 설정된 정보를 그대로 copy한다.
                         //
                         [_editCell setPhotoPosition:self.dummyCell.photoPosition andScale:self.dummyCell.photoScale];
                         
                         
                         // 초기화 시킨다.
                         //
                         self.dummyCell.hidden = YES;
                         self.cellEditView.userInteractionEnabled = NO;
                         self.cellScrollView.zoomScale = 1.f;
                         //self.cellBorderView.alpha = 0.f;
                     }];
}


#pragma mark - CollageDelegate

// Collage에서 하나의 셀이 선택됨
//
- (void)collage:(Collage *)collage selectedCell:(Cell *)cell {

    _popupBorder.hidden = YES;
    _popupLayout.hidden = YES;
    
    // 셀 편집 모드에 들어간다.
    //  셀 편집하는 방법을 여러가지 방법이 있겠지만
    //  여기서는 Shutterfly와 동일하게 구현하였다.
    _editCell = cell;
    
    
    // Scrollview 밖에 보여지는 dim먹은 imageview에 image를 설정한다.
    //
    //self.cellBackView.image = cell.photo;
    
    
    // 셀 편집모드 진입을 위한 editCell을 copy해서 만든다.
    //  셀 위에 동일한 크기로 붙였다가 자연스럽게 셀 편집모드에 들어가는 역활을 한다.
    //  Shutterfly를 보면 선택 된 셀은 제자리에 가만히 있고 별도의 셀이 생성되서 나타난다.
    {
        // editCell에 cell의 값을 copy
        //
        self.dummyCell.frame = [self.view convertRect:cell.frame fromView:cell.superview];
        [self.dummyCell copyCell:cell];
        
        
        // 화면에 나타나게 한다.
        //
        self.dummyCell.hidden = NO;
    }
    
    [self fitEditView:cell];
    
    // 화면에 셀 편집이 가능한 _cellEditView를 화면에 등장시킨다.
    //
    [UIView animateWithDuration:0.3f
                          delay:0.f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         
                         self.cellEditView.alpha = 1.f;
                         self.dummyCell.frame = [self.view convertRect:self.cellScrollView.frame
                                                              fromView:self.cellEditView];
                         
                     } completion:^(BOOL finished) {
                         
                         // PhotoImageView를 숨긴다.
                         //
                         self.dummyCell.hidden = YES;
                         
                         
                         // 완전히 등장했으면 이벤트를 받는다.
                         //
                         self.cellEditView.userInteractionEnabled = YES;
                         
                         
                         // Border가 등장한다.
                         //
                         [UIView animateWithDuration:0.15f
                                          animations:^{
                                              //self.cellBorderView.alpha = 1.f;
                                          }];
                     }];
}


// Collage에서 하나의 셀이 움직일 예정
//
- (void)collage:(Collage *)collage willMoveCell:(Cell *)cell {
    if (!_is_collage) return;

    _popupBorder.hidden = YES;
    _popupLayout.hidden = YES;
    
    [UIView animateWithDuration:0.3f
                          delay:0.f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         
                         // DeleteLabel을 보여준다.
                         //
                         if ([self.collage cellCount] > 1) {
                             self.deleteView.alpha = 1.f;
                             self.toolbarView.alpha = 0.f;
                         }

                     } completion:nil];
}


// Collage에서 셀이 움직이고 있음
//
- (void)collage:(Collage *)collage movingCell:(Cell *)cell {
    if (!_is_collage) return;
    
    _popupBorder.hidden = YES;
    _popupLayout.hidden = YES;
    
    [UIView animateWithDuration:0.15f
                          delay:0.f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         // Delete label 에 걸치는지 판단하고, 걸치면 걸쳤다는 의미로 deletelabel을 크게 한다.
                         //
                         if( CGRectContainsPoint(self.deleteView.frame, [self.view convertPoint:cell.center
                                                                                        fromView:cell.superview]) )
                         {
                             self.deleteView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
                             self.deleteView.highlighted = YES;
                         }
                         else
                         {
                             self.deleteView.transform = CGAffineTransformIdentity;
                             self.deleteView.highlighted = NO;
                         }
                     } completion:nil];
}


// Collage에서 셀이 움직임을 멈췄음
//  반환값이 YES면 삭제한다.
- (BOOL)collage:(Collage *)collage didMoveCell:(Cell *)cell {
    if (!_is_collage) return NO;
    
    [UIView animateWithDuration:0.3f
                          delay:0.f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         
                         // DeleteLabel을 사라지게 한다.
                         //
                         self.deleteView.alpha = 0.f;
                         self.toolbarView.alpha = 1.f;
                         
                     } completion:nil];
    
    
    // DeleteLabel이 확대된 상태이면 YES를 반환하고,
    // 그렇지 않으면 NO를 반환한다.
    if ([self.collage cellCount] <= 1) {
        return NO;
    }
    return !CGAffineTransformIsIdentity(self.deleteView.transform);
}

- (void)completeCollage {
    //NSLog(@"completeCollage....");
/*
    int count = 0;
    int total_count = 10;
    NSString *progress_str = [NSString stringWithFormat:@"액자 구성 중 (%d/%d)", count, total_count];
    NSLog(@"%@", progress_str);*/
    /*
    _HUD.progress = count/total_count;
    _HUD.labelText = progress_str;*/

    if (_HUD != nil) {
        [_HUD hide:YES afterDelay:0.1];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //self.cellBackView.frame = [self.cellEditView convertRect:self.cellImageView.frame fromView:self.cellScrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2) {
    //self.cellBackView.frame = [self.cellEditView convertRect:self.cellImageView.frame fromView:self.cellScrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.cellImageView;
}

#pragma mark - SelectPhotoDelegate methods

- (void)selectPhotoDone:(BOOL)is_singlemode {
	_no_hud = FALSE;

	if (_is_collage) {
        if (is_singlemode) {
			_no_hud = TRUE;
			[self startAppendPhotoThread];
            //[self appendPhoto];
        }
        else {
	        [self popupGuidePage:GUIDE_FRAME_EDIT];
            [self startFillPhotoThread];
        }
    }
    else {
		_no_hud = TRUE;
		// 2017.11.03
        [self popupGuidePage:GUIDE_FRAME_EDIT];
		[self startFillPhotoThread];
        //[self fillPhotos];
    }
}

- (void)selectPhotoCancel:(BOOL)is_singlemode {
    if (is_singlemode) {
    }
    else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

//
- (IBAction)cancel:(id)sender {
    if (_done_button.enabled == NO) { // 취소가 잘 안되는 문제가...
        if (_thread) {
            [_thread cancel];
            _thread = nil;
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {

    // 1. ctg
    [self saveTemplate:[NSString stringWithFormat:@"%@/save.ctg", _base_folder]];
    
    // 2. thumb
    UIImage *image = [self.collage getThumbImage];
    NSData *data = UIImageJPEGRepresentation(image, 0.5f);
    [data writeToFile:[NSString stringWithFormat:@"%@/thumb/thumb.jpg", _base_folder] atomically:YES];

    // 3. txt
    NSMutableArray *file_array = [self.collage filenameList];
    NSString *array_str = [file_array componentsJoinedByString:@"\n"];
    
    NSString *txtbody = [NSString stringWithFormat:@"%-12lu%@", (unsigned long)array_str.length, array_str];
    NSData *txtdata = [txtbody dataUsingEncoding:NSUTF8StringEncoding];
    [txtdata writeToFile:[NSString stringWithFormat:@"%@/upload.txt", _base_folder] atomically:YES];
    
    // upload
    FrameUploadViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FrameUploadPage"];
    vc.photofilelist = file_array;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - GuideDelegate methods

- (void)popupGuidePage:(NSString *)guide_id {
    if ([[Common info] checkGuideUserDefault:guide_id]) {
        GuideViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GuidePage"];
        if (vc) {
            vc.guide_id = guide_id;
            vc.delegate = self;
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (void)closeGuide {
    [self.cellImageView setNeedsDisplay];
}

#pragma mark - FrameUploadDelegate methods

- (void)completeUpload {
    [self dismissViewControllerAnimated:NO completion:^{
       [self.delegate completeEdit]; 
    }];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [_HUD removeFromSuperview];
    _HUD = nil;
}

- (void)viewDidUnload {
}

@end

