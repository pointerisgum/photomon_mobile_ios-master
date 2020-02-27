//
//  GiftMagnetProductViewController.h
//
//
//  Created by photoMac on 2015. 9. 16..
//
//

#import <UIKit/UIKit.h>

@interface GiftMagnetProduct : NSObject
@property (strong, nonatomic) NSString *idx;
@property (strong, nonatomic) NSString *pid;
@property (strong, nonatomic) NSString *thumb;
@property (strong, nonatomic) NSString *productname;
@property (strong, nonatomic) NSString *productcode;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *discount;
@property (strong, nonatomic) NSString *minprice;
@property (strong, nonatomic) NSString *discountminprice;
@property (strong, nonatomic) NSString *openurl;
@property (strong, nonatomic) NSString *webviewurl;
@end


@interface GiftMagnetProductViewController : UIViewController <NSXMLParserDelegate>

@property (assign) int product_type;
@property (strong, nonatomic) NSString* product_code;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) NSMutableArray *gift_products;

// TODO : 마그넷 : 삭제 필요
// 포토북 & 인스타북 & 손글씨포토북
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonbar_constraint;
@property (strong, nonatomic) IBOutlet UIView *bookbar;
@property (strong, nonatomic) IBOutlet UIButton *photobook_button;
@property (strong, nonatomic) IBOutlet UIButton *instabook_button;
@property (strong, nonatomic) IBOutlet UIButton *analogbook_button;


// 메소드
- (void)goStorage;
- (IBAction)cancel:(id)sender;
- (IBAction)popupMore:(id)sender;

@end
