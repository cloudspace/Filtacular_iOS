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

typedef void (^animationFinishBlock)(BOOL finished);

static const int cTweetsPerPage = 10;

@interface VCTwitterFeed ()

@property (strong, nonatomic) IBOutlet CustomTableView* table;
@property (strong, nonatomic) IBOutlet UIPickerView* pickerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* filterBarPositionFromBottomConstraint;
@property (strong, nonatomic) IBOutlet UIButton* userButton;
@property (strong, nonatomic) IBOutlet UIButton* filterButton;

@property (strong, nonatomic) UITapGestureRecognizer* tableTapGesture;
@property (strong, nonatomic) NSArray* tableData;
@property (strong, nonatomic) BasePickerViewAdapter* currentPickerAdapter;
@property (strong, nonatomic) NSOperationQueue* twitterUpdateQueue;

@property (copy, nonatomic) animationFinishBlock onPickerVisible;
@property (copy, nonatomic) animationFinishBlock onPickerHidden;
@property (copy, nonatomic) void(^onStartPickerShowAnimation)();

@property (assign, nonatomic) bool canRefresh;

//Paging Stuff

@property (strong, nonatomic) NSDate* createdAfterRefFrame;
@property (strong, nonatomic) NSDate* createdBeforeRefFrame;
@property (assign, nonatomic) int nextPage;

@end

@implementation VCTwitterFeed

- (void)viewDidLoad {
    
    _tableTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTableTapped)];
    _currentPickerAdapter = [BasePickerViewAdapter new];
    [_currentPickerAdapter bind:_pickerView];
    
    _twitterUpdateQueue = [[NSOperationQueue alloc] init];
    _twitterUpdateQueue.name = @"Twitter Update Queue";
    _twitterUpdateQueue.maxConcurrentOperationCount = 1;
    
    [_table setNoItemText:@"There are no tweets."];
    [_table addTableCellClass:[TweetCell class] forDataType:[Tweet class]];
    [_table addTableCellClass:[PageLoadingCell class] forDataType:[LoadingCallBack class]];
    [_table setSelectObjectBlock:nil];
    [_table activateRefreshable];
    __weak VCTwitterFeed* weakSelf = self;
    [_table setRefreshCalled:^{
        VCTwitterFeed* strongSelf = weakSelf;
        [strongSelf addNewerTweets];
    }];
    
    [self updateSelectedUserLabel:_selectedUser];
    [self.filterButton setTitle:_selectedFilter forState:UIControlStateNormal];
    [self updateAllTweets];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:animated];
}

