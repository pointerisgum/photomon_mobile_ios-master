//
//  PhotoSelectViewController.m
//  PHOTOMON
//
//  Created by 곽세욱 on 03/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "PhotoSelectViewController.h"
#import "Common.h"
#import "PhotoContainer.h"
#import "SocialBase.h"
#import "UIView+Toast.h"
#import "MonthlyBaby.h"
#import "MonthlyUploadPopup.h"
#import "MonthlyUploadDonePopup.h"

@interface PhotoSelectViewController ()

@end

@implementation PhotoSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	_imageManager = [[PHCachingImageManager alloc] init];
	
	if (_positionType == PHOTO_POSITION_LOCAL)
		[[PhotoContainer inst] clearCache:_positionType];
	
	if (_isSinglemode) {
		_selectListView.hidden = YES;
//		_bottomView.hidden = YES;
		_selectListViewHeight.constant = 0.0f;
//		_bottomViewHeight.constant = 0.0f;
	}
	
	_radioOnImage = [UIImage imageNamed:@"radio_on.png"];
    _radioOffImage = [UIImage imageNamed:@"radio_off.png"];
	
	_thread = nil;
	_waitIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	_waitIndicator.backgroundColor = [UIColor colorWithRed:128.0f/255.0f green:128.0f/255.0f blue:128.0f/255.0f alpha:0.5f];
	_waitIndicator.frame = self.view.frame;
	_waitIndicator.center = self.view.center;
	
	_groupIndex = -1;
	[self.view addSubview:_waitIndicator];
}

- (void)viewWillAppear:(BOOL)animated {
	if ([Common info].photobook.product_type == PRODUCT_BABY) {
		_selectButton.hidden = YES;
		_deselectButton.hidden = YES;
		
		NSLayoutConstraint *oldConstraint;
		
		oldConstraint = _selectWidth;
		NSLayoutConstraint *newConstraint1 = [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem attribute:oldConstraint.firstAttribute relatedBy:oldConstraint.relation toItem:oldConstraint.secondItem attribute:oldConstraint.secondAttribute multiplier:0 constant:oldConstraint.constant];
		
		oldConstraint = _selectWidth;
		NSLayoutConstraint *newConstraint2 = [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem attribute:oldConstraint.firstAttribute relatedBy:oldConstraint.relation toItem:oldConstraint.secondItem attribute:oldConstraint.secondAttribute multiplier:0 constant:oldConstraint.constant];
		oldConstraint = _doneWidth;
		NSLayoutConstraint *newConstraint3 = [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem attribute:oldConstraint.firstAttribute relatedBy:oldConstraint.relation toItem:oldConstraint.secondItem attribute:oldConstraint.secondAttribute multiplier:1 constant:oldConstraint.constant];
		oldConstraint = _doneCenterX;
		NSLayoutConstraint *newConstraint4 = [NSLayoutConstraint constraintWithItem:oldConstraint.firstItem attribute:oldConstraint.firstAttribute relatedBy:oldConstraint.relation toItem:oldConstraint.secondItem attribute:oldConstraint.secondAttribute multiplier:1 constant:oldConstraint.constant];
		
		@try {
			[_selectButton.superview removeConstraint:_selectWidth];
			[_deselectButton.superview removeConstraint:_deselectWidth];
			[_doneButton.superview removeConstraint:_doneWidth];
			[_doneButton.superview removeConstraint:_doneCenterX];
		}
		@catch (NSException *e) {
			[_selectButton.superview.superview removeConstraint:_selectWidth];
			[_deselectButton.superview.superview removeConstraint:_deselectWidth];
			[_doneButton.superview.superview removeConstraint:_doneWidth];
			[_doneButton.superview.superview removeConstraint:_doneCenterX];
		}
		
		[self.view addConstraint:newConstraint1];
		[self.view addConstraint:newConstraint2];
		[self.view addConstraint:newConstraint3];
		[self.view addConstraint:newConstraint4];
	}
	
	[_photoListView reloadData];
	[_selectListView reloadData];
	[self updateTitle];
	[self updateButtons];
}

