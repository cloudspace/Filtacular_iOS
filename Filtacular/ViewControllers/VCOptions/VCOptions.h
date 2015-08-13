//
//  VCOptions.h
//  Filtacular
//
//  Created by Isaac Paul on 8/12/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@class VCTwitterFeed;

@interface VCOptions : UIViewController

@property (strong, nonatomic) NSArray* users;
@property (strong, nonatomic) NSArray* filters;
@property (strong, nonatomic) User* selectedUser;
@property (strong, nonatomic) NSString* selectedFilter;

@property (weak, nonatomic) VCTwitterFeed* twitterFeed;

@end
