//
//  VCTwitterFeed.m
//  Filtacular
//
//  Created by Isaac Paul on 6/1/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "VCTwitterFeed.h"
#import "CustomTableView.h"
#import "Tweet.h"
#import "LoadingCallBack.h"
#import "TweetCell.h"
#import "PageLoadingCell.h"
#import "User.h"
#import "BasePickerViewAdapter.h"
#import "ServerWrapper.h"

#import <TwitterKit/TwitterKit.h>
#import <SVWebViewController.h>
#import <Mixpanel.h>
#import <IIViewDeckController.h>

#import "UIColor+Filtacular.h"
#import "RestkitRequest+API.h"
#import "UIImageView+SDWebCache.h"

typedef void (^animationFinishBlock)(BOOL finished);
static const int cTweetsPerPage = 100;

@interface VCTwitterFeed ()

@property (strong, nonatomic) IBOutlet CustomTableView* table;

@property (strong, nonatomic) IBOutlet UIView *viewBackToTop;
@property (strong, nonatomic) IBOutlet UIView *viewBackToTopShadow;
@property (strong, nonatomic) IBOutlet UIButton *btnUser;
@property (strong, nonatomic) IBOutlet UILabel *lblFilter;
@property (strong, nonatomic) IBOutlet UILabel *lblUser;
@property (strong, nonatomic) IBOutlet UIImageView *imgUser;
@property (strong, nonatomic) IBOutlet UIImageView *imgFilterIcon;

@property (strong, nonatomic) NSArray* tableData;
@property (strong, nonatomic) NSOperationQueue* twitterUpdateQueue;

@property (assign, nonatomic) bool canRefresh;

//Paging Stuff

@property (strong, nonatomic) NSDate* createdAfterRefFrame;
@property (strong, nonatomic) NSDate* createdBeforeRefFrame;
@property (assign, nonatomic) int nextPage;

@end

@implementation VCTwitterFeed

- (void)viewDidLoad {
    
    _twitterUpdateQueue = [[NSOperationQueue alloc] init];
    _twitterUpdateQueue.name = @"Twitter Update Queue";
    _twitterUpdateQueue.maxConcurrentOperationCount = 1;
    
//    UIImage* imageForRendering = [_imgFilterIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [_imgFilterIcon setImage:imageForRendering];
//    [_imgFilterIcon setTintColor:[UIColor fBarBlue]];
    
    [_table setNoItemText:@"There are no tweets."];
    [_table addTableCellClass:[TweetCell class] forDataType:[Tweet class]];
    [_table addTableCellClass:[PageLoadingCell class] forDataType:[LoadingCallBack class]];
    [_table setSelectObjectBlock:nil];
    [_table activateRefreshable];
    [_table setBackToTopButton:_viewBackToTop];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_viewBackToTopShadow.bounds];
    _viewBackToTopShadow.layer.masksToBounds = NO;
    _viewBackToTopShadow.layer.shadowColor = [UIColor blackColor].CGColor;
    _viewBackToTopShadow.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _viewBackToTopShadow.layer.shadowOpacity = 1.0f;
    _viewBackToTopShadow.layer.shadowPath = shadowPath.CGPath;
    _viewBackToTopShadow.layer.shouldRasterize = true;
    _viewBackToTopShadow.alpha = 0.8f;
    
    
    __weak VCTwitterFeed* weakSelf = self;
    [_table setRefreshCalled:^{
        VCTwitterFeed* strongSelf = weakSelf;
        [strongSelf addNewerTweets];
    }];
    
    [_imgUser setImageWithString:_selectedUser.profileImageUrl placeholderImage:nil];
    [_lblUser setText:_selectedUser.displayName];
    [_lblFilter setText:_selectedFilter];
    [self updateAllTweets];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //Fixes an animation bug with the options view
    [self.viewDeckController toggleRightViewAnimated:false];
    [self.viewDeckController toggleRightViewAnimated:false];
}

