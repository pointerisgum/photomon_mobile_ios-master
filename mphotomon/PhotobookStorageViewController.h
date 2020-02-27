//
//  PhotobookStorageViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 10. 7..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotobookStorageViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *book_array;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (assign, nonatomic) BOOL isFromMain;

- (IBAction)deletePhotobook:(id)sender;
- (IBAction)editPhotobook:(id)sender;
- (IBAction)orderPhotobook:(id)sender;

@end
