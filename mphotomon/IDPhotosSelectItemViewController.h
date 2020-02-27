//
//  IDPhotosSelectItemViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 17..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface IDPhotosSelectItemViewController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (weak, nonatomic) IBOutlet UIImageView *left_arrow;
@property (weak, nonatomic) IBOutlet UIImageView *right_arrow;
@property (strong, nonatomic) NSMutableArray *photos;
@property (assign) int idx;
@property (assign) int photoPosition;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_left_arrow_bottom_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_right_arrow_bottom_space;

@end
