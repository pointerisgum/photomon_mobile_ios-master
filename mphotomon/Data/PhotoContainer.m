//
//  PhotoContainer.m
//  PHOTOMON
//
//  Created by 곽세욱 on 04/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoContainer.h"
#import "SocialBase.h"
#import "Common.h"

@implementation PhotoItem
- (void) clear {
	_thumbnail = nil;
	_key = @"";
	_positionType = -1;
}

- (void)setPhoto:(Photo *)photo filename:(NSString *)filename creationDate:(NSString *)creationDate {
	
}

- (void)setPhoto:(int)positionType mainURL:(NSString *)mainURL thumbURL:(NSString *)thumbURL key:(NSString *)key filename:(NSString *)filename creationDate:(NSString *)creationDate {
	
}

- (BOOL)isPrintable {
	return NO;
}

- (UIImage *) getThumbnail{
	return nil;
}

- (UIImage *) getOriginal {
	return nil;
}

- (void) getThumbnailAsync:(void (^)(BOOL succeeded, UIImage *image))completionBlock {
	completionBlock(NO, nil);
}

- (BOOL)download:(NSString *)localpathname{
	return NO;
}

- (void)downloadToMemory {
	
}

- (NSString *)getCreationDate:(NSString *)format {
	NSDateFormatter *parseFormat = [[NSDateFormatter alloc] init];
	[parseFormat setDateFormat:@"yyyyMMdd"];
	
	NSDate* creationDate = [parseFormat dateFromString:self.creationDate];
	
	NSDateFormatter *toFormat = [[NSDateFormatter alloc] init];
	[toFormat setDateFormat:format];
	return [toFormat stringFromDate:creationDate];
}

- (UIImageOrientation)getOrientation {
	return UIImageOrientationUp;
}

- (CGSize) getPixelSize {
	return CGSizeZero;
}

- (CGSize) getDimension {
	return CGSizeZero;
}
@end

@implementation LocalItem

- (void) clear {
	[super clear];
	if (_photo != nil) {
		[_photo clear];
	}
	
	self.thumbnail = nil;
}

- (void) setPhoto:(Photo *)photo filename:(NSString *)filename creationDate:(NSString *)creationDate {
	if (photo != nil ) {
		_photo = photo;
		_checked = NO;
		_printable = TRUE;
		
		self.creationDate = creationDate;
		self.filename = filename;
		self.positionType = PHOTO_POSITION_LOCAL;
		self.key = [_photo.asset localIdentifier];
	}
}


- (void)setPhoto:(int)positionType mainURL:(NSString *)mainURL thumbURL:(NSString *)thumbURL key:(NSString *)key filename:(NSString *)filename creationDate:(NSString *)creationDate{
	// 아무것도 안함. SNS를 위한것
}

