//
//  GoodsPosterDesignViewController.h
//  PHOTOMON
//
//  Created by 안영건 on 06/05/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoodsPosterDesignViewController : UIViewController

@property (assign) int product_type;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

- (IBAction)popupMore:(id)sender;
- (void)goStorage;

@end

NS_ASSUME_NONNULL_END
