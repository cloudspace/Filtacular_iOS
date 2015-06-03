//
//  BasePickerViewAdapter.m
//  Filtacular
//
//  Created by John Li on 6/3/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "BasePickerViewAdapter.h"

@implementation BasePickerViewAdapter

-(void) bind: (UIPickerView*) pickerView : (itemSelectedBlock) onItemSelectBlock
{
    self.pickerViewDelegate.onItemSelected = onItemSelectBlock;
    pickerView.delegate = self.pickerViewDelegate;
    pickerView.dataSource = self.pickerViewDataSource;
}

-(void)setData:(NSArray *)data { }

@end