- (void)viewDidAppear:(BOOL)animated {
	
	if ([[PhotoContainer inst] cachedCount:_positionType]) {
		_hasMorePhoto = true;
	} else {
		_hasMorePhoto = false;
		if (_positionType == PHOTO_POSITION_LOCAL) {
			// ShowMore를 아무것도 없는것으로 한다.
			[_photoListView registerClass:[UICollectionReusableView class]
			   forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
					  withReuseIdentifier:@"ShowMore"];
			
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyyMMdd"];
			
			PHFetchOptions *albumFetchOption = [[PHFetchOptions alloc]init];
			albumFetchOption.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
			albumFetchOption.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
			
			PHFetchResult *loftAssetResult = [PHAsset fetchAssetsInAssetCollection:_selectedGroup options:albumFetchOption];
			
			[loftAssetResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
				if (![[PhotoContainer inst] isCached:asset]) {
					NSString *filename = [asset valueForKey:@"filename"];
					NSString *creationDate = [dateFormat stringFromDate:[asset creationDate]];
					[[PhotoContainer inst] cache:asset filename:filename creationDate:creationDate];
				}
				
				[[self photoListView] reloadData];
				[[self selectListView] reloadData];
				[self updateTitle];
			}];
		}else {
			[self more:@""];
		}
	}
}

- (void)setData:(id<SelectPhotoDelegate>)delegate positionType:(int)positionType  isSinglemode:(BOOL)isSinglemode minPictureCount:(int)minPictureCount param:(NSString *)param {
	_delegate = delegate;
	_positionType = positionType;
	_isSinglemode = isSinglemode;
	_minPictureCount = minPictureCount;
	_param = param;
}

- (void)setData:(id<SelectPhotoDelegate>)delegate positionType:(int)positionType  selectedGroup:(PHAssetCollection *)selectedGroup isSinglemode:(BOOL)isSinglemode minPictureCount:(int)minPictureCount param:(NSString *)param {
	
	_delegate = delegate;
	_positionType = positionType;
	_selectedGroup = selectedGroup;
	_isSinglemode = isSinglemode;
	_minPictureCount = minPictureCount;
	_param = param;
}

