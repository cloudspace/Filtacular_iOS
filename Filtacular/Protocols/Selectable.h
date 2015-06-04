//
//  Selectable.h
//  Filtacular
//
//  Created by John Li on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Selectable <NSObject>

typedef void (^itemSelectedBlock)(id item);

@property (nonatomic, copy) itemSelectedBlock onItemSelected;

@end