- (BOOL)isPrintable {
	if (_checked)
		return _printable;
	
	_checked = YES;
	_printable = FALSE;
	
	if(_photo == nil || _photo.asset == nil)
		return FALSE;
	
	PHAsset *asset = _photo.asset;
	if(asset.mediaType != PHAssetMediaTypeImage)
		return FALSE;
	
	//if(asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) return FALSE;
	if(asset.mediaSubtypes == PHAssetMediaSubtypeVideoTimelapse)
		return FALSE;
	
	_printable = TRUE;
	
	if(![[PHAssetUtility info] isHEIF:asset]) {
		int width = [[PHAssetUtility info] getPixelWidth:asset];
		int height = [[PHAssetUtility info] getPixelHeight:asset];
		NSURL* url = [[PHAssetUtility info] getUrl:asset];
		long size = [[PHAssetUtility info] getFastFileSize:asset];
		
		NSLog(@"width : %d / height : %d / size : %ld", width, height, size);
		
		// TODO : 테스트 필요
		if ([Common info].photobook.product_type == PRODUCT_BABY) {
			if (MAX(width, height) >= 1000 && MIN(width, height) >= 1000 && size <= 10000000) {
				
				NSString *filename = url.absoluteString;
				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		else if ([Common info].photobook.product_type == PRODUCT_CARD) {
			if (MAX(width, height) >= 740 && MIN(width, height) >= 740 && size <= 10000000) {
				
				NSString *filename = url.absoluteString;
				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		// 마그넷 : 400px 이상되는 사진만 처리하도록 수정
		else if ([Common info].photobook.product_type == PRODUCT_MAGNET) {
			if (MAX(width, height) >= 400 && MIN(width, height) >= 400 && size <= 10000000) {
				
				NSString *filename = url.absoluteString;
				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		else if ([Common info].photobook.product_type == PRODUCT_MONTHLYBABY
				 || [Common info].photobook.product_type == PRODUCT_PHOTOPRINT
				 ) {
			if (MAX(width, height) >= 640 && MIN(width, height) >= 480 && size <= 10000000) {
				return TRUE;
			}
		}
		else if ([Common info].photobook.product_type == PRODUCT_IDPHOTO) {
			return TRUE;
		}
		else {
			if (MAX(width, height) >= 640 && MIN(width, height) >= 480 && size <= 10000000) {
				
				NSString *filename = url.absoluteString;
				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		_printable = FALSE;
		return FALSE;
	}
	else {
		if(asset == nil)
		{
			_printable = FALSE;
			return FALSE;
		}
		
		// iOS 11 에서 사진 선택 썸네일 이미지 리스트 로딩이 굉장히 느리고 크래시나는 문제 수정
		int width = [[PHAssetUtility info] getPixelWidth:asset];
		int height = [[PHAssetUtility info] getPixelHeight:asset];
		
		NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
		NSString *filename = ((PHAssetResource*)resources[0]).originalFilename;
		// Failed to load image data for asset PHAsset with format 9998 관련하
		// 여 해당 에러가 나오기까지 딜레이가 심해서 바로 fileSize 키를 읽어옴
		//long size = [[PHAssetUtility info] getFileSize:asset];
		long size = [[PHAssetUtility info] getFastFileSize:asset];
		
		NSLog(@"width : %d / height : %d / size : %ld", width, height, size);
		
		// TODO : 테스트 필요
		if ([Common info].photobook.product_type == PRODUCT_BABY) {
			if (MAX(width, height) >= 1000 && MIN(width, height) >= 1000 && size <= 10000000) {
				
				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		else if ([Common info].photobook.product_type == PRODUCT_CARD) {
			if (MAX(width, height) >= 740 && MIN(width, height) >= 740 && size <= 10000000) {
				
				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		else if ([Common info].photobook.product_type == PRODUCT_MONTHLYBABY
				 || [Common info].photobook.product_type == PRODUCT_PHOTOPRINT) {
			if (MAX(width, height) >= 640 && MIN(width, height) >= 480 && size <= 10000000) {
				return TRUE;
			}
		}
		else if ([Common info].photobook.product_type == PRODUCT_IDPHOTO) {
			return TRUE;
		}
		else {
			if (MAX(width, height) >= 640 && MIN(width, height) >= 480 && size <= 10000000) {
				NSRange range = [filename rangeOfString:@".jpg" options:NSCaseInsensitiveSearch];
				if (range.location != NSNotFound) {
					return TRUE;
				}
			}
		}
		_printable = FALSE;
		return FALSE;
	}
}

- (UIImage *) getThumbnail{
	if (self.thumbnail){
		return  self.thumbnail;
	}
	
	self.thumbnail = [[PHAssetUtility info] getThumbnailUIImage:_photo.asset];
	
	return self.thumbnail;
}

- (UIImage *) getOriginal {
	return [UIImage imageWithData:[[PHAssetUtility info] getImageDataForAsset:_photo.asset]];
}

- (void) getThumbnailAsync:(void (^)(BOOL succeeded, UIImage *image))completionBlock {
	if (self.thumbnail == nil){
		self.thumbnail = [[PHAssetUtility info] getThumbnailUIImage:_photo.asset];
	}
	completionBlock(YES, self.thumbnail);
}

- (BOOL)download:(NSString *)localpathname{
	return YES;
}

- (void)downloadToMemory {
	// 아무짓도 안함
}

- (UIImageOrientation)getOrientation {
	return [[PHAssetUtility info] getOrientation:_photo.asset];
}

- (CGSize) getPixelSize {
	return CGSizeMake([[PHAssetUtility info] getPixelWidth:_photo.asset], [[PHAssetUtility info] getPixelHeight:_photo.asset]);
}

- (CGSize) getDimension {
	return [[Common info] getDimensions:_photo.asset];
}
@end

@implementation SocialItem
- (void)clear {
	
}

- (void)setPhoto:(Photo *)photo filename:(NSString *)filename creationDate:(NSString *)creationDate{
		// 아무 것도 안함. 로컬을 위한 것.
}

- (void)setPhoto:(int)positionType mainURL:(NSString *)mainURL thumbURL:(NSString *)thumbURL key:(NSString *)key filename:(NSString *)filename creationDate:(NSString *)creationDate {
	_mainURL = mainURL;
	_thumbURL = thumbURL;
	
	self.creationDate = creationDate;
	self.filename = filename;
	self.positionType = positionType;
	self.key = key;
}

- (BOOL)isPrintable {
	return TRUE;
}

- (UIImage *) getThumbnail{
	
	if (self.thumbnail){
		return self.thumbnail;
	}
	
	UIImage *thumb_img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_thumbURL]]];
	if (thumb_img != nil) {
		self.thumbnail = thumb_img;
	}
	
	return self.thumbnail;
}

- (UIImage *) getOriginal {
	if (self.original == nil) {
		[self downloadToMemory];
	}
	return self.original;
}

- (void) getThumbnailAsync:(void (^)(BOOL succeeded, UIImage *image))completionBlock {
	if (self.thumbnail){
		completionBlock(YES, self.thumbnail);
	}
	else {
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_thumbURL]];
		[NSURLConnection sendAsynchronousRequest:request
										   queue:[NSOperationQueue mainQueue]
							   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
								   if (!error) {
									   UIImage *thumb_img = [UIImage imageWithData:data];
									   self.thumbnail = thumb_img;
									   completionBlock(YES, thumb_img);
								   } else {
									   NSLog(@"** download error: %@", error);
									   completionBlock(NO, nil);
								   }
							   }];
	}
}

- (BOOL)download:(NSString *)localpathname {
	NSURL *url = [NSURL URLWithString:_mainURL];
	if ([[Common info] downloadImage:url ToFile:localpathname]) {
//		_image_path = localpathname;
		//NSLog(@"%@ downloaded..", localpathname);
		return YES;
	}
	return NO;
}

- (void)downloadToMemory {
	NSData *org_data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_mainURL]];
	self.original = [UIImage imageWithData:org_data];
}

- (UIImageOrientation)getOrientation {
	return UIImageOrientationUp;
}

- (CGSize) getPixelSize {
	return [self.original size];
}

- (CGSize) getDimension {
	return [self.original size];
}
@end

@implementation GroupingData : NSObject
- (void) initialize:(NSString *)creationDate positionType:(int)positionType {
	_creationDate = creationDate;
	_positionType = positionType;
	_photos = [[NSMutableArray alloc] init];
}

- (void) addPhoto:(PhotoItem *)item {
	[_photos addObject:item];
}

- (PhotoItem *) getPhoto:(int)index {
	if (index < _photos.count) {
		return _photos[index];
	}
	
	return nil;
}

- (NSUInteger) totalCount {
	return [_photos count];
}

- (NSUInteger) selectedCount {
	int selectedCnt = 0;
	
	for (int i = 0; i < _photos.count; i++) {
		PhotoItem *item = _photos[i];
		if ([[PhotoContainer inst] isSelected:_positionType key:item.key]) {
			selectedCnt++;
		}
	}
	
	return selectedCnt;
}

- (void) selectAll {
	for (PhotoItem *item in _photos) {
		if (! [[PhotoContainer inst] isSelected:_positionType key:item.key]) {
			[[PhotoContainer inst] add:item];
		}
	}
}

- (void) deSelectAll {
	for (PhotoItem *item in _photos) {
		if ([[PhotoContainer inst] isSelected:_positionType key:item.key]) {
			[[PhotoContainer inst] remove:_positionType key:item.key];
		}
	}
}

@end

@implementation PhotoContainer
// thread safe singleton
+ (PhotoContainer *)inst {
	static dispatch_once_t pred;
	static PhotoContainer *pool = nil;
	dispatch_once(&pred, ^{
		pool = [[PhotoContainer alloc] init];
		
		pool.selectPhotos = [[NSMutableArray alloc] init];
		pool.photos = [[NSMutableDictionary alloc] init];
		
		[pool.photos setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:PHOTO_POSITION_LOCAL]];
		[pool.photos setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:PHOTO_POSITION_INSTAGRAM]];
		[pool.photos setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:PHOTO_POSITION_FACEBOOK]];
		[pool.photos setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:PHOTO_POSITION_GOOGLEPHOTO]];
		[pool.photos setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:PHOTO_POSITION_KAKAOSTORY]];
		[pool.photos setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:PHOTO_POSITION_SMARTBOX]];
		
		pool.groups = [[NSMutableDictionary alloc] init];
		
		[pool.groups setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:PHOTO_POSITION_LOCAL]];
		[pool.groups setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:PHOTO_POSITION_INSTAGRAM]];
		[pool.groups setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:PHOTO_POSITION_FACEBOOK]];
		[pool.groups setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:PHOTO_POSITION_GOOGLEPHOTO]];
		[pool.groups setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:PHOTO_POSITION_KAKAOSTORY]];
		[pool.groups setObject:[[NSMutableArray alloc] init] forKey:[NSNumber numberWithInt:PHOTO_POSITION_SMARTBOX]];
	});
	return pool;
}

