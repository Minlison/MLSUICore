//
//  MLSThemeProtocol.h
//  qmuidemo
//
//  Created by MoLice on 2017/5/9.
//  Copyright © 2017年 MLS Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QMUIKit/QMUIConfiguration.h>
/// 所有主题均应实现这个协议，规定了 MLS Demo 里常用的几个关键外观属性
@protocol MLSThemeProtocol <QMUIConfigurationTemplateProtocol>

@required

- (UIColor *)themeTintColor;
- (UIColor *)themeListTextColor;
- (UIColor *)themeCodeColor;
- (UIColor *)themeGridItemTintColor;

- (NSString *)themeName;

@end


/// 所有能响应主题变化的对象均应实现这个协议，目前主要用于 MLSCommonViewController 及 MLSCommonTableViewController
@protocol MLSChangingThemeDelegate <NSObject>

@required

- (void)themeBeforeChanged:(NSObject<MLSThemeProtocol> *)themeBeforeChanged afterChanged:(NSObject<MLSThemeProtocol> *)themeAfterChanged;

@end
