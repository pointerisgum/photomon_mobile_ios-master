//
//  ProductTableViewController.h
//  photoprint
//
//  Created by photoMac on 2015. 6. 25..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressView.h"

@interface ProductTableViewController : UITableViewController

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) ProgressView *progressView;

- (IBAction)cancel:(id)sender;

@end
