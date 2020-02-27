//
//  IDPhotosUpload.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 14..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@interface IDPhotosUpload : NSObject <NSXMLParserDelegate>

@property (assign) int checksum;
@property (strong, nonatomic) IDPhotos *idphotos;
@property (strong, nonatomic) UIImage *upload_image;
@property (strong, nonatomic) NSData *thumb_data;
@property (strong, nonatomic) NSString *upload_url;
@property (strong, nonatomic) NSString *check_url;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) NSString *orderno;

@property (strong, nonatomic) NSString *parsing_element;

- (BOOL)prepareUploadServer;
- (BOOL)uploadFile:(int)index UploadController:(id)upload_controller;
- (BOOL)addCart;

- (BOOL)initOrderNumber;
- (void)clear;
- (void)makeThumb:(int)index ToFile:(NSString *)file;

@end
