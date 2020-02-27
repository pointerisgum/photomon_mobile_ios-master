//
//  CardDesignViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 10..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardDesignViewController : UIViewController

@property (strong, nonatomic) NSString* product_code;
@property (strong, nonatomic) NSString* product_id;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

- (void)goStorage;
- (IBAction)cancel:(id)sender;
- (void)loadCardTheme;
- (IBAction)popupMore:(id)sender;

@end
