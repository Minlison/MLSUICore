//
//  MLSThemeManager.h
//  qmuidemo
//
//  Created by MoLice on 2017/5/9.
//  Copyright © 2017年 MLS Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLSThemeProtocol.h"
/// 当主题发生变化时，会发送这个通知
extern NSString *const MLSThemeChangedNotification;

/// 主题发生改变前的值，类型为 NSObject<MLSThemeProtocol>，可能为 NSNull
extern NSString *const MLSThemeBeforeChangedName;

/// 主题发生改变后的值，类型为 NSObject<MLSThemeProtocol>，可能为 NSNull
extern NSString *const MLSThemeAfterChangedName;

/// 选中的主题 Class 名
extern NSString *const MLSSelectedThemeClassName;

/**
 *  MLS Demo 的皮肤管理器，当需要换肤时，请为 currentTheme 赋值；当需要获取当前皮肤时，可访问 currentTheme 属性。
 *  可通过监听 MLSThemeChangedNotification 通知来捕获换肤事件，默认地，MLSCommonViewController 及 MLSCommonTableViewController 均已支持响应换肤，其响应方法是通过 MLSChangingThemeDelegate 接口来实现的。
 */
@interface MLSThemeManager : NSObject<MLSChangingThemeDelegate>

+ (instancetype)sharedInstance;

@property(nonatomic, strong) NSObject<MLSThemeProtocol> *currentTheme;
@end
