//
//  PageLoadingCell.m
//  Filtacular
//
//  Created by Isaac Paul on 6/19/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "PageLoadingCell.h"
#import "LoadingCallBack.h"

@implementation PageLoadingCell

- (void)configureWithObject:(LoadingCallBack*)callBack {
    if (callBack.isShown)
        callBack.isShown();
}

- (CGFloat)calculateHeightWith:(LoadingCallBack*)callback {
    return self.frame.size.height;
}

@end
