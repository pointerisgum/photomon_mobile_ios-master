//
//  PhotobookDesignViewController.h
//
//
//  Created by photoMac on 2015. 9. 16..
//
//

#import <UIKit/UIKit.h>

@interface PhotobookDesignViewController : UIViewController

@property (assign) int product_type;
@property (assign) int sel_navibutton;
@property NSCache *thumbCache;

// 포토북 & 인스타북 & 손글씨포토북
@property (assign) int photobook_type; // 0:포토북, 1:인스타북, 2:손글씨포토북
@property (strong, nonatomic) IBOutlet NSString* product_code;
@property (strong, nonatomic) NSString* product_id;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_navi;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *naviHeight;

@property (strong, nonatomic) NSMutableArray *photobook_themes;

@property (assign, nonatomic) BOOL hideTapBar;

// 메소드
- (void)goStorage;
- (IBAction)onPhotobook:(id)sender;
- (IBAction)onInstabook:(id)sender;
- (IBAction)onAnalogBook:(id)sender;
- (IBAction)onSkinnyBook:(id)sender;
- (IBAction)onCatalogBook:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)popupMore:(id)sender;
- (int)getIdxOfProduct:(NSString *)productCode;

@end
