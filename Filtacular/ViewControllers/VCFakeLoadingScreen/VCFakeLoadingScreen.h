//
//  VCFakeLoadingScreen.h
//  Filtacular
//
//  Created by Isaac Paul on 6/24/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TWTRSession;

@interface VCFakeLoadingScreen : UIViewController

+ (VCFakeLoadingScreen*)buildWithSession:(TWTRSession*)session;

@end
