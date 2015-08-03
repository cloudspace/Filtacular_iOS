//
//  Tweet.m
//  Filtacular
//
//  Created by Isaac Paul on 6/1/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "Tweet.h"

#import "NSString+HtmlDecoding.h"
#import "NSDate+SimpleTimeAgo.h"
#import <TwitterKit/TwitterKit.h>

@implementation Tweet

@synthesize identifier;
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
@synthesize tweetId;
@synthesize media;

+ (RKObjectMapping*)objectMapping {
    RKObjectMapping *mapping = [super objectMapping];
    [mapping addAttributeMappingsFromArray:@[@"media"]];
    [mapping addAttributeMappingsFromDictionary:@{
        @"attributes.tweet-id"          :@"tweetId",
        @"attributes.url-image"         :@"urlImage",
        @"attributes.url-link"          :@"urlLink",
        @"attributes.tweet-created-at"  :@"tweetCreatedAt",
        @"attributes.retweet-count"     :@"retweetCount",
        @"attributes.favorites-count"   :@"favoriteCount",
        @"attributes.profile-image-url" :@"profilePicUrl",
        @"attributes.name"              :@"displayName",
        @"id"                           :@"identifier",
        @"attributes.screen-name"       :@"userName"
    }];
    
    //We want to map text, description, and title ourselves since its html encoded
    //We also trim whitespace
    //TODO: make category on RKObjectMapping
    RKAttributeMapping *textMapping = [self htmlEncodedMappingFromKeyPath:@"attributes.expanded-text" toKeyPath:@"text"];
    RKAttributeMapping *titleMapping = [self htmlEncodedMappingFromKeyPath:@"attributes.url-title" toKeyPath:@"urlTitle"];
    RKAttributeMapping *descMapping = [self htmlEncodedMappingFromKeyPath:@"attributes.url-description" toKeyPath:@"urlDescription"];
    
    [mapping addPropertyMapping:textMapping];
    [mapping addPropertyMapping:titleMapping];
    [mapping addPropertyMapping:descMapping];
    
    return mapping;
}

+ (RKAttributeMapping*)htmlEncodedMappingFromKeyPath:(NSString*)fromKey toKeyPath:(NSString*)toKey {
    RKValueTransformer *htmlEncodedTransformer = [RKBlockValueTransformer valueTransformerWithValidationBlock:^BOOL(__unsafe_unretained Class inputValueClass, __unsafe_unretained Class outputValueClass) {
        return [inputValueClass isSubclassOfClass:[NSString class]];
    } transformationBlock:^BOOL(id inputValue, __autoreleasing id *outputValue, __unsafe_unretained Class outputClass, NSError *__autoreleasing *error) {
        if ([inputValue isKindOfClass:[NSNull class]])
            return FALSE;
        
        *outputValue = [inputValue gtm_stringByUnescapingFromHTML];
        
        NSMutableString *trimWhiteSpace = [*outputValue mutableCopy];
        CFStringTrimWhitespace((__bridge CFMutableStringRef)trimWhiteSpace);
        
        *outputValue = [trimWhiteSpace copy];
        
        return YES;
    }];
    RKAttributeMapping *textMapping = [RKAttributeMapping attributeMappingFromKeyPath:fromKey toKeyPath:toKey];
    textMapping.valueTransformer = htmlEncodedTransformer;
    textMapping.propertyValueClass = [NSString class];
    return textMapping;
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

+ (NSArray*)removeDuplicates:(NSArray*)tweets {
    
    NSMutableArray* uniqueObjs = [NSMutableArray new];
    
    for (Tweet* eachTweet in tweets)
    {
        if ([uniqueObjs containsObject:eachTweet])
        {
            continue;
        }
        [uniqueObjs addObject:eachTweet];
    }
    
    return uniqueObjs;
}

- (TWTRTweet*)tweetWithTwitterId:(NSArray*)arrayOfTweets {
    for (TWTRTweet* eachTweet in arrayOfTweets) {
        if ([eachTweet.tweetID isEqualToString:self.tweetId] == false)
            continue;
        return eachTweet;
    }
    
    return nil;
}

- (void)configureWithTwitterTweet:(TWTRTweet*)twitterTweet {
    userName = twitterTweet.author.screenName;
    _retweeted = twitterTweet.isRetweeted;
    _favorited = twitterTweet.isFavorited;
}

- (NSString *)simpleTimeAgo {
    return [self.tweetCreatedAt timeAgoSimple];
}

- (NSString*)imageUrl {
    
    if (media.length > 5) {
        NSString* url = [media substringFromIndex:2];
        url = [url substringToIndex:url.length - 2];
        return url;
    }
    
    if (urlImage.length > 0)
        return urlImage;
    
    return nil;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:self.class] == false)
        return false;
    
    Tweet* other = object;
    
    if (urlLink.length > 0) {
        if ([urlLink isEqualToString:other.urlLink])
            return true; //The website version removes content that reuse the same link
    }
    
    if ([urlDescription isEqualToString:other.urlDescription] == false)
        return false;
    
    if ([urlTitle isEqualToString:other.urlTitle] == false)
        return false;
    
    if ([urlImage isEqualToString:other.urlImage] == false)
        return false;
    
    if ([media isEqualToString:other.media] == false)
        return false;
    
    if ([text isEqualToString:other.text] == false)
        return false;
    
    return true;
}

- (NSUInteger)hash {
    return [self identifier];
}

- (NSString*)displayLinkHost {
    
    return [Tweet formattedLinkHost:self.urlLink];
}

+ (NSString*)formattedLinkHost:(NSString*)linkHostString {
    NSString* host = [[NSURL URLWithString:linkHostString] host];
    
    if (host == nil)
        return nil;
    
    if (host.length >= 7 && [[[host substringToIndex:7] lowercaseString] isEqualToString:@"http://"])
        host = [host substringFromIndex:7];
    
    if (host.length >= 4 && [[[host substringToIndex:4] lowercaseString] isEqualToString:@"www."])
        host = [host substringFromIndex:4];
    
    
    host = [host uppercaseString];
    return host;
}

- (bool)isValidLinkyLooTweet {
    if (self.urlLink.length == 0)
        return false;
    
    if (self.urlTitle.length == 0)
        return false;
    
    if (self.urlImage.length == 0)
        return false;
    
    if (self.imageUrl.length == 0)
        return false;
    
    return true;
}

@end
