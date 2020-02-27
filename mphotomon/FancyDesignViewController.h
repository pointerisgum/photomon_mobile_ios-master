//
//  FancyDesignViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2018. 1. 30..
//  Copyright © 2018년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FancyDesignViewController : UIViewController

@property (assign) int product_type;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

- (IBAction)popupMore:(id)sender;

@end
