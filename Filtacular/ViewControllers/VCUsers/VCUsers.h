//
//  VCUsers.h
//  Filtacular
//
//  Created by Isaac Paul on 8/17/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@class VCTwitterFeed;

@interface VCUsers : UIViewController

@property (strong, nonatomic) NSArray* users;
@property (strong, nonatomic) User* selectedUser;

@property (weak, nonatomic) VCTwitterFeed* twitterFeed;

@end
