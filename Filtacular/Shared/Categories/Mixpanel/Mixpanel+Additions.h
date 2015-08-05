//
//  Mixpanel+Additions.h
//  Filtacular
//
//  Created by Isaac Paul on 8/5/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <Mixpanel.h>

@class TWTRSession;

@interface Mixpanel (Additions)

- (void)initializeUser:(TWTRSession*)session;

@end
