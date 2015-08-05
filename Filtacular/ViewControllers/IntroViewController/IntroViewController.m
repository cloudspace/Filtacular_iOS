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
#import "NSObject+Shortcuts.h"
#import "NSError+URLError.h"
#import "UIAlertView+Shortcuts.h"
#import "RestkitRequest+API.h"

#import <TwitterKit/TwitterKit.h>

#import <SDWebImageCompat.h>
#import "Mixpanel+Additions.h"

@interface IntroViewController ()

@property (nonatomic, strong) IBOutlet UIButton *btnTwitterLogin;
@end

@implementation IntroViewController

+ (IntroViewController*)build {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IntroViewController* vc = (IntroViewController*)[storyboard instantiateViewControllerWithIdentifier:@"IntroViewControllerID"];
    return vc;
}

- (IBAction)tapTwitterLogin {
    _btnTwitterLogin.enabled = false;
    
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session == nil) {
            NSLog(@"error: %@", [error localizedDescription]);
            [UIAlertView showError:error];
            _btnTwitterLogin.enabled = true;
            return;
        }
        
        [[Mixpanel sharedInstance] initializeUser:session];
        
        NSLog(@"signed in as %@", [session userName]);
        [IntroViewController loginToFiltacular:session failure:^(RKObjectRequestOperation *operation, NSError *error) {
            if (error) {
                if ([error isConnectionError]) {
                    [UIAlertView showMessage:[error connectionErrorString]];
                }
                else if (error.code == 3) {
                    [UIAlertView showAlertWithTitle:@"Wait List" andMessage:[error localizedDescription]];
                }
                else {
                    [UIAlertView showError:error];
                }
            }
            
            _btnTwitterLogin.enabled = true;
        } success:^(VCTwitterFeed *vcTwitterFeed) {
            _btnTwitterLogin.enabled = true;
            [self.navigationController pushViewController:vcTwitterFeed animated:true];
        }];
     }];
}

//TODO: This function is way too long
+ (void)loginToFiltacular:(TWTRSession*)twitterSession failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failureBlockParam success:(void (^)(VCTwitterFeed *vcTwitterFeed))successBlock {
    dispatch_async([ServerWrapper requestQueue], ^{
        
        //We hook the failure block to avoid repeating code
        __block void (^failureBlock)(RKObjectRequestOperation *operation, NSError *error) = ^(RKObjectRequestOperation *operation, NSError *error) {
            if (failureBlockParam == nil)
                return;
            
            dispatch_main_sync_safe(^{
                failureBlockParam(operation, error);
            });
        };
        
        NSError* error = [self updateCookies:twitterSession];
        if (error) {
            failureBlock(nil, error);
            return;
        }
    
        RestkitRequestReponse* response = [[ServerWrapper sharedInstance] performSyncGet:@"/twitter-users"];
        if (response.successful == false) {
            failureBlock(nil, response.error);
            return;
        }
        
        NSArray* users = response.mappingResult.array;
        
        //Grab Filters
        RestkitRequest* request = [RestkitRequest grabFiltersRequest];
        request.failure = failureBlock;
        
        response = [[ServerWrapper sharedInstance] performSyncRequest:request];
        if (response.successful == false)
            return;
        
        NSMutableArray* filters = [response.mappingResult.array mutableCopy];
        if (filters.count == 0) {
            failureBlock(nil, [self errorWithCode:1 andLocalizedDescription:@"No filters returned from the server"]);
            return;
        }
        
        for (int i = 0; i < filters.count; i+=1)
        {
            filters[i] = [filters[i] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        }
        
        //Find current user in user list
        User* selectedUser;
        for (User* eachUser in users)
        {
            if ([eachUser.userId isEqualToString:[twitterSession userID]]) {
                selectedUser = eachUser;
                break;
            }
        }
        
        if (selectedUser == nil) {
            NSString* errorMsg = [NSString stringWithFormat:@"Could not find user %@ (%@) in /twitter-users", [twitterSession userID], [twitterSession userName]];
            failureBlock(nil, [self errorWithCode:0 andLocalizedDescription:errorMsg]);
            return;
        }
        
        //Sort users
        users = [users sortedArrayUsingComparator:^NSComparisonResult(User* obj1, User* obj2) {
            return [[obj1 sortingName] compare:[obj2 sortingName]];
        }];
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            VCTwitterFeed* vcTwitterFeed = [VCTwitterFeed new];
            vcTwitterFeed.users = users;
            vcTwitterFeed.filters = [NSArray arrayWithArray:filters];
            vcTwitterFeed.twitterSession = twitterSession;
            vcTwitterFeed.selectedUser = selectedUser;
            vcTwitterFeed.selectedFilter = filters[0];
            successBlock(vcTwitterFeed);
        });
    });
}

+ (NSError*)updateCookies:(TWTRSession*)twitterSession {
    AFHTTPClient* client = [RKObjectManager sharedManager].HTTPClient;
    NSURL *cookieUrl = [NSURL URLWithString:@"/auth/twitter_access_token/callback" relativeToURL:client.baseURL];
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:cookieUrl];
    bool alreadyHaveCookies = (cookies.count != 0);
    if (alreadyHaveCookies)
        return nil;
    
    RestkitRequest* request = [RestkitRequest cookiesRequestToken:twitterSession.authToken secret:twitterSession.authTokenSecret];
    RestkitRequestReponse* response = [[ServerWrapper sharedInstance] performSyncRequest:request];
    if (response.successful == false)
        return response.error;
    
    NSHTTPURLResponse* urlResponse = response.error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
    NSString* absoluteString = urlResponse.URL.absoluteString;
    if ([absoluteString isEqualToString:@"http://filtacular.com/waitlist"])
    {
        NSError* error = [self errorWithCode:3 description:@"Thanks for connecting your Twitter account. We'll reach out when you can see the goodness."];
        return error;
    }
    
    return nil;
}

@end
