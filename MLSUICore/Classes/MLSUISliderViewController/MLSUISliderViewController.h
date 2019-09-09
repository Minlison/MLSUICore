//
//  MLSSliderViewController.h
//  MLSLearnCenter
//
//  Created by minlison on 2018/5/28.
//  Copyright © 2018年 minlison. All rights reserved.
//

#import "MLSBaseViewController.h"
#import "MLSUISliderView.h"
@class MLSUISliderViewController;
NS_ASSUME_NONNULL_BEGIN
@protocol MLSUISliderViewControllerDelegate <NSObject>
@optional
/**
 顶部最小距离
 
 @param sliderViewControler sliderViewControler
 @return 距离
 */
- (CGFloat)topMinHeight:(MLSUISliderViewController *)sliderViewControler;

/**
 顶部默认初试化距离

 @param sliderViewControler sliderViewControler
 @return 距离
 */
- (CGFloat)topDefaultHeight:(MLSUISliderViewController *)sliderViewControler;

/**
 底部最小距离
 
 @param sliderViewControler sliderViewControler
 @return 距离
 */
- (CGFloat)bottomMinHeight:(MLSUISliderViewController *)sliderViewControler;

/**
 最底部视图的高度
 
 @param sliderViewControler sliderViewControler
 @return 高度
 */
- (CGFloat)bottomActionViewHeight:(MLSUISliderViewController *)sliderViewControler;
@end
@protocol MLSUISliderViewControllerDataSource <NSObject>
@required
/**
 顶部视图控制器

 @param sliderViewControler sliderViewControler
 @return 顶部视图控制器
 */
- (__kindof UIViewController *)topViewController:(MLSUISliderViewController *)sliderViewControler;
/**
 底部视图控制器
 
 @param sliderViewControler sliderViewControler
 @return 底部视图控制器
 */
- (__kindof UIViewController *)bottomViewController:(MLSUISliderViewController *)sliderViewControler;

@optional
/**
 底部事件 view

 @param sliderViewControler sliderViewControler
 @return 底部事件 view
 */
- (nullable __kindof UIView *)bottomActionView:(MLSUISliderViewController *)sliderViewControler;
@end

@interface MLSUISliderViewController : MLSBaseViewController

/**
 顶部视图控制器
 */
@property (nonatomic, strong, readonly) __kindof  MLSBaseViewController *topViewController;

/**
 底部视图控制器
 */
@property (nonatomic, strong, readonly) __kindof  MLSBaseViewController *bottomViewController;

/**
 底部事件视图
 */
@property (nonatomic, strong, readonly) __kindof  UIView *bottomActionView;

/**
 拖拽视图 img
 */
@property (nonatomic, strong) UIImage *dragHandleImage;

/**
 代理
 */
@property (nonatomic, weak) id <MLSUISliderViewControllerDelegate> delegate;

/**
 数据源
 */
@property (nonatomic, weak) id <MLSUISliderViewControllerDataSource> dataSource;

/**
 重新加载 slider
 */
- (void)reloadSliderController;

/**
 是否因此底部控制器

 @param hidden 是否隐藏
 @param animation 是否动画
 */
- (void)setHiddenBottomView:(BOOL)hidden animation:(BOOL)animation;
@end
NS_ASSUME_NONNULL_END
