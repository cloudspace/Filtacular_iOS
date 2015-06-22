//
//  NSDate+SimpleTimeAgo.m
//  Filtacular
//
//  Created by Isaac Paul on 6/5/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "NSDate+SimpleTimeAgo.h"

@implementation NSDate (SimpleTimeAgo)

- (NSString *)timeAgoSimple;
{
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([self timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;
    
    int value = 0;
    NSString* abbr;
    
    if (deltaSeconds < 60)
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
        abbr = @"yr";
    }
    return [NSString stringWithFormat:@"%d %@", value, abbr];
}

@end
