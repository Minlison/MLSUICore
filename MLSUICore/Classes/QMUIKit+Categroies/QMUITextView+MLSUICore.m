//
//  QMUITextView+MLSUICore.m
//  MLSUICore
//
//  Created by minlison on 2019/1/16.
//  Copyright © 2019 minlison. All rights reserved.
//

#import <objc/runtime.h>
#import <QMUIKit/QMUIKit.h>

@interface QMUITextView (MLSUICore_Private)
@property(nonatomic, assign, readwrite) BOOL debug;
@property(nonatomic, assign, readwrite) BOOL shouldRejectSystemScroll;
@property(nonatomic, strong, readwrite) UILabel *placeholderLabel;
- (void)updatePlaceholderLabelHidden;
- (void)qmui_scrollCaretVisibleAnimated:(BOOL)animated;
@end

@implementation QMUITextView (MLSUICore)

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
    objc_setAssociatedObject(self, @selector(attributedPlaceholder), attributedPlaceholder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.placeholderLabel.attributedText = attributedPlaceholder;
    if (self.placeholderColor) {
        self.placeholderLabel.textColor = self.placeholderColor;
    }
    [self sendSubviewToBack:self.placeholderLabel];
    [self setNeedsLayout];
}
- (NSAttributedString *)attributedPlaceholder {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setAutoResizable:(BOOL)autoResizable {
    objc_setAssociatedObject(self, @selector(autoResizable), @(autoResizable), OBJC_ASSOCIATION_ASSIGN);
}
- (BOOL)autoResizable {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setResizeCallBackBlock:(void (^)(QMUITextView * _Nonnull, CGFloat))resizeCallBackBlock {
    objc_setAssociatedObject(self, @selector(resizeCallBackBlock), resizeCallBackBlock, OBJC_ASSOCIATION_COPY);
}
- (void (^)(QMUITextView * _Nonnull, CGFloat))resizeCallBackBlock {
    return objc_getAssociatedObject(self, _cmd);
}
/// 覆盖父类方法
- (void)handleTextChanged:(id)sender {
    // 输入字符的时候，placeholder隐藏
    if(self.placeholder.length > 0) {
        [self updatePlaceholderLabelHidden];
    }
    
    QMUITextView *textView = nil;
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        id object = ((NSNotification *)sender).object;
        if (object == self) {
            textView = (QMUITextView *)object;
        }
    } else if ([sender isKindOfClass:[QMUITextView class]]) {
        textView = (QMUITextView *)sender;
    }
    
    if (textView) {
        
        // 计算高度
        if (self.resizeCallBackBlock) {
            
            CGFloat resultHeight = flat([textView sizeThatFits:CGSizeMake(CGRectGetWidth(textView.bounds), CGFLOAT_MAX)].height);
            
            if (textView.debug) QMUILog(NSStringFromClass(textView.class), @"handleTextDidChange, text = %@, resultHeight = %f", textView.text, resultHeight);
            
            
            // 通知delegate去更新textView的高度
            if (resultHeight != flat(CGRectGetHeight(textView.bounds))) {
                [textView.delegate textView:textView newHeightAfterTextChanged:resultHeight];
            }
        }
        
        // textView 尚未被展示到界面上时，此时过早进行光标调整会计算错误
        if (!textView.window) {
            return;
        }
        
        textView.shouldRejectSystemScroll = YES;
        // 用 dispatch 延迟一下，因为在文字发生换行时，系统自己会做一些滚动，我们要延迟一点才能避免被系统的滚动覆盖
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            textView.shouldRejectSystemScroll = NO;
            [textView qmui_scrollCaretVisibleAnimated:NO];
        });
    }
}
@end



@interface QMUITextView_MLSUICore_Imp : NSObject
@end
@implementation QMUITextView_MLSUICore_Imp
@end
