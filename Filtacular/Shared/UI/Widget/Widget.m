//
//  Widget.m
//  Filtacular
//
//  Created by Isaac Paul on 5/16/14.
//  Copyright (c) 2014 NA. All rights reserved.
//

#import "Widget.h"
#import "UIView+Positioning.h"

@interface Widget ()

@property (strong, nonatomic, readwrite) UIView* view;

@end

@implementation Widget

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return self;

    [self awakeFromNib];
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (self.view != nil)
        return;
    
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    
    if (self.view == nil)
    {
        NSLog(@"WARNING VIEW NOT SET ON WIDGET: %@!!!", NSStringFromClass([self class]));
        return;
    }
    
    [self fitUIIfNecessary];
    
    [self addSubview:self.view];
}

- (void)fitUIIfNecessary {
    [self fitWidthWithContentIfNecessary];
    [self fitHeightWithContentIfNecessary];
}

- (void)fitWidthWithContentIfNecessary {
    bool flexableWidth = (self.view.autoresizingMask | UIViewAutoresizingFlexibleWidth);
    
    if (flexableWidth)
        self.view.width = self.width;
}

- (void)fitHeightWithContentIfNecessary {
    bool flexableHeight = (self.view.autoresizingMask | UIViewAutoresizingFlexibleHeight);
    
    if (flexableHeight)
        self.view.height = self.height;
}

@end
