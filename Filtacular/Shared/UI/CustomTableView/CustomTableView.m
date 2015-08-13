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

@property (strong, nonatomic) NSMutableDictionary* tableCellClassForDataType;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@property (strong, nonatomic) UITableViewController* tableViewController;
@property (strong, nonatomic) NSMutableArray* tableData;
@property (strong, nonatomic) MCCSmartGroup* smartGroup;
@property (strong, nonatomic) MCCSmartGroupManager* smartGroupManager;
@property (copy, nonatomic) DidSelectObjectBlock selectObjectBlock;

@property (assign, nonatomic) CGPoint dragStart;

@end

@implementation CustomTableView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpTable];
    [_table setHidden:true];
}

- (void)addTableCellClass:(Class)theClass forDataType:(Class)dataType {
    NSString* key = NSStringFromClass(dataType);
    [self addTableCellClass:theClass forKey:key];
}

- (void)addTableCellClass:(Class)theClass forKey:(NSString*)key {
    if (_tableCellClassForDataType == nil)
        _tableCellClassForDataType = [NSMutableDictionary new];
    
    _tableCellClassForDataType[key] = theClass;
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
    [_refreshControl addTarget:self action:@selector(userPulledToRefresh) forControlEvents:UIControlEventValueChanged];
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
        
        id cell = [strongSelf cellForObject:data];
        
        [cell configureWithObject:data];
        return cell;
    };
    
    _smartGroup.editable = false;
    
    self.smartGroupManager = [MCCSmartGroupManager new];
    [_smartGroupManager addSmartGroup:_smartGroup inTableView:_table];
    
    _table.dataSource = _smartGroupManager;
    _table.delegate = self;
    
    //Hides extra seperator cells
    _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    [_table setHidden:!hideNoItemsLabel];
    
    if (hideNoItemsLabel && _table.alpha == 0.0f) {
        [UIView animateWithDuration:0.3 animations:^{
            _table.alpha = 1.0f;
        }];
    }
    
    [_refreshControl endRefreshing];
    [_activityIndicator stopAnimating];
}

- (void)clearAndWaitForNewData {
    self.tableData = nil;

    _table.alpha = 0.0f;
    [UIView setAnimationsEnabled:NO];
    [_smartGroup processUpdates];
    [UIView setAnimationsEnabled:YES];
    [_lblNoItems setHidden:true];
    [_activityIndicator startAnimating];
    
}

- (void)userPulledToRefresh {
    if (_refreshCalled)
        _refreshCalled();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    id object = _tableData[indexPath.row];
    if (_selectObjectBlock)
        _selectObjectBlock(object);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = _tableData[indexPath.row];
    id cell = [self cachedCellForObject:object];//We cache the cell because its expensive to recreate it
    
    CGFloat height = [cell calculateHeightWith:object];
    return height;
}

static NSMutableDictionary* sCellCache = nil;

- (UITableViewCell*)cachedCellForObject:(id)object {
    
    if (sCellCache == nil)
        sCellCache = [NSMutableDictionary new];
    
    NSString* key = NSStringFromClass([object class]);
    if (key == nil)
        return nil;
    
    UITableViewCell* cachedCell = [sCellCache objectForKey:key];
    if (cachedCell == nil) {
        Class tableViewCellClass = self.tableCellClassForDataType[key];
        if (tableViewCellClass == nil)
            return nil;
        
        cachedCell = [tableViewCellClass createFromNib];
        sCellCache[key] = cachedCell;
    }
    return cachedCell;
}

- (UITableViewCell*)cellForObject:(id)object {
    id cell = nil;
    NSString* key = NSStringFromClass([object class]);
    Class tableViewCellClass = self.tableCellClassForDataType[key];
    NSString* cellId = [NSString stringWithFormat:@"%@Id", NSStringFromClass(tableViewCellClass)];
    cell = (id)[self.table dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell)
        cell = [tableViewCellClass createFromNib];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < _dragStart.y && scrollView.contentOffset.y > [UIScreen mainScreen].bounds.size.height) {
        [UIView animateWithDuration:0.5f animations:^{
            [_backToTopButton setAlpha:1.0f];
        }];
    } else {
        [UIView animateWithDuration:0.5f animations:^{
            [_backToTopButton setAlpha:0.0f];
        }];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _dragStart = scrollView.contentOffset;
}

- (IBAction)tapBackToTop {
    [_table setContentOffset:CGPointZero animated:YES];
}

@end