- (void) initialize {
	[self clearAllCache];
	[self removeAll];
}

#pragma mark - Cache
- (int) getCachedIndex:(int)positionType key:(NSString *)key {
	
	NSNumber *position = [NSNumber numberWithInt:positionType];
	
	NSMutableArray *cache = [_photos objectForKey:position];
	if (cache != nil) {
		for (int i = 0; i < cache.count; i++) {
			PhotoItem *item = cache[i];
			if (item.positionType == positionType && [item.key isEqual:key]) {
				return i;
			}
		}
	}
	
	return -1;
}

- (BOOL)isCached:(PHAsset *)asset {
	
	int index = [self getCachedIndex:PHOTO_POSITION_LOCAL key:[asset localIdentifier]];
	
	return index >= 0;
}

- (void)cache:(PHAsset *)asset filename:(NSString *)filename creationDate:(NSString *)creationDate {
	Photo *photo= [[Photo alloc] init];
	photo.asset = asset;
	
	LocalItem *item = [[LocalItem alloc] init];
	[item setPhoto:photo filename:filename creationDate:creationDate];
	
	NSNumber *position = [NSNumber numberWithInt:PHOTO_POSITION_LOCAL];
	
	NSMutableArray *cache = [_photos objectForKey:position];
	if (cache != nil) {
		[cache addObject:item];
		
		NSMutableArray *groupArray = [_groups objectForKey:position];
		
		GroupingData *gd = nil;
		
		for (int i = 0; i < groupArray.count; i++) {
			GroupingData *tgd = [groupArray objectAtIndex:i];
			if ([tgd.creationDate isEqualToString:creationDate]) {
				gd = tgd;
			}
		}
		
		if (gd == nil) {
			gd = [[GroupingData alloc] init];
			[gd initialize:creationDate positionType:PHOTO_POSITION_LOCAL];
			[groupArray addObject:gd];
		}
		
		[gd addPhoto:item];
	}
}

