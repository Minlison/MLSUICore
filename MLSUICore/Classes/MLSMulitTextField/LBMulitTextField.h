//
//  LBMulitTextField.h
//  Meeting
//
//  Created by 黄贤于 on 2018/12/14.
//  Copyright © 2018年 com.newchinese. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LBMulitTextFieldInputType) {
    LBMulitTextFieldInputType_Letter = 0,   // 只可输入字母
    LBMulitTextFieldInputType_Number,       // 只可输入数字
    LBMulitTextFieldInputType_Number_Letter,// 字母和数字
};

NS_ASSUME_NONNULL_BEGIN

@interface LBMulitTextFieldConfig : NSObject

/// 输入框总个数
@property (assign,nonatomic) NSInteger      inputBoxNumber;
/// 每行输入框个数, 默认等于总个数
@property (assign,nonatomic) NSInteger      rowInputBoxNumber;
/// 单个输入框的宽度, 默认20
@property (assign,nonatomic) CGFloat        inputBoxWidth;
/// 单个输入框的高度, 默认30
@property (assign,nonatomic) CGFloat        inputBoxHeight;
/// 输入框横向间距, 默认 10
@property (assign,nonatomic) CGFloat        inputBoxHorizontalSpacing;
/// 输入框竖向间距距, 默认 10
@property (assign,nonatomic) CGFloat        inputBoxVerticalSpacing;
/// 输入框距左距离, 默认整体居中
@property (nonatomic,assign) CGFloat        leftMargin;
/// 下划线尺寸, 默认 (self.width, 1)
@property (nonatomic,assign) CGSize         underLineSize;
/// 是否自动弹出键盘, 默认NO
@property (nonatomic,assign) BOOL           autoShowKeyboard;
/// 字体
@property (nonatomic,strong) UIFont         *textFont;

/// 选中时输入框背景色, 默认clearColor
@property (nonatomic,strong) UIColor        *inputBoxSelectBgColor;
/// 光标颜色, 默认蓝色黑色
@property (nonatomic,strong) UIColor        *inputTintColor;
/// 正在输入时的字体颜色, 默认blackColor
@property (nonatomic,strong) UIColor        *inputtingTextColor;
/// 已经输入了的字体颜色, 默认lightGrayColor
@property (nonatomic,strong) UIColor        *inputtedTextColor;
/// 正在输入时的下划线颜色, 默认blackColor
@property (nonatomic,strong) UIColor        *inputtingLineColor;
/// 已经输入了的下划线颜色, 默认lightGrayColor
@property (nonatomic,strong) UIColor        *inputtedLineColor;

/// 比较后正确的颜色, 默认greenColor
@property (nonatomic,strong) UIColor        *rigthColor;
/// 比较后错误的颜色, 默认redColor
@property (nonatomic,strong) UIColor        *errorColor;
/// 提前显示的颜色, 默认blackColor
@property (nonatomic,strong) UIColor        *prepTextColor;
/// 输入类型
@property (nonatomic,assign) LBMulitTextFieldInputType inputType;
/// 正确答案
@property (nonatomic,strong) NSString *rigthText;
/// 提前显示的答案下标, 没有 不设置
@property (nonatomic,strong) NSArray *prepTextIndexArray;
/// 空白位置数组
@property (nonatomic,strong) NSArray *blankIndexArray;
/// 比较大时 是否区分大小写 默认区分YES
@property (nonatomic,assign) BOOL isMatchCase;

@end


@interface LBMulitTextField : UIView


/**
 @param frame 高度根据输入框高度自适应
 */
- (instancetype)initWithFrame:(CGRect)frame config:(nullable LBMulitTextFieldConfig *)config;

/**
 输入回调

 @param change text: 输入的text, 如果还没输入完, 用空格代替. isFinished:是否输入完成
 */
- (void)mulitTextFieldChange:(void (^) (NSString *text, BOOL isFinished))change;

/**
 输入错误字符回调

 @param inputError errorText 错误的字符
 */
- (void)mulitTextFieldInputError:(void (^) (NSString *errorText))inputError;

/**
 比较对错
 */
- (BOOL)compareAnswer;

/**
 比较对错, 根据inputText
 */
- (BOOL)compareAnswerWitchInputText:(NSString *)inputText;

/**
 弹出键盘
 */
- (void)showKeyboard;

/// 获取用户输入的内容
- (NSString *)getInputText;

/**
 点击done
 */
- (void)mulitTextFieldShouldReturn:(void (^) (NSString *inputText))shouldReturn;

@property (nonatomic,strong) LBMulitTextFieldConfig *config;

@end

NS_ASSUME_NONNULL_END
