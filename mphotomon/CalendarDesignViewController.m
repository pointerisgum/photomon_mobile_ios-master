//
//  CalendarDesignViewController.m
//  PHOTOMON
//
//  Created by photoMac on 2015. 11. 10..
//  Copyright © 2015년 maybeone. All rights reserved.
//

#import "CalendarDesignViewController.h"
#import "CalendarDetailViewController.h"
#import "Common.h"

@interface CalendarDesignViewController ()

@end

@implementation CalendarDesignViewController

static NSString * const reuseIdentifier = @"CalendarDesignCell";

- (void)viewDidLoad {
    [super viewDidLoad];

	// 딥링크 관련 코드 ----------------------------------
	[[NSNotificationCenter defaultCenter] addObserverForName:@"deeplink-dismiss-notification" 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
		[self dismissViewControllerAnimated:NO completion:nil];
    }];
    if([Common info].deeplink_url != nil) {
        if ( [[Common info].deeplink_url rangeOfString:@"mobile_calendar"].location != NSNotFound ) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [Common info].deeplink_url= nil;
		}
    }
	// 딥링크 관련 코드 ----------------------------------

    [Common info].calendar_root_controller = self;
    [[Common info].photobook_theme loadTheme:PRODUCT_CALENDAR];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goStorage {
    [self.navigationController popToViewController:self animated:NO];
    [self performSegueWithIdentifier:@"CalendarStorageSegue" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CalendarDetailSegue"]) {
        CalendarDetailViewController *vc = [segue destinationViewController];
        if (vc) {
            NSIndexPath *indexPath = [[_collection_view indexPathsForSelectedItems] lastObject];
            vc.selected_theme = [Common info].photobook_theme.themes[indexPath.row];
            [vc updateTheme];
        }
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [Common info].photobook_theme.themes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.layer.borderColor = [UIColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:0.5f].CGColor;
    cell.layer.borderWidth = 1.0f;

	NSLog(@"fullpath : here #1");
    
    Theme *theme = [Common info].photobook_theme.themes[indexPath.row];
    if (theme) {

		// 달력 썸네일 fullurl
        NSString *fullpath = @"";
		if([theme.main_thumb containsString:@"://"])                              
			fullpath = theme.main_thumb;
		else
			fullpath = [NSString stringWithFormat:@"%@%@", [Common info].photobook_theme.thumb_url, theme.main_thumb];

        NSString *url = [fullpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[Common info] downloadAsyncWithURL:[NSURL URLWithString:url] completionBlock:^(BOOL succeeded, NSData *imageData) {
            if (succeeded) {
                UIImageView *imageview = (UIImageView *)[cell viewWithTag:100];
                imageview.image = [UIImage imageWithData:imageData];
            }
            else {
                NSLog(@"theme's thumbnail_image is not downloaded.");
            }
        }];
        
        NSString *price = [[Common info] toCurrencyString:[theme.price intValue]];
        NSString *discount = [[Common info] toCurrencyString:[theme.discount intValue]];
        
        UILabel *label1 = (UILabel *)[cell viewWithTag:102];
        label1.text = theme.theme_name;
        UILabel *label2 = (UILabel *)[cell viewWithTag:103];
        label2.text = [NSString stringWithFormat:@"%@원", price];
        UILabel *label3 = (UILabel *)[cell viewWithTag:104];
        label3.text = [NSString stringWithFormat:@"%@원", discount];
        
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat spacing = 10.0;
    CGFloat width = _collection_view.bounds.size.width - spacing*2;
    CGFloat height = width / 1.4f; // 1.4 : 1 = width : height -> height = width*1 / 1.4
    
    return CGSizeMake(width, height + 40);
}

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
