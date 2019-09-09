//
//  MLSBaseCommentToolBar.m
//  MinLison
//
//  Created by MinLison on 2017/11/7.
//  Copyright © 2017年 minlison. All rights reserved.
//

#import "MLSBaseCommentToolBar.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<QMUIKit/QMUIKit.h>)
#import <QMUIKit/QMUIKit.h>
#else
#import "QMUIKit.h"
#endif
#import "MLSFontUtils.h"
#import "MLSConfigurationDefine.h"
#import "QMUITextField+MLSUICore.h"
#import "QMUITextView+MLSUICore.h"


#define KMLSCommentToolBarSendBtnWidth             34
#define KMLSCommentToolBarTopMargin                8
#define KMLSCommentToolBarBottomMargin             8
#define KMLSCommentToolBarLeftMargin               15
#define KMLSCommentToolBarRightMargin              17
#define KMLSCommentToolBarDistance                 5
#define KMLSCommentToolBarTextView_Emotion         17
#define KMLSCommentToolBarEmotion_SendBtn          0

#define KMLSCommentToolBarResizeableHeight         48
#define KMLSCommentTextViewResizeableHeight        32
#define KMLSCommentToolBarNormalHeight             48
#define KMLSCommentTextViewNormalHeight            32

@interface MLSBaseCommentToolBar ()<QMUITextViewDelegate, QMUITextFieldDelegate>
@property(nonatomic, copy) MLSBaseCommentToolBarActionBlock actionBlock;
@property(nonatomic, strong) QMUITextView *textView;
@property(nonatomic, strong) QMUITextField *textField;
@property(nonatomic, strong) QMUIButton *sendButton;
@property(nonatomic, strong) QMUIButton *emotionButton;
@property(nonatomic, assign, getter=isHasEmotion) BOOL hasEmotion;
#ifdef MLSCommentToolBarUseEmotion
@property(nonatomic, weak) QMUIEmotionInputManager *qqEmotionManager;
#endif
@property(nonatomic, assign) BOOL autoResizeble;
@property(nonatomic, strong) UIView *textViewContainer;
@property(nonatomic, strong) UIView *bottomLineView;
@property(nonatomic, assign) CGFloat maxExpandHeight;
@property(nonatomic, strong) UIImageView *topShadowImgView;
@end

@implementation MLSBaseCommentToolBar

- (instancetype)init {
    return [self initWithEmotion:NO];
}
- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithEmotion:NO];
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithEmotion:NO];
}

