//
//  VCFilters.h
//  Filtacular
//
//  Created by Isaac Paul on 8/17/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VCTwitterFeed;

@interface VCFilters : UIViewController

@property (strong, nonatomic) NSArray* filters;
@property (strong, nonatomic) NSString* selectedFilter;

@property (weak, nonatomic) VCTwitterFeed* twitterFeed;

@end
