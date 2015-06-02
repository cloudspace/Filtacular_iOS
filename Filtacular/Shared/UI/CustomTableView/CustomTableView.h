//
//  CustomTableView.h
//  Blinq
//
//  Created by Isaac Paul on 11/7/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import "Widget.h"

/*! A tableview wrapper to make my code more DRY and so there is less boiler platecode */

typedef void(^DidSelectObjectBlock)(id object);

@interface CustomTableView : Widget

@property (strong, nonatomic) Class tableViewCellClass;
@property (assign, nonatomic) CGFloat tableViewCellHeight;
@property (strong, nonatomic) UIView* footerView;

- (void)loadData:(NSArray*)data;
- (void)loadData:(NSArray*)data withNoItemText:(NSString*)noItemText;
- (void)setSelectObjectBlock:(DidSelectObjectBlock)block;
- (void)clearAndWaitForNewData;

- (void)setNoItemText:(NSString*)noItemText;

@end
