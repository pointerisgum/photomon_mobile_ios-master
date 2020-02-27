//
//  IDPhotosCameraPreviewViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 17..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@interface IDPhotosCameraPreviewViewController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (weak, nonatomic) IBOutlet UIImageView *left_arrow;
@property (weak, nonatomic) IBOutlet UIImageView *right_arrow;
@property (strong, nonatomic) NSArray *image_paths;
@property (strong, nonatomic) NSString *image_path;
@property (assign) int idx;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_btn_1_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_btn_2_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_btn_3_width;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_left_arrow_bottom_space;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_right_arrow_bottom_space;
@property (weak, nonatomic) IBOutlet UIButton *bottom_btn_1;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)list:(id)sender;

@end
