//
//  YCPageView.m
//  YCPageView
//
//  Created by 米画师 on 2021/8/30.
//

#import "YCPageView.h"

static NSString *YCPageViewCollectionViewCellIdentifier = @"cell";

@interface YCPageCollectionView : UICollectionView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *headerContainerView;

@end

@implementation YCPageCollectionView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self.headerContainerView];
    if (CGRectContainsPoint(self.headerContainerView.bounds, point)) {
        return NO;
    }
    return YES;
}

@end

@interface YCPageView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
 
@property (nonatomic, strong) YCPageCollectionView *collectionView;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, id<YCPageListViewDelegate>> *listCache;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIView*> *headerCache;
@property (nonatomic, assign) BOOL syncListContentOffsetEnabled;
@property (nonatomic, strong) UIView       *headerContainerView;
@property (nonatomic, strong) UIScrollView *currentListScrollView;
@property (nonatomic, strong) UIScrollView *singleScrollView;
@property (nonatomic, assign) CGFloat      currentHeaderContainerViewY;
@property (nonatomic, assign) NSInteger    currentIndex;
@property (nonatomic, assign) CGFloat      heightForPageHeader;
@property (nonatomic, assign) CGFloat      heightForPinHeader;
@property (nonatomic, assign) CGFloat      heightForHeaderContainerView;
@property (nonatomic, assign) CGFloat      currentListInitializeContentOffsetY;

@end

@implementation YCPageView

- (void)dealloc {
    for (id<YCPageListViewDelegate> list in self.listCache.allValues) {
        [[list listScrollView] removeObserver:self forKeyPath:@"contentOffset"];
        [[list listScrollView] removeObserver:self forKeyPath:@"contentSize"];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    [self addSubview:self.collectionView];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.collectionView.frame = self.bounds;
    if (self.singleScrollView != nil) {
        self.singleScrollView.frame = self.bounds;
    }
    if (CGRectEqualToRect(self.headerContainerView.frame, CGRectZero)) {
        [self reloadData];
    }
}

- (void)reloadData {
    self.currentListScrollView = nil;
    self.currentIndex = self.selectedIndex;
    self.currentHeaderContainerViewY = 0;
    self.syncListContentOffsetEnabled = NO;

    for (id<YCPageListViewDelegate> list in self.listCache.allValues) {
        [[list listScrollView] removeObserver:self forKeyPath:@"contentOffset"];
        [[list listScrollView] removeObserver:self forKeyPath:@"contentSize"];
        [[list listView] removeFromSuperview];
    }
    [self.listCache removeAllObjects];
    [self.headerCache removeAllObjects];
    
    self.heightForPageHeader = [self.dataSource heightForPageHeaderInPageView:self];
    self.heightForPinHeader = [self.dataSource heightForPinHeaderInPageView:self];
    self.heightForHeaderContainerView = self.heightForPageHeader + self.heightForPinHeader;
    
    UIView *pagerHeader = [self.dataSource viewForPageHeaderInPageView:self];
    UIView *pinHeader = [self.dataSource viewForPinHeaderInPageView:self];
    [self.headerContainerView addSubview:pagerHeader];
    [self.headerContainerView addSubview:pinHeader];

    self.headerContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.heightForHeaderContainerView);
    pagerHeader.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.heightForPageHeader);
    pinHeader.frame = CGRectMake(0, self.heightForPageHeader, CGRectGetWidth(self.bounds), self.heightForPinHeader);
    [self.collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.collectionView.bounds) * self.selectedIndex, 0) animated:NO];
    [self.collectionView reloadData];

    if ([self.dataSource numberOfListsInPageView:self] == 0) {
        self.singleScrollView = [[UIScrollView alloc] init];
        [self addSubview:self.singleScrollView];
        [self.singleScrollView addSubview:pagerHeader];
        self.singleScrollView.contentSize = CGSizeMake(self.bounds.size.width, self.heightForPageHeader);
    } else if (self.singleScrollView != nil) {
        [self.singleScrollView removeFromSuperview];
        self.singleScrollView = nil;
    }
}

