//
//  IntroViewController.m
//  Filtacular
//
//  Created by John Li on 6/1/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "IntroViewController.h"
#import "VCTwitterFeed.h"
#import "VCUsers.h"
#import "VCFilters.h"

#import "ServerWrapper.h"
#import "User.h"

#import "NSObject+Shortcuts.h"
#import "NSError+URLError.h"
#import "UIAlertView+Shortcuts.h"
#import "RestkitRequest+API.h"
#import "Mixpanel+Additions.h"
#import "UIView+Positioning.h"

#import <IIViewDeckController.h>
#import <IISideController.h>
#import <TwitterKit/TwitterKit.h>
#import <SDWebImageCompat.h>

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
        } success:^(UIViewController *mainScreen) {
            _btnTwitterLogin.enabled = true;
            
            [self.navigationController pushViewController:mainScreen animated:true];
        }];
     }];
}

//TODO: This function is way too long
+ (void)loginToFiltacular:(TWTRSession*)twitterSession failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failureBlockParam success:(void (^)(UIViewController *mainScreen))successBlock {
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
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* lastSelectedUserId = [defaults objectForKey:@"lastSelectedUser"];
        if (lastSelectedUserId == nil)
            lastSelectedUserId = [twitterSession userID];
        
        selectedUser = [User findUserWithId:lastSelectedUserId inList:users];
        
        if (selectedUser == nil && lastSelectedUserId != [twitterSession userID]) {
            lastSelectedUserId = [twitterSession userID];
            selectedUser = [User findUserWithId:lastSelectedUserId inList:users];
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
        
        NSString* selectedFilter = [defaults objectForKey:@"lastSelectedFilter"];
        if (selectedFilter == nil || [filters containsObject:selectedFilter] == false) {
            selectedFilter = filters[0];
        }
        
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            VCTwitterFeed* vcTwitterFeed    = [VCTwitterFeed new];
            vcTwitterFeed.currentUsersName  = twitterSession.userName;
            vcTwitterFeed.selectedUser      = selectedUser;
            vcTwitterFeed.selectedFilter    = selectedFilter;
            
            VCUsers* vcUsers                = [VCUsers new];
            vcUsers.users                   = users;
            vcUsers.selectedUser            = selectedUser;
            vcUsers.twitterFeed             = vcTwitterFeed;
            
            VCFilters* vcFilters            = [VCFilters new];
            vcFilters.filters               = [NSArray arrayWithArray:filters];
            vcFilters.selectedFilter        = selectedFilter;
            vcFilters.twitterFeed           = vcTwitterFeed;
            
            UIViewController* mainScreen = [IntroViewController buildMainScreen:vcTwitterFeed vcUsers:vcUsers vcFilters:vcFilters];
            
            successBlock(mainScreen);
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

+ (UIViewController*)buildMainScreen:(VCTwitterFeed*)twitterFeed vcUsers:(VCUsers*)vcUsers vcFilters:(VCFilters*)vcFilters {
    CGFloat bleedSize       = 62.0f;
    CGFloat sideViewWidth   = [UIApplication sharedApplication].keyWindow.bounds.size.width - bleedSize;
    
    IISideController *constrainedLeftController     = [[IISideController alloc]         initWithViewController:vcUsers   constrained:sideViewWidth];
    IISideController *constrainedRightController    = [[IISideController alloc]         initWithViewController:vcFilters constrained:sideViewWidth];
    IIViewDeckController* deckController            = [[IIViewDeckController alloc]     initWithCenterViewController:twitterFeed leftViewController:constrainedLeftController rightViewController:constrainedRightController];
    deckController.rightSize                        = bleedSize;
    deckController.leftSize                         = bleedSize;
    deckController.centerhiddenInteractivity        = IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose;
    
    return deckController;
}

@end
