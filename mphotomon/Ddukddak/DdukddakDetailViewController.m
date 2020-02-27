//
//  DdukddakDetailViewController.m
//  PHOTOMON
//
//  Created by 곽세욱 on 04/10/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "DdukddakDetailViewController.h"
#import "Common.h"
#import "WebpageViewController.h"
#import "ZoomViewController.h"
#import "DdukddakUploadPopupViewController.h"
#import "DdukddakOptionViewController.h"

@interface DdukddakDetailViewController ()

@end

@implementation DdukddakDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
//     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[Ddukddak LoadProduct];
	
	_selSizeIndex = 0;
	_selCoverIndex = 0;
	_selCoatingIndex = 0;
	_selectedTheme = [Ddukddak inst].selectedTheme;
    [self setTitle: [Ddukddak inst].selectedTheme.theme_name];
	[self updateBookInfo];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return UIInterfaceOrientationPortrait;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// 포토북
    // remove delivery info 9 -> 8
    // return 9;
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (indexPath.row == 0) // 0번은 썸네일
		return 290;
	
	return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *seqnum = [_bookInfo.productcode substringWithRange:NSMakeRange(3,3)];
	NSInteger row = indexPath.row;
	
	if(row == 0) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThumbnailCell" forIndexPath:indexPath];
		
		UICollectionView *cv = [cell viewWithTag:101];
		
		if (cv) {
			_thumbnailView = cv;
			[cv setDelegate:self];
			[cv setDataSource:self];
		}
		
		UIPageControl *pc = [cell viewWithTag:102];
		if (pc) {
			_thumbnailPageControl = pc;
		}
		
		UIButton *showDetail = [cell viewWithTag:103];
		[showDetail removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
		[showDetail addTarget:self action:@selector(popupDetail:) forControlEvents:UIControlEventTouchUpInside];
		
		UIButton *showMore = [cell viewWithTag:104];
		[showMore removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
		[showMore addTarget:self action:@selector(popupMore:) forControlEvents:UIControlEventTouchUpInside];
		
		return cell;
	}
	else if (row > 0 && row <= 3) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DropdownOptionCell" forIndexPath:indexPath];
		
		UILabel *title = [cell viewWithTag:301];
		UIButton *opt1 = [cell viewWithTag:302];
		UIButton *opt2 = [cell viewWithTag:303];
	
		[opt1 removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
		[opt1 addTarget:self action:@selector(clickOption:) forControlEvents:UIControlEventTouchUpInside];
		
		[opt2 removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
		[opt2 addTarget:self action:@selector(clickOption:) forControlEvents:UIControlEventTouchUpInside];
		
		if (row == 1) {
			[title setText:@"사이즈"];
			opt1.layer.name = @"size";
			opt2.layer.name = @"size";
			NSString *option = [NSString stringWithFormat:@"%@ (%@)", _selectedTheme.book_sizes[_selSizeIndex], _bookInfo.cm];
			[opt1 setTitle:option forState:UIControlStateNormal];
		} else if (row == 2) {
			[title setText:@"커버종류"];
			opt1.layer.name = @"cover";
			opt2.layer.name = @"cover";
            SelectOption *sel_item;
            if(_selectedTheme.sel_covertypes.count > 0 )
            {
                sel_item = _selectedTheme.sel_covertypes[_selCoverIndex];
                [opt1 setTitle:sel_item.comment forState:UIControlStateNormal];
            }else{
                [opt1 setTitle:_bookInfo.covertype forState:UIControlStateNormal];
            }
			
		} else if (row == 3) {
			[title setText:@"내지코팅"];
			opt1.layer.name = @"coat";
			opt2.layer.name = @"coat";
            SelectOption *so;
            if(_selectedTheme.sel_coatings.count > 0){
                so = (SelectOption *)_selectedTheme.sel_coatings[_selCoatingIndex];
                       [opt1 setTitle:so.comment forState:UIControlStateNormal];
            }
            else{
                [opt1 setTitle:_bookInfo.pagepaper forState:UIControlStateNormal];
            }
           
		}
		
		return cell;
	}
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DescriptionCell" forIndexPath:indexPath];
	UILabel *title = [cell viewWithTag:201];
	UILabel *desc = [cell viewWithTag:202];
	
	if (row == 4) {
		[title setText:@"금액"];
		
//		NSString *price = [[Common info] toCurrencyString:[bi.price intValue]];
//        NSString *discount = [[Common info] toCurrencyString:[bi.discount intValue]];
//		NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@원 %@원", price, discount]];
//		[text addAttributes:@{NSStrikethroughStyleAttributeName : @1,
//							NSStrikethroughColorAttributeName : [UIColor lightGrayColor],
//							NSForegroundColorAttributeName : [UIColor grayColor]}
//					   range:NSMakeRange(0, [price length] + 1)];
//		[text addAttributes:@{
//							NSFontAttributeName: [UIFont boldSystemFontOfSize:14],
//							NSForegroundColorAttributeName : [UIColor redColor]}
//					   range:NSMakeRange([price length] + 2, [discount length] + 1)];
		
		NSString *price = [[Common info] toCurrencyString:(int)[Ddukddak inst].price];
		NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@원", price]];
		[text addAttributes:@{
							NSForegroundColorAttributeName : [UIColor grayColor]}
					   range:NSMakeRange(0, [price length] + 1)];
		
		[desc setAttributedText:text];
	} else if (row == 5) {
		[title setText:@"최소사진개수"];
		// 사진 수는 확인 후 변경가능성있음.
		NSString *formatedStr = [NSString stringWithFormat:@"%@장", _bookInfo.minpictures];
//		NSString *formatedStr = @"60 ~ 600장";
		NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:formatedStr];
		[text addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}
					   range:NSMakeRange(0, [formatedStr length])];
		[desc setAttributedText:text];
	} else if (row == 6) {
		NSString *addprice = [[Common info] toCurrencyString:[_bookInfo.addpageprice intValue] * 2];
		NSString *titleStr = @"";
		NSString *descStr = @"";
		if ([seqnum isEqualToString:@"268"] || [seqnum isEqualToString:@"267"]) {
			titleStr = @"기본구성";
			if( _bookInfo.minpages == _bookInfo.maxpages )
				descStr = [NSString stringWithFormat:@"기본 %@p (페이지추가불가)", _bookInfo.minpages];
			else
				descStr = [NSString stringWithFormat:@"기본 %@p~%@p (2p추가시 %@원)", _bookInfo.minpages, _bookInfo.maxpages, addprice];
		}
		else if ([seqnum isEqualToString:@"269"] || [seqnum isEqualToString:@"270"]) { // analogue photobook
			titleStr = @"기본구성";
			descStr = [NSString stringWithFormat:@"표지포함 %@p (페이지추가불가)", _bookInfo.productoption2];
		}
		else {
			// SJYANG : 2017.12.09 : 스키니북/카달로그 처리
			titleStr = @"페이지수";
			if([_bookInfo.productcode isEqualToString:@"300180"] || [_bookInfo.productcode isEqualToString:@"300181"]) {
				descStr = @"기본 23p (커버제외)";
			}
			else if([_bookInfo.productcode isEqualToString:@"120069"]) {
				descStr = [NSString stringWithFormat:@"기본%@p~최대%@p (4p씩 추가가능)", _bookInfo.minpages, _bookInfo.maxpages];
			}
			else if ([seqnum isEqualToString:@"201"] || [seqnum isEqualToString:@"203"] || [seqnum isEqualToString:@"205"]) {
				descStr = [NSString stringWithFormat:@"기본%@p~최대%@p (2p추가시 %@원)", _bookInfo.minpages, _bookInfo.maxpages, @"1,000"];
			}
			else {
				descStr = [NSString stringWithFormat:@"기본%@p~최대%@p (2p추가시 %@원)", _bookInfo.minpages, _bookInfo.maxpages, addprice];
			}
		}
		
		[title setText:titleStr];
		NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:descStr];
		[text addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}
					   range:NSMakeRange(0, [descStr length])];
		[desc setAttributedText:text];
	} else if (row == 7) {
		NSString *titleStr = @"용지";
		NSString *descStr = @"";
		
		if ([seqnum isEqualToString:@"268"] || [seqnum isEqualToString:@"267"]) {
			descStr = [NSString stringWithFormat:@"커버:%@ / 내지:%@", _bookInfo.coverpaper, _bookInfo.pagepaper];
		}
		else if ([seqnum isEqualToString:@"269"] || [seqnum isEqualToString:@"270"]) { // analogue photobook
			descStr = _bookInfo.pagepaper;
		}
		else {
			// SJYANG : 2017.12.09 : 스키니북/카달로그 처리
			if([_bookInfo.productcode isEqualToString:@"300180"] || [_bookInfo.productcode isEqualToString:@"300181"] || [_bookInfo.productcode isEqualToString:@"120069"]) {
				titleStr = @"제본";
				descStr = _bookInfo.bind;
			}
			else if ([seqnum isEqualToString:@"201"] || [seqnum isEqualToString:@"203"] || [seqnum isEqualToString:@"205"]) {
				descStr = [NSString stringWithFormat:@"커버:%@", _bookInfo.coverpaper];
			}
			else {
				// SJYANG
				// 프리미엄북일 경우 항목에서 "커버:xx / 내지:xx" 에서 "커버:xx" 정보를 표시하지 않음
				if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] )
					descStr = [NSString stringWithFormat:@"내지:%@", _bookInfo.pagepaper];
				else
					descStr = [NSString stringWithFormat:@"커버:%@ / 내지:%@", _bookInfo.coverpaper, _bookInfo.pagepaper];
			}
		}
		
		[title setText:titleStr];
		// 예외처리 필요
		NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:descStr];
		[text addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}
					   range:NSMakeRange(0, [descStr length])];
		[desc setAttributedText:text];
	} else if (row == 8) {
		[title setText:@"주문안내"];
		// 내용 필요
		NSString *productmsg;
        if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] )
            productmsg = [[Common info].connection productMsg:2];
        else
            productmsg = [[Common info].connection productMsg:1];
        if (productmsg.length > 0) {
            NSString *temp_msg = [NSString stringWithFormat:@"(%.0f만원 이상 무료)", (float)([Common info].connection.delivery_free_cost / 10000)];
            productmsg = [productmsg stringByReplacingOccurrencesOfString:@"입니다." withString:@"."];
            productmsg = [NSString stringWithFormat:@"%@%@", productmsg, temp_msg];
            
			NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:productmsg];
			[text addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}
						   range:NSMakeRange(0, [productmsg length])];
			[desc setAttributedText:text];
            
            UILabel *deliverytitle = (UILabel *)[cell viewWithTag:222];
            deliverytitle.numberOfLines = 0;
            [deliverytitle sizeToFit];
		} else {
			NSString *formatedStr = [NSString stringWithFormat:@"지금 주문하시면 8월 10일(수)까지\n시안작업 완료 예정"];
			NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:formatedStr];
			[text addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]}
						   range:NSMakeRange(0, [formatedStr length])];
			[desc setAttributedText:text];
		}
		
