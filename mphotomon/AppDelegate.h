//
//  AppDelegate.h
//  mphotomon
//
//  Created by photoMac on 2015. 7. 21..
//  Copyright (c) 2015년 maybeone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Pushwoosh/PushNotificationManager.h>
/*
 1.
 Visit Developer Center. and go AppIDs..
 Confirm your id 'com-photomon(id:com.photomon)' -> DO NOT DELETE!!!
 2.
 pushwoosh.com (id:photomon_dev, pw:foto1201)
 */
@import GoogleSignIn;

@interface AppDelegate : UIResponder <UIApplicationDelegate, PushNotificationDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

