//
//  InstagramViewController.h
//  PHOTOMON
//
//  Created by ios_dev on 2016. 3. 15..
//  Copyright © 2016년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPool.h"

@interface InstagramViewController : UIViewController

@property (assign) BOOL load_complete;

@property (assign) BOOL is_singlemode;
@property (assign) int  min_pictures;
@property (strong, nonatomic) NSString *param;
@property (strong, nonatomic) id<SelectPhotoDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *next_button;
@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

- (IBAction)more:(id)sender;
- (IBAction)deselectAll:(id)sender;
- (IBAction)selectAll:(id)sender;
- (IBAction)done:(id)sender;

@end
