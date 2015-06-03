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
    [_table loadData:tweets];
}

- (IBAction)tapFilter {

}

- (IBAction)tapUser {
    [self updateCurrentPicker: self.userPickerAdapter];
    [self toggleViewPicker];
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}

-(NSArray*) getTestUsers
{
    User* testOne = [User createEntity];
    testOne.nickname = @"The best";
    
    User* testTwo = [User createEntity];
    testTwo.nickname = @"The Second best";
    
    User* testThree = [User createEntity];
    testThree.nickname = @"The Third best";
    return @[testOne, testTwo, testThree];
}

-(void) updateCurrentPicker: (BasePickerViewAdapter*) newPickerAdapter
{
    self.currentPickerAdapter = newPickerAdapter;
    [self.currentPickerAdapter bind: self.pickerView];
    [self.currentPickerAdapter setData: [self getTestUsers]];
}

-(void) toggleViewPicker
{
    self.filterBarPositionFromBottomConstraint.constant = 162;
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
