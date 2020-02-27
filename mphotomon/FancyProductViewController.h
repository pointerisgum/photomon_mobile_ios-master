//
//  FancyProductViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2018. 1. 30..
//  Copyright © 2018년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FancyProduct : NSObject
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

@interface FancyProductViewController : UIViewController <NSXMLParserDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) NSMutableArray *fancy_products;

- (void)goStorage;
- (IBAction)cancel:(id)sender;
- (IBAction)popupMore:(id)sender;

@end
