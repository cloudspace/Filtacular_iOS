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

@interface VCTwitterFeed ()

@property (strong, nonatomic) NSArray* tableData;
@property (strong, nonatomic) IBOutlet CustomTableView* table;

@end

@implementation VCTwitterFeed

- (void)viewDidLoad {
    
    [_table setNoItemText:@"There are no tweets."];
    [_table setTableViewCellClass:[TweetCell class]];
    //__weak VCTwitterFeed* weakSelf = self;
    [_table setSelectObjectBlock:^(Tweet* tweet) {
        //VCTwitterFeed* strongSelf = weakSelf;
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"WIP" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
    
    [self updateTweets];
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

- (IBAction)tapFilter {
    
}

- (IBAction)tapUser {
    
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}

@end
