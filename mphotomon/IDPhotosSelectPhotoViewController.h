//
//  IDPhotosSelectPhotoViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 3..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface IDPhotosSelectPhotoViewController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (nonatomic, strong) PHAssetCollection *assetGroup;
@property (nonatomic, strong) NSMutableArray *photos;

- (IBAction)cancel:(id)sender;

@end
