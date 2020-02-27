//
//  PhotoPositionSelectController.m
//  PHOTOMON
//
//  Created by 곽세욱 on 02/08/2019.
//  Copyright © 2019 maybeone. All rights reserved.
//

#import "PhotoPositionSelectController.h"
#import "AlbumSelectViewController.h"
#import "PhotoSelectViewController.h"
#import "SNSLoginViewController.h"
#import "PhotoContainer.h"
#import "UIView+Toast.h"
#import "SocialBase.h"
#import "SocialGooglePhoto.h"

@interface PhotoPositionSelectController () <UITableViewDelegate, socialAuthDelegate>

@end

@implementation PhotoPositionSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	_allowPosition = [NSArray arrayWithObjects:
					  [NSNumber numberWithInt:PHOTO_POSITION_LOCAL]
//					  , [NSNumber numberWithInt:PHOTO_POSITION_SMARTBOX]
					  , [NSNumber numberWithInt:PHOTO_POSITION_INSTAGRAM]
//					  , [NSNumber numberWithInt:PHOTO_POSITION_FACEBOOK]
					  , [NSNumber numberWithInt:PHOTO_POSITION_GOOGLEPHOTO]
					  , [NSNumber numberWithInt:PHOTO_POSITION_KAKAOSTORY]
					  , nil];
	
	_positionType = -1;
	
	[[PhotoContainer inst] initialize];
}

- (void)setData:(id<SelectPhotoDelegate>)delegate isSinglemode:(BOOL)isSinglemode minPictureCount:(int)minPictureCount param:(NSString *)param {
	_delegate = delegate;
	_isSinglemode = isSinglemode;
	_minPictureCount = minPictureCount;
	_param = param;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	
	if ([segue.identifier isEqualToString:@"AlbumSelectSegue"]) {
		AlbumSelectViewController *vc = (AlbumSelectViewController *)[segue destinationViewController];
		if (vc) {
			[vc setData:_delegate positionType:_positionType isSinglemode:_isSinglemode minPictureCount:_minPictureCount param:_param];
			vc.selectDoneOp = _selectDoneOp;
		}
	}
	else if ([segue.identifier isEqualToString:@"PhotoSelectSegue"]) {
		PhotoSelectViewController *vc = (PhotoSelectViewController *)[segue destinationViewController];
		if (vc) {
			[vc setData:_delegate positionType:_positionType isSinglemode:_isSinglemode minPictureCount:_minPictureCount param:_param];
			vc.selectDoneOp = _selectDoneOp;
		}
	}
	else if ([segue.identifier isEqualToString:@"LoginSocialSegue"]) {
		SNSLoginViewController *vc = (SNSLoginViewController *)[segue destinationViewController];
		if (vc) {
			[vc setData:_positionType delegate:self];
		}
	}
}

- (IBAction)cancel:(id)sender {
	
	if (_cancelOp) {
		_cancelOp(self);
	} else {
		[self dismissViewControllerAnimated:YES completion:^{
			[self.delegate selectPhotoCancel:_isSinglemode];
		}];
	}
}

#pragma mark - positionListView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _allowPosition.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PositionCell" forIndexPath:indexPath];
	
	UILabel *positionName = (UILabel *)[cell viewWithTag:200];
	UIImageView *positionIcon = (UIImageView *)[cell viewWithTag:201];
	int idx = [_allowPosition[indexPath.row] intValue];
	
	// 추후 순서에 따라 아래 if문 안의 블록을 수정.
	if (idx == PHOTO_POSITION_LOCAL) {
		[positionIcon setImage:[UIImage imageNamed:@"ic_phone.png"]];
		[positionName setText:@"휴대폰 사진"];
	} else if (idx == PHOTO_POSITION_INSTAGRAM) {
		[positionIcon setImage:[UIImage imageNamed:@"ic_instagram.png"]];
		[positionName setText:@"인스타그램"];
	} else if (idx == PHOTO_POSITION_FACEBOOK) {
		[positionIcon setImage:[UIImage imageNamed:@"ic_facebook.png"]];
		[positionName setText:@"페이스북"];
	} else if (idx == PHOTO_POSITION_GOOGLEPHOTO) {
		[positionIcon setImage:[UIImage imageNamed:@"ic_googlephoto.png"]];
		[positionName setText:@"구글포토"];
	} else if (idx == PHOTO_POSITION_KAKAOSTORY) {
		[positionIcon setImage:[UIImage imageNamed:@"ic_kakaostory.png"]];
		[positionName setText:@"카카오스토리"];
	} else if (idx == PHOTO_POSITION_SMARTBOX) {
		[positionIcon setImage:[UIImage imageNamed:@"box_gray.png"]];
		[positionName setText:@"스마트박스"];
	}
	
	return cell;
}