//		NSString *formatedStr = [NSString stringWithFormat:@"5~7일이내 (토/일 공휴일 제외)"];
//		NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:formatedStr];
//		[text addAttributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor]}
//					   range:NSMakeRange(0, [formatedStr length])];
//		[desc setAttributedText:text];
		
	}

	return cell;
}

- (IBAction)popupDetail:(id)sender {
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZoomViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ZoomPage"];
	vc.selected_theme = _selectedTheme;
    vc.option_str = _selectedTheme.book_sizes[_selSizeIndex];
    vc.product_type = PRODUCT_PHOTOBOOK;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)popupMore:(id)sender {
    NSString *intnum = @"";
    NSString *seqnum = @"";
    NSString *product_code = [Common info].photobook.ProductCode;
    if (product_code.length == 6) {
        intnum = [product_code substringWithRange:NSMakeRange(0, 3)];
        seqnum = [product_code substringWithRange:NSMakeRange(3, 3)];
    }

	// SJYANG : 상품유형 추가 (손글씨포토북/인스타북)
    if ([seqnum isEqualToString:@"270"])
		seqnum = @"269";
    else if ([seqnum isEqualToString:@"268"])
		seqnum = @"267";

    NSString *url = [NSString stringWithFormat:URL_PRODUCT_DETAIL, intnum, seqnum];
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WebpageViewController *vc = [sb instantiateViewControllerWithIdentifier:@"WebPage"];
    vc.url = url;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)clickUpload:(id)sender {
	
	NSData *url_ret = [[Common info] downloadSyncWithURL:[NSURL URLWithString:[NSString stringWithFormat:URL_GET_UPLOAD_SERVER_BY_SVCMODE, @"ddudak"]]];
	NSString *uploadURL = nil;
	if (url_ret != nil) {
		uploadURL = [[NSString alloc] initWithData:url_ret encoding:NSUTF8StringEncoding];
	}
	
	if (uploadURL == nil || [uploadURL isEqualToString:@""]) {
		return;
	}
	
	[Ddukddak inst].selSize = _selectedTheme.book_sizes[_selSizeIndex];
    SelectOption *selCover;
    if(_selectedTheme.sel_covertypes.count > 0 ){
       selCover = _selectedTheme.sel_covertypes[_selCoverIndex];
        [Ddukddak inst].selCover = selCover.comment;
    }else{
        [Ddukddak inst].selCover = _bookInfo.covertype;
    }
    
    SelectOption *selCoating;
    if(_selectedTheme.sel_coatings.count > 0){
        selCoating = (SelectOption *)_selectedTheme.sel_coatings[_selCoatingIndex];
               [Ddukddak inst].selCoating = selCoating.comment;
    }
    else{
        [Ddukddak inst].selCoating = _bookInfo.pagepaper;
    }
	
	[Common info].photobook.product_type = PRODUCT_DDUKDDAK;
	// 사진 수는 확인 후 변경가능성있음.
	[[Common info] selectPhoto:self Singlemode:NO MinPictures:60 Param:@"600"
		cancelOp:^(UIViewController *vc) {
			[[Common info] alert:self Title:@"뚝딱서비스 주문을 취소하시겠습니까?" Msg:@"" okCompletion:^{
			} cancelCompletion:^{
				[vc dismissViewControllerAnimated:YES completion:nil];
			} okTitle:@"계속 주문" cancelTitle:@"취소"];
		}
		selectDoneOp:^(UIViewController *vc) {
			int totalCount = (int)[[PhotoContainer inst] selectCount];
			NSString *msg = [NSString stringWithFormat:@"%d장의 사진을 업로드 하시겠습니까?\nWifi환경이 아니면 통신요금이 부과될 수 있습니다.", totalCount ];
			
			[[Common info] alert:vc Title:msg Msg:@"" okCompletion:^{
				
				DdukddakUploadPopupViewController *mupvc = [self.storyboard instantiateViewControllerWithIdentifier:@"UploadPhotoPopup"];
				
				if (mupvc) {
					[mupvc setData:totalCount uploadURL:uploadURL svcmode:@"ddudak" uploadDoneOp:^(BOOL isSuccess, NSString* imageKey) {
						[Ddukddak inst].totSaveCount = [[PhotoContainer inst] selectCount];
						[[PhotoContainer inst] removeAll];
						// presentViewController 필요
						[vc dismissViewControllerAnimated:NO completion:^{
							DdukddakOptionViewController *dovc = [self.storyboard instantiateViewControllerWithIdentifier:@"ddukddakOptionViewController"];
							[self.navigationController pushViewController:dovc animated:YES];
						}];
						
					}];
					[vc presentViewController:mupvc animated:NO completion:nil];
				}
				
			} cancelCompletion:^{
			} okTitle:@"네" cancelTitle:@"아니오"];
		}
	 ];
}

