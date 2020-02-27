//
//  PhotoDetailViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDetailViewController : UIViewController

@property (assign) BOOL is_first;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) NSMutableArray *keyArray;

- (IBAction)click_delbutton:(id)sender;
@end
