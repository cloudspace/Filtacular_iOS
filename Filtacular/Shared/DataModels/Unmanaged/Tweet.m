//
//  Tweet.m
//  Filtacular
//
//  Created by Isaac Paul on 6/1/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

@synthesize displayName;
@synthesize userName;
@synthesize profilePicUrl;
@synthesize postDate;
@synthesize linkUrl;
@synthesize retweetCount;
@synthesize favoriteCount;

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping *mapping = [super objectMapping];
    [mapping addAttributeMappingsFromArray:@[@"displayName", @"userName", @"displayName", @"profilePicUrl", @"postDate", @"linkUrl", @"retweetCount", @"favoriteCount"]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"identifier"}];
    
    return mapping;
}

static const int cNumRandoms = 3;
static NSArray* sDisplayNames = nil;
static NSArray* sUserNames = nil;
static NSArray* sProfilePicUrls = nil;
static NSArray* sPostDates = nil;
static NSArray* sLinkUrls = nil;

static int cRetweetCounts[cNumRandoms] = { 0, 2, 500 };
static int cFavoriteCounts[cNumRandoms] = { 0, 6, 200 };


+ (void)load {
    sDisplayNames = @[@"Bill", @"Jane", @"Joe"];
    sUserNames = @[@"YouJobEi", @"MilkyWookee", @"KicksAndGiggles"];
    sProfilePicUrls = @[@"http://pbs.twimg.com/profile_images/458940244847374336/ITrc9uEy_normal.jpeg", @"http://pbs.twimg.com/profile_images/458940244847374336/ITrc9uEy_normal.jpeg", @"https://abs.twimg.com/sticky/default_profile_images/default_profile_3_400x400.png"];
    sPostDates = @[[self randomDateInYearOfDate], [self randomDateInYearOfDate], [self randomDateInYearOfDate]];
    sLinkUrls = @[@"http://google.com", @"http://bing.com", @"http://yahoo.com"];
}

+ (NSDate *)randomDateInYearOfDate {
    NSDate* date = [NSDate date];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    [comps setMonth:arc4random_uniform(3)];
    
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[currentCalendar dateFromComponents:comps]];
    
    [comps setDay:(unsigned int)arc4random_uniform((u_int32_t)range.length)];
    
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    [comps setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    return [currentCalendar dateFromComponents:comps];
}

+ (Tweet*)generateRandomTweet {
    Tweet* newTweet = [Tweet new];
    
    newTweet.displayName = sDisplayNames[arc4random_uniform(3)];
    newTweet.userName = sUserNames[arc4random_uniform(3)];
    newTweet.profilePicUrl = sProfilePicUrls[arc4random_uniform(3)];
    newTweet.postDate = sPostDates[arc4random_uniform(3)];
    newTweet.linkUrl = sLinkUrls[arc4random_uniform(3)];
    newTweet.retweetCount = cRetweetCounts[arc4random_uniform(3)];
    newTweet.favoriteCount = cFavoriteCounts[arc4random_uniform(3)];
    
    return newTweet;
}

@end
