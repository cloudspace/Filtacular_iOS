//
//  Tweet.h
//  Filtacular
//
//  Created by Isaac Paul on 6/1/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "BaseUnmanagedModel.h"

@interface Tweet : BaseUnmanagedModel

@property (nonatomic, strong) NSString* displayName;
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* profilePicUrl;
@property (nonatomic, strong) NSDate* tweetCreatedAt;
@property (nonatomic, strong) NSString* urlLink;
@property (nonatomic, strong) NSString* urlDescription;
@property (nonatomic, strong) NSString* urlTitle;
@property (nonatomic, strong) NSString* urlImage;
@property (nonatomic, strong) NSString* text;
@property (nonatomic, assign) int retweetCount;
@property (nonatomic, assign) int favoriteCount;
@property (nonatomic, assign) int tweetId;

+ (Tweet*)generateRandomTweet;

@end