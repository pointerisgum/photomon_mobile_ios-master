//
//  AppDelegate.m
//  mphotomon
//
//  Created by photoMac on 2015. 7. 21..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import "AppDelegate.h"
#import "Analysis.h"
#import "Common.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "Firebase.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Analysis regist];
    [FIRApp configure];

	// 2019.01.02 : 구닥북 연동 관련
	[Common info].dynamic_link_init = NO;

    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
//    NaverThirdPartyLoginConnection *connection = [NaverThirdPartyLoginConnection getSharedInstance];
//    
//    connection.isInAppOauthEnable = true;
//    connection.isNaverAppOauthEnable = true;
//    connection.consumerKey = kConsumerKey;
//    connection.consumerSecret = kConsumerSecret;
//    connection.appName = kServiceAppName;

    //[[Common info] isDigit:@"012!&342353456098"];

    application.applicationIconBadgeNumber = 0;

    //-----------PUSHWOOSH PART-----------
    // set custom delegate for push handling, in our case - view controller
    PushNotificationManager * pushManager = [PushNotificationManager pushManager];
    pushManager.delegate = self;

    // handling push on app start
    [[PushNotificationManager pushManager] handlePushReceived:launchOptions];

    // make sure we count app open in Pushwoosh stats
    [[PushNotificationManager pushManager] sendAppOpen];

    // register for push notifications!
    [[PushNotificationManager pushManager] registerForPushNotifications];
    //-----------PUSHWOOSH PART-----------

    // 디바이스 식별문자열
    UIDevice *device = [UIDevice currentDevice];
    NSString* idForVendor = [device.identifierForVendor UUIDString];
    NSLog(@"identifierForVendor:\n %@ (len:%d)", idForVendor, (int)idForVendor.length);

    // 이니페이모바일 세션만료 오류경고 발생할 수 있으므로 쿠키 허용 코드 삽입. INIpayMobile_web_manual_v.4.13.pdf 36page
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
	
	// Google Sign In
	[GIDSignIn sharedInstance].clientID = GOOGLE_SIGNIN_CLIENT_ID;
	[GIDSignIn sharedInstance].delegate = self;
	
	// Darkmode 안되게 설정
	if ( @available(iOS 13.0, *)) {
		[[self window] setOverrideUserInterfaceStyle:UIUserInterfaceStyleLight];
	}

    return YES;
}

//-----------PUSHWOOSH PART-----------
// system push notification registration success callback, delegate to pushManager
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

// system push notifications callback, delegate to pushManager
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
}

- (void)onPushReceived:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification onStart:(BOOL)onStart {
    NSLog(@"*************************************************** Push notification received");
}

- (void)onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification {
    NSLog(@"*************************************************** Push notification accepted");
}

- (void)onDidRegisterForRemoteNotificationsWithDeviceToken:(NSString *)token {
    NSLog(@"*************************************************** onDidRegisterForRemoteNotificationsWithDeviceToken");
}

- (void)onDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"*************************************************** onDidFailToRegisterForRemoteNotificationsWithError");
}
//-----------PUSHWOOSH PART-----------

