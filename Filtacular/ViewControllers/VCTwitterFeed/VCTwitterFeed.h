//
//  VCTwitterFeed.h
//  Filtacular
//
//  Created by Isaac Paul on 6/1/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TWTRSession;
@class User;

@interface VCTwitterFeed : UIViewController

@property (strong, nonatomic) NSString* currentUsersName;

@property (strong, nonatomic) User* selectedUser;
@property (strong, nonatomic) NSString* selectedFilter;

- (void)showUser:(User*)user;
- (void)showFilter:(NSString*)filter;

@end
