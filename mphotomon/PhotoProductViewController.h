//
//  PhotoProductViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoProduct : NSObject
@property (strong, nonatomic) NSString *idx;
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSString *thumb;
@property (strong, nonatomic) NSString *productname;
@property (strong, nonatomic) NSString *productcode;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *discount;
@property (strong, nonatomic) NSString *openurl;
@property (strong, nonatomic) NSString *webviewurl;
@end


@interface PhotoProductViewController : UIViewController <NSXMLParserDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) NSMutableArray *photo_products;

- (void)goStorage;
- (IBAction)cancel:(id)sender;
- (IBAction)popupMore:(id)sender;
- (void)popupDetailPage:(NSString *)intnum;
- (int)getIdxOfProduct:(NSString *)productCode;

@end