#pragma mark - UICollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.bounds.size;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfListsInPageView:)]) {
        return [self.dataSource numberOfListsInPageView:self];
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YCPageViewCollectionViewCellIdentifier forIndexPath:indexPath];
    id <YCPageListViewDelegate> list = self.listCache[@(indexPath.item)];
    if (list == nil) {
        list = [self.dataSource pageView:self listAtIndex:indexPath.item];
        self.listCache[@(indexPath.item)] = list;
        [[list listView] setNeedsLayout];
        [[list listView] layoutIfNeeded];
        UIScrollView *listScrollView = [list listScrollView];
        if ([listScrollView isKindOfClass:[UITableView class]]) {
            ((UITableView *)listScrollView).estimatedRowHeight = 0;
            ((UITableView *)listScrollView).estimatedSectionFooterHeight = 0;
            ((UITableView *)listScrollView).estimatedSectionHeaderHeight = 0;
        }
        if (@available(iOS 11.0, *)) {
            listScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        listScrollView.contentInset = UIEdgeInsetsMake(self.heightForHeaderContainerView, 0, 0, 0);
        self.currentListInitializeContentOffsetY = -listScrollView.contentInset.top + MIN(-self.currentHeaderContainerViewY, self.heightForPageHeader);
        listScrollView.contentOffset = CGPointMake(0, self.currentListInitializeContentOffsetY);
        UIView *listHeader = [[UIView alloc] initWithFrame:CGRectMake(0, -self.heightForHeaderContainerView, CGRectGetWidth(self.bounds), self.heightForHeaderContainerView)];
        [listScrollView addSubview:listHeader];
        if (self.headerContainerView.superview == nil) {
            [listHeader addSubview:self.headerContainerView];
        }
        self.headerCache[@(indexPath.item)] = listHeader;
        [listScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [listScrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    for (id<YCPageListViewDelegate> listItem in self.listCache.allValues) {
        [listItem listScrollView].scrollsToTop = (listItem == list);
    }
    UIView *listView = [list listView];
    if (listView != nil && listView.superview != cell.contentView) {
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        listView.frame = cell.contentView.bounds;
        [cell.contentView addSubview:listView];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self listDidAppear:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self listDidDisappear:indexPath.item];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageViewDidScroll:)]) {
        [self.delegate pageViewDidScroll:scrollView];
    }
    CGFloat indexPercent = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    NSInteger index = floor(indexPercent);
    UIScrollView *listScrollView = [self.listCache[@(index)] listScrollView];
    if (indexPercent - index == 0 && index != self.currentIndex && !(scrollView.isDragging || scrollView.isDecelerating) && listScrollView.contentOffset.y <= -self.heightForPinHeader) {
        [self horizontalScrollDidEndAtIndex:index];
    } else {
        //左右滚动的时候，就把listHeaderContainerView添加到self，达到悬浮在顶部的效果
        if (self.headerContainerView.superview != self) {
            self.headerContainerView.frame = CGRectMake(0, self.currentHeaderContainerViewY, CGRectGetWidth(self.headerContainerView.bounds), CGRectGetHeight(self.headerContainerView.bounds));
            [self addSubview:self.headerContainerView];
        }
    }
    if (self.currentIndex != index) {
        self.currentIndex = index;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        NSInteger index = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
        [self horizontalScrollDidEndAtIndex:index];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x/scrollView.bounds.size.width;
    [self horizontalScrollDidEndAtIndex:index];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        UIScrollView *scrollView = (UIScrollView *)object;
        if (scrollView != nil) {
            [self listDidScroll:scrollView];
        }
    } else if ([keyPath isEqualToString:@"contentSize"]) {
        UIScrollView *scrollView = (UIScrollView *)object;
        if (scrollView != nil) {
            CGFloat minContentSizeHeight = CGRectGetHeight(self.bounds) - self.heightForPinHeader;
            if (minContentSizeHeight > scrollView.contentSize.height) {
                scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, minContentSizeHeight);
                //新的scrollView第一次加载的时候重置contentOffset
                if (self.currentListScrollView != nil && self.currentListScrollView != scrollView) {
                    scrollView.contentOffset = CGPointMake(0, self.currentListInitializeContentOffsetY);
                }
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Event

- (void)listDidScroll:(UIScrollView *)scrollView {
    if (self.collectionView.isDragging || self.collectionView.isDecelerating) {
        return;
    }
    NSInteger listIndex = [self listIndexForListScrollView:scrollView];
    if (self.currentIndex != listIndex) {
        return;
    }
    self.currentListScrollView = scrollView;
    CGFloat contentOffsetY = scrollView.contentOffset.y + self.heightForHeaderContainerView;
    if (contentOffsetY < self.heightForPageHeader) {
        self.syncListContentOffsetEnabled = YES;
        self.currentHeaderContainerViewY = -contentOffsetY;
        for (id<YCPageListViewDelegate> list in self.listCache.allValues) {
            if ([list listScrollView] != self.currentListScrollView) {
                [[list listScrollView] setContentOffset:scrollView.contentOffset animated:NO];
            }
        }
        UIView *listHeader = [self listHeaderForListScrollView:scrollView];
        if (self.headerContainerView.superview != listHeader) {
            self.headerContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.headerContainerView.bounds), CGRectGetHeight(self.headerContainerView.bounds));
            [listHeader addSubview:self.headerContainerView];
        }
    } else {
        if (self.headerContainerView.superview != self) {
            self.headerContainerView.frame = CGRectMake(0, -self.heightForPageHeader, CGRectGetWidth(self.headerContainerView.bounds), CGRectGetHeight(self.headerContainerView.bounds));
            [self addSubview:self.headerContainerView];
        }
        if (self.syncListContentOffsetEnabled) {
            self.syncListContentOffsetEnabled = NO;
            self.currentHeaderContainerViewY = -self.heightForPageHeader;
            for (id<YCPageListViewDelegate> list in self.listCache.allValues) {
                if ([list listScrollView] != scrollView) {
                    [[list listScrollView] setContentOffset:CGPointMake(0, -self.heightForPinHeader) animated:NO];
                }
            }
        }
    }
}

#pragma mark - Private

- (UIView *)listHeaderForListScrollView:(UIScrollView *)scrollView {
    for (NSNumber *index in self.listCache) {
        if ([self.listCache[index] listScrollView] == scrollView) {
            return self.headerCache[index];
        }
    }
    return nil;
}

- (NSInteger)listIndexForListScrollView:(UIScrollView *)scrollView {
    for (NSNumber *index in self.listCache) {
        if ([self.listCache[index] listScrollView] == scrollView) {
            return [index integerValue];
        }
    }
    return 0;
}

- (void)listDidAppear:(NSInteger)index {
    NSUInteger count = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfListsInPageView:)]) {
        count = [self.dataSource numberOfListsInPageView:self];
    }
    if (count <= 0 || index >= count) {
        return;
    }
    id<YCPageListViewDelegate> list = self.listCache[@(index)];
    if (list && [list respondsToSelector:@selector(listDidAppear)]) {
        [list listDidAppear];
    }
}

