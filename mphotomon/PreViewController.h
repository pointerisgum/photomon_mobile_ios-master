//
//  PreViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 7. 16..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreViewController : UIViewController

@property (assign) int type;
@property (strong, nonatomic) NSString *param;

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;
@property (strong, nonatomic) IBOutlet UILabel *print_prop;
@property (strong, nonatomic) IBOutlet UILabel *print_size;
@property (strong, nonatomic) IBOutlet UILabel *print_filename;

- (IBAction)done:(id)sender;
@end
