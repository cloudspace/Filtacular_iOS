//
//  RestkitRequest+API.h
//  Filtacular
//
//  Created by Isaac Paul on 7/27/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "RestkitRequest.h"

@interface RestkitRequest (API)

+ (RestkitRequest*)grabFiltersRequest;

+ (RestkitRequest*)cookiesRequestToken:(NSString*)token secret:(NSString*)secret;

+ (RestkitRequest*)retweetRequest:(NSString*)tweetId;

+ (RestkitRequest*)favoriteRequest:(NSString*)tweetId;

+ (RestkitRequest*)followRequest:(NSString*)userName;

+ (RestkitRequest*)tweetListRequest:(NSString*)userId filters:(NSDictionary*)filters page:(int)page pageSize:(int)pageSize;

@end
