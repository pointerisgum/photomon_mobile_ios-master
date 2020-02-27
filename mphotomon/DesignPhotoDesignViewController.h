//
//  DesignPhotoDesignViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 4. 18..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DesignPhotoDesignViewController : UIViewController

@property (assign) int product_type;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

- (IBAction)popupMore:(id)sender;

@end
