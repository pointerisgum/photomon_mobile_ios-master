//
//  IDPhotosProductListViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDPhotosProductListViewController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (weak, nonatomic) IBOutlet UILabel *lb_guide;

- (IBAction)cancel:(id)sender;

@end