- (void)updateAllTweets {

    _tableData = @[];
    [_table clearAndWaitForNewData];
    
    _canRefresh = false; //TODO: Pair tabledata and can refresh together
    [self resetPagingFrameOfReferenceUsingFilter:_selectedFilter];
    [self fetchTweets:_nextPage];
}

- (void)addNewerTweets {
    
    if (_tableData.count == 0) {
        [self updateAllTweets];
        return;
    }
    
    [self resetPagingFrameOfReferenceUsingFilter:_selectedFilter];
    [self fetchTweets:_nextPage];
}

- (void)addMoreTweets {
    [self fetchTweets:_nextPage];
}

- (void)resetPagingFrameOfReferenceUsingFilter:(NSString*)filter {
    _createdBeforeRefFrame = [NSDate date];
    
    if ([filter isEqualToString:@"swish"] == false) {
        //We hard code this one hour offset because for all other filters because the tweets are still coming in until an hour after
        NSTimeInterval beginTime = [_createdBeforeRefFrame timeIntervalSinceReferenceDate] - 60 * 60 * 1; //1 hour earlier
        _createdBeforeRefFrame = [NSDate dateWithTimeIntervalSinceReferenceDate:beginTime];
    }
    NSTimeInterval endTimeFrame = [_createdBeforeRefFrame timeIntervalSinceReferenceDate] - 60 * 60 * 24; //24 hours earlier
    _createdAfterRefFrame = [NSDate dateWithTimeIntervalSinceReferenceDate:endTimeFrame];
    _nextPage = 1;
}

- (void)fetchTweets:(int)page {
    [_twitterUpdateQueue cancelAllOperations];
    [[ServerWrapper sharedInstance] cancelAllRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"/twitter-users/:userId/tweets"];
    
    NSBlockOperation* twitterUpdater = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation* twitterBlockOp = twitterUpdater;
    [twitterUpdater addExecutionBlock:^{
        if (twitterBlockOp.cancelled)
            return;
        
        NSDictionary* filterDictionary = @{@"created_before":_createdBeforeRefFrame, @"created_after":_createdAfterRefFrame};
        NSString* filter = [_selectedFilter stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSMutableDictionary* filterMod = [filterDictionary mutableCopy];
        [filterMod setObject:@(1) forKey:filter];
        
        RestkitRequest* request = [RestkitRequest tweetListRequest:_selectedUser.userId filters:filterMod page:page pageSize:cTweetsPerPage];
        RestkitRequestReponse* response = [[ServerWrapper sharedInstance] performSyncRequest:request];
        if (response.successful == false) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (twitterBlockOp.cancelled)
                    return;
                [self loadTweets:_tableData];
            });
            return;
        }
        
        if (twitterBlockOp.cancelled)
            return;
        
        NSArray* filtacularTweets = response.mappingResult.array;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (twitterBlockOp.cancelled)
                return;
            
            bool thereMayBeMoreTweets = (cTweetsPerPage == filtacularTweets.count);
            _canRefresh = thereMayBeMoreTweets;
            [self loadTweets:filtacularTweets];
            
            if (_nextPage < page + 1)
                _nextPage = page + 1;
        });
    }];
    
    [_twitterUpdateQueue addOperation:twitterUpdater];
}