- (BOOL)isGroupedPosition {
	if (_positionType == PHOTO_POSITION_LOCAL
//		|| _positionType == PHOTO_POSITION_GOOGLEPHOTO
//		|| _positionType == PHOTO_POSITION_FACEBOOK
//		|| _positionType == PHOTO_POSITION_INSTAGRAM
//		|| _positionType == PHOTO_POSITION_KAKAOSTORY
//		|| _positionType == PHOTO_POSITION_SMARTBOX
		)
		return YES;
	
	return NO;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	if (collectionView == _photoListView && [self isGroupedPosition]) {
		return [[PhotoContainer inst] groupCount:_positionType];
	}
	
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	
	if (collectionView == _photoListView) {
		if ([self isGroupedPosition]) {
			return [[PhotoContainer inst] groupTotalCount:_positionType groupIndex:(int)section];
		}
		
		return [[PhotoContainer inst] cachedCount:_positionType];
	}
	else if (collectionView == _selectListView) {
		return [[PhotoContainer inst] selectCount];
	}
	//	return [[Common info].photo_pool totalCount];
	return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	
	if (collectionView != _photoListView)
		return nil;
	
	UICollectionReusableView *reusableview = nil;
	
	if (kind == UICollectionElementKindSectionFooter) {
		UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ShowMore" forIndexPath:indexPath];
		
		UIButton *more_button = (UIButton *)[footerview viewWithTag:200];
		if (more_button != nil) {
			more_button.enabled = _hasMorePhoto;
		}
		
		reusableview = footerview;
	} else if (kind == UICollectionElementKindSectionHeader) {
		UICollectionReusableView *headerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"DateGroup" forIndexPath:indexPath];
		
		GroupingData *gd = [[PhotoContainer inst] getGroupingData:_positionType groupIndex:(int)indexPath.section];
		
		if (gd != nil) {
			UIButton *sgBtn = (UIButton *)[headerview viewWithTag:300];
			if (sgBtn != nil) {
				if ([gd totalCount] == [gd selectedCount]) {
					[sgBtn setImage:_radioOnImage forState:UIControlStateNormal];
				} else {
					[sgBtn setImage:_radioOffImage forState:UIControlStateNormal];
				}
				[sgBtn setTitle:[NSString stringWithFormat:@"%lu", indexPath.section] forState:UIControlStateNormal];
			}
			
			UILabel *giLabel = (UILabel *)[headerview viewWithTag:301];
			if (giLabel != nil) {
				[giLabel setText:[NSString stringWithFormat:@"%lu", [gd totalCount]]];
			}
			
			UILabel *gdLabel = (UILabel *)[headerview viewWithTag:302];
			if (gdLabel != nil) {
				//년월일
				NSDateFormatter *parseFormat = [[NSDateFormatter alloc] init];
				[parseFormat setDateFormat:@"yyyyMMdd"];
				
				NSDate* creationDate = [parseFormat dateFromString:gd.creationDate];
				
				NSDateFormatter *toFormat = [[NSDateFormatter alloc] init];
				[toFormat setDateFormat:@"YYYY년 M월 d일"];
				
				[gdLabel setText:[toFormat stringFromDate:creationDate]];
			}
		}
		
		reusableview = headerview;
	}
	
	return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
	NSUInteger groupCnt = [[PhotoContainer inst] groupCount:_positionType];
	
	if (_positionType != PHOTO_POSITION_LOCAL) {
		if (![self isGroupedPosition] || section == groupCnt - 1)
			return CGSizeMake(0, 50);
	}
	
	return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
	
	if ([self isGroupedPosition])
		return CGSizeMake(0, 40);
	
	return CGSizeZero;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	if (collectionView == _photoListView)
	{
		UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
	
		PhotoItem *photoItem = nil;
		
		if ([self isGroupedPosition]) {
			photoItem = [[PhotoContainer inst] getCachedItem:_positionType groupIndex:(int)indexPath.section index:(int)indexPath.row];
		}
		else {
			photoItem = [[PhotoContainer inst] getCachedItem:_positionType index:(int)indexPath.row];
		}
		
		if (photoItem) {
			
			UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
			
			imageview.image = nil;
			[photoItem getThumbnailAsync:^(BOOL succeeded, UIImage *image) {
				if (succeeded) {
					imageview.image = image;
				}else {
					imageview.image = nil;
				}
			}];
			
			UIImageView *checkview = (UIImageView *)[cell viewWithTag:101];
			checkview.hidden = ![[PhotoContainer inst] isSelected:photoItem.positionType key:photoItem.key];
			checkview.alpha = checkview.hidden ? 1.0f : 0.5f;
			UIImageView *warningview = (UIImageView *)[cell viewWithTag:102];
			warningview.hidden = [photoItem isPrintable];
		}
		return cell;
	}
	
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectPhotoCell" forIndexPath:indexPath];
	PhotoItem *photoItem = [[PhotoContainer inst] getSelectedItem:(int)indexPath.row];
	
	if (photoItem) {
		UIImageView *imageview = (UIImageView *)[cell viewWithTag:200];
		imageview.image = nil;
		[photoItem getThumbnailAsync:^(BOOL succeeded, UIImage *image) {
			if (succeeded) {
				imageview.image = image;
			}else {
				imageview.image = nil;
			}
		}];
	}
	return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (collectionView == _selectListView) {
		return CGSizeMake(80, 80);
	}
	CGFloat spacing = 5.0;
	CGFloat size = (collectionView.bounds.size.width - spacing*4) / 3;
	return CGSizeMake(size, size);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if (collectionView == _selectListView) {
		[collectionView reloadData];
		return;
	}
	
	PhotoItem *photoItem = nil;
	
	if ([self isGroupedPosition]) {
		photoItem = [[PhotoContainer inst] getCachedItem:_positionType groupIndex:(int)indexPath.section index:(int)indexPath.row];
	}
	else {
		photoItem = [[PhotoContainer inst] getCachedItem:_positionType index:(int)indexPath.row];
	}
	
	if (photoItem){
		
		if ([photoItem isPrintable]) {
			if (_isSinglemode) {
				[[PhotoContainer inst] removeAll];
			}
			
			if ( [[PhotoContainer inst] isSelected:photoItem.positionType key:photoItem.key]){
				[[PhotoContainer inst] remove:photoItem.positionType key:photoItem.key];
			}
			else {
				if ([Common info].photobook.product_type == PRODUCT_BABY && [Common info].photobook.minpictures == 1) {
					[[PhotoContainer inst] removeAll];
				}
				else if ([Common info].photobook.product_type == PRODUCT_PHONECASE && [Common info].photobook.minpictures == 1) {
					[[PhotoContainer inst] removeAll];
				}
				
				if ([Common info].photobook.product_type == PRODUCT_BABY && [Common info].photobook.minpictures == 3) {
					if([[PhotoContainer inst] selectCount] < 3 ) {
						[[PhotoContainer inst] add:photoItem];
					}
				}
				else if ([Common info].photobook.product_type == PRODUCT_PHONECASE) {
					if([[PhotoContainer inst] selectCount] < [Common info].photobook.minpictures ) {
						[[PhotoContainer inst] add:photoItem];
					}
				}
				else if ([Common info].photobook.product_type == PRODUCT_MONTHLYBABY) {
					int maxCount = _minPictureCount;
					
					if (_param.length > 0) {
						int temp = [_param intValue];
						if (temp > 0) {
							maxCount = temp;
						}
					}					
					if([[PhotoContainer inst] selectCount] < maxCount ) {
						[[PhotoContainer inst] add:photoItem];
					}
				}
				else if ([Common info].photobook.product_type == PRODUCT_DDUKDDAK) {
					if ([[PhotoContainer inst] selectCount] < 600){
						[[PhotoContainer inst] add:photoItem];
					} else {
						[self.view makeToast:@"사진은 최대 600 장까지 선택할 수 있습니다."];
					}
				}
				else {
					[[PhotoContainer inst] add:photoItem];
				}
			}
			
			[self updateTitle];
			[self updateButtons];
			[_photoListView reloadData];
			if (!_isSinglemode)
				[_selectListView reloadData];
		}
	}
}

