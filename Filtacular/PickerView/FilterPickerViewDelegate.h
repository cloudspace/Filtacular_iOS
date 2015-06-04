//
//  FilterPickerViewDelegate.h
//  Filtacular
//
//  Created by John Li on 6/4/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "BasePickerViewAdapter.h"
#import "Selectable.h"
#import "Reloadable.h"

@interface FilterPickerViewDelegate : NSObject <UIPickerViewDelegate, Reloadable, Selectable>

@property (nonatomic, copy) itemSelectedBlock onItemSelected;

-(void) reload : (NSArray*) data;

@end
