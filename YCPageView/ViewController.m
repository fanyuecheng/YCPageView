//
//  ViewController.m
//  YCPageView
//
//  Created by 米画师 on 2021/8/30.
//

#import "ViewController.h"
#import "YCPageView.h"
#import "HeaderTableViewController.h"
#import "ListTableViewController.h"

@interface ViewController () <YCPageViewDelegate, YCPageViewDataSource>

@property (nonatomic, strong) HeaderTableViewController *headerController;
@property (nonatomic, strong) ListTableViewController   *list1Controller;
@property (nonatomic, strong) ListTableViewController   *list2Controller;
@property (nonatomic, strong) YCPageView                *pageView;
@property (nonatomic, strong) UISegmentedControl        *segmentedControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.pageView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.pageView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.navigationController.navigationBar.frame));
}

#pragma mark - YCPageViewDataSource
- (CGFloat)heightForPageHeaderInPageView:(YCPageView *)pageView {
    return self.headerController.view.bounds.size.height;
}

- (UIView *)viewForPageHeaderInPageView:(YCPageView *)pageView {
    return self.headerController.view;
}

- (CGFloat)heightForPinHeaderInPageView:(YCPageView *)pageView {
    return 50;
}

- (UIView *)viewForPinHeaderInPageView:(YCPageView *)pageView {
    return self.segmentedControl;
}

- (NSInteger)numberOfListsInPageView:(YCPageView *)pageView {
    return 2;
}

- (id<YCPageListViewDelegate>)pageView:(YCPageView *)pageView listAtIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return self.list1Controller;
            break;
            
        default:
            return self.list2Controller;
            break;
    }
}


#pragma mark JXPagerSmoothViewDelegate
- (void)pageViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging || scrollView.isTracking) {
        NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
        if (index != self.segmentedControl.selectedSegmentIndex) {
            self.segmentedControl.selectedSegmentIndex = index;
        }
    }
}

#pragma mark - Get
- (YCPageView *)pageView {
    if (!_pageView) {
        _pageView = [[YCPageView alloc] init];
        _pageView.delegate = self;
        _pageView.dataSource = self;
    }
    return _pageView;
}

- (ListTableViewController *)list1Controller {
    if (!_list1Controller) {
        _list1Controller = [[ListTableViewController alloc] init];
    }
    return _list1Controller;
}
 
- (ListTableViewController *)list2Controller {
    if (!_list2Controller) {
        _list2Controller = [[ListTableViewController alloc] init];
    }
    return _list2Controller;
}

- (HeaderTableViewController *)headerController {
    if (!_headerController) {
        _headerController = [[HeaderTableViewController alloc] init];
        _headerController.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300);
    }
    return _headerController;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"11111", @"22222"]];
        [_segmentedControl addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventValueChanged];
        _segmentedControl.selectedSegmentIndex = 0;
        _segmentedControl.backgroundColor = UIColor.redColor;
    }
    return _segmentedControl;
}

#pragma mark - Action
- (void)changeAction:(UISegmentedControl *)sender {
    NSInteger index = sender.selectedSegmentIndex;
    
    [self.pageView.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}



@end
