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
@property (nonatomic, strong) NSDate* postDate;
@property (nonatomic, strong) NSString* linkUrl;
@property (nonatomic, assign) int retweetCount;
@property (nonatomic, assign) int favoriteCount;
@property (nonatomic, assign) int identifier;

+ (Tweet*)generateRandomTweet;

@end
