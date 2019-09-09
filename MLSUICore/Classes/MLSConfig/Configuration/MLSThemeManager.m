//
//  MLSThemeManager.m
//  qmuidemo
//
//  Created by MoLice on 2017/5/9.
//  Copyright © 2017年 MLS Team. All rights reserved.
//

#import "MLSThemeManager.h"
#import "QMUIConfigurationTemplate.h"
#import "MLSCommonUI.h"
#import "MLSUIHelper.h"
NSString *const MLSThemeChangedNotification = @"MLSThemeChangedNotification";
NSString *const MLSThemeBeforeChangedName = @"MLSThemeBeforeChangedName";
NSString *const MLSThemeAfterChangedName = @"MLSThemeAfterChangedName";
NSString *const MLSSelectedThemeClassName = @"MLSSelectedThemeClassName";

@implementation MLSThemeManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static MLSThemeManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThemeChangedNotification:) name:MLSThemeChangedNotification object:nil];
    }
    return self;
}

- (void)handleThemeChangedNotification:(NSNotification *)notification {
    NSObject<MLSThemeProtocol> *themeBeforeChanged = notification.userInfo[MLSThemeBeforeChangedName];
    themeBeforeChanged = [themeBeforeChanged isKindOfClass:[NSNull class]] ? nil : themeBeforeChanged;
    
    NSObject<MLSThemeProtocol> *themeAfterChanged = notification.userInfo[MLSThemeAfterChangedName];
    themeAfterChanged = [themeAfterChanged isKindOfClass:[NSNull class]] ? nil : themeAfterChanged;
    
    [self themeBeforeChanged:themeBeforeChanged afterChanged:themeAfterChanged];
}

- (void)setCurrentTheme:(NSObject<MLSThemeProtocol> *)currentTheme {
    BOOL isThemeChanged = _currentTheme != currentTheme;
    NSObject<MLSThemeProtocol> *themeBeforeChanged = nil;
    if (isThemeChanged) {
        themeBeforeChanged = _currentTheme;
    }
    _currentTheme = currentTheme;
    if (isThemeChanged && themeBeforeChanged) {// 从 nil 变成某个 theme 就不发通知了，初始化时会自动 apply，这里只需要处理在 MLS 里手动更改 theme 的场景就行
        [currentTheme applyConfigurationTemplate];
        [[NSNotificationCenter defaultCenter] postNotificationName:MLSThemeChangedNotification object:self userInfo:@{MLSThemeBeforeChangedName: themeBeforeChanged ?: [NSNull null], MLSThemeAfterChangedName: currentTheme ?: [NSNull null]}];
    }
}

#pragma mark - <MLSChangingThemeDelegate>

- (void)themeBeforeChanged:(NSObject<MLSThemeProtocol> *)themeBeforeChanged afterChanged:(NSObject<MLSThemeProtocol> *)themeAfterChanged {
    // 主题发生变化，在这里更新全局 UI 控件的 appearance
    [MLSCommonUI renderGlobalAppearances];
    
    // 更新表情 icon 的颜色
    [MLSUIHelper updateEmotionImages]; 
}

@end
