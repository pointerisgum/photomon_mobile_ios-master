//
//  PhotobookTypeViewController.h
//
//
//  Created by photoMac on 2015. 9. 16..
//
//

#import <UIKit/UIKit.h>

@interface PhotobookTypeViewController : UIViewController

@property (assign) int product_type;
@property (strong, nonatomic) NSString* product_code;

// 포토북 & 인스타북 & 손글씨포토북
@property (assign) int photobook_type; // 0:포토북, 1:인스타북, 2:손글씨포토북, 3:프리미엄북
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonbar_constraint;
@property (strong, nonatomic) IBOutlet UIView *bookbar;
@property (strong, nonatomic) IBOutlet UIButton *photobook_button;
@property (strong, nonatomic) IBOutlet UIButton *instabook_button;
@property (strong, nonatomic) IBOutlet UIButton *analogbook_button;

//
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

// 메소드
- (void)goStorage;
/*
- (IBAction)onPhotobook:(id)sender;
- (IBAction)onInstabook:(id)sender;
- (IBAction)onAnalogBook:(id)sender;
*/
- (IBAction)cancel:(id)sender;
- (IBAction)popupMore:(id)sender;

@end
