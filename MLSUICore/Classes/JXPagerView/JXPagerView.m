//
//  JXPagerView.m
//  JXPagerView
//
//  Created by jiaxin on 2018/8/27.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

#import "JXPagerView.h"

@interface JXPagerView () <UITableViewDataSource, UITableViewDelegate, JXPagerListContainerViewDelegate>

@property (nonatomic, strong) JXPagerMainTableView *mainTableView;
@property (nonatomic, strong) JXPagerListContainerView *listContainerView;
@property (nonatomic, strong) UIScrollView *currentScrollingListView;
@property (nonatomic, strong) id<JXPagerViewListViewDelegate> currentListView;

@end

@implementation JXPagerView

- (instancetype)initWithDelegate:(id<JXPagerViewDelegate>)delegate {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _delegate = delegate;
        [self initializeViews];
    }
    return self;
}

- (void)initializeViews {
    _mainTableView = [[JXPagerMainTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.mainTableView.showsVerticalScrollIndicator = NO;
    self.mainTableView.showsHorizontalScrollIndicator = NO;
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mainTableView.dataSource = self;
    self.mainTableView.delegate = self;
    self.mainTableView.tableHeaderView = [self.delegate tableHeaderViewInPagerView:self];
    [self.mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    if (@available(iOS 11.0, *)) {
        self.mainTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self addSubview:self.mainTableView];

    _listContainerView = [[JXPagerListContainerView alloc] initWithDelegate:self];
    self.listContainerView.mainTableView = self.mainTableView;

    [self configListViewDidScrollCallback];

    self.isListHorizontalScrollEnabled = YES;
    
    self.mainTableMaxOffset = (int)[self.delegate tableHeaderViewHeightInPagerView:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.mainTableView.frame = self.bounds;
}

- (void)setIsListHorizontalScrollEnabled:(BOOL)isListHorizontalScrollEnabled {
    _isListHorizontalScrollEnabled = isListHorizontalScrollEnabled;
    
    self.listContainerView.collectionView.scrollEnabled = isListHorizontalScrollEnabled;
}

- (void)reloadData {
    self.currentListView = nil;
    self.currentScrollingListView = nil;
    [self configListViewDidScrollCallback];
    self.mainTableView.tableHeaderView = [self.delegate tableHeaderViewInPagerView:self];
    [self.mainTableView reloadData];
    [self.listContainerView reloadData];
}


- (void)scrollToMaxOffset {
    [self.mainTableView setContentOffset:CGPointMake(0, self.mainTableMaxOffset) animated:YES];
}

- (void)preferredProcessListViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat headerH = self.mainTableMaxOffset;//[self.delegate tableHeaderViewHeightInPagerView:self];
    
    if (self.mainTableView.contentOffset.y < headerH) {
        //mainTableView的header还没有消失，让listScrollView一直为0
        if (self.currentListView && [self.currentListView respondsToSelector:@selector(listScrollViewWillResetContentOffset)]) {
            [self.currentListView listScrollViewWillResetContentOffset];
        }
        scrollView.contentOffset = CGPointZero;
        scrollView.showsVerticalScrollIndicator = NO;
    }else {
        //mainTableView的header刚好消失，固定mainTableView的位置，显示listScrollView的滚动条
        self.mainTableView.contentOffset = CGPointMake(0, headerH);
        scrollView.showsVerticalScrollIndicator = YES;
    }
}

- (void)preferredProcessMainTableViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat headerH = self.mainTableMaxOffset;//[self.delegate tableHeaderViewHeightInPagerView:self];
        
    if (self.currentScrollingListView != nil && self.currentScrollingListView.contentOffset.y > 0) {
        //mainTableView的header已经滚动不见，开始滚动某一个listView，那么固定mainTableView的contentOffset，让其不动
        [self.mainTableView setContentOffset:CGPointMake(0, headerH) animated:false];
        
    }

    if (scrollView.contentOffset.y < headerH) {
        //mainTableView已经显示了header，listView的contentOffset需要重置
        NSArray *listViews = [self.delegate listViewsInPagerView:self];
        for (id<JXPagerViewListViewDelegate> listView in listViews) {
            if ([listView respondsToSelector:@selector(listScrollViewWillResetContentOffset)]) {
                [listView listScrollViewWillResetContentOffset];
            }
            [listView listScrollView].contentOffset = CGPointZero;
        }
    }

    if (scrollView.contentOffset.y > headerH && self.currentScrollingListView.contentOffset.y == 0) {
        //当往上滚动mainTableView的headerView时，滚动到底时，修复listView往上小幅度滚动
        [self.mainTableView setContentOffset:CGPointMake(0, headerH) animated:false];
    }
}

#pragma mark - Private

- (void)configListViewDidScrollCallback {
    NSArray *listViews = [self.delegate listViewsInPagerView:self];
    __weak typeof(self)weakSelf = self;
    for (id<JXPagerViewListViewDelegate> listView in listViews) {
        __weak typeof(id<JXPagerViewListViewDelegate>) weakListView = listView;
        [listView listViewDidScrollCallback:^(UIScrollView *scrollView) {
            weakSelf.currentListView = weakListView;
            [weakSelf listViewDidScroll:scrollView];
        }];
    }
}

- (void)listViewDidScroll:(UIScrollView *)scrollView {
    self.currentScrollingListView = scrollView;

    [self preferredProcessListViewDidScroll:scrollView];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size.height - [self.delegate heightForPinSectionHeaderInPagerView:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    self.listContainerView.frame = cell.contentView.bounds;
    [cell.contentView addSubview:self.listContainerView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self.delegate heightForPinSectionHeaderInPagerView:self];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self.delegate viewForPinSectionHeaderInPagerView:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    footer.backgroundColor = [UIColor clearColor];
    return footer;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(mainTableViewDidScroll:)]) {
        [self.delegate mainTableViewDidScroll:scrollView];
    }

    if (scrollView.isTracking && self.isListHorizontalScrollEnabled) {
        self.listContainerView.collectionView.scrollEnabled = NO;
    }

    [self preferredProcessMainTableViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    if (self.isListHorizontalScrollEnabled) {
        self.listContainerView.collectionView.scrollEnabled = YES;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

    if (self.isListHorizontalScrollEnabled) {
        self.listContainerView.collectionView.scrollEnabled = YES;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.isListHorizontalScrollEnabled) {
        self.listContainerView.collectionView.scrollEnabled = YES;
    }
}

#pragma mark - JXPagingListContainerViewDelegate

- (NSInteger)numberOfRowsInListContainerView:(JXPagerListContainerView *)listContainerView {
    NSArray *listViews = [self.delegate listViewsInPagerView:self];
    return listViews.count;
}

- (UIView *)listContainerView:(JXPagerListContainerView *)listContainerView listViewInRow:(NSInteger)row {
    NSArray *listViews = [self.delegate listViewsInPagerView:self];
    return [listViews[row] listView];
}

- (void)listContainerView:(JXPagerListContainerView *)listContainerView willDisplayCellAtRow:(NSInteger)row {
    NSArray *listViews = [self.delegate listViewsInPagerView:self];
    self.currentScrollingListView = [listViews[row] listScrollView];
}

@end
