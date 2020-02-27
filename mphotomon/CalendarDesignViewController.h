//
//  CalendarDesignViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 10..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarDesignViewController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *collection_view;

- (void)goStorage;
- (IBAction)cancel:(id)sender;

@end
