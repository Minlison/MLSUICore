//
//  QMUITextField+MLSUICore.m
//  MLSUICore
//
//  Created by minlison on 2019/1/16.
//  Copyright © 2019 minlison. All rights reserved.
//
#import <objc/runtime.h>
#import "QMUITextField+MLSUICore.h"


@implementation QMUITextField (MLSUICore)
- (void)setPlaceholderFont:(UIFont *)placeholderFont {
    objc_setAssociatedObject(self, @selector(placeholderFont), placeholderFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.placeholder) {
        [self updateAttributedPlaceholderIfNeeded];
    }
}
- (UIFont *)placeholderFont {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)updateAttributedPlaceholderIfNeeded {
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:2];
    if (self.placeholderColor) {
        [attributes setObject:self.placeholderColor forKey:NSForegroundColorAttributeName];
    }
    if (self.placeholderFont) {
        [attributes setObject:self.placeholderFont forKey:NSFontAttributeName];
    }
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:attributes];
}
@end




@interface QMUITextField_MLSUICore_Imp : NSObject
@end
@implementation QMUITextField_MLSUICore_Imp
@end
