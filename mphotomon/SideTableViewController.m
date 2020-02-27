//
//  SideTableViewController.m
//  mphotomon
//
//  Created by photoMac on 2015. 7. 21..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "SideTableViewController.h"
#import "SWRevealViewController.h"
#import "InviteViewController.h"
#import "LoginViewController.h"
#import "PhotomonInfo.h"
#import "Common.h"
#import "WVCartViewController.h"

@interface SideTableViewController ()

@end

@implementation SideTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [self toggleState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleState {
    BOOL is_state_changed = FALSE;
    if ([Common info].user.mUserid.length < 1) {
        is_state_changed = _logoutButton.hidden ? FALSE : TRUE;
        
        _logoutButton.hidden = YES;
        _loginButton.hidden = NO;
        _signupButton.hidden = NO;
        
        _welcomeMsg.textAlignment = NSTextAlignmentLeft;
        _welcomeMsg.text = @"포토몬 회원만의 특별한 혜택을 만나세요.";
    }
    else {
        is_state_changed = _logoutButton.hidden ? TRUE : FALSE;
        
        _logoutButton.hidden = NO;
        _loginButton.hidden = YES;
        _signupButton.hidden = YES;
       
        _welcomeMsg.textAlignment = NSTextAlignmentCenter;
        _welcomeMsg.text = [NSString stringWithFormat:@"%@님 반갑습니다.", [Common info].user.mUserName];
    }
    
    if (is_state_changed) { // 로그인/아웃 상태가 변경되면 장바구니 정보를 다시 읽어온다.
		[Common info].login_status_changed = YES;

		[[PhotomonInfo sharedInfo] loadCartSession];
        [[PhotomonInfo sharedInfo] loadCartList];
    }
    _cartItemCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)[PhotomonInfo sharedInfo].cartList.count];
}

- (IBAction)goHome:(id)sender {
    if ([Common info].main_controller.revealViewController != nil) {
        [[Common info].main_controller.revealViewController revealToggle:nil];
    }
}

- (IBAction)logout:(id)sender {
    if ([[Common info].login_info sendLogout]) {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject: @"" forKey:@"userID"];
        [userDefaults setObject: @"" forKey:@"userPassword"];
        [userDefaults setObject: @"" forKey:@"loginType"];
        [userDefaults synchronize];

		//[Common info].login_status_changed = YES;
        [[Common info].connection loadVersionInfo_v2];
        [[PhotomonInfo sharedInfo] alertMsg:@"로그아웃되었습니다."];

		NSLog(@"postNotificationName");
		UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
		UIViewController *vc  = [mainStoryboard instantiateViewControllerWithIdentifier: @"MainViewController"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshViewController" object:nil userInfo:nil];
    }
    else {
        [[PhotomonInfo sharedInfo] alertMsg:@"로그아웃에 실패했습니다."];
    }

    [self toggleState];
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
/*    if (indexPath.row == 3) {
        InviteViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InviteViewController"];
        if (vc != nil) {
            [self addChildViewController:vc];
            [self.view addSubview:vc.view];
        }
    }*/
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SideCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CartSegue"]) {
        UINavigationController *navController = segue.destinationViewController;
        WVCartViewController *viewController = navController.viewControllers[0];

        viewController.callerViewController = self;
    }
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"OrderListSegue"] || [identifier isEqualToString:@"ContactusSegue"] || [identifier isEqualToString:@"CouponSegue"]) {
        if ([Common info].login_info.user_id.length < 1) {
            
            // 비회원 주문조회가 가능하도록 수정 2015.11.18 (이동헌 요청)
            if ([identifier isEqualToString:@"OrderListSegue"] && [PhotomonInfo sharedInfo].cartSession.length > 0) {
                return YES;
            }
            
            [[Common info]alert:self Title:@"로그인을 해주세요." Msg:@"" completion:^{
                LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginPage"];
                [self presentViewController:vc animated:YES completion:nil];

            }];
            return NO;
        }
    }
    return YES;
}

@end
