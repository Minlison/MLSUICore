//
//  QMUIAlertController+MLSUICore.m
//  MLSUICore
//
//  Created by minlison on 2019/1/16.
//  Copyright © 2019 minlison. All rights reserved.
//
#import <QMUIKit/QMUIKit.h>
#import <MLSUICore/MLSUICore.h>

@interface QMUIAlertController ()
@property(nonatomic, strong, readwrite) UIView *containerView;
@property(nonatomic, strong, readwrite) UIControl *maskView;
@property(nonatomic, strong, readwrite) UIView *scrollWrapView;
@property(nonatomic, strong, readwrite) UIScrollView *headerScrollView;
@property(nonatomic, strong, readwrite) UIScrollView *buttonScrollView;
@property(nonatomic, strong, readwrite) CALayer *extendLayer;
@property(nonatomic, strong, readwrite) UILabel *titleLabel;
@property(nonatomic, strong, readwrite) UILabel *messageLabel;
@property(nonatomic, strong, readwrite) QMUIAlertAction *cancelAction;
@property(nonatomic, strong, readwrite) NSMutableArray<QMUIAlertAction *> *alertActions;
@property(nonatomic, strong, readwrite) NSMutableArray<QMUIAlertAction *> *destructiveActions;
@property(nonatomic, strong, readwrite) NSMutableArray<UITextField *> *alertTextFields;
@property(nonatomic, assign, readwrite) CGFloat keyboardHeight;
@property(nonatomic, assign, readwrite) BOOL willShow;
@property(nonatomic, assign, readwrite) BOOL showing;
@property(nonatomic, assign, readwrite) BOOL isNeedsHideAfterAlertShowed;
@property(nonatomic, assign, readwrite) BOOL isAnimatedForHideAfterAlertShowed;
@property(nonatomic, strong, readwrite) UIView *customView;
+ (void)resetAppearance;
- (void)didInitialized;
- (NSArray *)orderedAlertActions:(NSArray *)actions;
@end

@implementation QMUIAlertController (MLSUICore)
QMUISynthesizeIdStrongProperty(maskColor, setMaskColor)
QMUISynthesizeIdStrongProperty(alertBackgroundColor, setAlertBackgroundColor)
QMUISynthesizeUIEdgeInsetsProperty(alertFooterInsets, setAlertFooterInsets)
QMUISynthesizeCGFloatProperty(alertBtnMargin, setAlertBtnMargin)
QMUISynthesizeIdStrongProperty(sheetBackgroundColor, setSheetBackgroundColor)


+ (void)load {
    ExchangeImplementations(self, @selector(didInitialized), @selector(mls_didInitialized));
    ExchangeImplementations(self, @selector(viewDidLoad), @selector(mls_viewDidLoad));
}

- (void)mls_didInitialized {
    [self mls_didInitialized];
    self.maskColor = UIColorMask;
    self.alertBackgroundColor = [UIColor clearColor];
    self.alertFooterInsets = UIEdgeInsetsZero;
    self.alertBtnMargin = 10;
    self.sheetBackgroundColor = [UIColor clearColor];
}

