//
//  MLSAlertController.m
//  MLSUICore
//
//  Created by minlison on 2018/5/23.
//

#import "MLSAlertController.h"
#import "MLSConfigurationDefine.h"
#import "MLSFontUtils.h"
#import "QMUIAlertController+MLSUICore.h"
#import <QMUIKit/UIImage+QMUI.h>
@interface QMUIAlertController (MLSAlert)
- (void)didInitialized;
@end

@interface MLSAlertController ()

@end

@implementation MLSAlertController
+ (instancetype)overturnAlertWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(QMUIAlertControllerStyle)preferredStyle {
    MLSAlertController *alert = [[MLSAlertController alloc] initWithTitle:title message:message preferredStyle:(preferredStyle)];
    [alert _initOverTurnAlert];
    return alert;
}
+ (instancetype)defaultAlertWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(QMUIAlertControllerStyle)preferredStyle {
    MLSAlertController *alert = [[MLSAlertController alloc] initWithTitle:title message:message preferredStyle:(preferredStyle)];
    [alert _initDefaultAlert];
    return alert;
}
- (void)didInitialized {
    [super didInitialized];
    [self _initDefaultAlert];
}
- (void)_initOverTurnAlert {
    [self setMaskColor:[UIColor colorWithWhite:0 alpha:0.7]];
    [self setAlertBackgroundColor:[UIColor whiteColor]];
    [self setAlertHeaderBackgroundColor:[UIColor whiteColor]];
    [self setAlertButtonBackgroundColor:[UIColor whiteColor]];
    [self setAlertSeparatorColor:[UIColor whiteColor]];
    [self setAlertContentCornerRadius:8];
    [self setAlertButtonHeight:__MLSHeight(44)];
    [self setAlertTitleMessageSpacing:__MLSHeight(20)];
    [self setAlertHeaderInsets:UIEdgeInsetsMake(__MLSHeight(30), __MLSWidth(15), __MLSHeight(33), __MLSWidth(15))];
    [self setAlertContentMargin:UIEdgeInsetsMake(0, __MLSWidth(42), 0, __MLSWidth(42))];
    self.alertContentMaximumWidth = __MLSWidth(291);
    self.alertFooterInsets = UIEdgeInsetsMake(0, __MLSWidth(20), __MLSHeight(30), __MLSWidth(20));
    self.alertBtnMargin = __MLSWidth(11);
    
    NSMutableDictionary *alertTitleDict = [NSMutableDictionary dictionaryWithDictionary:[QMUIAlertController appearance].alertTitleAttributes];
    [alertTitleDict setValuesForKeysWithDictionary:@{
                                                     NSFontAttributeName : MLSBoldSystem20Font,
                                                     NSForegroundColorAttributeName : UIColorHex(0x333333)
                                                     }];
    [self setAlertTitleAttributes:alertTitleDict];
    NSMutableDictionary *alertMsgDict = [NSMutableDictionary dictionaryWithDictionary:[QMUIAlertController appearance].alertMessageAttributes];
    [alertMsgDict setValuesForKeysWithDictionary:@{
                                                   NSFontAttributeName : MLSSystem16Font,
                                                   NSForegroundColorAttributeName : UIColorHex(0x333333)
                                                   }];
    [self setAlertMessageAttributes:alertMsgDict];
    
    NSMutableDictionary *alertBtnDict = [NSMutableDictionary dictionaryWithDictionary:[QMUIAlertController appearance].alertButtonAttributes];
    [alertBtnDict setValuesForKeysWithDictionary:@{
                                                   NSFontAttributeName : MLSBoldSystem16Font,
                                                   NSForegroundColorAttributeName : UIColorHex(0xFFFFFF)
                                                   }];
    
    [self setAlertButtonAttributes:alertBtnDict];
    
    NSMutableDictionary *alertCancelBtnDict = [NSMutableDictionary dictionaryWithDictionary:[QMUIAlertController appearance].alertCancelButtonAttributes];
    [alertCancelBtnDict setValuesForKeysWithDictionary:@{
                                                         NSFontAttributeName : MLSBoldSystem16Font,
                                                         NSForegroundColorAttributeName : UIColorHex(0xFF8800)
                                                         }];
    [self setAlertCancelButtonAttributes:alertCancelBtnDict];
    
    NSMutableDictionary *alertDestructiveBtnDict = [NSMutableDictionary dictionaryWithDictionary:[QMUIAlertController appearance].alertDestructiveButtonAttributes];
    [alertDestructiveBtnDict setValuesForKeysWithDictionary:@{
                                                              NSFontAttributeName : MLSBoldSystem16Font,
                                                              NSForegroundColorAttributeName : UIColorHex(0xFF8800)
                                                              }];
    [self setAlertDestructiveButtonAttributes:alertDestructiveBtnDict];
    
}
- (void)_initDefaultAlert {
    [self setMaskColor:[UIColor colorWithWhite:0 alpha:0.7]];
    [self setAlertBackgroundColor:[UIColor whiteColor]];
    [self setAlertHeaderBackgroundColor:[UIColor whiteColor]];
    [self setAlertButtonBackgroundColor:[UIColor whiteColor]];
    [self setAlertSeparatorColor:[UIColor whiteColor]];
    [self setAlertContentCornerRadius:8];
    [self setAlertButtonHeight:__MLSHeight(44)];
    [self setAlertTitleMessageSpacing:__MLSHeight(20)];
    [self setAlertHeaderInsets:UIEdgeInsetsMake(__MLSHeight(30), __MLSWidth(15), __MLSHeight(33), __MLSWidth(15))];
    [self setAlertContentMargin:UIEdgeInsetsMake(0, __MLSWidth(42), 0, __MLSWidth(42))];
    self.alertContentMaximumWidth = __MLSWidth(291);
    self.alertFooterInsets = UIEdgeInsetsMake(0, __MLSWidth(20), __MLSHeight(30), __MLSWidth(20));
    self.alertBtnMargin = __MLSWidth(11);
    NSMutableDictionary *alertTitleDict = [NSMutableDictionary dictionaryWithDictionary:[QMUIAlertController appearance].alertTitleAttributes];
    [alertTitleDict setValuesForKeysWithDictionary:@{
                                                     NSFontAttributeName : MLSBoldSystem20Font,
                                                     NSForegroundColorAttributeName : UIColorHex(0x333333),
                                                     }];
    [self setAlertTitleAttributes:alertTitleDict];
    NSMutableDictionary *alertMsgDict = [NSMutableDictionary dictionaryWithDictionary:[QMUIAlertController appearance].alertMessageAttributes];
    [alertMsgDict setValuesForKeysWithDictionary:@{
                                                   NSFontAttributeName : MLSSystem16Font,
                                                   NSForegroundColorAttributeName : UIColorHex(0x333333)
                                                   }];
    [self setAlertMessageAttributes:alertMsgDict];
    
    NSMutableDictionary *alertBtnDict = [NSMutableDictionary dictionaryWithDictionary:[QMUIAlertController appearance].alertButtonAttributes];
    [alertBtnDict setValuesForKeysWithDictionary:@{
                                                   NSFontAttributeName : MLSBoldSystem16Font,
                                                   NSForegroundColorAttributeName : UIColorHex(0xFF8800)
                                                   }];
    
    [self setAlertButtonAttributes:alertBtnDict];
    
    NSMutableDictionary *alertCancelBtnDict = [NSMutableDictionary dictionaryWithDictionary:[QMUIAlertController appearance].alertCancelButtonAttributes];
    [alertCancelBtnDict setValuesForKeysWithDictionary:@{
                                                         NSFontAttributeName : MLSBoldSystem16Font,
                                                         NSForegroundColorAttributeName : UIColorHex(0xFFFFFF)
                                                         }];
    [self setAlertCancelButtonAttributes:alertCancelBtnDict];
    
    NSMutableDictionary *alertDestructiveBtnDict = [NSMutableDictionary dictionaryWithDictionary:[QMUIAlertController appearance].alertDestructiveButtonAttributes];
    [alertDestructiveBtnDict setValuesForKeysWithDictionary:@{
                                                              NSFontAttributeName : MLSBoldSystem16Font,
                                                              NSForegroundColorAttributeName : UIColorHex(0xFFFFFF)
                                                              }];
    [self setAlertDestructiveButtonAttributes:alertDestructiveBtnDict];
}
@end
