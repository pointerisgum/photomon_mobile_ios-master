//
//  IDPhotosCameraImageListViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDPhotosCameraImageListViewController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) NSArray *image_paths;

- (IBAction)cancel:(id)sender;

@end