- (void)cache:(int)positionType mainURL:(NSString *)mainURL thumbURL:(NSString *)thumbURL key:(NSString *)key filename:(NSString *)filename creationDate:(NSString *)creationDate {
	
	SocialItem *socialItem = [[SocialItem alloc] init];
	[socialItem setPhoto:positionType mainURL:mainURL thumbURL:thumbURL key:key filename:filename creationDate:creationDate];
	
	NSNumber *position = [NSNumber numberWithInt:positionType];
	
	NSMutableArray *cache = [_photos objectForKey:position];
	if (cache != nil) {
		[cache addObject:socialItem];
		
		NSMutableArray *groupArray = [_groups objectForKey:position];
		
		GroupingData *gd = nil;
		
		for (int i = 0; i < groupArray.count; i++) {
			GroupingData *tgd = [groupArray objectAtIndex:i];
			if ([tgd.creationDate isEqualToString:creationDate]) {
				gd = tgd;
			}
		}
		
		if (gd == nil) {
			gd = [[GroupingData alloc] init];
			[gd initialize:creationDate positionType:positionType];
			[groupArray addObject:gd];
		}
		
		[gd addPhoto:socialItem];
	}
}

- (void)clearCache:(int)positionType {
	NSNumber *position = [NSNumber numberWithInt:positionType];
	NSMutableArray *cache = [_photos objectForKey:position];
	if (cache != nil) {
		[cache removeAllObjects];
		[[SocialManager inst] initialize:positionType];
	}
	
	NSMutableArray *groupArray = [_groups objectForKey:position];
	
	if (groupArray != nil) {
		[groupArray removeAllObjects];
	}
}

