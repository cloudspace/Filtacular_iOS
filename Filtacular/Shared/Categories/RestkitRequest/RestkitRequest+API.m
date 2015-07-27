//
//  RestkitRequest+API.m
//  Filtacular
//
//  Created by Isaac Paul on 7/27/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "RestkitRequest+API.h"

@implementation RestkitRequest (API)

+ (RestkitRequest*)grabFiltersRequest {
    RestkitRequest* request = [RestkitRequest new];
    request.requestMethod = RKRequestMethodGET;
    request.path = @"/lenses";
    request.noMappingRequired = true;
    return request;
}

+ (RestkitRequest*)cookiesRequestToken:(NSString*)token secret:(NSString*)secret {
    RestkitRequest* request = [RestkitRequest new];
    request.requestMethod = RKRequestMethodGET;
    request.path = @"/auth/twitter_access_token/callback";
    request.noMappingRequired = true;
    request.parameters = @{@"token":token, @"token_secret":secret};
    request.customHeaders = @{};
    return request;
}

+ (RestkitRequest*)retweetRequest:(NSString*)tweetId {
    RestkitRequest* request = [RestkitRequest new];
    request.requestMethod = RKRequestMethodGET;
    request.path = @"/retweet";
    request.parameters = @{@"tweet_id":tweetId};
    request.noMappingRequired = true;
    return request;
}

+ (RestkitRequest*)favoriteRequest:(NSString*)tweetId {
    RestkitRequest* request = [RestkitRequest new];
    request.requestMethod = RKRequestMethodGET;
    request.path = @"/favorite";
    request.parameters = @{@"tweet_id":tweetId};
    request.noMappingRequired = true;
    return request;
}

+ (RestkitRequest*)followRequest:(NSString*)userName {
    RestkitRequest* request = [RestkitRequest new];
    request.requestMethod = RKRequestMethodGET;
    request.path = @"/follow";
    request.parameters = @{@"screen_name":userName};
    request.noMappingRequired = true;
    return request;
}

+ (RestkitRequest*)tweetListRequest:(NSString*)userId filters:(NSDictionary*)filters page:(int)page pageSize:(int)pageSize  {
    RestkitRequest* request = [RestkitRequest new];
    request.requestMethod = RKRequestMethodGET;
    request.path = [NSString stringWithFormat:@"/twitter-users/%@/tweets", userId];
    request.parameters = @{@"filter":filters, @"page":@{@"number":@(page), @"size":@(pageSize)}};
    return request;
}

@end