- (void)kakaoSessionDidChangeWithNotification {
//    [self reloadRootViewController];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
    application.applicationIconBadgeNumber = 0;
    [KOSession handleDidEnterBackground];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
	
	[KOSession handleDidBecomeActive];
    NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {

//    if ([KOSession handleOpenURL:url]) {
//        return YES;
//    }
    
	NSLog(@"DEBUG :: FUNCTION : openURL");
	[Common info].conn_link_init = YES;

	// 구닥북 링크 관련
    if (url != nil && [url.absoluteString rangeOfString:@"photomonmobilekr"].location != NSNotFound) {
		[Common info].deeplink_url = url.absoluteString;
		[IgaworksCore passOpenURL:url];

		[[NSNotificationCenter defaultCenter] postNotificationName:@"deeplink-dismiss-notification" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deeplink-move-notification" object:self];

		// 2019.01.02 : 구닥북 연동 관련
		[Common info].dynamic_link_init = YES;
	}

    return [self application:app
                      openURL:url
            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
//
//    if ([KOSession handleOpenURL:url]) {
//        return YES;
//    }
    
    FIRDynamicLink *dynamicLink = [[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];

	[Common info].conn_link_init = YES;

	NSLog(@"DEBUG :: FUNCTION : openURL (FIRDynamicLink)");

	if (dynamicLink) {
		//NSLog(@"DEBUG :: Dynamic link has a deep link #1");

		if (dynamicLink.url) {
			// Handle the deep link. For example, show the deep-linked content,
			// apply a promotional offer to the user's account or show customized onboarding view.
			// ...

			// 구닥북 링크 관련
			//NSLog(@"DEBUG :: Dynamic link has a deep link url #2 : %@", url.absoluteString);
			NSURL* url = dynamicLink.url;

			//if([Common info].dynamic_link_init == NO || TRUE) { // 2019.01.02
			if (url != nil && [url.absoluteString rangeOfString:@"photomonmobilekr"].location != NSNotFound) {
				[Common info].deeplink_url = url.absoluteString;
				[Common info].dynamic_link_init = YES;
				[IgaworksCore passOpenURL:url];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"deeplink-dismiss-notification" object:self];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"deeplink-move-notification" object:self];
			}
			//}
		} else {
			// Dynamic link has empty deep link. This situation will happens if
			// Firebase Dynamic Links iOS SDK tried to retrieve pending dynamic link,
			// but pending link is not available for this device/App combination.
			// At this point you may display default onboarding view.
			NSLog(@"DEBUG :: Dynamic link has empty deep link");
			[Common info].dynamic_link_init = YES;
		}
		return YES;
	}
	// 2019.01.03
	else {
		[Common info].dynamic_link_init = YES;
	}

	// 2019.01.02 : CHECK
//	return NO;
	// 카카오 관련 URL이면
	if ([KOSession isKakaoAccountLoginCallback:url]) {
		return [KOSession handleOpenURL:url];
	}
	
	// 구글 SignIn 으로 마무리
	BOOL handled = [[GIDSignIn sharedInstance] handleURL:url sourceApplication:sourceApplication annotation:annotation];
	
	if (!handled) {
		handled = [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
	}
	
	return handled;
}


- (BOOL)application:(UIApplication *)application
continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:
#if defined(__IPHONE_12_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_12_0)
    (nonnull void (^)(NSArray<id<UIUserActivityRestoring>> *_Nullable))restorationHandler {
#else
    (nonnull void (^)(NSArray *_Nullable))restorationHandler {
#endif  // __IPHONE_12_0
	NSLog(@"DEBUG :: continueUserActivity");
	[Common info].conn_link_init = YES;
	BOOL handled = [[FIRDynamicLinks dynamicLinks] handleUniversalLink:userActivity.webpageURL
														  completion:^(FIRDynamicLink * _Nullable dynamicLink,
																	   NSError * _Nullable error) {
			// 구닥북 링크 관련
			if(dynamicLink && dynamicLink.url) {																	   		
				NSURL* url = dynamicLink.url;
				[Common info].deeplink_url = url.absoluteString;
				[Common info].dynamic_link_init = YES;
				[IgaworksCore passOpenURL:url];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"deeplink-dismiss-notification" object:self];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"deeplink-move-notification" object:self];
				NSLog(@"DEBUG :: continueUserActivity : UNIVERSAL LINK SETTING");
		}
	}];
	return handled;
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
withError:(NSError *)error {
	if (error != nil) {
		if (error.code == kGIDSignInErrorCodeHasNoAuthInKeychain) {
			NSLog(@"The user has not signed in before or they have since signed out.");
		} else {
			NSLog(@"%@", error.localizedDescription);
		}
		return;
	}
}
	
- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
withError:(NSError *)error {
	// Perform any operations when the user disconnects from app here.
	// ...
}
@end
