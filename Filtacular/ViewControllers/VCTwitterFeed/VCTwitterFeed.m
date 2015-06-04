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
#import "User.h"
#import "Selectable.h"

@interface VCTwitterFeed ()
@property (strong, nonatomic) IBOutlet CustomTableView* table;
@property (strong, nonatomic) IBOutlet UIPickerView* pickerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint* filterBarPositionFromBottomConstraint;

@property (strong, nonatomic) NSArray* tableData;

@property (strong, nonatomic) BasePickerViewAdapter* currentPickerAdapter;
@property (strong, nonatomic) UserPickerViewAdapter* userPickerAdapter;

@property (assign, nonatomic) BOOL isPickerVisible;

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

- (IBAction)tapFilter {

}

- (IBAction)tapUser {
    [self updateCurrentPicker: self.userPickerAdapter :^(id item){
        [self onUserSelected:item];
    }];
    [self toggleViewPicker];
}

- (void)onUserSelected:(id) user
{
    NSLog(@"Selected: %@", [user nickname]);
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}

- (void)updateCurrentPicker:(BasePickerViewAdapter*) newPickerAdapter : (itemSelectedBlock) block
{
    self.currentPickerAdapter = newPickerAdapter;
    [self.currentPickerAdapter bind: self.pickerView :block];
    [self.currentPickerAdapter setData: self.users];
}

- (void)toggleViewPicker
{
    self.filterBarPositionFromBottomConstraint.constant = self.pickerView.frame.size.height;
    if(!self.isPickerVisible){
        [UIView animateWithDuration:.25f
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
        self.isPickerVisible = YES;
    }else{
        self.filterBarPositionFromBottomConstraint.constant = 0;
        [UIView animateWithDuration:.25f
                         animations:^{
                             [self.view layoutIfNeeded];
                         }];
        self.isPickerVisible = NO;
    }
}

@end
