//
//  GiftMagnetDesignViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 18..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiftMagnetDesignViewController : UIViewController

@property (assign) BOOL autoselect_mode;
@property (assign) int autoselect_idx;
@property (assign) BOOL autoselect_done;
@property (assign) BOOL theme_loaded;

@property (assign) int product_type;
@property (strong, nonatomic) NSString* product_code;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
- (IBAction)popupMore:(id)sender;

@end
