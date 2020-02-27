#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

@interface PHAssetUtility : NSObject

+ (PHAssetUtility *)info;
- (long)getFileSize:(PHAsset *)asset;
- (UIImageOrientation)getOrientation:(PHAsset *)asset;
- (int)getPixelWidth:(PHAsset *)asset;
- (int)getPixelHeight:(PHAsset *)asset;
- (NSURL*)getUrl:(PHAsset *)asset;
- (NSString *)getFileName:(PHAsset *)asset;
- (NSMutableArray*)getUserAlbums;
- (void)getThumbnailInfoForCollection:(PHAssetCollection*)collection withImageView:(UIImageView *)imageview withNameLabel:(UILabel *)namelabel withCountLabel:(UILabel *)countlabel;
- (void)getThumbnailInfoForAsset:(PHAsset*)asset withImageView:(UIImageView *)imageview;
- (UIImage *)getThumbnailUIImage:(PHAsset*)asset;
- (NSData *)getImageDataForAsset:(PHAsset*)asset;
- (NSData *)getFastJpegImageDataForAsset:(PHAsset*)asset;
- (NSData *)getFastExactJpegImageDataForAsset:(PHAsset*)asset;
- (NSData *)getJpegImageDataForAsset:(PHAsset*)asset;
- (long)getFastFileSize:(PHAsset *)asset;
- (BOOL)isHEIF:(PHAsset *)asset;

@end