#pragma mark - UI
- (void) updateTitle {
	// 아이콘 있는거 못봐서 그건 좀있다 수정.
	int count = (int)[[PhotoContainer inst] selectCount];
	if ( count> 0 ){
		if (_minPictureCount > 0) {
			[self setTitle: [NSString stringWithFormat:@"사진 선택 (%d/%d)", count, _minPictureCount]];
		}
		else {
			[self setTitle: [NSString stringWithFormat:@"%d 장 선택", count]];
		}
	}
	else{
		[self setTitle:@"사진 선택"];
	}
}

- (void) updateButtons {
	int count = (int)[[PhotoContainer inst] selectCount];
	if (count > 0) {
		[_selectButton setHidden:YES];
		[_deselectButton setHidden:NO];
		[_doneButton setBackgroundColor:[UIColor colorWithRed:253.0f/255.0f green:177.0f / 255.0f blue:9.0f/255.0f alpha:1.0f]];
	}
	else {
		[_selectButton setHidden:NO];
		[_deselectButton setHidden:YES];
		[_doneButton setBackgroundColor:UIColor.lightGrayColor];
	}
}

- (IBAction)clickDelete:(id)sender {
	if ([sender superview] != nil) {
		// iOS 7 이상은 super's super. 이전에는 그냥 super.
		if ([[sender superview] superview] != nil) {
			UICollectionViewCell *cell = (UICollectionViewCell*)[[sender superview] superview];
			if (cell != nil) {
				NSIndexPath *indexPath = [_selectListView indexPathForCell:cell];
				if (indexPath) {
					[[PhotoContainer inst] removeAtIndex:(int)indexPath.row];
				}
				[_photoListView reloadData];
				[_selectListView reloadData];
				[self updateTitle];
				[self updateButtons];
			}
		}
	}
}

- (void)doingThread {
	[[PhotoContainer inst] removeAll];
	
	int count = 0;
	int maxCount = _minPictureCount;
	
	if (_isSinglemode)
		maxCount = 1;
	
	if (_param.length > 0) {
		int temp = [_param intValue];
		if (temp > 0) {
			maxCount = temp;
		}
	}
	
	int cachedCount = (int)[[PhotoContainer inst] cachedCount:_positionType];
	
	for (int i = 0; i < cachedCount; i++)
	{
		if (count >= maxCount){// minPictures개수만큼만 추가한다. 포토북의 경우는 _param 참고(248장)... 1200개를 넘으면 메모리 경고
			break;
		}
		
		PhotoItem *photoItem = [[PhotoContainer inst] getCachedItem:_positionType index:i];
		
		if ([photoItem isPrintable]) {
			[[PhotoContainer inst] add:photoItem];
			NSString *count_str = [NSString stringWithFormat:@"%d", ++count];
			[self performSelectorOnMainThread:@selector(setTitleThread:) withObject:count_str waitUntilDone:YES];
		}
		
		if ([[NSThread currentThread] isCancelled])
		{
			[[PhotoContainer inst] removeAll];
		}
	}
	
	[self performSelectorOnMainThread:@selector(doneThread) withObject:nil waitUntilDone:NO];
}

- (void)setTitleThread:(NSString *)count {
	[self updateTitle];
	[self updateButtons];
}

- (void)doneThread {
	[_waitIndicator stopAnimating];
	_naviDoneButton.enabled = YES;
	_selectButton.enabled = YES;
	
	[_photoListView reloadData];
	[_selectListView reloadData];
	[self updateTitle];
	[self updateButtons];
	_groupIndex = -1;
}

