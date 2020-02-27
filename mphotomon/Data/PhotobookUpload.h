//
//  PhotobookUpload.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 14..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@interface PhotobookUploadItem : NSObject

@property (assign) int type;
@property (strong, nonatomic) NSString *pageno;
@property (strong, nonatomic) NSString *uploadfilename;
@property (strong, nonatomic) NSString *localpathname;

@end

@interface PhotobookUpload : NSObject

@property (assign) int checksum;
@property (strong, nonatomic) Photobook *photobook;
@property (strong, nonatomic) NSString *upload_url;
@property (strong, nonatomic) NSString *check_url;
@property (strong, nonatomic) NSMutableArray *items;

- (BOOL)prepareUploadServer;
//- (int)getUploadItemCount;
- (BOOL)prepareItemsFrame:(NSMutableArray *)filearray;
- (BOOL)prepareItems;
- (void)addItem:(int)type UploadName:(NSString *)uploadname LocalName:(NSString *)localname PageNo:(int)pageno;

- (BOOL)uploadFile:(int)index UploadController:(id)upload_controller;
- (BOOL)checkUploadResult;
- (BOOL)addCart;

- (void)clear;

@end
