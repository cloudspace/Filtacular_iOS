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
@synthesize tweetCreatedAt;
@synthesize urlLink;
@synthesize urlDescription;
@synthesize urlTitle;
@synthesize urlImage;
@synthesize text;
@synthesize retweetCount;
@synthesize favoriteCount;
@synthesize pictureOnly;

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping *mapping = [super objectMapping];
    [mapping addAttributeMappingsFromArray:@[@"displayName", @"userName", @"text", @"profilePicUrl", @"pictureOnly"]];
    [mapping addAttributeMappingsFromDictionary:@{@"tweet_id": @"tweetId", @"url_description": @"urlDescription", @"url_title": @"urlTitle", @"url_image":@"urlImage", @"url_link": @"urlLink", @"tweetCreatedAt": @"tweet_created_at", @"retweet_count":@"retweetCount", @"favorites_count":@"favoriteCount"}];
    
    return mapping;
}

static const int cNumRandoms = 3;
static NSArray* sDisplayNames = nil;
static NSArray* sUserNames = nil;
static NSArray* sProfilePicUrls = nil;
static NSArray* sPostDates = nil;
static NSArray* sLinkUrls = nil;
static NSArray* sUrlTitles = nil;
static NSArray* sUrlDescriptions = nil;
static NSArray* sUrlImages = nil;
static NSArray* sTexts = nil;

static int cRetweetCounts[cNumRandoms] = { 0, 2, 500 };
static int cFavoriteCounts[cNumRandoms] = { 0, 6, 200 };


+ (void)load {
    sDisplayNames = @[@"Billaedjaskjldsjalakj", @"Jane", @"Joe"];
    sUserNames = @[@"@YouJobEi", @"@MilkyWookee", @"@KicksAndGiggles"];
    sProfilePicUrls = @[@"http://pbs.twimg.com/profile_images/458940244847374336/ITrc9uEy_normal.jpeg", @"https://lh3.googleusercontent.com/-ZadaXoUTBfs/AAAAAAAAAAI/AAAAAAAAAAA/3rh5IMTHOzg/photo.jpg", @"https://abs.twimg.com/sticky/default_profile_images/default_profile_3_400x400.png"];
    sPostDates = @[[self randomDateInYearOfDate], [self randomDateInYearOfDate], [self randomDateInYearOfDate]];
    sLinkUrls = @[@"http://google.com", @"http://bing.com", @"http://yahoo.com", @"", @""];
    sUrlImages = @[@"http://pbs.twimg.com/media/CGbL81WWoAAHDuY.jpg:small", @"http://pbs.twimg.com/media/CGfZJSlUgAEtQt9.jpg:small", @"http://pbs.twimg.com/media/CGfYREFVAAAH21c.jpg:small", @"", @""];
    sTexts = @[@"XCOM 2 has been announced. It's PC exclusive, and will feature official modding support. Fill Fill Yo Yo laka laka laka. I need twenty more.", @"I am a short tweet🔥🔥.", @"I am a bit longer of a tweet and may take 2 lines."];
    sUrlTitles = @[@"XCOM 2 has been announced", @"I am Short Title", @"Url Title Yo"];
    sUrlDescriptions = @[@"XCOM 2 has been announced.", @"Fill Fill Yo Yo laka laka laka.", @"I am a short description."];
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
    newTweet.tweetCreatedAt = sPostDates[arc4random_uniform(3)];
    newTweet.urlLink = sLinkUrls[arc4random_uniform(5)];
    newTweet.urlTitle = sUrlTitles[arc4random_uniform(3)];
    newTweet.urlDescription = sUrlDescriptions[arc4random_uniform(3)];
    newTweet.urlImage = sUrlImages[arc4random_uniform(5)];
    newTweet.retweetCount = cRetweetCounts[arc4random_uniform(3)];
    newTweet.favoriteCount = cFavoriteCounts[arc4random_uniform(3)];
    newTweet.text = sTexts[arc4random_uniform(3)];
    if (newTweet.urlImage.length > 0)
        newTweet.pictureOnly = (arc4random_uniform(2) == 1);
    
    return newTweet;
}

- (NSString *)simpleTimeAgo {
    return [Tweet timeAgoSimple:self.tweetCreatedAt];
}

+ (NSString *)timeAgoSimple:(NSDate*)date
{
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([date timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    int value = 0;
    NSString* abbr = @"yr";
    
    if(deltaSeconds < 60)
    {
        abbr = @"s";
        value = deltaSeconds;
    }
    else if (deltaMinutes < 60)
    {
        abbr = @"m";
        value = deltaMinutes;
    }
    else if (deltaMinutes < (24 * 60))
    {
        value = (int)floor(deltaMinutes/60);
        abbr = @"h";
    }
    else if (deltaMinutes < (24 * 60 * 7))
    {
        value = (int)floor(deltaMinutes/(60 * 24));
        abbr = @"d";
    }
    else if (deltaMinutes < (24 * 60 * 31))
    {
        value = (int)floor(deltaMinutes/(60 * 24 * 7));
        abbr = @"w";
    }
    else if (deltaMinutes < (24 * 60 * 365.25))
    {
        value = (int)floor(deltaMinutes/(60 * 24 * 30));
        abbr = @"mo";
    }
    else {
        value = (int)floor(deltaMinutes/(60 * 24 * 365));
        abbr = @"mo";
    }
    return [NSString stringWithFormat:@"%d %@", value, abbr];
}

@end
