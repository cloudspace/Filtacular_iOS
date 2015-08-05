//
//  AppDelegate.m
//  Filtacular
//
//  Created by Isaac Paul on 6/1/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "AppDelegate.h"
#import "RestkitService.h"

#import "RootNavigationController.h"
#import "VCFakeLoadingScreen.h"
#import "IntroViewController.h"

#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <SDWebImage/SDImageCache.h>

#import "Mixpanel+Additions.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self registerService:[RestkitService new]];
    [Fabric with:@[[Twitter sharedInstance]]];
    [[SDImageCache sharedImageCache] setMaxCacheAge: 604800]; //1 week in seconds
    
    [self invokeServiceMethodWithSelector:@selector(application:didFinishLaunchingWithOptions:) withArgument:&launchOptions];
    
    NSString* mixpanelToken = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Mixpanel Token"];
    if (mixpanelToken) {
        [Mixpanel sharedInstanceWithToken:mixpanelToken];
    }
    
    [self setupWindow];

    return YES;
}

- (void)setupWindow {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    RootNavigationController *rootVC = [[RootNavigationController alloc] init];
    [rootVC setNavigationBarHidden:true];
    
    TWTRSession* existingSession = [[Twitter sharedInstance] session];
    if (existingSession) {
        [[Mixpanel sharedInstance] initializeUser:existingSession];
        rootVC.viewControllers = @[[VCFakeLoadingScreen buildWithSession:existingSession]];
    }
    else {
        rootVC.viewControllers = @[[IntroViewController build]];
    }
    
    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self trackAppOpenEvent];
}

- (void)trackAppOpenEvent {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    bool brandNewUser = ([defaults objectForKey:@"Have Opened Before"] == nil);
    NSString* isBrandNew = @"no";
    if (brandNewUser) {
        [defaults setObject:@(1) forKey:@"Have Opened Before"];
        [defaults synchronize];
        isBrandNew = @"yes";
    }
    
    NSString* entry = @"Cold";
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Opened the app" properties:@{@"Entry Method": entry, @"Is New User": isBrandNew}];
}

@end