- (void)mls_viewDidLoad {
    [self mls_viewDidLoad];
    if (self.preferredStyle == QMUIAlertControllerStyleActionSheet) {
        self.containerView.backgroundColor = self.sheetBackgroundColor;
    } else {
        self.containerView.backgroundColor = self.alertBackgroundColor;
    }
}
///重写方法
- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    BOOL hasTitle = (self.titleLabel.text.length > 0 && !self.titleLabel.hidden);
    BOOL hasMessage = (self.messageLabel.text.length > 0 && !self.messageLabel.hidden);
    BOOL hasTextField = self.alertTextFields.count > 0;
    BOOL hasCustomView = !!self.customView;
    CGFloat contentOriginY = 0;
    
    self.maskView.frame = self.view.bounds;
    self.maskView.backgroundColor = self.maskColor;
    
    if (self.preferredStyle == QMUIAlertControllerStyleAlert) {
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        
        CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField || hasCustomView) ? self.alertHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField || hasCustomView) ? self.alertHeaderInsets.bottom : 0;
        self.containerView.qmui_width = fmin(self.alertContentMaximumWidth, CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.alertContentMargin));
        self.scrollWrapView.qmui_width = CGRectGetWidth(self.containerView.bounds);
        self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), 0);
        contentOriginY = contentPaddingTop;
        // 标题和副标题布局
        if (hasTitle) {
            CGFloat titleLabelLimitWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
            CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelLimitWidth, CGFLOAT_MAX)];
            self.titleLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, titleLabelLimitWidth, titleLabelSize.height?:QMUIViewSelfSizingHeight));
            contentOriginY = CGRectGetMaxY(self.titleLabel.frame) + (hasMessage ? self.alertTitleMessageSpacing : contentPaddingBottom);
        }
        if (hasMessage) {
            CGFloat messageLabelLimitWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
            CGSize messageLabelSize = [self.messageLabel sizeThatFits:CGSizeMake(messageLabelLimitWidth, CGFLOAT_MAX)];
            self.messageLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, messageLabelLimitWidth, messageLabelSize.height?:QMUIViewSelfSizingHeight));
            contentOriginY = CGRectGetMaxY(self.messageLabel.frame) + contentPaddingBottom;
        }
        // 输入框布局
        if (hasTextField) {
            for (int i = 0; i < self.alertTextFields.count; i++) {
                UITextField *textField = self.alertTextFields[i];
                CGFloat textFieldWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
                textField.frame = CGRectMake(contentPaddingLeft, contentOriginY, textFieldWidth, 25);
                contentOriginY = CGRectGetMaxY(textField.frame) - 1;
            }
            contentOriginY += 16;
        }
        // 自定义view的布局 - 自动居中
        if (hasCustomView) {
            CGSize customViewSize = [self.customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), CGFLOAT_MAX)];
            self.customView.frame = CGRectFlatted(CGRectMake((CGRectGetWidth(self.headerScrollView.bounds) - customViewSize.width) / 2, contentOriginY, customViewSize.width, customViewSize.height));
            contentOriginY = CGRectGetMaxY(self.customView.frame) + contentPaddingBottom;
        }
        // 内容scrollView的布局
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentOriginY);
        self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), contentOriginY);
        contentOriginY = CGRectGetMaxY(self.headerScrollView.frame);
        // 按钮布局
        self.buttonScrollView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = 0;
        NSArray<QMUIAlertAction *> *newOrderActions = [self orderedAlertActions:self.alertActions];
        if (newOrderActions.count > 0) {
            BOOL verticalLayout = YES;
            if (self.alertActions.count == 2) {
                CGFloat halfWidth = CGRectGetWidth(self.buttonScrollView.bounds) / 2;
                halfWidth = halfWidth - self.alertFooterInsets.left - self.alertFooterInsets.right - self.alertBtnMargin - PixelOne;
                QMUIAlertAction *action1 = newOrderActions[0];
                QMUIAlertAction *action2 = newOrderActions[1];
                CGSize actionSize1 = [action1.button sizeThatFits:CGSizeMax];
                CGSize actionSize2 = [action2.button sizeThatFits:CGSizeMax];
                if (actionSize1.width < halfWidth && actionSize2.width < halfWidth) {
                    verticalLayout = NO;
                }
            }
            if (!verticalLayout) {
                // 对齐系统，先 add 的在右边，后 add 的在左边
                QMUIAlertAction *leftAction = newOrderActions[1];
                CGFloat btnWidth = CGRectGetWidth(self.buttonScrollView.bounds) - self.alertFooterInsets.left - self.alertFooterInsets.right - (self.alertActions.count - 1) * (self.alertBtnMargin + PixelOne);
                CGFloat hafBtnWidth = btnWidth * 0.5;
                leftAction.button.frame = CGRectMake(self.alertFooterInsets.left, contentOriginY, hafBtnWidth, self.alertButtonHeight);
                leftAction.button.qmui_borderPosition = QMUIViewBorderPositionTop|QMUIViewBorderPositionRight;
                
                QMUIAlertAction *rightAction = newOrderActions[0];
                rightAction.button.frame = CGRectMake(CGRectGetMaxX(leftAction.button.frame)  + PixelOne + self.alertBtnMargin,
                                                      contentOriginY + PixelOne,
                                                      hafBtnWidth,
                                                      self.alertButtonHeight);
                rightAction.button.qmui_borderPosition = QMUIViewBorderPositionTop;
                contentOriginY = CGRectGetMaxY(leftAction.button.frame);
            } else {
                for (int i = 0; i < newOrderActions.count; i++) {
                    QMUIAlertAction *action = newOrderActions[i];
                    if (i != newOrderActions.count - 1 && i != 0) {
                        contentOriginY = contentOriginY + self.alertBtnMargin;
                    }
                    action.button.frame = CGRectMake(self.alertFooterInsets.left,
                                                     contentOriginY + PixelOne,
                                                     CGRectGetWidth(self.containerView.bounds) - self.alertFooterInsets.left - self.alertFooterInsets.right,
                                                     self.alertButtonHeight - PixelOne);
                    action.button.qmui_borderPosition = QMUIViewBorderPositionTop;
                    contentOriginY = CGRectGetMaxY(action.button.frame);
                }
            }
        }
        contentOriginY = contentOriginY + self.alertFooterInsets.bottom;
        // 按钮scrollView的布局
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, contentOriginY);
        self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.buttonScrollView.bounds), contentOriginY);
        // 容器最后布局
        CGFloat contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
        CGFloat screenSpaceHeight = CGRectGetHeight(self.view.bounds);
        if (contentHeight > screenSpaceHeight - 20) {
            screenSpaceHeight -= 20;
            CGFloat contentH = fmin(CGRectGetHeight(self.headerScrollView.bounds), screenSpaceHeight / 2);
            CGFloat buttonH = fmin(CGRectGetHeight(self.buttonScrollView.bounds), screenSpaceHeight / 2);
            if (contentH >= screenSpaceHeight / 2 && buttonH >= screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight / 2);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight / 2);
            } else if (contentH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight - contentH);
            } else if (buttonH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight - buttonH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonH);
            }
            contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds);
            screenSpaceHeight += 20;
        }
        self.scrollWrapView.frame =  CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), contentHeight);
        self.mainVisualEffectView.frame = self.scrollWrapView.bounds;
        
        CGRect containerRect = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.containerView.bounds)) / 2, (screenSpaceHeight - contentHeight - self.keyboardHeight) / 2, CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.scrollWrapView.bounds));
        self.containerView.frame = CGRectFlatted(CGRectApplyAffineTransform(containerRect, self.containerView.transform));
    }
    
    else if (self.preferredStyle == QMUIAlertControllerStyleActionSheet) {
        
        CGFloat contentPaddingLeft = self.alertHeaderInsets.left;
        CGFloat contentPaddingRight = self.alertHeaderInsets.right;
        
        CGFloat contentPaddingTop = (hasTitle || hasMessage || hasTextField) ? self.sheetHeaderInsets.top : 0;
        CGFloat contentPaddingBottom = (hasTitle || hasMessage || hasTextField) ? self.sheetHeaderInsets.bottom : 0;
        self.containerView.qmui_width = fmin(self.sheetContentMaximumWidth, CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.sheetContentMargin));
        self.scrollWrapView.qmui_width = CGRectGetWidth(self.containerView.bounds);
        self.headerScrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = contentPaddingTop;
        // 标题和副标题布局
        if (hasTitle) {
            CGFloat titleLabelLimitWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
            CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelLimitWidth, CGFLOAT_MAX)];
            self.titleLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, titleLabelLimitWidth, titleLabelSize.height?:QMUIViewSelfSizingHeight));
            contentOriginY = CGRectGetMaxY(self.titleLabel.frame) + (hasMessage ? self.sheetTitleMessageSpacing : contentPaddingBottom);
        }
        if (hasMessage) {
            CGFloat messageLabelLimitWidth = CGRectGetWidth(self.headerScrollView.bounds) - contentPaddingLeft - contentPaddingRight;
            CGSize messageLabelSize = [self.messageLabel sizeThatFits:CGSizeMake(messageLabelLimitWidth, CGFLOAT_MAX)];
            self.messageLabel.frame = CGRectFlatted(CGRectMake(contentPaddingLeft, contentOriginY, messageLabelLimitWidth, messageLabelSize.height?:QMUIViewSelfSizingHeight));
            contentOriginY = CGRectGetMaxY(self.messageLabel.frame) + contentPaddingBottom;
        }
        // 自定义view的布局 - 自动居中
        if (hasCustomView) {
            CGSize customViewSize = [self.customView sizeThatFits:CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), CGFLOAT_MAX)];
            self.customView.frame = CGRectFlatted(CGRectMake((CGRectGetWidth(self.headerScrollView.bounds) - customViewSize.width) / 2, contentOriginY, customViewSize.width, customViewSize.height));
            contentOriginY = CGRectGetMaxY(self.customView.frame) + contentPaddingBottom;
        }
        // 内容scrollView布局
        self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentOriginY);
        self.headerScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerScrollView.bounds), contentOriginY);
        contentOriginY = CGRectGetMaxY(self.headerScrollView.frame);
        // 按钮的布局
        self.buttonScrollView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), 0);
        contentOriginY = 0;
        NSArray<QMUIAlertAction *> *newOrderActions = [self orderedAlertActions:self.alertActions];
        if (self.alertActions.count > 0) {
            contentOriginY = (hasTitle || hasMessage || hasCustomView) ? contentOriginY : contentOriginY;
            for (int i = 0; i < newOrderActions.count; i++) {
                QMUIAlertAction *action = newOrderActions[i];
                if (action.style == QMUIAlertActionStyleCancel && i == newOrderActions.count - 1) {
                    continue;
                } else {
                    action.button.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.buttonScrollView.bounds), self.sheetButtonHeight - PixelOne);
                    action.button.qmui_borderPosition = QMUIViewBorderPositionTop;
                    contentOriginY = CGRectGetMaxY(action.button.frame) + PixelOne;
                }
            }
            contentOriginY -= PixelOne;
        }
        // 按钮scrollView布局
        self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, contentOriginY);
        self.buttonScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.buttonScrollView.bounds), contentOriginY);
        // 容器最终布局
        self.scrollWrapView.frame =  CGRectMake(0, 0, CGRectGetWidth(self.scrollWrapView.bounds), CGRectGetMaxY(self.buttonScrollView.frame));
        self.mainVisualEffectView.frame = self.scrollWrapView.bounds;
        contentOriginY = CGRectGetMaxY(self.scrollWrapView.frame) + self.sheetCancelButtonMarginTop;
        if (self.cancelAction) {
            self.cancelButtonVisualEffectView.frame = CGRectMake(0, contentOriginY, CGRectGetWidth(self.containerView.bounds), self.sheetButtonHeight);
            self.cancelAction.button.frame = self.cancelButtonVisualEffectView.bounds;
            contentOriginY = CGRectGetMaxY(self.cancelButtonVisualEffectView.frame);
        }
        // 把上下的margin都加上用于跟整个屏幕的高度做比较
        CGFloat contentHeight = contentOriginY + UIEdgeInsetsGetVerticalValue(self.sheetContentMargin);
        CGFloat screenSpaceHeight = CGRectGetHeight(self.view.bounds);
        if (contentHeight > screenSpaceHeight) {
            CGFloat cancelButtonAreaHeight = (self.cancelAction ? (CGRectGetHeight(self.cancelAction.button.bounds) + self.sheetCancelButtonMarginTop) : 0);
            screenSpaceHeight = screenSpaceHeight - cancelButtonAreaHeight - UIEdgeInsetsGetVerticalValue(self.sheetContentMargin);
            CGFloat contentH = MIN(CGRectGetHeight(self.headerScrollView.bounds), screenSpaceHeight / 2);
            CGFloat buttonH = MIN(CGRectGetHeight(self.buttonScrollView.bounds), screenSpaceHeight / 2);
            if (contentH >= screenSpaceHeight / 2 && buttonH >= screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight / 2);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight / 2);
            } else if (contentH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, contentH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, screenSpaceHeight - contentH);
            } else if (buttonH < screenSpaceHeight / 2) {
                self.headerScrollView.frame = CGRectSetHeight(self.headerScrollView.frame, screenSpaceHeight - buttonH);
                self.buttonScrollView.frame = CGRectSetY(self.buttonScrollView.frame, CGRectGetMaxY(self.headerScrollView.frame));
                self.buttonScrollView.frame = CGRectSetHeight(self.buttonScrollView.frame, buttonH);
            }
            self.scrollWrapView.frame =  CGRectSetHeight(self.scrollWrapView.frame, CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds));
            if (self.cancelAction) {
                self.cancelButtonVisualEffectView.frame = CGRectSetY(self.cancelButtonVisualEffectView.frame, CGRectGetMaxY(self.scrollWrapView.frame) + self.sheetCancelButtonMarginTop);
            }
            contentHeight = CGRectGetHeight(self.headerScrollView.bounds) + CGRectGetHeight(self.buttonScrollView.bounds) + cancelButtonAreaHeight + self.sheetContentMargin.bottom;
            screenSpaceHeight += (cancelButtonAreaHeight + UIEdgeInsetsGetVerticalValue(self.sheetContentMargin));
        } else {
            // 如果小于屏幕高度，则把顶部的top减掉
            contentHeight -= self.sheetContentMargin.top;
        }
        
        CGRect containerRect = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.containerView.bounds)) / 2, screenSpaceHeight - contentHeight - SafeAreaInsetsConstantForDeviceWithNotch.bottom, CGRectGetWidth(self.containerView.bounds), contentHeight + (self.isExtendBottomLayout ? SafeAreaInsetsConstantForDeviceWithNotch.bottom : 0));
        self.containerView.frame = CGRectFlatted(CGRectApplyAffineTransform(containerRect, self.containerView.transform));
        
        self.extendLayer.frame = CGRectFlatMake(0, CGRectGetHeight(self.containerView.bounds) - SafeAreaInsetsConstantForDeviceWithNotch.bottom - 1, CGRectGetWidth(self.containerView.bounds), SafeAreaInsetsConstantForDeviceWithNotch.bottom + 1);
    }
}

@end





@interface QMUIAlertController_MLSUICore_Imp : NSObject
@end
@implementation QMUIAlertController_MLSUICore_Imp
@end
