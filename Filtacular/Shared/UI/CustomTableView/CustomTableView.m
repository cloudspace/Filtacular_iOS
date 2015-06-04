//
//  CustomTableView.m
//  Blinq
//
//  Created by Isaac Paul on 11/7/14.
//  Copyright (c) 2014 CloudSpace. All rights reserved.
//

#import "CustomTableView.h"
#import "MCCSmartGroup.h"
#import "MCCSmartGroupManager.h"
#import "ConfigurableViewProtocol.h"
#import "UIView+Positioning.h"

@interface CustomTableView () <UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView* table;
@property (strong, nonatomic) IBOutlet UILabel *lblNoItems;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSString* cellId;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@property (strong, nonatomic) UITableViewController* tableViewController;
@property (strong, nonatomic) NSMutableArray* tableData;
@property (strong, nonatomic) MCCSmartGroup* smartGroup;
@property (strong, nonatomic) MCCSmartGroupManager* smartGroupManager;
@property (copy, nonatomic) DidSelectObjectBlock selectObjectBlock;

@end

@implementation CustomTableView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpTable];
}

- (void)setTableViewCellClass:(Class)tableViewCellClass {
    _tableViewCellClass = tableViewCellClass;
    UITableViewCell* temp = [_tableViewCellClass createFromNib];
    [_table setRowHeight:temp.height];
    self.tableViewCellHeight = temp.height;
    self.cellId = [NSString stringWithFormat:@"%@Id", NSStringFromClass(_tableViewCellClass)];
}

- (void)setNoItemText:(NSString*)noItemText {
    [_lblNoItems setText:noItemText];
}

- (void)cellHeightChanged {
    [_table beginUpdates];
    [_table endUpdates];
}

- (void)setUpTable {
    [_table setRowHeight:_tableViewCellHeight];
    self.refreshControl = [UIRefreshControl new];
    [_refreshControl addTarget:self action:@selector(refreshCalled) forControlEvents:UIControlEventValueChanged];
    self.tableViewController = [UITableViewController new];
    [_tableViewController setView:_table];
    self.tableData  = [NSMutableArray new];
    self.smartGroup = [MCCSmartGroup new];
    
    __weak CustomTableView* weakSelf = self;
    self.smartGroup.dataBlock = ^id {
        CustomTableView* strongSelf = weakSelf;
        if (strongSelf.tableData)
            return strongSelf.tableData;
        
        return @[];
    };
    
    self.smartGroup.viewBlock = ^UIView *(NSInteger index, id data) {
        CustomTableView* strongSelf = weakSelf;
        
        id cell = nil;
        cell = (id)[strongSelf.table dequeueReusableCellWithIdentifier:strongSelf.cellId];
        
        if (!cell)
            cell = [strongSelf.tableViewCellClass createFromNib];
        
        [cell configureWithObject:data];
        return cell;
    };
    
    _smartGroup.editable = false;
    
    self.smartGroupManager = [MCCSmartGroupManager new];
    [_smartGroupManager addSmartGroup:_smartGroup inTableView:_table];
    
    _table.dataSource = _smartGroupManager;
    _table.delegate = self;
}

- (void)activateRefreshable {
    [_tableViewController setRefreshControl:_refreshControl];
}

- (void)deactivateRefreshable {
    [_tableViewController setRefreshControl:nil];
}

- (void)loadData:(NSArray*)data withNoItemText:(NSString*)noItemText {
    [self loadData:data];
    [self setNoItemText:noItemText];
}

- (void)loadData:(NSArray*)data {
    self.tableData = [data mutableCopy];
    [_smartGroup processUpdates];
    
    bool hideNoItemsLabel = (_tableData.count != 0);
    [_lblNoItems setHidden:hideNoItemsLabel];
    
    [_refreshControl endRefreshing];
    [_activityIndicator stopAnimating];
    
    if (data.count > 0)
        [_table setTableFooterView:_footerView];
    else
        [_table setTableFooterView:nil];
}

- (void)clearAndWaitForNewData {
    self.tableData = nil;
    [_table setTableFooterView:nil];
    [_smartGroup processUpdates];
    
    [_lblNoItems setHidden:true];
    [_activityIndicator startAnimating];
}

- (void)refreshCalled {
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    id object = _tableData[indexPath.row];
    if (_selectObjectBlock)
        _selectObjectBlock(object);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = _tableData[indexPath.row];
    id <ConfigurableView> cell = [_smartGroup viewForRowAtIndex:indexPath.row];
    [cell configureWithObject:object];
    return [(UIView*)cell frame].size.height;
}

@end
