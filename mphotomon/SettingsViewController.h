//
//  SettingsViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 11..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "oAuthViewController.h"

@interface SettingsViewController : BaseViewController <oAuthDelegate>

@property (strong, nonatomic) NSThread *thread;
@property (strong, nonatomic) NSString *storage_calc;

@property (strong, nonatomic) IBOutlet UILabel *currentVersion;
@property (strong, nonatomic) IBOutlet UILabel *latestVersion;
@property (strong, nonatomic) IBOutlet UISwitch *guide_switch;
@property (strong, nonatomic) IBOutlet UISwitch *insta_switch;
@property (strong, nonatomic) IBOutlet UILabel *storageSize;

- (IBAction)deleteStorage:(id)sender;
- (IBAction)cancel:(id)sender;

@end
