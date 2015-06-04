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
#import "UserPickerViewAdapter.h"
#import "FilterPickerViewAdapter.h"
#import "User.h"
#import "Filter.h"
#import "Selectable.h"


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
@property (strong, nonatomic) UserPickerViewAdapter* userPickerAdapter;
@property (strong, nonatomic) FilterPickerViewAdapter* filterPickerAdapter;

@property (assign, nonatomic) BOOL isPickerVisible;

@property (strong, nonatomic) User* selectedUser;
@property (strong, nonatomic) Filter* selectedFilter;

@property (copy, nonatomic) animationFinishBlock onPickerVisible;
@property (copy, nonatomic) animationFinishBlock onPickerHidden;

@property (copy, nonatomic) void(^onStartPickerShowAnimation)();

@end

@implementation VCTwitterFeed

- (void)viewDidLoad {
    
    [_table setNoItemText:@"There are no tweets."];
    [_table setTableViewCellClass:[TweetCell class]];
    [_table setSelectObjectBlock:^(Tweet* tweet) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"WIP" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
    self.userPickerAdapter = [[UserPickerViewAdapter alloc] init];
    self.filterPickerAdapter = [[FilterPickerViewAdapter alloc] init];
    [self updateTweets];
    
    self.isPickerVisible = NO;
}

- (void)updateTweets {
    [self performSelector:@selector(fakeLoadTweets) withObject:nil afterDelay:0.5f];
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
        
        [eachTweet setTappedLink:^{
            
        }];
        
        [eachTweet setTappedTweet:^{
            
        }];
        
        [eachTweet setTappedUser:^{
            
        }];
    }
    [_table loadData:tweets];
}


#pragma mark - Actions

- (IBAction)tapFilter {
    [self updateCurrentPicker:self.filterPickerAdapter :self.filters :^(id item){
        [self onFilterSelected:item];
    }];
    __weak typeof(self) weakSelf = self;
    self.onStartPickerShowAnimation = ^(){
        NSUInteger index = [weakSelf.filters indexOfObject: weakSelf.selectedFilter];
        if(index != NSNotFound)
            [weakSelf.pickerView selectRow:index inComponent:0 animated:NO];
    };
}

- (IBAction)tapUser {
    [self updateCurrentPicker:self.userPickerAdapter :self.users :^(id item){
        [self onUserSelected:item];
    }];
    
    __weak typeof(self) weakSelf = self;
    self.onStartPickerShowAnimation = ^(){
        NSUInteger index = [weakSelf.users indexOfObject: weakSelf.selectedUser];
        if(index != NSNotFound)
            [weakSelf.pickerView selectRow:index inComponent:0 animated:NO];
    };
}

- (void)onFilterSelected:(id) filter
{
    //TODO, filter tweets by selected filter
    self.selectedFilter = filter;
    [self.filterButton setTitle:[filter displayName] forState:UIControlStateNormal];
}

- (void)onUserSelected:(id) user
{
    //TODO, filter tweets by selected user
    self.selectedUser = user;
    [self.userButton setTitle:[user nickname] forState:UIControlStateNormal];
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}

#pragma mark - View Picker

- (void)updateCurrentPicker:(BasePickerViewAdapter*) to : (NSArray*) data :(itemSelectedBlock) block
{
    // Check if we are toggling visibility or switching to the other view picker
    BOOL isToggling = (!self.currentPickerAdapter || self.currentPickerAdapter == to) ? YES : NO;
    self.currentPickerAdapter = to;
    [self.currentPickerAdapter bind:self.pickerView :block];
    
    //Clear picker view content (or else we'll see cached picker view entries as we transition out)
    [self.currentPickerAdapter setData: nil];
    [self.pickerView reloadAllComponents];
    
    __weak typeof(self) weakSelf = self;
    if(isToggling){
        self.onPickerHidden = ^(BOOL finished) { weakSelf.isPickerVisible = NO; };
        [self.currentPickerAdapter setData: data];
        [self toggleViewPickerVisibility];
    } else{
        self.onPickerHidden = ^(BOOL finished){
            [weakSelf.currentPickerAdapter setData: data];
            [weakSelf.pickerView reloadAllComponents];      //redraws entries in picker view
            [weakSelf animateShowViewPicker];
        };
        [self animateHideViewPicker];
    }
}

- (void)toggleViewPickerVisibility
{
    if(!self.isPickerVisible){
        [self animateShowViewPicker];
    }else{
        [self animateHideViewPicker];
    }
}

- (void) animateShowViewPicker
{
    if(self.onStartPickerShowAnimation)
        self.onStartPickerShowAnimation();
    
    self.filterBarPositionFromBottomConstraint.constant = self.pickerView.frame.size.height;
    [UIView animateWithDuration:.25f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }completion:self.onPickerVisible];
    
    [self attachTableTapListener];
    
    self.isPickerVisible = YES;
}

- (void) animateHideViewPicker{
    self.filterBarPositionFromBottomConstraint.constant = 0;
    [UIView animateWithDuration:.25f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:self.onPickerHidden];

    [self detachTableTapListener];
}

- (void) onTableTapped
{
    self.onPickerHidden = nil;
    [self animateHideViewPicker];
}

- (void)attachTableTapListener
{
    self.tableTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTableTapped)];
    [self.table addGestureRecognizer:self.tableTapGesture];
}

- (void)detachTableTapListener
{
    [self.table removeGestureRecognizer:self.tableTapGesture];
}

@end
