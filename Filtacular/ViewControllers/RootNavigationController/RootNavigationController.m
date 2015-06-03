//
//  RootNavigationController.m
//  Filtacular
//
//  Created by Isaac Paul on 6/2/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "RootNavigationController.h"

@interface RootNavigationController ()

@end

@implementation RootNavigationController

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeNone;
}

- (BOOL)extendedLayoutIncludesOpaqueBars {
    return false;
}

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return false;
}

@end