- (instancetype)initWithEmotion:(BOOL)emotion {
    if (self = [super initWithFrame:CGRectZero]) {
        self.hasEmotion = emotion;
        [self _SetupView];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (NSString *)text {
    return self.autoResizeble ? self.textView.text : self.textField.text;
}
#if __IPHONE_OS_VERSION_MIN_REQUIRED > __IPHONE_10_0
- (id<UITextInput,UIContentSizeCategoryAdjusting>)realTextView {
    return self.textView.isHidden ? self.textField : self.textView;
}
#else
- (id<UITextInput>)realTextView {
    return self.textView.isHidden ? self.textField : self.textView;
}
#endif

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    self.bottomLineView.backgroundColor = backgroundColor;
}
- (void)_SetupView {
    self.topShadowImgView = [[UIImageView alloc] initWithImage:[UIImage qmui_imageWithColor:[UIColor clearColor]]];
    self.bottomLineView = [[UIView alloc] init];
    self.bottomLineView.backgroundColor = self.backgroundColor;
    [self addSubview:self.bottomLineView];
    [self.bottomLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(10);
    }];
    UIView *textViewContainer = [[UIView alloc] init];
    textViewContainer.backgroundColor = [UIColor clearColor];
    [textViewContainer addSubview:self.textField];
    [textViewContainer addSubview:self.textView];
    [self addSubview:self.topShadowImgView];
    
    self.textViewContainer = textViewContainer;
    [self addSubview:textViewContainer];
    [self addSubview:self.sendButton];
    [self addSubview:self.emotionButton];
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(textViewContainer);
    }];
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(textViewContainer);
    }];
    [self.topShadowImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_top);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(2);
    }];
    [self.sendButton addTarget:self
                        action:@selector(sendButtonDidClick:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.emotionButton addTarget:self
                           action:@selector(semotionButtonDidClick:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self _ReLayoutView];
}
- (void)sendButtonDidClick:(UIButton *)btn {
    if (self.actionBlock) {
        self.actionBlock(MLSBaseCommentToolBarActionTypeSend, self);
    }
}
- (void)semotionButtonDidClick:(UIButton *)btn {
    if (self.actionBlock) {
        self.emotionButton.selected = !self.emotionButton.selected;
        self.actionBlock(self.emotionButton.isSelected ? MLSBaseCommentToolBarActionTypeShowEmotion : MLSBaseCommentToolBarActionTypeHideEmotion, self);
        
    }
}
- (void)_ReLayoutView {
    [self.textViewContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(KMLSCommentToolBarLeftMargin);
        make.top.equalTo(self).offset(KMLSCommentToolBarTopMargin);
        make.bottom.equalTo(self).offset(-KMLSCommentToolBarBottomMargin);
        if (self.autoResizeble)
        {
            make.height.mas_equalTo(KMLSCommentTextViewResizeableHeight);
        }
        else
        {
            make.height.mas_equalTo(KMLSCommentTextViewNormalHeight);
        }
    }];
    if (!self.autoResizeble) {
        self.realTextView.layer.cornerRadius = KMLSCommentTextViewNormalHeight * 0.5;
        self.realTextView.clipsToBounds = YES;
    }
    else {
        self.realTextView.layer.borderColor  = [UIColor clearColor].CGColor;
        self.realTextView.layer.cornerRadius = 1.0;
        self.realTextView.clipsToBounds = YES;
    }
    self.emotionButton.hidden = !self.hasEmotion;
    [self.emotionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textView.mas_right).offset(KMLSCommentToolBarTextView_Emotion);
        make.width.mas_equalTo(self.hasEmotion ? KMLSCommentToolBarSendBtnWidth : 0);
        if (self.autoResizeble)
        {
            make.bottom.equalTo(self).offset(-KMLSCommentToolBarBottomMargin);
        }
        else
        {
            make.top.bottom.equalTo(self.textViewContainer);
        }
    }];
    [self.sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.emotionButton.mas_right).offset(self.hasEmotion ? KMLSCommentToolBarDistance : 0);
        make.right.equalTo(self.mas_right).offset(-KMLSCommentToolBarRightMargin);
        make.width.mas_equalTo(KMLSCommentToolBarSendBtnWidth);
        make.top.bottom.equalTo(self.emotionButton);
    }];
    
}
/// MARK: TextView Delegate

- (void)textViewDidChangeSelection:(UITextView *)textView {
#ifdef MLSCommentToolBarUseEmotion
    self.qqEmotionManager.selectedRangeForBoundTextInput = [self.textView qmui_convertNSRangeFromUITextRange:textView.selectedTextRange];
#endif
}
/// MARK: - QMUITextView delegate
- (void)textView:(QMUITextView *)textView newHeightAfterTextChanged:(CGFloat)height {
    [self.textViewContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(MIN(MAX(height, KMLSCommentTextViewResizeableHeight), self.maxExpandHeight));
    }];
}
- (BOOL)textViewShouldReturn:(QMUITextView *)textView {
    if (self.actionBlock) {
        self.actionBlock(MLSBaseCommentToolBarActionTypeSend, self);
    }
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(commentToolBarWillHide:)]) {
        return [self.delegate commentToolBarWillShow:self];
    }
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.emotionButton.selected = NO;
    if ([self.delegate respondsToSelector:@selector(commentToolBarWillShow:)]) {
        return [self.delegate commentToolBarWillShow:self];
    }
    return YES;
}

/// MARK: TextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.emotionButton.selected = NO;
    if ([self.delegate respondsToSelector:@selector(commentToolBarWillShow:)]) {
        return [self.delegate commentToolBarWillShow:self];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
#ifdef MLSCommentToolBarUseEmotion
    self.qqEmotionManager.selectedRangeForBoundTextInput = self.textField.qmui_selectedRange;
#endif
    if ([self.delegate respondsToSelector:@selector(commentToolBarWillHide:)]) {
        return [self.delegate commentToolBarWillShow:self];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.actionBlock) {
        self.actionBlock(MLSBaseCommentToolBarActionTypeSend, self);
    }
    return YES;
}