- (void)clickOption:(id)sender {
	UIButton *btn = (UIButton *)sender;
	NSString *type = btn.layer.name;
	
	UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *alert_action = nil;
	
	if ([type isEqualToString:@"size"]) {
		for (int i = 0; i < _selectedTheme.book_sizes.count; i++) {
			int idx = i;
			NSString *option = [NSString stringWithFormat:@"%@ (%@)", _selectedTheme.book_sizes[idx], _bookInfo.cm];
			alert_action = [UIAlertAction actionWithTitle:option style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				self->_selSizeIndex = idx;
				
				[self updateBookInfo];
				[self.tableView reloadData];
				[vc dismissViewControllerAnimated:YES completion:nil];
			}];
			[vc addAction:alert_action];
		}
	} else if ([type isEqualToString:@"cover"]) {
		for (int i = 0; i < _selectedTheme.sel_covertypes.count; i++){
			int idx = i;
			SelectOption *sel_item = _selectedTheme.sel_covertypes[idx];
			alert_action = [UIAlertAction actionWithTitle:sel_item.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				self->_selCoverIndex = idx;
				
				if (self->_selCoverIndex == 1)
					self->_selCoatingIndex = 0;
				
				[self updateBookInfo];
				[self.tableView reloadData];
				[vc dismissViewControllerAnimated:YES completion:nil];
			}];
			[vc addAction:alert_action];
		}
	} else if ([type isEqualToString:@"coat"]) {
		for (int i = 0; i < _selectedTheme.sel_coatings.count; i++) {
			int idx = i;
			SelectOption *option = _selectedTheme.sel_coatings[idx];
			alert_action = [UIAlertAction actionWithTitle:option.comment style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
				self->_selCoatingIndex = idx;
				
				[self updateBookInfo];
				[self.tableView reloadData];
				[vc dismissViewControllerAnimated:YES completion:nil];
			}];
			[vc addAction:alert_action];
			
			if (self->_selCoverIndex == 1)
				break;
		}
	}
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"취소" style:UIAlertActionStyleDefault handler:nil];
    [vc addAction:cancel];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	
	NSInteger cnt = 1 + ([Ddukddak inst].selectedTheme.preview_thumbs.count - 1) / 2;
	_thumbnailPageControl.numberOfPages = cnt;
	
    return cnt;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	NSString *seqnum = [_bookInfo.productcode substringWithRange:NSMakeRange(3,3)];
	UICollectionViewCell *cell = nil;
	
	if (indexPath.row == 0) {
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbnailImageCell" forIndexPath:indexPath];
	} else {
		cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Thumbnail2ImageCell" forIndexPath:indexPath];
	}
	
	NSInteger thumbIndex = indexPath.row == 0 ? 0 : indexPath.row * 2 - 1;
	
	UILabel *pageLabel = (UILabel *)[cell viewWithTag:1000];
	
	if ([seqnum isEqualToString:@"269"] || [seqnum isEqualToString:@"270"]) {
		if (indexPath.row == 0) {
			pageLabel.text = @"cover";
		}
		else if (indexPath.row == (_selectedTheme.preview_thumbs.count-1)) {
			pageLabel.text = @"back";
		}
		else {
			pageLabel.text = [NSString stringWithFormat:@"%d-%dp", (int)indexPath.row*2-1, (int)indexPath.row*2];
		}
	}
	else {
		if (indexPath.row == 0) {
			pageLabel.text = @"cover";
		}
		else if (indexPath.row == 1) {
			pageLabel.text = [NSString stringWithFormat:@"%d-%dp", (int)indexPath.row*2-1, (int)indexPath.row*2];
		}
		else if (indexPath.row == (_selectedTheme.preview_thumbs.count-1)) {
			pageLabel.text = @"back";
		}
		else {
			if( [[Common info].photobook.ThemeName isEqualToString:@"premium"] && (_selectedTheme.preview_thumbs.count-1) )
				pageLabel.text = [NSString stringWithFormat:@"%ddp", (int)indexPath.row*2-2];
			else
				pageLabel.text = [NSString stringWithFormat:@"%d-%dp", (int)indexPath.row*2-1, (int)indexPath.row*2];
		}
	}
	
	UIImageView __block *imageview = (UIImageView *)[cell viewWithTag:1001];
	
	[[Common info] downloadAsyncWithURL:[NSURL URLWithString:[Ddukddak inst].selectedTheme.preview_thumbs[thumbIndex]] completionBlock:^(BOOL succeeded, NSData *imageData) {
		if (succeeded) {
			imageview.image = [UIImage imageWithData:imageData];
		}
		else {
			NSLog(@"theme-detail's thumbnail_image is not downloaded.");
		}
	}];
	
	if (indexPath.row != 0) {
		UIImageView __block *imageview2 = (UIImageView *)[cell viewWithTag:1002];
		[[Common info] downloadAsyncWithURL:[NSURL URLWithString:[Ddukddak inst].selectedTheme.preview_thumbs[thumbIndex + 1]] completionBlock:^(BOOL succeeded, NSData *imageData) {
			if (succeeded) {
				imageview2.image = [UIImage imageWithData:imageData];
			}
			else {
				NSLog(@"theme-detail's thumbnail_image is not downloaded.");
			}
		}];
	}
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.height);
}

