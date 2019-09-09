//
//  QMUIAlertController+MLSUICore.h
//  MLSUICore
//
//  Created by minlison on 2019/1/16.
//  Copyright © 2019 minlison. All rights reserved.
//

#import <QMUIKit/QMUIAlertController.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMUIAlertController (MLSUICore)
/// 底部背景色 默认 UIColorMask
@property (nonatomic, strong) UIColor *maskColor;
/// Alert 弹框背景色
@property(nonatomic, strong) UIColor *alertBackgroundColor;
/// Alert 底部按钮视图间距
@property(nonatomic, assign) UIEdgeInsets alertFooterInsets;
/// Alert 弹框，按钮间距
@property(nonatomic, assign) CGFloat alertBtnMargin;
/// Sheet 背景色
@property(nonatomic, strong) UIColor *sheetBackgroundColor;
@end

NS_ASSUME_NONNULL_END
