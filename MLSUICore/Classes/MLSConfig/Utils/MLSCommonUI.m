//
//  MLSCommonUI.m
//  qmuidemo
//
//  Created by MoLice on 16/8/8.
//  Copyright © 2016年 MLS Team. All rights reserved.
//

#import "MLSCommonUI.h"
#import "MLSUIHelper.h"
#import "MLSUICore.h"
#import <QMUIKit/CALayer+QMUI.h>

const CGFloat QMUIButtonSpacingHeight = 72;

@implementation MLSCommonUI

+ (void)renderGlobalAppearances {
    [MLSUIHelper customMoreOperationAppearance];
    [MLSUIHelper customAlertControllerAppearance];
    [MLSUIHelper customDialogViewControllerAppearance];
    [MLSUIHelper customImagePickerAppearance];
    [MLSUIHelper customEmotionViewAppearance];
}

@end

@implementation MLSCommonUI (ThemeColor)

static NSArray<UIColor *> *themeColors = nil;
+ (UIColor *)randomThemeColor {
    if (!themeColors) {
        themeColors = @[UIColorTheme1,
                        UIColorTheme2,
                        UIColorTheme3,
                        UIColorTheme4,
                        UIColorTheme5,
                        UIColorTheme6,
                        UIColorTheme7,
                        UIColorTheme8,
                        UIColorTheme9];
    }
    return themeColors[arc4random() % 9];
}

@end

@implementation MLSCommonUI (Layer)

+ (CALayer *)generateSeparatorLayer {
    CALayer *layer = [CALayer layer];
    [layer qmui_removeDefaultAnimations];
    layer.backgroundColor = UIColorSeparator.CGColor;
    return layer;
}

@end