- (IBAction)selectAll:(id)sender {
	_selectButton.enabled = NO;
	_naviDoneButton.enabled = NO;
	[_waitIndicator startAnimating];

	if (_thread) {
	[_thread cancel];
		_thread = nil;
	}
	_thread = [[NSThread alloc] initWithTarget:self selector:@selector(doingThread) object:nil];
	[_thread start];
}

- (IBAction)deselectAll:(id)sender {
	[[PhotoContainer inst] removeAll];
	
	[_photoListView reloadData];
	[_selectListView reloadData];
	[self updateTitle];
	[self updateButtons];
}

- (IBAction)done:(id)sender {
	
	if ([[PhotoContainer inst] selectCount] <= 0) {
		[self.view makeToast:@"선택한 사진이 없습니다."];
		return;
	}
	
	if ([Common info].photobook.product_type == PRODUCT_DDUKDDAK) {
		if ([[PhotoContainer inst] selectCount] < _minPictureCount){
			[self.view makeToast:[NSString stringWithFormat:@"최소 %d장의 사진이 필요합니다.", _minPictureCount]];
			return;
		}
	}
	
	if (_selectDoneOp) {
		_selectDoneOp(self);
	} else {
		[self dismissViewControllerAnimated:YES completion:^{
			[self.delegate selectPhotoDone:_isSinglemode];
		}];
	}
}

- (void)fetchingPhotos {
	_hasMorePhoto = [[SocialManager inst] fetchMediaRecent:_positionType];
	
	[self performSelectorOnMainThread:@selector(doneThread) withObject:nil waitUntilDone:NO];
}

- (IBAction)more:(id)sender {
	_selectButton.enabled = NO;
	_naviDoneButton.enabled = NO;
	[_waitIndicator startAnimating];
	
	if (_thread) {
		[_thread cancel];
		_thread = nil;
	}
	_thread = [[NSThread alloc] initWithTarget:self selector:@selector(fetchingPhotos) object:nil];
	[_thread start];
}


- (void)doingToggleThread {
	
	int count = 0;
	int maxCount = _minPictureCount;
	
	if (_param.length > 0) {
		int temp = [_param intValue];
		if (temp > 0) {
			maxCount = temp;
		}
	}
	
	GroupingData *gd = [[PhotoContainer inst] getGroupingData:_positionType groupIndex:_groupIndex];
	
	for (int i = 0; i < [gd totalCount]; i++)
	{
		if (count >= maxCount){// minPictures개수만큼만 추가한다. 포토북의 경우는 _param 참고(248장)... 1200개를 넘으면 메모리 경고
			if ([Common info].photobook.product_type == PRODUCT_DDUKDDAK) {
				[self.view makeToast:@"사진은 최대 600 장까지 선택할 수 있습니다."];
			}
			break;
		}
		
		PhotoItem *photoItem = [gd getPhoto:i];
		
		if ([photoItem isPrintable]) {
			if (![[PhotoContainer inst] isSelected:_positionType key:photoItem.key]) {
				[[PhotoContainer inst] add:photoItem];
			}
			NSString *count_str = [NSString stringWithFormat:@"%d", ++count];
			[self performSelectorOnMainThread:@selector(setTitleThread:) withObject:count_str waitUntilDone:YES];
		}
		
		if ([[NSThread currentThread] isCancelled])
		{
			[gd deSelectAll];
		}
	}
	
	[self performSelectorOnMainThread:@selector(doneThread) withObject:nil waitUntilDone:NO];
}

- (IBAction) toggleGroupPhotos:(UIButton *)sender {
//	[self.view makeToast:sender.currentTitle];
	
	_groupIndex = [sender.currentTitle intValue];
	
	GroupingData *gd = [[PhotoContainer inst] getGroupingData:_positionType groupIndex:_groupIndex];
	
	if (gd != nil) {
		if ([gd totalCount] == [gd selectedCount]) {
			// 전부 없애기
			[gd deSelectAll];
			[_photoListView reloadData];
			[_selectListView reloadData];
			[self updateTitle];
			[self updateButtons];
			_groupIndex = -1;
		} else {
			// 모두 선택 이미 있는건 추가 안함
			if (_thread) {
			[_thread cancel];
				_thread = nil;
			}
			_thread = [[NSThread alloc] initWithTarget:self selector:@selector(doingToggleThread) object:nil];
			[_thread start];
		}
	}
	
}

@end
