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

@end

@implementation VCTwitterFeed

- (void)viewDidLoad {
    
    [_table setNoItemText:@"There are no tweets."];
    [_table setTableViewCellClass:[TweetCell class]];
    [_table setSelectObjectBlock:nil];
    
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
}

- (IBAction)tapUser {
    [self updateCurrentPicker:self.userPickerAdapter :self.users :^(id item){
        [self onUserSelected:item];
    }];
}

- (void)onFilterSelected:(id) filter
{
    //TODO, filter tweets by selected filter
    [self.filterButton setTitle:[filter displayName] forState:UIControlStateNormal];
    NSLog(@"Selected: %@", [filter displayName]);
}

- (void)onUserSelected:(id) user
{
    //TODO, filter tweets by selected user
    [self.userButton setTitle:[user nickname] forState:UIControlStateNormal];
    NSLog(@"Selected: %@", [user nickname]);
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
    
    if(isToggling){
        [self.currentPickerAdapter setData: data];
        [self toggleViewPickerVisibility];
    } else{
        [self animateHideViewPicker:^(BOOL finished){
            [self.currentPickerAdapter setData: data];
            [self.pickerView reloadAllComponents];      //redraws entries in picker view
            [self animateShowViewPicker];
        }];
    }
}

- (void)toggleViewPickerVisibility
{
    if(!self.isPickerVisible){
        [self animateShowViewPicker];
    }else{
        [self animateHideViewPicker: nil];
    }
}

- (void) animateShowViewPicker
{
    self.filterBarPositionFromBottomConstraint.constant = self.pickerView.frame.size.height;
    [UIView animateWithDuration:.25f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }];
    self.isPickerVisible = YES;
    [self attachTableTapListener];
}

- (void) animateHideViewPicker
{
    [self animateHideViewPicker:nil];
}

- (void) animateHideViewPicker: (void (^)(BOOL finished)) onHidden
{
    self.filterBarPositionFromBottomConstraint.constant = 0;
    [UIView animateWithDuration:.25f
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:onHidden];

    self.isPickerVisible = NO;
    [self detachTableTapListener];
}

- (void)attachTableTapListener
{
    self.tableTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateHideViewPicker)];
    [self.table addGestureRecognizer:self.tableTapGesture];
}

- (void)detachTableTapListener
{
    [self.table removeGestureRecognizer:self.tableTapGesture];
}


@end
