//
//  MLSAlertController.h
//  MLSUICore
//
//  Created by minlison on 2018/5/23.
//
#import <QMUIKit/QMUIAlertController.h>
@interface MLSAlertController : QMUIAlertController

/**
 默认的弹框

 @return 默认弹框, 确定按钮 白色背景, 取消按钮 橙色背景
 */
+ (instancetype)defaultAlertWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(QMUIAlertControllerStyle)preferredStyle;

/**
 默认的弹框 翻转
 
 @return 默认弹框, 确定按钮 橙色背景, 取消按钮 白色背景
 */
+ (instancetype)overturnAlertWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(QMUIAlertControllerStyle)preferredStyle;
@end
