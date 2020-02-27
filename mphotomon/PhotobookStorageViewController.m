//
//  PhotobookStorageViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 7..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "PhotobookStorageViewController.h"
#import "PhotobookEditTableViewController.h"
#import "PhotobookV2EditTableViewController.h"
#import "CalendarEditTableViewController.h"
#import "DesignPhotoEditViewController.h"
#import "CardEditTableViewController.h"
#import "GiftPostcardEditViewController.h"
#import "GiftMagnetEditViewController.h"
#import "BabyEditViewController.h"
#import "PhotobookUploadViewController.h"
#import "SingleCardEditViewController.h"
#import "Common.h"
#import "Define.h"
#import "GoodsPosterEditViewController.h"
#import "GoodsPaperSloganEditViewController.h"
#import "GoodsTransparentCardEditViewController.h"
#import "FancyDivisionEditViewController.h"

@interface PhotobookStorageViewController ()

@end

@implementation PhotobookStorageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Analysis log:@"PhotoProductStorage"];
    self.navigationItem.rightBarButtonItem = nil; // 스토리보드를 위한 더미 버튼이라 보일 필요가 없다.
    
    if (self.isFromMain) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"닫기" style:UIBarButtonItemStyleDone target:self action:@selector(didTouchCloseButton)];
    }
    
    NSMutableArray *book_array = [[NSMutableArray alloc] init];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docPath = [[Common info] documentPath];  // 도큐먼트 폴더 찾기
    
    NSArray *pathArray = [fileManager contentsOfDirectoryAtPath:docPath error:nil];
    for (NSString *path in pathArray) {
        if ([path isEqualToString:@"mug"]) continue;
        if ([path isEqualToString:@"phonecase"]) continue;
        if ([path isEqualToString:@"baby"]) continue;
        
        NSString *fullpathname = [NSString stringWithFormat:@"%@/%@/save.ctg", docPath, path];
        
        BOOL is_dir;
        if ([fileManager fileExistsAtPath:fullpathname isDirectory:&is_dir]) {
            NSData *data = [fileManager contentsAtPath:fullpathname];

            Photobook *photobook = [[Photobook alloc] init];
            BOOL is_valid_data = [photobook loadData:data IsHeaderOnly:YES];
            if (is_valid_data) {
                [book_array addObject:photobook];
                
                photobook.base_folder = [NSString stringWithFormat:@"%@/%@", docPath, path];
                
                BOOL is_exist_calendarthumb = YES;
                if (photobook.product_type == PRODUCT_CALENDAR || photobook.product_type == PRODUCT_CARD) {
                    NSString *thumb_path = [NSString stringWithFormat:@"%@/thumb", photobook.base_folder];
                    for (int i = 0; i < 3; i++) {
                        NSString *thumbfile = [NSString stringWithFormat:@"%@/thumb%02d.jpg", thumb_path, i];
                        
                        BOOL is_dir;
                        if ([fileManager fileExistsAtPath:thumbfile isDirectory:&is_dir]) {
                            [photobook.thumbs addObject:thumbfile];
                        }
                        else {
                            [photobook.thumbs removeAllObjects];
                            is_exist_calendarthumb = NO;
                            break;
                        }
                    }
                }
                
                if ((photobook.product_type != PRODUCT_CALENDAR && photobook.product_type != PRODUCT_CARD) || !is_exist_calendarthumb) {
                    int thumb_count = 0;
                    NSString *thumb_path = [NSString stringWithFormat:@"%@/edit", photobook.base_folder];
                    NSArray *thumbArray = [fileManager contentsOfDirectoryAtPath:thumb_path error:nil];
                    
                    // PRODUCT_SINGLECARD 일 경우에만 jpg 확장자만 넣도록 함
                    // 기존의 소스에 영향을 주기 않기위해 if 문 씀
                    if (photobook.product_type == PRODUCT_SINGLECARD) {
                        for (NSString *thumb_pathname in thumbArray) {
                            if ([[thumb_pathname lowercaseString] rangeOfString:@".jpg"].location != NSNotFound) {
                                if (++thumb_count > 3) break;
                                [photobook.thumbs addObject:[NSString stringWithFormat:@"%@/%@", thumb_path, thumb_pathname]];
                            }
                        }
                    }
                    else if (photobook.product_type == PRODUCT_MAGNET) {
                        for (NSString *thumb_pathname in thumbArray) {
                            if ([[thumb_pathname lowercaseString] rangeOfString:@".jpg"].location != NSNotFound) {
                                if (++thumb_count > 3) break;
                                [photobook.thumbs addObject:[NSString stringWithFormat:@"%@/%@", thumb_path, thumb_pathname]];
                            }
                        }
                    }
					else {
                        //기존 소스 처리
                        for (NSString *thumb_pathname in thumbArray) {
                            if ([thumb_pathname hasPrefix:@"tc"]) {
                                continue;
                            }
                            if (++thumb_count > 3) break;
                            [photobook.thumbs addObject:[NSString stringWithFormat:@"%@/%@", thumb_path, thumb_pathname]];
                        }                    
					}
                }
            }
        }
    }
    
    NSArray *sorted_array = (NSMutableArray *)[book_array sortedArrayUsingComparator:^NSComparisonResult(Photobook *book1, Photobook *book2) {
        if ([book1.ProductId compare:book2.ProductId] < 0) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedAscending;
        }
    }];
    _book_array = [NSMutableArray arrayWithArray:sorted_array];
    [_collection_view reloadData];
}

