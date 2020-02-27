//
//  SearchIDViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 6..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SearchIDViewController : BaseViewController

@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *emailAddress;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@end
