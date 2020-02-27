//
//  SelectAlbumViewController.h
//  PHOTOMON
//
//  Created by photoMac on 2015. 12. 1..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPool.h"
#import "oAuthViewController.h"

@interface SelectAlbumViewController : UIViewController <oAuthDelegate>

@property (assign) BOOL is_first;       // 가이드 한번만 보이도록
@property (assign) BOOL is_singlemode;  // 한장 선택, 다중 선택
@property (assign) int  min_pictures;   //
@property (strong, nonatomic) NSString *param; // 사진인화일 경우 크기 정보 포함. 그밖에는 @""

@property (strong, nonatomic) id<SelectPhotoDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *group_array;

@property (strong, nonatomic) IBOutlet UICollectionView *selthumb_view;
@property (strong, nonatomic) IBOutlet UITableView      *table_view;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selthumb_view_constraint_h;

- (IBAction)clickDelete:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)popupGuidePage:(NSString *)guide_id;
@end
