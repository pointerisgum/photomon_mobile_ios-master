//
//  IDPhotosPreviewViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface IDPhotosPreviewViewController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (nonatomic, strong) UIImage* image;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_collection_view_height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraints_bottom_btn_1_width;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
