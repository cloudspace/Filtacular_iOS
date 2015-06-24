//
//  IntroViewController.h
//  Filtacular
//
//  Created by John Li on 6/1/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TWTRSession;
@class RKObjectRequestOperation;
@class VCTwitterFeed;

@interface IntroViewController : UIViewController

+ (IntroViewController*)build;

+ (void)loginToFiltacular:(TWTRSession*)twitterSession failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failureBlock success:(void (^)(VCTwitterFeed *vcTwitterFeed))successBlock;

@end
