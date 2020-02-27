//
//  BabyProductViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 4..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BabyProductViewController : UIViewController

@property (assign) int product_type;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

- (IBAction)popupMore:(id)sender;
- (IBAction)cancel:(id)sender;

@end
