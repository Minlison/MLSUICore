//
//  MLSUIAlertAction.m
//  MLSUICore
//
//  Created by minlison on 2018/5/23.
//

#import "MLSUIAlertAction.h"
#import "MLSConfigurationDefine.h"
#import "MLSUICore.h"
#import <QMUIKit/QMUIKit.h>
@interface QMUIAlertAction (Private)
@property(nonatomic, assign, readwrite) QMUIAlertActionStyle style;
@property(nonatomic, copy, readwrite) NSString *title;
@property(nonatomic, copy, readwrite) void (^handler)(QMUIAlertController *aAlertController, QMUIAlertAction *action);
@end
@implementation MLSUIAlertAction
+ (nonnull instancetype)actionWithTitle:(nullable NSString *)title style:(QMUIAlertActionStyle)style handler:(void (^)(__kindof QMUIAlertController *, QMUIAlertAction *))handler {
    MLSUIAlertAction *alertAction = [[MLSUIAlertAction alloc] init];
    alertAction.title = title;
    alertAction.style = style;
    alertAction.handler = handler;
    return alertAction;
}
- (void)setStyle:(QMUIAlertActionStyle)style {
    [super setStyle:style];
    self.button.layer.cornerRadius = __MLSHeight(22);
//    self.button.clipsToBounds = YES;
    switch (style) {
        case QMUIAlertActionStyleDefault: {
            UIImage *image = [UIImage qmui_imageWithStrokeColor:UIColorMakeWithHex(@"#FF9800") size:CGSizeMake(__MLSWidth(80), __MLSHeight(44)) lineWidth:__MLSHeight(1) cornerRadius:__MLSHeight(22)];
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, image.size.width * 0.5 - 1, 0, image.size.width * 0.5 - 1) resizingMode:(UIImageResizingModeStretch)];
            [self.button setBackgroundImage:image forState:(UIControlStateNormal)];
        }
            break;
        case QMUIAlertActionStyleCancel:
        case QMUIAlertActionStyleDestructive:{
            UIColor *color =  [UIColor colorWithPatternImage:[MLSUICoreBuldleImage(@"reload_button") qmui_imageResizedInLimitedSize:CGSizeMake(__MLSWidth(80), __MLSHeight(44)) resizingMode:(QMUIImageResizingModeScaleAspectFill)]];
            UIImage *image = [UIImage qmui_imageWithColor:color size:CGSizeMake(__MLSWidth(80), __MLSHeight(44)) cornerRadiusArray:@[@(__MLSHeight(22)),@(__MLSHeight(22)),@(__MLSHeight(22)),@(__MLSHeight(22))]];
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, image.size.width * 0.5 - 0.5, 0, image.size.width * 0.5 - 0.5) resizingMode:(UIImageResizingModeStretch)];
            [self.button setBackgroundImage:image forState:(UIControlStateNormal)];
        }
            break;
        default:
            break;
    }
}

@end
@implementation MLSUIOverturnAction
+ (nonnull instancetype)actionWithTitle:(nullable NSString *)title style:(QMUIAlertActionStyle)style handler:(void (^)(__kindof QMUIAlertController *, QMUIAlertAction *))handler {
    MLSUIOverturnAction *alertAction = [[MLSUIOverturnAction alloc] init];
    alertAction.title = title;
    alertAction.style = style;
    alertAction.handler = handler;
    return alertAction;
}
- (void)setStyle:(QMUIAlertActionStyle)style {
    [super setStyle:style];
    self.button.layer.cornerRadius = __MLSHeight(22);
    //    self.button.clipsToBounds = YES;
    switch (style) {
        case QMUIAlertActionStyleDefault: {
            UIColor *color =  [UIColor colorWithPatternImage:[MLSUICoreBuldleImage(@"reload_button") qmui_imageResizedInLimitedSize:CGSizeMake(__MLSWidth(80), __MLSHeight(44)) resizingMode:(QMUIImageResizingModeScaleAspectFill)]];
            UIImage *image = [UIImage qmui_imageWithColor:color size:CGSizeMake(__MLSWidth(80), __MLSHeight(44)) cornerRadiusArray:@[@(__MLSHeight(22)),@(__MLSHeight(22)),@(__MLSHeight(22)),@(__MLSHeight(22))]];
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, image.size.width * 0.5 - 0.5, 0, image.size.width * 0.5 - 0.5) resizingMode:(UIImageResizingModeStretch)];
            [self.button setBackgroundImage:image forState:(UIControlStateNormal)];
        }
            break;
        case QMUIAlertActionStyleCancel:
        case QMUIAlertActionStyleDestructive:{
            UIImage *image = [UIImage qmui_imageWithStrokeColor:UIColorMakeWithHex(@"#FF8800") size:CGSizeMake(__MLSWidth(80), __MLSHeight(44)) lineWidth:__MLSHeight(1) cornerRadius:__MLSHeight(22)];
            image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, image.size.width * 0.5 - 0.5, 0, image.size.width * 0.5 - 0.5) resizingMode:(UIImageResizingModeStretch)];
            [self.button setBackgroundImage:image forState:(UIControlStateNormal)];
            
        }
            break;
        default:
            break;
    }
}

@end
