//
//  Tweet.h
//  Filtacular
//
//  Created by Isaac Paul on 6/1/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "BaseUnmanagedModel.h"

@class TWTRTweet;

@interface Tweet : BaseUnmanagedModel

@property (nonatomic, strong) NSString* displayName;
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* profilePicUrl;
@property (nonatomic, strong) NSDate* tweetCreatedAt;
@property (nonatomic, strong) NSString* urlLink;
@property (nonatomic, strong) NSString* urlDescription;
@property (nonatomic, strong) NSString* urlTitle;
@property (nonatomic, strong) NSString* urlImage;
@property (nonatomic, strong) NSString* media;
@property (nonatomic, strong) NSString* text;
@property (nonatomic, assign) long long retweetCount;
@property (nonatomic, assign) long long favoriteCount;
@property (nonatomic, assign) NSString* tweetId;
@property (nonatomic, assign) int identifier;

@property (nonatomic, assign) bool pictureOnly;//big picture mode
@property (nonatomic, assign) bool retweeted;
@property (nonatomic, assign) bool favorited;

@property (nonatomic, assign) bool bigPicOpenedCache;
@property (nonatomic, copy) void (^tappedBigPic) ();
@property (nonatomic, copy) void (^tappedLink) ();
@property (nonatomic, copy) void (^tappedUser) ();
@property (nonatomic, copy) void (^tappedTweet) ();

+ (Tweet*)generateRandomTweet;

- (NSString *)simpleTimeAgo;

- (TWTRTweet*)tweetWithTwitterId:(NSArray*)arrayOfTweets;

- (void)configureWithTwitterTweet:(TWTRTweet*)twitterTweet;

@end
