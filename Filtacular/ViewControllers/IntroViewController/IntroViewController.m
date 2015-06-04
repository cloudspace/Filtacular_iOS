//
//  IntroViewController.m
//  Filtacular
//
//  Created by John Li on 6/1/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "IntroViewController.h"
#import "VCTwitterFeed.h"
#import "ServerWrapper.h"

#import "User.h"
#import "Filter.h"

@interface IntroViewController ()

@property (nonatomic,strong) IBOutlet UIButton *btnTwitterLogin;
@end

@implementation IntroViewController


- (IBAction)tapTwitterLogin {
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
         if (session) {
             NSLog(@"signed in as %@", [session userName]);
             [self loginToFiltacular:session];
         } else {
             NSLog(@"error: %@", [error localizedDescription]);
         }
     }];
}

- (void)loginToFiltacular:(TWTRSession*)twitterSession {
    
    VCTwitterFeed* vcTwitterFeed = [VCTwitterFeed new];
    vcTwitterFeed.users = [User pseudoUsers];
    vcTwitterFeed.filters = [Filter pseudoFilters];
    vcTwitterFeed.twitterSession = twitterSession;
    [self.navigationController pushViewController:vcTwitterFeed animated:true];
    
    return;
    
    //Can't test until I have an api
//    dispatch_async([ServerWrapper requestQueue], ^{
//    
//        RestkitRequestReponse* response = [[ServerWrapper sharedInstance] performSyncGet:@"users"];
//        if (response.successful == false) {
//            //TODO
//            return;
//        }
//        
//        NSArray* users = response.mappingResult.array;
//        
//        response = [[ServerWrapper sharedInstance] performSyncGet:@"filters"];
//        if (response.successful == false) {
//            //TODO
//            return;
//        }
//        
//        NSArray* filters = response.mappingResult.array;
//        
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            VCTwitterFeed* vcTwitterFeed = [VCTwitterFeed new];
//            vcTwitterFeed.users = users;
//            vcTwitterFeed.filters = filters;
//            vcTwitterFeed.twitterSession = twitterSession;
//            [self.navigationController pushViewController:vcTwitterFeed animated:true];
//        });
//    });
}

@end