- (void)collectionView:(UICollectionView *)cellectionView didEndDisplayingCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
	NSLog(@"??? : %ld, %ld", indexPath.row, indexPath.section);
	
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _thumbnailView.frame.size.width;
    int page = floor((_thumbnailView.contentOffset.x - pageWidth/2) / pageWidth) + 1;
//
//    _page_control.currentPage = page;
	_thumbnailPageControl.currentPage = page;
}

- (void)updateBookInfo {
	BookInfo *equalBookSizeInfo;
	NSString *selSize = _selectedTheme.book_sizes[_selSizeIndex];
    SelectOption *cover;
    NSString *selCover;
    if(_selectedTheme.sel_covertypes.count > 0)
    {
        cover = _selectedTheme.sel_covertypes[_selCoverIndex];
        selCover = cover.comment;
    }
	
	for (BookInfo *bookinfo in _selectedTheme.book_infos) {
	   
		if ([bookinfo.booksize isEqualToString:selSize] ) {
			equalBookSizeInfo = bookinfo;
		}
		if (selCover != nil && [bookinfo.booksize isEqualToString:selSize] && [bookinfo.covertype isEqualToString:selCover] ) {
			[[Common info].photobook initPhotobookInfo:bookinfo ThemeInfo:_selectedTheme];
			_bookInfo = bookinfo;
			equalBookSizeInfo = nil;
			[_tableView reloadData];
			break;
		}
	}
	// 해당 사이즈는 있고 커버 타입이 맞는 것이 없는 경우는 사이즈가 같은것으로 설정
	if(equalBookSizeInfo){
		[[Common info].photobook initPhotobookInfo:equalBookSizeInfo ThemeInfo:_selectedTheme];
		_bookInfo = equalBookSizeInfo;
		[_tableView reloadData];
	}
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
