//
//  GoodsProductViewController.h
//  PHOTOMON
//
//  Created by 안영건 on 29/04/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoodsProduct : NSObject
@property (strong, nonatomic) NSString *idx;
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSString *thumb;
@property (strong, nonatomic) NSString *productname;
@property (strong, nonatomic) NSString *productcode; // SJYANG : 기프트에서 productcode property 추가
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *discount;
@property (strong, nonatomic) NSString *openurl;
@property (strong, nonatomic) NSString *webviewurl;
@end

@interface GoodsProductViewController : UIViewController <NSXMLParserDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) NSMutableArray *goods_products;

- (IBAction)cancel:(id)sender;
- (IBAction)popupMore:(id)sender;
- (void)goStorage;

@end

NS_ASSUME_NONNULL_END