- (void)didTouchCloseButton {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [Analysis firAnalyticsWithScreenName:@"PhotoProductStorage" ScreenClass:[self.classForCoder description]];
    [_collection_view reloadData];
    isForceProgress = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

static BOOL isForceProgress = NO;

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    /*
    if ([identifier isEqualToString:@"PhotobookUploadSegue"]) {
        if ([Common info].photobook != nil) {
            if (![Common info].photobook.Edited) {
                [[Common info] alert:self Msg:@"편집이 완료되지 않았습니다."];
                return NO;
            }
        }
    }
    */
    if ([identifier isEqualToString:@"PhotobookUploadSegue"]) {
        if ([Common info].photobook.product_type == PRODUCT_POLAROID) {
            if ([Common info].photobook != nil) {
                BOOL allTextEdited = TRUE;
                for (Page *page in [Common info].photobook.pages) {
                    for (Layer *layer in page.layers) {
                        if (layer.AreaType == 2 && (layer.TextDescription == nil || [layer.TextDescription isEqualToString:@""])) {
                            allTextEdited = FALSE;
                        }
                    }
                }
                if(isForceProgress == NO && allTextEdited == FALSE) {
                    //MAcheck
                    [[Common info]alert:self Title:@"글상자 영역이 편집되지 않았습니다.\n그대로 주문전송 하시겠습니까?" Msg:@"" okCompletion:^{
                        isForceProgress = YES;
                        [Common info].photobook.useTitleHint = NO;
                        [self.collection_view reloadData];
                        [self performSegueWithIdentifier:@"PhotobookUploadSegue" sender:self];

                    } cancelCompletion:^{
                        
                    } okTitle:@"네" cancelTitle:@"아니오"];
                    return NO;
                }
            }
        }
		// FIX : 마그넷 : 레트로/포토부스 공통 : 텍스트 입력을 안할 경우, 기본 문구 "텍스트 입력"이 그대로 넘어옴
        else if ([Common info].photobook.product_type == PRODUCT_MAGNET) {
            if ([Common info].photobook != nil) {
				[Common info].photobook.useTitleHint = NO;
			}
		}
    }
    return YES;
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PhotobookLoadSegue"]) {
        PhotobookEditTableViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_new = NO;
        }
    }
    else if ([segue.identifier isEqualToString:@"CalendarLoadSegue"]) {
        CalendarEditTableViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_new = NO;
        }
    }
    else if ([segue.identifier isEqualToString:@"PolaroidLoadSegue"]) {
        CalendarEditTableViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_new = NO;
        }
    }
    else if ([segue.identifier isEqualToString:@"DesignPhotoLoadSegue"]) {
        DesignPhotoEditViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_new = NO;
        }
    }
    else if ([segue.identifier isEqualToString:@"PostcardLoadSegue"]) {
        GiftPostcardEditViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_new = NO;
        }
    }
    else if ([segue.identifier isEqualToString:@"MagnetLoadSegue"]) {
        GiftMagnetEditViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_new = NO;
        }
    }
    else if ([segue.identifier isEqualToString:@"BabyLoadSegue"]) {
        BabyEditViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_new = NO;
        }
    }
    else if ([segue.identifier isEqualToString:@"CardLoadSegue"]) {
        CardEditTableViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_new = NO;
        }
    }
    else if ([segue.identifier isEqualToString:@"PhotobookUploadSegue"]) {
        PhotobookUploadViewController *vc = [segue destinationViewController];
        if (vc) {
        }
    }
    else if ([segue.identifier isEqualToString:@"PosterLoadSegue"]) {
        GoodsPosterEditViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_new = NO;
        }
    }
    else if ([segue.identifier isEqualToString:@"PaperSloganLoadSegue"]) {
        GoodsPaperSloganEditViewController *vc = [segue destinationViewController];
        if (vc) {
            vc.is_new = NO;
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _book_array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotobookStorageCell" forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;
    
    Photobook *photobook = _book_array[indexPath.row];
    if (photobook) {
        UILabel *title_label = (UILabel *)[cell viewWithTag:100];
        UILabel *date_label = (UILabel *)[cell viewWithTag:101];
        UIImageView *edit_flag = (UIImageView *)[cell viewWithTag:102];
        UIImageView *thumb1 = (UIImageView *)[cell viewWithTag:103];
        UIImageView *thumb2 = (UIImageView *)[cell viewWithTag:104];
        UIImageView *thumb3 = (UIImageView *)[cell viewWithTag:105];
        
        if (photobook.product_type == PRODUCT_PHOTOBOOK) {
            // SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
            if( [photobook.ProductCode isEqualToString:@"300270"] )
                title_label.text = [NSString stringWithFormat:@"기본형 손글씨포토북 %dP - %@", photobook.TotalPageCount, photobook.ThemeHangulName];
            else if( [photobook.ProductCode isEqualToString:@"300269"] )
                title_label.text = [NSString stringWithFormat:@"라이트형 손글씨포토북 %dP - %@", photobook.TotalPageCount, photobook.ThemeHangulName];
            else if( [photobook.ProductCode isEqualToString:@"300268"] )
                title_label.text = [NSString stringWithFormat:@"기본형 인스타북 %dP - %@", photobook.TotalPageCount, photobook.ThemeHangulName];
            else if( [photobook.ProductCode isEqualToString:@"300267"] )
                title_label.text = [NSString stringWithFormat:@"라이트형 인스타북 %dP - %@", photobook.TotalPageCount, photobook.ThemeHangulName];
			// SJYANG : 포토북 > 스키니북 
            else if( [photobook.ProductCode isEqualToString:@"300180"] )
	            title_label.text = [NSString stringWithFormat:@"스키니북 %dP - %@", photobook.TotalPageCount, photobook.ThemeHangulName];
			// SJYANG : 포토북 > 포토카달로그
			else if( [photobook.ProductCode isEqualToString:@"120069"] )
	            title_label.text = [NSString stringWithFormat:@"포토카달로그 %dP - %@", photobook.TotalPageCount, photobook.ThemeHangulName];
            else {
	            title_label.text = [NSString stringWithFormat:@"%@ 포토북 %dP - %@", photobook.ProductSize, photobook.TotalPageCount, photobook.ThemeHangulName];

                if ([photobook.ProductSize isEqualToString:@"5.5x5.5"]) {
                    title_label.text = [NSString stringWithFormat:@"인스타북 %dP - %@", photobook.TotalPageCount, photobook.ThemeHangulName];
                }
                else if ([photobook.ProductSize isEqualToString:@"A5w"]) {
                    title_label.text = [NSString stringWithFormat:@"손글씨포토북 %dP - %@", photobook.TotalPageCount, photobook.ThemeHangulName];
                }
                // SJYANG : 2016.05.30
                if( [photobook.ThemeName isEqualToString:@"premium"] ) {
                    title_label.text = [NSString stringWithFormat:@"%@ 프리미엄 포토북 %dP - %@", photobook.ProductSize, photobook.TotalPageCount, photobook.ThemeHangulName];
                }
            }
        }
        else if (photobook.product_type == PRODUCT_CALENDAR) {
            title_label.text = [NSString stringWithFormat:@"탁상달력 - %@", photobook.ThemeHangulName];
            if (photobook.ProductCode.length >= 6) {
                NSString *type = [photobook.ProductCode substringWithRange:NSMakeRange(0,3)];
                if ([type isEqualToString:@"367"])
                    title_label.text = [NSString stringWithFormat:@"소형벽걸이달력 - %@", photobook.ThemeHangulName];
                else if ([type isEqualToString:@"368"])
                    title_label.text = [NSString stringWithFormat:@"미니특가달력 - %@", photobook.ThemeHangulName];
                else if ([type isEqualToString:@"369"])
                    title_label.text = [NSString stringWithFormat:@"우드스탠드 - %@", photobook.ThemeHangulName];
                else if ([type isEqualToString:@"391"])
                    title_label.text = [NSString stringWithFormat:@"시트달력 - %@", photobook.ThemeHangulName];
                else if ([type isEqualToString:@"392"])
                    title_label.text = [NSString stringWithFormat:@"대형벽걸이달력 - %@", photobook.ThemeHangulName];
                else if ([type isEqualToString:@"393"])
                    title_label.text = [NSString stringWithFormat:@"포스터달력 - %@", photobook.ThemeHangulName];
				else if ([type isEqualToString:@"447"])
					title_label.text = [NSString stringWithFormat:@"세로탁상달력 - %@", photobook.ThemeHangulName];
				else if ([type isEqualToString:@"448"])
					title_label.text = [NSString stringWithFormat:@"미니탁상달력 - %@", photobook.ThemeHangulName];
				else if ([type isEqualToString:@"449"])
					title_label.text = [NSString stringWithFormat:@"정사각탁상 - %@", photobook.ThemeHangulName];
				else if ([type isEqualToString:@"450"])
					title_label.text = [NSString stringWithFormat:@"대형탁상달력 - %@", photobook.ThemeHangulName];
				else if ([type isEqualToString:@"452"])
					title_label.text = [NSString stringWithFormat:@"와이드탁상달력 - %@", photobook.ThemeHangulName];
				else if ([type isEqualToString:@"455"])
					title_label.text = [NSString stringWithFormat:@"브라스이젤달력 - %@", photobook.ThemeHangulName];
				
            }
        }
        else if (photobook.product_type == PRODUCT_POLAROID) {
            title_label.text = [NSString stringWithFormat:@"폴라로이드 - %@", photobook.ThemeHangulName];
        }
        else if (photobook.product_type == PRODUCT_POSTCARD) {
            title_label.text = [NSString stringWithFormat:@"포토엽서 - %@ %dP", photobook.ThemeHangulName, photobook.MinPage];
        }
        else if (photobook.product_type == PRODUCT_MAGNET) {
            title_label.text = [NSString stringWithFormat:@"냉장고자석 - %@ %dP", photobook.ThemeHangulName, photobook.MinPage];
        }
        else if (photobook.product_type == PRODUCT_CARD) {
            title_label.text = [NSString stringWithFormat:@"포토카드 - %@", photobook.ThemeHangulName];
        }
        else if (photobook.product_type == PRODUCT_DESIGNPHOTO) {
            title_label.text = [NSString stringWithFormat:@"디자인포토 - %@", photobook.ThemeHangulName];
        }
        else if (photobook.product_type == PRODUCT_SINGLECARD) {
            title_label.text = [NSString stringWithFormat:@"포토카드 - %@", photobook.ThemeHangulName];
        }
        else if (photobook.product_type == PRODUCT_POSTER) {
            title_label.text = [NSString stringWithFormat:@"포스터 - %@", photobook.ThemeHangulName];
        }
        else if (photobook.product_type == PRODUCT_PAPERSLOGAN) {
            title_label.text = [NSString stringWithFormat:@"종이슬로건 - %@", photobook.ThemeHangulName];
        }
        else if (photobook.product_type == PRODUCT_TRANSPARENTCARD) {
            title_label.text = [NSString stringWithFormat:@"투명 포토카드 - %@", photobook.ThemeHangulName];
        }
        else if (photobook.product_type == PRODUCT_DIVISIONSTICKER) {
            title_label.text = [NSString stringWithFormat:@"분할스티커 - %@", photobook.ThemeHangulName];
        }
        else {
            NSAssert(NO, @"PhotobookStorage: product type is wrong !!");
            title_label.text = @"unknown";
        }
/*
        NSString *year = [photobook.ProductId substringWithRange:NSMakeRange(0, 2)];
        NSString *month = [photobook.ProductId substringWithRange:NSMakeRange(2, 2)];
        NSString *day = [photobook.ProductId substringWithRange:NSMakeRange(4, 2)];
        NSString *hour = [photobook.ProductId substringWithRange:NSMakeRange(6, 2)];
        NSString *minute = [photobook.ProductId substringWithRange:NSMakeRange(8, 2)];
        NSString *second = [photobook.ProductId substringWithRange:NSMakeRange(10, 2)];
        date_label.text = [NSString stringWithFormat:@"파일명: 20%@-%@-%@ %@:%@:%@", year, month, day, hour, minute, second];*/
        date_label.text = [NSString stringWithFormat:@"파일명: %@", photobook.BasketName];
        
        edit_flag.image = (photobook.Edited) ? [UIImage imageNamed:@"photobook_edit_done.jpg"] : [UIImage imageNamed:@"photobook_edit_doing.jpg"];

        NSLog(@"photobook.thumbs : %@", photobook.thumbs);

        if (photobook.thumbs.count > 2) {
            thumb1.image = [UIImage imageWithContentsOfFile:photobook.thumbs[0]];
            thumb2.image = [UIImage imageWithContentsOfFile:photobook.thumbs[1]];
            thumb3.image = [UIImage imageWithContentsOfFile:photobook.thumbs[2]];
        }
        else if (photobook.thumbs.count > 1) {
            thumb1.image = [UIImage imageWithContentsOfFile:photobook.thumbs[0]];
            thumb2.image = [UIImage imageWithContentsOfFile:photobook.thumbs[1]];
            thumb3.image = [UIImage imageNamed:@"photobook_emptyphoto.png"];
        }
        else if (photobook.thumbs.count > 0) {
            thumb1.image = [UIImage imageWithContentsOfFile:photobook.thumbs[0]];
            thumb2.image = [UIImage imageNamed:@"photobook_emptyphoto.png"];
            thumb3.image = [UIImage imageNamed:@"photobook_emptyphoto.png"];
        }
        else {
            thumb1.image = [UIImage imageNamed:@"photobook_emptyphoto.png"];
            thumb2.image = [UIImage imageNamed:@"photobook_emptyphoto.png"];
            thumb3.image = [UIImage imageNamed:@"photobook_emptyphoto.png"];
        }
/*
        UIButton *button1 = (UIButton *)[cell viewWithTag:106];
        UIButton *button2 = (UIButton *)[cell viewWithTag:107];
        button1.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
        button1.layer.borderWidth = 1.0f;
        button2.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
        button2.layer.borderWidth = 1.0f;*/
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = 220;

    return CGSizeMake(width, height);
}
//MAcheck
- (IBAction)deletePhotobook:(id)sender {
    
    [[Common info]alert:self Title:@"삭제하시겠습니까?" Msg:@"" okCompletion:^{
        
        if ([sender superview] != nil) {
            // iOS 7 이상은 super's super. 이전에는 그냥 super.
            if ([[sender superview] superview] != nil) {
                UICollectionViewCell *cell = (UICollectionViewCell*)[[sender superview] superview];
                if (cell != nil) {
                    NSIndexPath *indexPath = [self.collection_view indexPathForCell:cell];
                    if (indexPath) {
                        Photobook *photobook = self.book_array[indexPath.row];
                        if (photobook != nil) {
                            // 폴더 삭제.
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            if ([fileManager removeItemAtPath:photobook.base_folder error:nil] == YES) {
                                NSLog(@"폴더 삭제 완료");
                            }
                            else {
                                NSLog(@"폴더 삭제 실패");
                            }
                            [self.book_array removeObject:photobook];
                            [self.collection_view deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                            [self.collection_view reloadData];
                        }
                    }
                }
            }
        }

    } cancelCompletion:^{
        
    } okTitle:@"확인" cancelTitle:@"취소"];
}

- (IBAction)editPhotobook:(id)sender {
    if ([sender superview] != nil) {
        // iOS 7 이상은 super's super. 이전에는 그냥 super.
        if ([[sender superview] superview] != nil) {
            UICollectionViewCell *cell = (UICollectionViewCell*)[[sender superview] superview];
            if (cell != nil) {
                NSIndexPath *indexPath = [self.collection_view indexPathForCell:cell];
                if (indexPath) {
                    Photobook *photobook = _book_array[indexPath.row];
                    if (photobook != nil) {
                        [Common info].photobook = nil;
                        [Common info].photobook = photobook;

                        if (photobook.product_type == PRODUCT_PHOTOBOOK && ([Common info].photobook.depth1_key.length > 0 || [Common info].photobook.ProductType.length > 0 )) {
                            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotobookV2" bundle:nil];
                            PhotobookV2EditTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PhotobookEditTableView"];
                            if (vc) {
                                vc.is_new = NO;
                                
                                [self.navigationController pushViewController:vc animated:YES];
                            }
                        }
                        else if (photobook.product_type == PRODUCT_PHOTOBOOK) {
                            [self performSegueWithIdentifier:@"PhotobookLoadSegue" sender:self];
                        }
                        else if (photobook.product_type == PRODUCT_CALENDAR) {
                            [self performSegueWithIdentifier:@"CalendarLoadSegue" sender:self];
                        }
                        else if (photobook.product_type == PRODUCT_POLAROID) {
                            [self performSegueWithIdentifier:@"PolaroidLoadSegue" sender:self];
                        }
                        else if (photobook.product_type == PRODUCT_DESIGNPHOTO) {
                            [self performSegueWithIdentifier:@"DesignPhotoLoadSegue" sender:self];
                        }
                        else if (photobook.product_type == PRODUCT_SINGLECARD) {
                            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotoCard24" bundle:nil];
                            SingleCardEditViewController *vc = [sb instantiateViewControllerWithIdentifier:@"designPhotoEditViewController"];
                            if (vc) {
                                vc.is_new = NO;
                            }
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                        /*
                         DesignPhotoEditViewController *vc = [segue destinationViewController];
                         
                         */
                        else if (photobook.product_type == PRODUCT_CARD) {
                            [self performSegueWithIdentifier:@"CardLoadSegue" sender:self];
                        }
                        else if (photobook.product_type == PRODUCT_POSTCARD) {
                            [self performSegueWithIdentifier:@"PostcardLoadSegue" sender:self];
                        }
                        else if (photobook.product_type == PRODUCT_MAGNET) {
                            [self performSegueWithIdentifier:@"MagnetLoadSegue" sender:self];
                        }
                        else if (photobook.product_type == PRODUCT_POSTER) {
                            [self performSegueWithIdentifier:@"PosterLoadSegue" sender:self];
                        }
                        else if (photobook.product_type == PRODUCT_PAPERSLOGAN) {
                            [self performSegueWithIdentifier:@"PaperSloganLoadSegue" sender:self];
                        }
                        else if (photobook.product_type == PRODUCT_TRANSPARENTCARD) {
                            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PhotoCard24" bundle:nil];
                            GoodsTransparentCardEditViewController *vc = [sb instantiateViewControllerWithIdentifier:@"GoodsTransparentCardEditViewController"];
                            if (vc) {
                                vc.is_new = NO;
                            }
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                        else if (photobook.product_type == PRODUCT_DIVISIONSTICKER) {
                            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"FancyDivision" bundle:nil];
                            FancyDivisionEditViewController *vc = [sb instantiateViewControllerWithIdentifier:@"FancyDivisionEditView"];
                            if (vc) {
                                vc.is_new = NO;
                            }
                            [self.navigationController pushViewController:vc animated:YES];
                        }
                        else {
                            NSAssert(NO, @"PhotobookStorage's edit segue: product type is wrong !!");
                        }
                    }
                }
            }
        }
    }
}

- (IBAction)orderPhotobook:(id)sender {
    if ([sender superview] != nil) {
        // iOS 7 이상은 super's super. 이전에는 그냥 super.
        if ([[sender superview] superview] != nil) {
            UICollectionViewCell *cell = (UICollectionViewCell*)[[sender superview] superview];
            if (cell != nil) {
                NSIndexPath *indexPath = [self.collection_view indexPathForCell:cell];
                if (indexPath) {
                    Photobook *photobook = _book_array[indexPath.row];
                    if (photobook != nil) {
                        // checkDiscontinuedProduct :: 여기서 구현                        
                        NSString *intnum = @"";
                        NSString *seqnum = @"";
                        if (photobook.ProductCode.length == 6) {
                            intnum = [photobook.ProductCode substringWithRange:NSMakeRange(0, 3)];
                            seqnum = [photobook.ProductCode substringWithRange:NSMakeRange(3, 3)];

							// SJYANG 수정 : 이동헌 대리님 요청 사항
                            NSString *url = [NSString stringWithFormat:URL_CHECK_DISCONTINUED_PRODUCT, intnum, seqnum, photobook.TotalPageCount, [Common info].device_uuid];

							NSString *addParam = @"";
							@try {
								if (photobook.product_type == PRODUCT_PHOTOBOOK) {
									if( [photobook.ThemeName isEqualToString:@"premium"] ) {
										addParam = [NSString stringWithFormat:@"^^0^%@^%d^%@_%@", [Common info].user.mUserid, photobook.ProductPrice, [photobook.DefaultStyle lowercaseString], photobook.AddParams];
									} 
								}
								else if (photobook.product_type == PRODUCT_POLAROID || photobook.product_type == PRODUCT_POSTCARD) {
									addParam = photobook.AddParams;
								}
								else if (photobook.product_type == PRODUCT_CARD) {
									NSString* tAddParams = @"";
									NSString* tScodix = @"";

									NSString *params_filepath = [NSString stringWithFormat:@"%@/edit/params.%@", photobook.base_folder, photobook.ProductId];
									NSString* tContent = [NSString stringWithContentsOfFile:params_filepath encoding:NSUTF8StringEncoding error:nil];

									NSArray *tArray = [tContent componentsSeparatedByString:@":"];
									tScodix = tArray[0];
									tAddParams = tArray[1];
									if( tScodix == nil ) tScodix = @"";
									if( tAddParams == nil ) tAddParams = @"";

									addParam = tAddParams;
								}
								else if (photobook.product_type == PRODUCT_FRAME || photobook.product_type == PRODUCT_MUG) {
									addParam = photobook.AddParams;
								}
								else if (photobook.product_type == PRODUCT_PHONECASE) {
									addParam = photobook.AddParams;
								}
								else if (photobook.product_type == PRODUCT_BABY) {
									addParam = photobook.AddParams;
								}
								else if (photobook.product_type == PRODUCT_CALENDAR) {
									// 포스터 달력 : AddParams
									if ([intnum isEqualToString:@"393"]) 
										addParam = photobook.AddParams;
								}
							}
					        @catch (NSException *e) {
								NSLog(@"addParam 오류 발생 !!!");
							}

							url = [NSString stringWithFormat:@"%@&AddParam=%@", url, addParam];
							//NSLog(@"URL_CHECK_DISCONTINUED_PRODUCT : %@", url);

                            NSData *ret_val = [[Common info] downloadSyncWithURL:[NSURL URLWithString:url]];
                            if (ret_val != nil) {
                                NSString *data = [[NSString alloc] initWithData:ret_val encoding:NSUTF8StringEncoding];
                                data = [data stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
#ifndef PHOTOMON_TESTMODE
                                if (![data isEqualToString:@"y"]) {
                                    [[Common info] alert:self Msg:@"품절 혹은 판매중지된 상품입니다.\n\n자세한 문의사항은\n고객센터로 연락주세요."];
                                    [Common info].photobook = nil;
                                    // SJYANG : 다음과 같은 오류로 인해 아래 라인 추가
                                    // *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'PolaroidDetailViewController.m: 코팅에러2'
                                    [Common info].photobook = photobook;
                                    return;
                                }
#endif
                            }
                            
                            // SJYANG : 미니폴라로이드 단종 오류 수정
                            // daypark : 미니폴라로이드 세트의 페이지 수가 기존 41p에서 39p로 변경됨에 따라, 기존 41p는 주문을 못하도록 막아야 한다. 2017.9.15
                            if ([photobook.ProductCode isEqualToString:@"347032"] && photobook.TotalPageCount != 39) {
                                [[Common info] alert:self Msg:@"품절 혹은 판매중지된 상품입니다.\n\n자세한 문의사항은\n고객센터로 연락주세요."];
                                [Common info].photobook = nil;
                                [Common info].photobook = photobook;
                                return;
                            }
                        }

                        // 편집 완료 여부 체크
                        //photobook.Edited = [photobook isEditComplete]; // 포토북을 모두 로드한 상태가 아니라 체크 불가.
                        if (!photobook.Edited) {
                            [[Common info] alert:self Msg:@"편집이 완료되지 않았습니다."];
                            [Common info].photobook = nil;
                            // SJYANG : 다음과 같은 오류로 인해 아래 라인 추가
                            // *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'PolaroidDetailViewController.m: 코팅에러2'
                            [Common info].photobook = photobook;
                            return;
                        }

                        [Common info].photobook = nil;
                        [Common info].photobook = photobook;
                        if ([self shouldPerformSegueWithIdentifier:@"PhotobookUploadSegue" sender:self]) {
                            [self performSegueWithIdentifier:@"PhotobookUploadSegue" sender:self];
                        }
                    }
                }
            }
        }
    }
}
@end
