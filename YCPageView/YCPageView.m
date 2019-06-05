//
//  YCPageView.m
//  YCPageView
//
//  Created by 月成 on 2019/6/5.
//  Copyright © 2019 fancy. All rights reserved.
//

#import "YCPageView.h"

@interface YCPageView () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UITableView        *tableView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UICollectionView   *collectionView;

@end

@implementation YCPageView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialized];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(headerViewInPageView:)]) {
        self.tableView.tableHeaderView = [self.dataSource headerViewInPageView:self];
    }
}

#pragma mark - Method
- (void)initialized {
    [self addSubview:self.tableView];
}

#pragma mark - Action
- (void)segmentedControlAction:(UISegmentedControl *)sender {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:sender.selectedSegmentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.segmentedControl;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(heightForSectionInPageView:)]) {
        return [self.dataSource heightForSectionInPageView:self];
    }
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kTableViewCellIdentifer = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTableViewCellIdentifer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (!self.collectionView.superview) {
        self.collectionView.frame = CGRectMake(0, 0, tableView.bounds.size.width, [self tableView:tableView heightForRowAtIndexPath:indexPath]);
        [cell.contentView addSubview:self.collectionView];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat sectionHeight = 0;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(heightForSectionInPageView:)]) {
        sectionHeight = [self.dataSource heightForSectionInPageView:self];
    }
    return tableView.bounds.size.height - sectionHeight;
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(viewsInPageView:)]) {
        return [self.dataSource viewsInPageView:self].count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(viewsInPageView:)]) {
        UIView *view = [self.dataSource viewsInPageView:self][indexPath.item];
        view.frame = cell.contentView.bounds;
        [cell.contentView addSubview:view];
    }
    
    return cell;
}

#pragma mark - ScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        self.segmentedControl.selectedSegmentIndex = scrollView.contentOffset.x / scrollView.bounds.size.width;
    }
}

#pragma mark - Get
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (@available(iOS 11, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl && self.dataSource && [self.dataSource respondsToSelector:@selector(titlesInPageView:)]) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:[self.dataSource titlesInPageView:self]];
        
        [_segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor grayColor], NSForegroundColorAttributeName,
                                                   [UIFont systemFontOfSize:14], NSFontAttributeName,
                                                   nil]
                                         forState:UIControlStateNormal];
        
        [_segmentedControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor redColor], NSForegroundColorAttributeName,
                                                   [UIFont systemFontOfSize:14], NSFontAttributeName,
                                                   nil]
                                         forState:UIControlStateSelected];
        
        _segmentedControl.selectedSegmentIndex = 0;
        _segmentedControl.tintColor = [UIColor clearColor];
        _segmentedControl.backgroundColor = [UIColor whiteColor];
        _segmentedControl.highlighted = NO;
        [_segmentedControl addTarget:self action:@selector(segmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        layout.itemSize = CGSizeMake(self.bounds.size.width, [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    }
    return _collectionView;
}

@end

