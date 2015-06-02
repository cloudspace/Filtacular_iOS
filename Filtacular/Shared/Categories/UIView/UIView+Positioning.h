//
//  UIView+Positioning.h
//  IsaacsIOSLibrary
//
//  Created by IsaacPaul on 10/29/13.
//  Copyright (c) 2013 Isaac Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Positioning)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize  size;
@property (nonatomic, assign) CGPoint origin;

- (void)cropForVisibleSubviews;

- (void)centerSubviewsVerticallyWithPadding:(CGFloat)padding;

- (void)evenlySpaceSubviewsHorizontally;

- (void)alignViewsToTheLeft:(CGFloat)padding;

@end
