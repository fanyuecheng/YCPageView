//
//  YCPageView.h
//  YCPageView
//
//  Created by 月成 on 2019/6/5.
//  Copyright © 2019 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YCPageView;
@protocol YCPageViewDataSource <NSObject>

@required
- (__kindof UIView *)headerViewInPageView:(YCPageView *)pageView;
- (CGFloat)heightForSectionInPageView:(YCPageView *)pageView;
- (NSArray <NSString *>*)titlesInPageView:(YCPageView *)pageView;
- (NSArray <UIView *>*)viewsInPageView:(YCPageView *)pageView;

@end

@protocol YCPageViewDelegate <NSObject>

//index的切换,view的滚动等

@end

@interface YCPageView : UIView

@property (nonatomic, strong, readonly) UITableView        *tableView;
@property (nonatomic, strong, readonly) UISegmentedControl *segmentedControl;
@property (nonatomic, weak) id <YCPageViewDataSource> dataSource;
@property (nonatomic, weak) id <YCPageViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
