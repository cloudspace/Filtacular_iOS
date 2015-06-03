//
//  Filter.m
//  Filtacular
//
//  Created by Isaac Paul on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "Filter.h"

@implementation Filter

+ (NSArray*)pseudoFilters {
    Filter* filter1 = [Filter new];
    filter1.displayName = @"sassypants";
    
    Filter* filter2 = [Filter new];
    filter2.displayName = @"aye aye";
    
    Filter* filter3 = [Filter new];
    filter3.displayName = @"small talk";
    
    return @[filter1, filter2, filter3];
}

@end
