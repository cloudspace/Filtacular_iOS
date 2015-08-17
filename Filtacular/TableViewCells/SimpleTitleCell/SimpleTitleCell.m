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

@implementation TitleObject

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:self.class] == false)
        return false;
    
    TitleObject* other = (TitleObject*)object;
    
    if ([_title isEqual:other.title] == false)
        return false;
    
    if (_isBold != other.isBold)
        return false;
    
    if ([_associatedObj isEqual:other.associatedObj] == false)
        return false;
    
    return true;
}

- (NSUInteger)hash {
    if (_associatedObj)
        return [_associatedObj hash];
    
    return [_title hash];
}

@end

@interface SimpleTitleCell ()
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation SimpleTitleCell

- (void)configureWithObject:(TitleObject*)title {
    
    NSString* text = title.title;
    if ([text isKindOfClass:[User class]]) //TODO: Hack
        text = [(User*)text stringForPicker];
    [_lblTitle setText:text];
    
    UIFont* font = [UIFont systemFontOfSize:_lblTitle.font.pointSize];
    if (title.isBold)
        font = [UIFont boldSystemFontOfSize:_lblTitle.font.pointSize];
    [_lblTitle setFont:font];
}

- (CGFloat)calculateHeightWith:(id)object {
    self.width = [[UIScreen mainScreen] bounds].size.width;
    [self layoutIfNeeded];
    return self.height;
}

@end
