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
#import "TweetCell.h"
#import "User.h"
#import "BasePickerViewAdapter.h"
#import "ServerWrapper.h"

#import <TwitterKit/TwitterKit.h>

typedef void (^animationFinishBlock)(BOOL finished);

@interface VCTwitterFeed ()

@property (strong, nonatomic) IBOutlet CustomTableView* table;
@property (strong, nonatomic) IBOutlet UIPickerView* pickerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* filterBarPositionFromBottomConstraint;
@property (strong, nonatomic) IBOutlet UIButton* userButton;
@property (strong, nonatomic) IBOutlet UIButton* filterButton;

@property (strong, nonatomic) UITapGestureRecognizer* tableTapGesture;

@property (strong, nonatomic) NSArray* tableData;

@property (strong, nonatomic) BasePickerViewAdapter* currentPickerAdapter;

@property (copy, nonatomic) animationFinishBlock onPickerVisible;
@property (copy, nonatomic) animationFinishBlock onPickerHidden;

@property (copy, nonatomic) void(^onStartPickerShowAnimation)();

@property (strong, nonatomic) NSOperationQueue* twitterUpdateQueue;

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
    [_table setTableViewCellClass:[TweetCell class]];
    [_table setSelectObjectBlock:nil];
    
    [self updateTweets];
}

- (void)updateTweets {
    [_twitterUpdateQueue cancelAllOperations];
    [[ServerWrapper sharedInstance] cancelAllRequestOperationsWithMethod:RKRequestMethodGET matchingPathPattern:@"/twitter-users/:userId/tweets"];
    
    [_table clearAndWaitForNewData];
    NSBlockOperation* twitterUpdater = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation* twitterBlockOp = twitterUpdater;
    [twitterUpdater addExecutionBlock:^{
        if (twitterBlockOp.cancelled)
            return;
        
        RestkitRequest* request = [RestkitRequest new];
        request.requestMethod = RKRequestMethodGET;
        request.path = [NSString stringWithFormat:@"/twitter-users/%@/tweets", _selectedUser.userId];;
        request.parameters = @{@"filter":@{_selectedFilter: @(1)}};
        
        RestkitRequestReponse* response = [[ServerWrapper sharedInstance] performSyncRequest:request];
        if (response.successful == false) {
            //TODO
            return;
        }
        
        if (twitterBlockOp.cancelled)
            return;
        
        NSArray* filtacularTweets = response.mappingResult.array;
        NSMutableArray* tweetIds = [[NSMutableArray alloc] initWithCapacity:filtacularTweets.count];
        for (Tweet* eachTweet in filtacularTweets) {
            [tweetIds addObject:eachTweet.tweetId];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (twitterBlockOp.cancelled)
                return;
            [[[Twitter sharedInstance] APIClient] loadTweetsWithIDs:tweetIds completion:^(NSArray *tweets,  NSError *error) {
                
                if (twitterBlockOp.cancelled)
                    return;
                
                for (Tweet* eachTweet in filtacularTweets) {
                    TWTRTweet* twitterTweet = [eachTweet tweetWithTwitterId:tweets];
                    if (twitterTweet == nil)
                        continue;
                    
                    [eachTweet configureWithTwitterTweet:twitterTweet];
                }
                
                
                [_table loadData:filtacularTweets];
                
            }];
        });
    }];
    
    [_twitterUpdateQueue addOperation:twitterUpdater];
}

- (void)fakeLoadTweets {
    NSMutableArray * tweetMut = [NSMutableArray new];
    for (int i = arc4random_uniform(100); i >= 0; i -=1) {
        [tweetMut addObject:[Tweet generateRandomTweet]];
    }
    
    NSArray* tweets = [NSArray arrayWithArray:tweetMut];
    self.tableData = [tweets sortedArrayUsingComparator:^NSComparisonResult(Tweet* obj1, Tweet* obj2) {
        return [obj2.tweetCreatedAt compare:obj1.tweetCreatedAt];
    }];
    
    __weak VCTwitterFeed* weakSelf = self;
    for (__weak Tweet* eachTweet in tweets) {
        
        [eachTweet setTappedBigPic:^{
            Tweet* strongTweet = eachTweet;
            strongTweet.bigPicOpenedCache = !strongTweet.bigPicOpenedCache;
            
            VCTwitterFeed* strongSelf = weakSelf;
            [strongSelf.table cellHeightChanged];
        }];
        
    }
    [_table loadData:tweets];
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
    [self updateTweets];
}

- (void)onUserSelected:(id) user
{
    if (self.selectedUser == user)
        return;
    
    self.selectedUser = user;
    [self.userButton setTitle:[user nickname] forState:UIControlStateNormal];
    [self updateTweets];
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
