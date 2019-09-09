//
//  QMUITextView+MLSUICore.h
//  MLSUICore
//
//  Created by minlison on 2019/1/16.
//  Copyright © 2019 minlison. All rights reserved.
//

#import <QMUIKit/QMUITextView.h>
NS_ASSUME_NONNULL_BEGIN

@interface QMUITextView (MLSUICore)

/**
 placehoder 属性文本
 */

@property (nonatomic, copy) NSAttributedString *attributedPlaceholder;

/**
 *  是否支持自动拓展高度，默认为NO
 *  @see textView:newHeightAfterTextChanged:
 */
@property(nonatomic, assign) BOOL autoResizable;

/**
 *  输入框高度发生变化时的回调，仅当 `autoResizable` 属性为 YES 时才有效。
 *  @note 只有当内容高度与当前输入框的高度不一致时才会调用到这里，所以无需在内部做高度是否变化的判断。
 */
@property (nonatomic, copy) void (^resizeCallBackBlock)(QMUITextView *textView, CGFloat newHeight);
@end

NS_ASSUME_NONNULL_END
