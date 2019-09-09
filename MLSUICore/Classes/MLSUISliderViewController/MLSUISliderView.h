//
//  MLSSliderView.h
//  MLSLearnCenter
//
//  Created by minlison on 2018/5/28.
//  Copyright © 2018年 minlison. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MLSUISliderView : UIView

/**
 手柄视图，可以设置图片
 */
@property (nonatomic, strong, readonly) UIImageView *dragHandleImgView;

/**
 顶部视图最小高度
 */
@property (nonatomic, assign) CGFloat topMinHeight;

/**
 底部视图最小高度
 */
@property (nonatomic, assign) CGFloat bottomMinHeight;

/**
 底部事件视图高度
 */
@property (nonatomic, assign) CGFloat bottomActionViewHeight;

/**
 顶部默认视图的高度
 */
@property (nonatomic, assign) CGFloat defaultTopHeight;

/**
 顶部视图高度
 */
@property (nonatomic, weak) UIView *topView;

/**
 底部视图高度
 */
@property (nonatomic, weak) UIView *bottomView;

/**
 底部事件视图高度
 */
@property (nonatomic, weak) UIView *bottomActionView;

/**
 隐藏底部控制器
 
 @param animation 是否动画
 */
- (void)hideBottomAnimation:(BOOL)animation;

/**
 显示底部控制器
 
 @param animation 是否动画
 */
- (void)showBottomAnimation:(BOOL)animation;

/**
 承载控制器
 */
@property (nonatomic, weak) UIViewController *controller;

/**
 配置子视图
 */
- (void)setupView;
@end
