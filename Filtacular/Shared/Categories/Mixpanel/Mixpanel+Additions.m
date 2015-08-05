//
//  Mixpanel+Additions.m
//  Filtacular
//
//  Created by Isaac Paul on 8/5/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "Mixpanel+Additions.h"

#import <TwitterKit/TwitterKit.h>

@implementation Mixpanel (Additions)

- (void)initializeUser:(TWTRSession*)session {
    [[Mixpanel sharedInstance] identify:[session userID]];
    [[Mixpanel sharedInstance].people setOnce:@{@"$name":session.userName}];
}

@end