- (void)loadTweets:(NSArray*)tweets {
    
    //Remove the Loading cell if it exists
    id lastObj = [_tableData lastObject];
    if ([lastObj isKindOfClass:[LoadingCallBack class]]) {
        NSRange range;
        range.location = 0;
        range.length = _tableData.count - 1;
        _tableData = [_tableData subarrayWithRange:range];
    }
    
    //Filter out invalid tweets
    bool isLinkyLoo = [_selectedFilter isEqualToString:@"linky loo"];
    if (isLinkyLoo) {
        tweets = [tweets objectsAtIndexes:[tweets indexesOfObjectsPassingTest:^BOOL(Tweet* obj, NSUInteger idx, BOOL *stop) {
            return [obj isValidLinkyLooTweet];
        }]];
    }
    
    NSObject* firstTweet = nil;
    if (_tableData.count > 0)
        firstTweet = _tableData[0];
    
    if (_nextPage != 1)
        _tableData = [_tableData arrayByAddingObjectsFromArray:tweets];
    else
        _tableData = tweets; //Fixes some ugly animations if we clear the table after we load the data.
    
    _tableData = [Tweet removeDuplicates:_tableData];
    
    __weak VCTwitterFeed* weakSelf = self;
    for (__weak Tweet* eachTweet in tweets) {
        
        if ([_selectedFilter isEqualToString:@"aye aye"]) {
            eachTweet.pictureOnly = true;
        }
        else if ([_selectedFilter isEqualToString:@"linky loo"]) {
            eachTweet.linkOnly = true;
        }
        
        if ([_selectedUser.nickname isEqualToString:_currentUsersName] == false)
            eachTweet.showFollowButton = true;
        
        [eachTweet setTappedBigPic:^{
            Tweet* strongTweet = eachTweet;
            strongTweet.bigPicOpenedCache = !strongTweet.bigPicOpenedCache;
            
            VCTwitterFeed* strongSelf = weakSelf;
            [strongSelf.table cellHeightChanged];
        }];
        
        [eachTweet setTappedLink:^(NSString* link) {
            VCTwitterFeed* strongSelf = weakSelf;
            SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:link];
            [strongSelf.navigationController pushViewController:webViewController animated:YES];
            [strongSelf.navigationController setNavigationBarHidden:false animated:false];
        }];
        
    }
    
    if (_canRefresh)
    {
        __weak VCTwitterFeed* weakSelf = self;
        LoadingCallBack* callbackModel = [LoadingCallBack new];
        [callbackModel setIsShown:^{
            VCTwitterFeed* strongSelf = weakSelf;
            [strongSelf addMoreTweets];
        }];
        _tableData = [_tableData arrayByAddingObject:callbackModel];
    }
    
    
    if (_nextPage == 1 && firstTweet != nil) {
        [UIView setAnimationsEnabled:NO];
        [_table loadData:_tableData];
        [UIView setAnimationsEnabled:YES];
        [_table scrollToObject:firstTweet atScrollPosition:UITableViewScrollPositionTop animated:false];
    }
    else {
        [_table loadData:_tableData];
    }
}

- (void)fakeLoadTweets {
    NSMutableArray * tweetMut = [NSMutableArray new];
    for (int i = arc4random_uniform(100); i >= 0; i -=1) {
        [tweetMut addObject:[Tweet generateRandomTweet]];
    }
    NSArray* tweets = [NSArray arrayWithArray:tweetMut];
    
    [self loadTweets:tweets];
}

//TODO: Figure out how to get rid of this via UI Builder
- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}

#pragma mark - Actions

- (IBAction)tapFilters {
    [self.viewDeckController toggleRightViewAnimated:true];
}

- (IBAction)tapUsers {
    [self.viewDeckController toggleLeftViewAnimated:true];
}

- (void)showFilter:(NSString*)filter
{
    if (self.selectedFilter == filter)
        return;
    
    self.selectedFilter = filter;
    [_lblFilter setText:_selectedFilter];
    [self updateAllTweets];
    [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Viewed Filter: %@", _selectedFilter]];
    
}

- (void)showUser:(User*)user
{
    if (self.selectedUser == user)
        return;
    
    self.selectedUser = user;
    [_imgUser setImageWithString:_selectedUser.profileImageUrl placeholderImage:nil];
    [_lblUser setText:_selectedUser.displayName];
    [self updateAllTweets];
    [[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Viewed User: %@", _selectedUser.nickname]];
}

@end
