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

#import <TwitterKit/TwitterKit.h>

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
    _btnTwitterLogin.enabled = false;
    dispatch_async([ServerWrapper requestQueue], ^{
    
        RestkitRequestReponse* response = [[ServerWrapper sharedInstance] performSyncGet:@"/twitter-users"];
        if (response.successful == false) {
            //TODO
            return;
        }
        
        NSArray* users = response.mappingResult.array;
        
        RestkitRequest* request = [RestkitRequest new];
        request.requestMethod = RKRequestMethodGET;
        request.path = @"/lenses";
        request.noMappingRequired = true;
        
        response = [[ServerWrapper sharedInstance] performSyncRequest:request];
        
        if (response.successful == false) {
            //TODO
            return;
        }
        
        User* selectedUser;
        for (User* eachUser in users)
        {
            if ([eachUser.userId isEqualToString:[twitterSession userID]]) {
                selectedUser = eachUser;
                break;
            }
        }
        
        if (selectedUser == nil) {
            
            return;
        }
        
        NSArray* filters = response.mappingResult.array;
        if (filters.count == 0)
            return;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            VCTwitterFeed* vcTwitterFeed = [VCTwitterFeed new];
            vcTwitterFeed.users = users;
            vcTwitterFeed.filters = filters;
            vcTwitterFeed.twitterSession = twitterSession;
            vcTwitterFeed.selectedUser = selectedUser;
            vcTwitterFeed.selectedFilter = filters[0];
            [self.navigationController pushViewController:vcTwitterFeed animated:true];
        });
    });
    _btnTwitterLogin.enabled = true;
}

@end