#pragma mark - PositionListView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	_positionType = [_allowPosition[indexPath.row] intValue];
	
	if (_positionType == PHOTO_POSITION_LOCAL) {
		// 앨범 뷰
		[self performSegueWithIdentifier:@"AlbumSelectSegue" sender:self];
	}
	else {
		if ( [[SocialManager inst] isSessionValid:_positionType] ){
			[self performSegueWithIdentifier:@"PhotoSelectSegue" sender:self];
		} else {
			if (_positionType == PHOTO_POSITION_GOOGLEPHOTO){
				GIDSignIn *signIn = [GIDSignIn sharedInstance];
				
				if ([signIn hasAuthInKeychain]){
					[signIn signInSilently];
				} else {
					signIn.language = @"kr";
					signIn.shouldFetchBasicProfile = YES;
					signIn.scopes = [[SocialManager inst] getScopes:_positionType];
					signIn.delegate = self;
					signIn.uiDelegate = self;
					[signIn signIn];
				}
			}
			else if (_positionType == PHOTO_POSITION_KAKAOSTORY) {
				[[KOSession sharedSession] close];
							
				[[KOSession sharedSession] openWithCompletionHandler:^(NSError *error) {
					if ([[KOSession sharedSession] isOpen]) {
						[self oAuthDone:YES snsType:_positionType];
					} else {
						[self oAuthDone:NO snsType:_positionType];
					}
				}];
			}
			else if (_positionType == PHOTO_POSITION_FACEBOOK) {
				FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
				[manager logInWithReadPermissions:[[SocialManager inst] getScopes:_positionType] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
					if (error) {
						[self oAuthDone:NO snsType:_positionType];
					} else if (result.isCancelled) {
						[self oAuthDone:NO snsType:_positionType];
					} else {
						[self oAuthDone:YES snsType:_positionType];
					}
				}];
			}
			else {
				[self performSegueWithIdentifier:@"LoginSocialSegue" sender:self];
			}
		}
	}
}

#pragma mark - oAuthDelegate methods

- (void)oAuthDone:(BOOL)result snsType:(int)snsType {
	if (result) {
		[self.view makeToast:@"로그인되었습니다."];
		if ( [[SocialManager inst] isSessionValid:snsType] ){
			[self performSegueWithIdentifier:@"PhotoSelectSegue" sender:self];
		}
	}
	else {
		[self.view makeToast:@"로그인되지 않았습니다."];
		[[SocialManager inst] logout:_positionType];
	}
}

#pragma mark - Google Sign-in Delegate
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
	 withError:(NSError *)error {
	// Perform any operations on signed in user here.
	
	//	[_delegate oAuthDone: snsType:<#(int)#>
	
	if (error) {
		[self oAuthDone:NO snsType:_positionType];
	} else {
		NSString *accessToken = user.authentication.accessToken; // Safe to send to the server
		[[SocialManager inst] evaluateAuthResponse:_positionType response:accessToken];
		
		[self oAuthDone:YES snsType:_positionType];
	}
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
	 withError:(NSError *)error {
	// Perform any operations when the user disconnects from app here.
	// ...
	NSLog(@"Disconnect");
	
	[self oAuthDone:NO snsType:_positionType];
}
@end
