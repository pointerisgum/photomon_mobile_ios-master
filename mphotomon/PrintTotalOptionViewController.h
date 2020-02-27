//
//  PrintTotalOptionViewController.h
//  mphotomon
//
//  Created by photoMac on 2015. 8. 19..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface PrintTotalOptionViewController : BaseViewController

@property (assign) BOOL is_includeLargeTypePrint;
@property (assign) int selected_row;
@property (assign) int image_h;

@property (strong, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) NSString *full_type;
@property (strong, nonatomic) NSString *border_type;
@property (strong, nonatomic) NSString *surface_type;
@property (strong, nonatomic) NSString *revise_type;
@property (strong, nonatomic) NSString *date_type;

- (UITableViewCell *)getSelectedCell:(id)sender;

- (IBAction)clickOption:(id)sender;
- (IBAction)clickDetail:(id)sender;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
