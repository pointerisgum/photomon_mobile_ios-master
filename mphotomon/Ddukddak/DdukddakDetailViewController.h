//
//  DdukddakDetailViewController.h
//  PHOTOMON
//
//  Created by 곽세욱 on 04/10/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ddukddak.h"
#import "Common.h"

NS_ASSUME_NONNULL_BEGIN

@interface DdukddakDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UICollectionView *thumbnailView;
@property (strong, nonatomic) IBOutlet UIPageControl *thumbnailPageControl;

@property (strong, nonatomic) Theme *selectedTheme;
@property (strong, nonatomic) BookInfo *bookInfo;

@property (assign) int selSizeIndex;
@property (assign) int selCoverIndex;
@property (assign) int selCoatingIndex;

- (IBAction)clickUpload:(id)sender;

@end

NS_ASSUME_NONNULL_END
