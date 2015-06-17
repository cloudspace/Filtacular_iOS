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
        
        RestkitRequest* request = [RestkitRequest new];
        request.requestMethod = RKRequestMethodGET;
        request.path = @"/auth/twitter_access_token/callback";
        request.noMappingRequired = true;
        request.parameters = @{@"token":twitterSession.authToken, @"token_secret":twitterSession.authTokenSecret};
        
        RestkitRequestReponse* response = [[ServerWrapper sharedInstance] performSyncRequest:request];
        
        if (response.successful == false) {
            //TODO
            NSHTTPURLResponse* urlResponse = response.error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            NSString* absoluteString = urlResponse.URL.absoluteString;
            if ([absoluteString isEqualToString:@"http://filtacular.com/waitlist"])
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Wait List" message:@"Thanks for connecting your Twitter account. We'll reach out when you can see the goodness." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
            }
            
            if ([absoluteString isEqualToString:@"http://filtacular.com/user/IsaacPaul13"] == false)
                return;
        }
    
        response = [[ServerWrapper sharedInstance] performSyncGet:@"/twitter-users"];
        if (response.successful == false) {
            //TODO
            return;
        }
        
        NSArray* users = response.mappingResult.array;
        
        request = [RestkitRequest new];
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
        
        NSMutableArray* filters = [response.mappingResult.array mutableCopy];
        if (filters.count == 0)
            return;
        
        for (int i = 0; i < filters.count; i+=1)
        {
            filters[i] = [filters[i] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            VCTwitterFeed* vcTwitterFeed = [VCTwitterFeed new];
            vcTwitterFeed.users = users;
            vcTwitterFeed.filters = [NSArray arrayWithArray:filters];
            vcTwitterFeed.twitterSession = twitterSession;
            vcTwitterFeed.selectedUser = selectedUser;
            vcTwitterFeed.selectedFilter = filters[0];
            [self.navigationController pushViewController:vcTwitterFeed animated:true];
        });
    });
    _btnTwitterLogin.enabled = true;
}

@end