/// MARK: - Protocol
- (void)setPlaceHolder:(id)placeHolder {
    if (placeHolder == nil) {
        return;
    }
    if ([placeHolder isKindOfClass:[NSString class]]) {
        self.textView.placeholder = placeHolder;
        self.textField.placeholder = placeHolder;
    } else if ([placeHolder isKindOfClass:[NSAttributedString class]]) {
        self.textView.attributedPlaceholder = placeHolder;
        self.textField.attributedPlaceholder = placeHolder;
    }
}
- (void)setMaxExpandHeight:(CGFloat)maxExpandHeight {
    _maxExpandHeight = MAX(maxExpandHeight, KMLSCommentTextViewResizeableHeight);
}
- (BOOL)isShowingEmotion {
    return self.emotionButton.isSelected;
}
- (void)setToolBarActionBlock:(MLSBaseCommentToolBarActionBlock)actionBlock {
    self.actionBlock = actionBlock;
}
#ifdef MLSCommentToolBarUseEmotion
- (void)setEmotionManager:(QMUIEmotionInputManager *)emotionManager {
    self.qqEmotionManager = emotionManager;
}
#endif
- (void)setAutoResizable:(BOOL)autoResizable {
    _autoResizeble = autoResizable;
    self.textView.autoResizable = autoResizable;
    self.textField.hidden = autoResizable;
    self.textView.hidden = !autoResizable;
    [self _ReLayoutView];
}
- (QMUITextView *)textView {
    if (_textView == nil) {
        _textView = [[QMUITextView alloc] init];
        _textView.returnKeyType      = UIReturnKeySend;
        _textView.clipsToBounds      = YES;
        _textView.font               = MLSSystem14Font;
        _textView.backgroundColor    = UIColorMake(196, 200, 208);
        _textView.textAlignment      = NSTextAlignmentLeft;
        _textView.placeholderColor = UIColorMake(133, 140, 150);
        _textView.textColor = UIColorMake(133, 140, 150);
        _textView.tintColor = UIColorHex(0xf6645f);
        
    }
    return _textView;
}
- (QMUITextField *)textField {
    if (_textField == nil) {
        _textField = [[QMUITextField alloc] init];
        _textField.returnKeyType      = UIReturnKeySend;
        _textField.borderStyle        = UITextBorderStyleNone;
        _textField.tintColor = UIColorHex(0xf6645f);
        _textField.clipsToBounds      = YES;
        _textField.font               = MLSSystem14Font;
        _textField.backgroundColor    = UIColorMake(196, 200, 208);
        _textField.textAlignment      = NSTextAlignmentLeft;
        _textField.minimumFontSize    = 15.0;
        _textField.placeholderColor   = UIColorMake(133, 140, 150);
        _textField.placeholderFont = MLSSystem14Font;
        _textField.textColor = UIColorMake(133, 140, 150);
        _textField.textInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    }
    return _textField;
}
- (QMUIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [[QMUIButton alloc] initWithFrame:CGRectZero];
        _sendButton.enabled = NO;
        _sendButton.qmui_outsideEdge = UIEdgeInsetsMake(-KMLSCommentToolBarTopMargin, -KMLSCommentToolBarDistance, -KMLSCommentToolBarBottomMargin, -KMLSCommentToolBarRightMargin);
        _sendButton.titleLabel.font = MLSSystem14Font;
        [_sendButton setTitleColor:UIColorMake(133, 140, 150) forState:UIControlStateDisabled];
        [_sendButton setTitleColor:UIColorHex(0x333333) forState:(UIControlStateNormal)];
        _sendButton.adjustsImageWhenHighlighted = NO;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    }
    return _sendButton;
}
- (QMUIButton *)emotionButton {
    if (_emotionButton == nil) {
        _emotionButton = [[QMUIButton alloc] initWithFrame:CGRectZero];
        _emotionButton.titleLabel.font = MLSSystem14Font;
        [_emotionButton setTitle:@"表情" forState:UIControlStateNormal];
    }
    return _emotionButton;
}
@end