- (void)updateAllTweets {

    [_table clearAndWaitForNewData];
    _tableData = @[];
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
    NSTimeInterval endTimeFrame = [_createdAfterRefFrame timeIntervalSinceReferenceDate] - 60 * 60 * 24; //24 hours earlier
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
        
        RestkitRequest* request = [RestkitRequest new];
        request.requestMethod = RKRequestMethodGET;
        request.path = [NSString stringWithFormat:@"/twitter-users/%@/tweets", _selectedUser.userId];
        request.parameters = @{@"filter":filterMod, @"page":@{@"number":@(page), @"size":@(cTweetsPerPage)}};
        
        RestkitRequestReponse* response = [[ServerWrapper sharedInstance] performSyncRequest:request];
        if (response.successful == false) {
            //TODO
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
    
    id lastObj = [_tableData lastObject];
    if ([lastObj isKindOfClass:[LoadingCallBack class]]) {
        NSRange range;
        range.location = 0;
        range.length = _tableData.count - 1;
        _tableData = [_tableData subarrayWithRange:range];
    }
    
    bool isLinkyLoo = [_selectedFilter isEqualToString:@"linky loo"];
    if (isLinkyLoo) {
        tweets = [tweets objectsAtIndexes:[tweets indexesOfObjectsPassingTest:^BOOL(Tweet* obj, NSUInteger idx, BOOL *stop) {
            return [obj isValidLinkyLooTweet];
        }]];
    }
    
    if (_nextPage != 1)
        _tableData = [_tableData arrayByAddingObjectsFromArray:tweets];
    else
        _tableData = tweets; //Fixes some ugly animations if we clear the table after we load the data.
    
    _tableData = [Tweet removeDuplicates:_tableData];
    
    __weak VCTwitterFeed* weakSelf = self;
    for (__weak Tweet* eachTweet in tweets) {
        
        if ([_selectedFilter isEqualToString:@"aye aye"])
            eachTweet.pictureOnly = true;
        else if ([_selectedFilter isEqualToString:@"linky loo"])
            eachTweet.linkOnly = true;
        
        if ([_selectedUser.nickname isEqualToString:_twitterSession.userName] == false)
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
    
    [_table loadData:_tableData];
}

- (void)fakeLoadTweets {
    NSMutableArray * tweetMut = [NSMutableArray new];
    for (int i = arc4random_uniform(100); i >= 0; i -=1) {
        [tweetMut addObject:[Tweet generateRandomTweet]];
    }
    NSArray* tweets = [NSArray arrayWithArray:tweetMut];
    
    [self loadTweets:tweets];
}


#pragma mark - Actions

- (IBAction)tapFilter {

    NSInteger indexOfCurrentObj = [_filters indexOfObject:_selectedFilter];
    [self showPickerForData:_filters selectedIndex:indexOfCurrentObj];
    __weak VCTwitterFeed* weakSelf = self;
    [_currentPickerAdapter setOnItemSelected:^(id item) {
        VCTwitterFeed* strongSelf = weakSelf;
        [strongSelf onFilterSelected:item];
    }];
}

- (IBAction)tapUser {
    
    NSInteger indexOfCurrentObj = [_users indexOfObject:_selectedUser];
    [self showPickerForData:_users selectedIndex:indexOfCurrentObj];
    
    __weak VCTwitterFeed* weakSelf = self;
    [_currentPickerAdapter setOnItemSelected:^(id item) {
        VCTwitterFeed* strongSelf = weakSelf;
        [strongSelf onUserSelected:item];
    }];
}

- (void)showPickerForData:(NSArray*)data selectedIndex:(NSInteger)index {
    bool pickerIsHidden = (self.filterBarPositionFromBottomConstraint.constant == 0);
    if (pickerIsHidden) {
        _currentPickerAdapter.data = data;
        [_pickerView reloadAllComponents];
        [_pickerView selectRow:index inComponent:0 animated:false];
        [self animateShowViewPickerCompletion:nil];
        return;
    }
    
    bool pickerIsShowingCurrentData = (_currentPickerAdapter.data == data);
    if (pickerIsShowingCurrentData) {
        [self animateHideViewPickerCompletion:nil];
        return;
    }
    
    _currentPickerAdapter.data = nil;
    [self animateHideViewPickerCompletion:^(BOOL finished) {
        _currentPickerAdapter.data = data;
        [_pickerView reloadAllComponents];
        [_pickerView selectRow:index inComponent:0 animated:false];
        [self animateShowViewPickerCompletion:nil];
    }];
}

- (void)onFilterSelected:(id) filter
{
    if (self.selectedFilter == filter)
        return;
    
    self.selectedFilter = filter;
    [self.filterButton setTitle:filter forState:UIControlStateNormal];
    [self updateAllTweets];
}

- (void)onUserSelected:(User*) user
{
    if (self.selectedUser == user)
        return;
    
    self.selectedUser = user;
    [self updateSelectedUserLabel:user];
    [self updateAllTweets];
}

- (void)updateSelectedUserLabel:(User*)user {
    NSString* userNameText = [user nickname];
    userNameText = [userNameText stringByAppendingString:@"'s"];
    [self.userButton setTitle:userNameText forState:UIControlStateNormal];
}

//TODO: Needed?
- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}

#pragma mark - View Picker
- (void)animateShowViewPickerCompletion:(void (^)(BOOL finished))completion
{
    if (self.onStartPickerShowAnimation)
        self.onStartPickerShowAnimation();
    
    self.filterBarPositionFromBottomConstraint.constant = self.pickerView.frame.size.height;
    [UIView animateWithDuration:0.33f animations:^{
        [self.view layoutIfNeeded];
    } completion:completion];
    
    [self.table addGestureRecognizer:self.tableTapGesture];
}

- (void)animateHideViewPickerCompletion:(void (^)(BOOL finished))completion {
    self.filterBarPositionFromBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.33f animations:^{
        [self.view layoutIfNeeded];
    } completion:completion];

    [self.table removeGestureRecognizer:self.tableTapGesture];
}

- (void)onTableTapped
{
    [self animateHideViewPickerCompletion:nil];
}

@end
