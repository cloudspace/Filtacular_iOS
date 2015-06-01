//
//  UIView+SwapWithView.m
//  Filtacular
//
//  Created by John Li on 6/1/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "UIView+SwapWithView.h"

@implementation UIView (SwapWithView)

- (void)swapWithView:(UIView*)view {
    
    CGRect storeFrame = self.frame;
    NSUInteger storeIndex = [self indexInSuperview];
    UIView* storeSuperview = self.superview;
    UIViewAutoresizing storeResizeMask = self.autoresizingMask;
    
    self.frame = view.frame;
    [view.superview insertSubview:self aboveSubview:view];
    self.autoresizingMask = view.autoresizingMask;
    
    view.frame = storeFrame;
    [storeSuperview insertSubview:view atIndex:storeIndex];
    view.autoresizingMask = storeResizeMask;
}

- (NSUInteger)indexInSuperview {
    for (NSUInteger i = 0; i < self.superview.subviews.count; i += 1)
    {
        UIView* view = self.superview.subviews[i];
        if (view != self)
            continue;
        return i;
    }
    return 0;
}

@end
