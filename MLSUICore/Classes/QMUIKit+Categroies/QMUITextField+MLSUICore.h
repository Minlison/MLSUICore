//
//  QMUITextField+MLSUICore.h
//  MLSUICore
//
//  Created by minlison on 2019/1/16.
//  Copyright © 2019 minlison. All rights reserved.
//


#import <QMUIKit/QMUITextField.h>
NS_ASSUME_NONNULL_BEGIN

@interface QMUITextField (MLSUICore)
/**
 占位文本字体
 */
@property(nonatomic, strong) IBInspectable UIFont *placeholderFont;
@end

NS_ASSUME_NONNULL_END
