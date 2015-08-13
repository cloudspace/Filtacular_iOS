//
//  SearchBarAutoKeyboard.m
//  Filtacular
//
//  Created by Isaac Paul on 8/13/15.
//  Copyright (c) 2015 Cloudspace. All rights reserved.
//

#import "SearchBarAutoKeyboard.h"

@interface SearchBarAutoKeyboard () <UIGestureRecognizerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UIGestureRecognizer* tapGesture;
@property (weak,   nonatomic) id<UISearchBarDelegate> searchBarDelegate;
@property (assign, nonatomic) UIView* viewWithTapGesture;

@end

@implementation SearchBarAutoKeyboard

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tapGesture = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(clickOut)];
    self.viewWithTapGesture = [[UIApplication sharedApplication].delegate window].rootViewController.view;
    
    [_tapGesture setDelegate:self];
    [_tapGesture setCancelsTouchesInView:true];
    [super setDelegate:self];
}

- (void)clickOut {
    
}

- (void)setDelegate:(id<UISearchBarDelegate>)delegate {
    _searchBarDelegate = delegate;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view == self || [touch.view isDescendantOfView:self])
        return NO;
    if ([touch.view isKindOfClass:[UITextField class]])
        return NO;
    if ([touch.view isKindOfClass:[UITextView class]])
        return NO;
    if ([touch.view isKindOfClass:[UIButton class]])
    {
        [self performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.1];//TODO:Hacky
        return NO;
    }
    [self resignFirstResponder];
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return false;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if ([_searchBarDelegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        return [_searchBarDelegate searchBarShouldBeginEditing:searchBar];
    }
    
    return true;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_viewWithTapGesture addGestureRecognizer:_tapGesture];
    if ([_searchBarDelegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [_searchBarDelegate searchBarTextDidBeginEditing:searchBar];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if ([_searchBarDelegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        return [_searchBarDelegate searchBarShouldEndEditing:searchBar];
    }
    
    return true;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [_viewWithTapGesture removeGestureRecognizer:_tapGesture];
    if ([_searchBarDelegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]) {
        [_searchBarDelegate searchBarTextDidEndEditing:searchBar];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([_searchBarDelegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [_searchBarDelegate searchBar:searchBar textDidChange:searchText];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0) {
    if ([_searchBarDelegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
        return [_searchBarDelegate searchBar:searchBar shouldChangeTextInRange:range replacementText:text];
    }
    
    return true;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([_searchBarDelegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [_searchBarDelegate searchBarSearchButtonClicked:searchBar];
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    if ([_searchBarDelegate respondsToSelector:@selector(searchBarBookmarkButtonClicked:)]) {
        [_searchBarDelegate searchBarBookmarkButtonClicked:searchBar];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if ([_searchBarDelegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [_searchBarDelegate searchBarCancelButtonClicked:searchBar];
    }
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar NS_AVAILABLE_IOS(3_2) {
    if ([_searchBarDelegate respondsToSelector:@selector(searchBarResultsListButtonClicked:)]) {
        [_searchBarDelegate searchBarResultsListButtonClicked:searchBar];
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0) {
    if ([_searchBarDelegate respondsToSelector:@selector(searchBar:selectedScopeButtonIndexDidChange:)]) {
        [_searchBarDelegate searchBar:searchBar selectedScopeButtonIndexDidChange:selectedScope];
    }
}

@end
