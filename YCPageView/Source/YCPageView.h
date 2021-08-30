//
//  YCPageView.h
//  YCPageView
//
//  Created by 米画师 on 2021/8/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YCPageView;

@protocol YCPageListViewDelegate <NSObject>
/**
返回listView。如果是vc包裹的就是vc.view；如果是自定义view包裹的，就是自定义view自己。
*/
- (UIView *)listView;
/**
 返回YCPageListViewDelegate内部持有的UIScrollView或UITableView或UICollectionView
 */
- (UIScrollView *)listScrollView;

@optional
- (void)listDidAppear;
- (void)listDidDisappear;

@end

@protocol YCPageViewDataSource <NSObject>

/**
 返回页面header的高度
 */
- (CGFloat)heightForPageHeaderInPageView:(YCPageView *)pageView;

/**
 返回页面header视图
 */
- (UIView *)viewForPageHeaderInPageView:(YCPageView *)pageView;

/**
 返回悬浮视图的高度
 */
- (CGFloat)heightForPinHeaderInPageView:(YCPageView *)pageView;

/**
 返回悬浮视图
 */
- (UIView *)viewForPinHeaderInPageView:(YCPageView *)pageView;

/**
 返回列表的数量
 */
- (NSInteger)numberOfListsInPageView:(YCPageView *)pageView;

/**
 根据index初始化一个对应列表实例，需要是遵从`YCPageListViewDelegate`协议的对象。
 如果列表是用自定义UIView封装的，就让自定义UIView遵从`YCPageListViewDelegate`协议，该方法返回自定义UIView即可。
 如果列表是用自定义UIViewController封装的，就让自定义UIViewController遵从`YCPageListViewDelegate`协议，该方法返回自定义UIViewController即可。

 @param pageView pagerView description
 @param index index description
 @return 新生成的列表实例
 */
- (id<YCPageListViewDelegate>)pageView:(YCPageView *)pageView
                           listAtIndex:(NSInteger)index;

@end

@protocol YCPageViewDelegate <NSObject>

- (void)pageViewDidScroll:(UIScrollView *)scrollView;

@end

@interface YCPageView : UIView

@property (nonatomic, strong, readonly) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, weak) id <YCPageViewDelegate> delegate;
@property (nonatomic, weak) id <YCPageViewDataSource> dataSource;

- (void)reloadData;

@end


NS_ASSUME_NONNULL_END
