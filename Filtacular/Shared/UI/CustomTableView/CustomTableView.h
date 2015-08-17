//
//  CustomTableView.h
//  Blinq
//
//  Created by Isaac Paul on 11/7/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import "Widget.h"

/*! A tableview wrapper to reduce boiler platecode */

typedef void(^DidSelectObjectBlock)(id object);

@interface CustomTableView : Widget

@property (assign, nonatomic) CGFloat tableViewCellHeight;
@property (strong, nonatomic) UIView* backToTopButton;
@property (nonatomic, copy) void (^refreshCalled) ();

- (void)activateRefreshable;
- (void)deactivateRefreshable;
- (void)addTableCellClass:(Class)theClass forDataType:(Class)dataType;
- (void)addTableCellClass:(Class)theClass forKey:(NSString*)key;
- (void)loadData:(NSArray*)data;
- (void)loadData:(NSArray*)data withNoItemText:(NSString*)noItemText;
- (void)setSelectObjectBlock:(DidSelectObjectBlock)block;
- (void)clearAndWaitForNewData;

- (void)setNoItemText:(NSString*)noItemText;
- (void)reload;
- (void)cellHeightChanged;

- (IBAction)tapBackToTop;

@end
