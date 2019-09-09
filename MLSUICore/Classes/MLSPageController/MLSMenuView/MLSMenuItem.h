//
//  MLSMenuItem.h
//  MLSPageController
//
//  Created by minlison on 18/5/9.
//  Copyright (c) 2018年 minlison. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MLSMenuItem;

typedef NS_ENUM(NSUInteger, MLSMenuItemState) {
    MLSMenuItemStateSelected,
    MLSMenuItemStateNormal,
};

NS_ASSUME_NONNULL_BEGIN
@protocol MLSMenuItemDelegate <NSObject>
@optional
- (void)didPressedMenuItem:(MLSMenuItem *)menuItem;
@end

@interface MLSMenuItem : UILabel

@property (nonatomic, assign) CGFloat rate;           ///> 设置 rate, 并刷新标题状态 (0~1)
@property (nonatomic, assign) CGFloat normalSize;     ///> Normal状态的字体大小，默认大小为15
@property (nonatomic, assign) CGFloat selectedSize;   ///> Selected状态的字体大小，默认大小为18
@property (nonatomic, strong) UIColor *normalColor;   ///> Normal状态的字体颜色，默认为黑色 (可动画)
@property (nonatomic, strong) UIColor *selectedColor; ///> Selected状态的字体颜色，默认为红色 (可动画)
@property (nonatomic, assign) CGFloat speedFactor;    ///> 进度条的速度因数，默认 15，越小越快, 必须大于0
@property (nonatomic, nullable, weak) id<MLSMenuItemDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL selected;

- (void)setSelected:(BOOL)selected withAnimation:(BOOL)animation;

@end
NS_ASSUME_NONNULL_END
