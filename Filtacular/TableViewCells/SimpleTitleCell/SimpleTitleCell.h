//
//  SimpleTitleCell.h
//  Filtacular
//
//  Created by Isaac Paul on 8/13/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigurableViewProtocol.h"

@interface TitleObject : NSObject

@property (strong, nonatomic) NSString* title;
@property (assign, nonatomic) BOOL isBold;

@property (strong, nonatomic) NSObject* associatedObj;

@end

@interface SimpleTitleCell : UITableViewCell <ConfigurableView>

@end