- (void)clearAllCache {
	for (NSMutableArray *cache in [_photos allValues]) {
		[cache removeAllObjects];
	}
	
	for (NSMutableArray *groupArray in [_groups allValues]) {
		[groupArray removeAllObjects];
	}
	[[SocialManager inst] initializeAll];
}

- (PhotoItem *) getCachedItem:(int)positionType index:(int)index {
	NSNumber *position = [NSNumber numberWithInt:positionType];
	NSMutableArray *cache = [_photos objectForKey:position];
	if (cache != nil) {
		if (index < cache.count) {
			return [cache objectAtIndex:index];
		}
	}
	return nil;
}

- (NSUInteger)cachedCount:(int)positionType {
	NSNumber *position = [NSNumber numberWithInt:positionType];
	NSMutableArray *cache = [_photos objectForKey:position];
	if (cache != nil) {
		return [cache count];
	}
	return 0;
}

#pragma mark - Group
- (NSUInteger)groupCount:(int)positionType {
	NSNumber *position = [NSNumber numberWithInt:positionType];
	NSMutableArray *groupArray = [_groups objectForKey:position];
	if (groupArray != nil) {
		return [groupArray count];
	}
	return 0;
}

- (NSUInteger)groupTotalCount:(int)positionType groupIndex:(int)groupIndex {
	NSNumber *position = [NSNumber numberWithInt:positionType];
	NSMutableArray *groupArray = [_groups objectForKey:position];
	if (groupArray != nil) {
		if (groupIndex < groupArray.count) {
			GroupingData *gd = groupArray[groupIndex];
			return [gd totalCount];
		}
	}
	return 0;
}

- (GroupingData *)getGroupingData:(int)positionType groupIndex:(int)groupIndex{
	NSNumber *position = [NSNumber numberWithInt:positionType];
	NSMutableArray *groupArray = [_groups objectForKey:position];
	if (groupArray != nil) {
		if (groupIndex < groupArray.count) {
			GroupingData *gd = groupArray[groupIndex];
			return gd;
		}
	}
	return nil;
}

- (PhotoItem *)getCachedItem:(int)positionType groupIndex:(int)groupIndex index:(int)index {
	NSNumber *position = [NSNumber numberWithInt:positionType];
	NSMutableArray *groupArray = [_groups objectForKey:position];
	if (groupArray != nil) {
		if (groupIndex < groupArray.count) {
			GroupingData *gd = groupArray[groupIndex];
			
			return [gd getPhoto:index];
		}
	}
	return nil;
}

#pragma mark - Select
- (void)add:(PhotoItem *)item {
	[_selectPhotos addObject:item];
}

- (PhotoItem *)getSelectedItem:(int)index {
	if (index < _selectPhotos.count) {
		return [_selectPhotos objectAtIndex:index];
	}
	return nil;
}

- (int) getItemIndex:(int)positionType key:(NSString *)key {
	for (int i = 0; i < _selectPhotos.count; i++) {
		PhotoItem *item = _selectPhotos[i];
		if (item.positionType == positionType && [item.key isEqual:key]) {
			return i;
		}
	}
	return -1;
}

- (void) removeAtIndex:(int)index {
	if (index < _selectPhotos.count) {
		[_selectPhotos removeObjectAtIndex:index];
	}
}

- (void) remove:(int)positionType key:(NSString *)key {
	int removeIdx = [self getItemIndex:positionType key:key];
	
	if (removeIdx >= 0)
		[_selectPhotos removeObjectAtIndex:removeIdx];
}

- (void)removeAll {
	[_selectPhotos removeAllObjects];
}

- (BOOL)isSelected:(int)positionType key:(NSString *)key {
	int index = [self getItemIndex:positionType key:key];
	
	return index >= 0;
}

- (NSUInteger)selectCount {
	return _selectPhotos.count;
}

@end
