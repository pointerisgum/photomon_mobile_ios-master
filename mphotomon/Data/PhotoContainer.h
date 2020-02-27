//
//  PhotoContainer.h
//  PHOTOMON
//
//  Created by 곽세욱 on 04/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "PhotoPool.h"
#import "PHAssetUtility.h"

@interface PhotoItem : NSObject
@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) NSString *creationDate;
@property (strong, nonatomic) UIImage *thumbnail;
@property (strong, nonatomic) UIImage *original;
@property (strong, nonatomic) NSString *key;
@property (assign) int positionType;

- (void)clear;
- (void)setPhoto:(Photo *)photo filename:(NSString *)filename creationDate:(NSString *)creationDate;
- (void)setPhoto:(int)positionType mainURL:(NSString *)mainURL thumbURL:(NSString *)thumbURL key:(NSString *)key filename:(NSString *)filename creationDate:(NSString *)creationDate;
- (BOOL)isPrintable;
- (UIImage *) getThumbnail;
- (UIImage *) getOriginal;
- (void) getThumbnailAsync:(void (^)(BOOL succeeded, UIImage *image))completionBlock;
- (BOOL)download:(NSString *)localpathname;
- (void)downloadToMemory;
- (NSString *)getCreationDate:(NSString *)format;
- (UIImageOrientation)getOrientation;
- (CGSize) getPixelSize;
- (CGSize) getDimension;
@end

@interface SocialItem : PhotoItem
@property (strong, nonatomic) NSString *thumbURL;
@property (strong, nonatomic) NSString *mainURL;
@end

@interface LocalItem : PhotoItem
@property (strong, nonatomic) Photo *photo;
@property (assign) BOOL printable; // 출력가능여부
@property (assign) BOOL checked;
@end

@interface GroupingData : NSObject
@property (strong, nonatomic) NSString *creationDate;
@property (strong, nonatomic) NSMutableArray *photos;
@property (assign) int positionType;

- (void) initialize:(NSString *)creationDate positionType:(int)positionType;
- (void) addPhoto:(PhotoItem *)item;
- (void) selectAll;
- (void) deSelectAll;

- (PhotoItem *) getPhoto:(int)index;
- (NSUInteger) totalCount;
- (NSUInteger) selectedCount;
@end

@interface PhotoContainer : NSObject

@property (strong, nonatomic) NSMutableArray *selectPhotos;
@property (strong, nonatomic) NSMutableDictionary *photos;
@property (strong, nonatomic) NSMutableDictionary *groups;

+ (PhotoContainer *)inst;

- (void) initialize;

#pragma mark - Cache
- (BOOL)isCached:(PHAsset *)asset;
- (void)cache:(PHAsset *)asset filename:(NSString *)filename creationDate:(NSString *)creationDate;
- (void)cache:(int)positionType mainURL:(NSString *)mainURL thumbURL:(NSString *)thumbURL key:(NSString *)key filename:(NSString *)filename creationDate:(NSString *)creationDate;

- (void)clearCache:(int)positionType;
- (void)clearAllCache;
- (int) getCachedIndex:(int)positionType key:(NSString *)key;
- (NSUInteger)cachedCount:(int)positionType;
- (PhotoItem *) getCachedItem:(int)positionType index:(int)index;

#pragma mark - Group
- (NSUInteger)groupCount:(int)positionType;
- (NSUInteger)groupTotalCount:(int)positionType groupIndex:(int)groupIndex;
- (GroupingData *)getGroupingData:(int)positionType groupIndex:(int)groupIndex;
- (PhotoItem *)getCachedItem:(int)positionType groupIndex:(int)groupIndex index:(int)index;

#pragma mark - Select
- (void)add:(PhotoItem *)item;
- (PhotoItem *)getSelectedItem:(int)index;
- (void) removeAtIndex:(int)index;
- (void) remove:(int)positionType key:(NSString *)key;
- (void)removeAll;
- (BOOL)isSelected:(int)positionType key:(NSString *)key;

- (NSUInteger)selectCount;

//- (BOOL)isSelectedThumb:(InstaPhoto *)selected;
//- (void)add:(InstaPhoto *)selected;
//- (void)remove:(InstaPhoto *)selected;
//- (void)selectAll;
//- (void)removeAll;
//- (int)selectedCount;
//- (int)totalCount;

@end