- (void)listDidDisappear:(NSInteger)index {
    NSUInteger count = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfListsInPageView:)]) {
        count = [self.dataSource numberOfListsInPageView:self];
    }
    if (count <= 0 || index >= count) {
        return;
    }
    id<YCPageListViewDelegate> list = self.listCache[@(index)];
    if (list && [list respondsToSelector:@selector(listDidDisappear)]) {
        [list listDidDisappear];
    }
}

/// 列表左右切换滚动结束之后，需要把pagerHeaderContainerView添加到当前index的列表上面
- (void)horizontalScrollDidEndAtIndex:(NSInteger)index {
    self.currentIndex = index;
    UIView *listHeader = self.headerCache[@(index)];
    UIScrollView *listScrollView = [self.listCache[@(index)] listScrollView];
    if (listHeader != nil && listScrollView.contentOffset.y <= -self.heightForPinHeader) {
        for (id<YCPageListViewDelegate> listItem in self.listCache.allValues) {
            [listItem listScrollView].scrollsToTop = ([listItem listScrollView] == listScrollView);
        }
        self.headerContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.headerContainerView.bounds), CGRectGetHeight(self.headerContainerView.bounds));
        [listHeader addSubview:self.headerContainerView];
    }
}

#pragma mark - Get
- (UIView *)headerContainerView {
    if (!_headerContainerView) {
        _headerContainerView = [[UIView alloc] init];
    }
    return _headerContainerView;
}
 
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[YCPageCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.bounces = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollsToTop = NO;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:YCPageViewCollectionViewCellIdentifier];
        if (@available(iOS 10.0, *)) {
            _collectionView.prefetchingEnabled = NO;
        }
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _collectionView.headerContainerView = self.headerContainerView;
    }
    return _collectionView;
}

- (NSDictionary<NSNumber *, id<YCPageListViewDelegate>> *)listCache {
    if (!_listCache) {
        _listCache = [NSMutableDictionary dictionary];
    }
    return _listCache;
}

- (NSMutableDictionary<NSNumber *, UIView *> *)headerCache {
    if (!_headerCache) {
        _headerCache = [NSMutableDictionary dictionary];
    }
    return _headerCache;
}

#pragma mark - Set
- (void)setDataSource:(id<YCPageViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self.collectionView reloadData];
}

@end

