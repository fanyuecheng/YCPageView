//
//  ViewController.m
//  YCPageView
//
//  Created by 月成 on 2019/6/5.
//  Copyright © 2019 fancy. All rights reserved.
//

#import "ViewController.h"
#import "YCPageView.h"

@interface ViewController () <YCPageViewDelegate, YCPageViewDataSource>

@property (nonatomic, strong) YCPageView *pageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.pageView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat top = self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y;
    
    if (@available(iOS 11.0, *)) {
        self.pageView.frame = CGRectMake(0, top, self.view.bounds.size.width, self.view.bounds.size.height - top - self.view.safeAreaInsets.bottom);
    }
}

#pragma mark - YCPageView
- (UIView *)headerViewInPageView:(YCPageView *)pageView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
    headerView.backgroundColor = [UIColor redColor];
    
    return headerView;
}

- (NSArray<NSString *> *)titlesInPageView:(YCPageView *)pageView {
    return @[@"1111", @"2222", @"3333", @"4444"];
}

- (CGFloat)heightForSectionInPageView:(YCPageView *)pageView {
    return 50.0;
}

- (NSArray<UIView *> *)viewsInPageView:(YCPageView *)pageView {
    UIView *view1 = [UIView new];
    view1.backgroundColor = [self randomColor];
    
    UIView *view2 = [UIView new];
    view2.backgroundColor = [self randomColor];
    
    UIView *view3 = [UIView new];
    view3.backgroundColor = [self randomColor];
    
    UIView *view4 = [UIView new];
    view4.backgroundColor = [self randomColor];
    
    return @[view1, view2, view3, view4];
}

- (UIColor *)randomColor {
    CGFloat red = ( arc4random() % 255 / 255.0 );
    CGFloat green = ( arc4random() % 255 / 255.0 );
    CGFloat blue = ( arc4random() % 255 / 255.0 );
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

#pragma mark - Get
- (YCPageView *)pageView {
    if (!_pageView) {
        _pageView = [[YCPageView alloc] init];
        _pageView.dataSource = self;
        _pageView.delegate = self;
    }
    return _pageView;
}


@end
