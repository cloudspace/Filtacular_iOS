//
//  SimpleTitleCell.m
//  Filtacular
//
//  Created by Isaac Paul on 8/13/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "SimpleTitleCell.h"
#import "User.h"

#import "UIView+Positioning.h"

@interface SimpleTitleCell ()
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation SimpleTitleCell

- (void)configureWithObject:(NSString*)title {
    
    if ([title isKindOfClass:[User class]]) //TODO: Hack
        title = [(User*)title stringForPicker];
    [_lblTitle setText:title];
}

- (CGFloat)calculateHeightWith:(id)object {
    self.width = [[UIScreen mainScreen] bounds].size.width;
    [self layoutIfNeeded];
    return self.height;
}

@end
