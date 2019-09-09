//
//  MLSMenuView.h
//  MLSPageController
//
//  Created by minlison on 18/5/9.
//  Copyright (c) 2018年 minlison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLSMenuItem.h"
#import "MLSProgressView.h"

@class MLSMenuView;


typedef NS_ENUM(NSUInteger, MLSMenuViewStyle) {
    MLSMenuViewStyleDefault,      // 默认
    MLSMenuViewStyleLine,         // 带下划线 (若要选中字体大小不变，设置选中和非选中大小一样即可)
    MLSMenuViewStyleTriangle,     // 三角形 (progressHeight 为三角形的高, progressWidths 为底边长)
    MLSMenuViewStyleFlood,        // 涌入效果 (填充)
    MLSMenuViewStyleFloodHollow,  // 涌入效果 (空心的)
    MLSMenuViewStyleSegmented,    // 涌入带边框,即网易新闻选项卡
};

// 原先基础上添加了几个方便布局的枚举，更多布局格式可以通过设置 `itemsMargins` 属性来自定义
// 以下布局均只在 item 个数较少的情况下生效，即无法滚动 MenuView 时.
typedef NS_ENUM(NSUInteger, MLSMenuViewLayoutMode) {
    MLSMenuViewLayoutModeScatter, // 默认的布局模式, item 会均匀分布在屏幕上，呈分散状
    MLSMenuViewLayoutModeLeft,    // Item 紧靠屏幕左侧
    MLSMenuViewLayoutModeRight,   // Item 紧靠屏幕右侧
    MLSMenuViewLayoutModeCenter,  // Item 紧挨且居中分布
};

@protocol MLSMenuViewDelegate <NSObject>
@optional
- (BOOL)menuView:(MLSMenuView *)menu shouldSelesctedIndex:(NSInteger)index;
- (void)menuView:(MLSMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex;
- (CGFloat)menuView:(MLSMenuView *)menu widthForItemAtIndex:(NSInteger)index;
- (CGFloat)menuView:(MLSMenuView *)menu itemMarginAtIndex:(NSInteger)index;
- (CGFloat)menuView:(MLSMenuView *)menu titleSizeForState:(MLSMenuItemState)state atIndex:(NSInteger)index;
- (UIColor *)menuView:(MLSMenuView *)menu titleColorForState:(MLSMenuItemState)state atIndex:(NSInteger)index;
- (void)menuView:(MLSMenuView *)menu didLayoutItemFrame:(MLSMenuItem *)menuItem atIndex:(NSInteger)index;
@end

@protocol MLSMenuViewDataSource <NSObject>

@required
- (NSInteger)numbersOfTitlesInMenuView:(MLSMenuView *)menu;
- (NSString *)menuView:(MLSMenuView *)menu titleAtIndex:(NSInteger)index;

@optional
/**
 *  角标 (例如消息提醒的小红点) 的数据源方法，在 MLSPageController 中实现这个方法来为 menuView 提供一个 badgeView
    需要在返回的时候同时设置角标的 frame 属性，该 frame 为相对于 menuItem 的位置
 *
 *  @param index 角标的序号
 *
 *  @return 返回一个设置好 frame 的角标视图
 */
- (UIView *)menuView:(MLSMenuView *)menu badgeViewAtIndex:(NSInteger)index;

/**
 *  用于定制 MLSMenuItem，可以对传出的 initialMenuItem 进行修改定制，也可以返回自己创建的子类，需要注意的是，此时的 item 的 frame 是不确定的，所以请勿根据此时的 frame 做计算！
    如需根据 frame 修改，请使用代理
 *
 *  @param menu            当前的 menuView，frame 也是不确定的
 *  @param initialMenuItem 初始化完成的 menuItem
 *  @param index           Item 所属的位置;
 *
 *  @return 定制完成的 MenuItem
 */
- (MLSMenuItem *)menuView:(MLSMenuView *)menu initialMenuItem:(MLSMenuItem *)initialMenuItem atIndex:(NSInteger)index;

@end

@interface MLSMenuView : UIView <MLSMenuItemDelegate>
@property (nonatomic, strong) NSArray *progressWidths;
@property (nonatomic, weak) MLSProgressView *progressView;
@property (nonatomic, strong) UIColor *progressBgColor;
@property (nonatomic, assign) CGFloat progressHeight;
@property (nonatomic, assign) MLSMenuViewStyle style;
@property (nonatomic, assign) MLSMenuViewLayoutMode layoutMode;
@property (nonatomic, assign) CGFloat contentMargin;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat progressViewBottomSpace;
@property (nonatomic, weak) id<MLSMenuViewDelegate> delegate;
@property (nonatomic, weak) id<MLSMenuViewDataSource> dataSource;
@property (nonatomic, weak) UIView *leftView;
@property (nonatomic, weak) UIView *rightView;
@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, weak) UIScrollView *scrollView;
/** 进度条的速度因数，默认为 15，越小越快， 大于 0 */
@property (nonatomic, assign) CGFloat speedFactor;
@property (nonatomic, assign) CGFloat progressViewCornerRadius;
@property (nonatomic, assign) BOOL progressViewIsNaughty;
/// 分割线
@property (nonatomic, assign) UIEdgeInsets separateInset;
@property (nonatomic, assign) CGFloat separateHeight;
@property (nonatomic, strong) UIColor *separateColor;
@property (nonatomic, assign) CGFloat separateWidth;
/// 分割线

- (void)slideMenuAtProgress:(CGFloat)progress;
- (void)selectItemAtIndex:(NSInteger)index;
- (void)resetFrames;
- (void)reload;
- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index andWidth:(BOOL)update;
- (void)updateAttributeTitle:(NSAttributedString *)title atIndex:(NSInteger)index andWidth:(BOOL)update;
- (MLSMenuItem *)itemAtIndex:(NSInteger)index;
/// 立即刷新 menuView 的 contentOffset，使 title 居中
- (void)refreshContenOffset;
- (void)deselectedItemsIfNeeded;
/**
 *  更新角标视图，如要移除，在 -menuView:badgeViewAtIndex: 中返回 nil 即可
 */
- (void)updateBadgeViewAtIndex:(NSInteger)index;

@end
