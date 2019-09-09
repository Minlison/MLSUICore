//
//  LBMulitTextField.m
//  Meeting
//
//  Created by 黄贤于 on 2018/12/14.
//  Copyright © 2018年 com.newchinese. All rights reserved.
//

#import "LBMulitTextField.h"

@implementation LBMulitTextFieldConfig

- (instancetype)init {
    if (self = [super init]) {
        self.inputBoxWidth = 20;
        self.inputBoxHeight = 30;
        self.inputBoxHorizontalSpacing = 10;
        self.inputBoxVerticalSpacing = 10;
        self.leftMargin = -1;
        self.textFont = [UIFont systemFontOfSize:16];
        self.inputBoxSelectBgColor = [UIColor clearColor];
        self.inputtingTextColor = [UIColor blackColor];
        self.inputtingLineColor = [UIColor blackColor];
        self.prepTextColor = [UIColor blackColor];
        self.inputtedTextColor = [UIColor lightGrayColor];
        self.inputtedLineColor = [UIColor lightGrayColor];
        self.inputTintColor = [UIColor blackColor];
        self.rigthColor = [UIColor greenColor];
        self.errorColor = [UIColor redColor];
        self.isMatchCase = YES;
    }
    return self;
}

@end

@class LBMulitCustomTextField;
@protocol LBMulitCustomTextFieldDelegate <NSObject>
- (void)lb_textFieldDeleteBackward:(LBMulitCustomTextField *)textField;
@end

@interface LBMulitCustomTextField : UITextField
@property (nonatomic,weak) id <LBMulitCustomTextFieldDelegate> lb_delegate;
@end

@implementation LBMulitCustomTextField

- (void)deleteBackward {
    if ([self.lb_delegate respondsToSelector:@selector(lb_textFieldDeleteBackward:)]) {
        [self.lb_delegate lb_textFieldDeleteBackward:self];
    }
    [super deleteBackward];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    UIMenuController *menuC = [UIMenuController sharedMenuController];
    if (menuC) {
        menuC.menuVisible = NO;
    }
    return NO;
}

@end


@interface LBMulitTextField () <LBMulitCustomTextFieldDelegate, UITextFieldDelegate>


@property (nonatomic,strong) NSMutableArray <LBMulitCustomTextField *>*textFieldArray;
@property (nonatomic,strong) NSMutableArray <UIView *>*lineArray;
@property (nonatomic,strong) NSMutableArray *editArray; // 可以编辑的下标
@property (nonatomic,assign) NSInteger currentEditIndex; // 记录editArray下标
@property (nonatomic,assign) NSInteger currentIndex; // 记录当前输入框下标
@property (nonatomic,strong) NSString *currentText; // 记录当前输入框字母
@property (nonatomic,copy)   void (^textFieldChanged) (NSString *text, BOOL isFinished);
@property (nonatomic,copy)   void (^inputError) (NSString *errorText);
@property (nonatomic,copy)   void (^shouldReturn) (NSString *inputText);

@end

@implementation LBMulitTextField

- (instancetype)initWithFrame:(CGRect)frame config:(LBMulitTextFieldConfig *)config {
    if (self = [super initWithFrame:frame]) {
        _config = config;
        if (config) {
            [self customView];
        }
    }
    return self;
}

- (void)setConfig:(LBMulitTextFieldConfig *)config {
    
    _config = config;
    [self customView];
}

- (void)customView {
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self editArrayConfig];
    
    self.currentIndex = 0;
    self.currentEditIndex = 0;
    self.currentText = @"";
    
    if (_config.inputBoxNumber <= 0 || _config.inputBoxWidth > self.qmui_width) return;
    
    CGFloat inputBoxSpacing = _config.inputBoxHorizontalSpacing;
    
    CGFloat inputBoxWidth = 0;
    if (_config.inputBoxWidth > 0) {
        inputBoxWidth = _config.inputBoxWidth;
    }
    
    int rowMaxNumber = 0;
    if (_config.rowInputBoxNumber > _config.inputBoxNumber) {
        _config.rowInputBoxNumber = _config.inputBoxNumber;
    }
    
    if (_config.rowInputBoxNumber > 0 ) {
        rowMaxNumber = (int)_config.rowInputBoxNumber;
    } else {
        rowMaxNumber = (int)_config.inputBoxNumber;
    }
    
    CGFloat leftMargin = 0;
    if (self.config.leftMargin < 0) {
        if (inputBoxWidth > 0) {
            leftMargin = (self.qmui_width-inputBoxWidth*rowMaxNumber-inputBoxSpacing*(rowMaxNumber-1))*0.5;
        } else {
            _config.inputBoxWidth = (self.qmui_width-inputBoxSpacing*(rowMaxNumber-1)-leftMargin*2)/rowMaxNumber;
            inputBoxWidth = _config.inputBoxWidth;
        }
        
        if (leftMargin < 0) {
            leftMargin = 0;
            _config.inputBoxWidth = (self.qmui_width-inputBoxSpacing*(rowMaxNumber-1)-leftMargin*2)/rowMaxNumber;
            inputBoxWidth = _config.inputBoxWidth;
        }
    } else {
        leftMargin = self.config.leftMargin;
    }
    
    if (_config.underLineSize.width <= 0) {
        CGSize size = _config.underLineSize;
        size.width = inputBoxWidth;
        _config.underLineSize = size;
    }
    if (_config.underLineSize.height <= 0) {
        CGSize size = _config.underLineSize;
        size.height = 1;
        _config.underLineSize = size;
    }
    
    CGFloat inputBoxHeight = 0;
    if (_config.inputBoxHeight > self.qmui_height || _config.inputBoxHeight == 0) {
        _config.inputBoxHeight = self.qmui_height;
    }
    inputBoxHeight = _config.inputBoxHeight;
    
    for (int i = 0; i < _config.inputBoxNumber; ++i) {
        
        int lastRowNumber = i % rowMaxNumber;
        int row = (i / rowMaxNumber);
        
        CGFloat textX = leftMargin+(inputBoxWidth+inputBoxSpacing) * lastRowNumber;
        CGFloat textY = row * (inputBoxHeight + _config.inputBoxVerticalSpacing);
        
        LBMulitCustomTextField *textField = [[LBMulitCustomTextField alloc] init];
        textField.frame = CGRectMake(textX, textY, inputBoxWidth, inputBoxHeight);
        textField.textAlignment = NSTextAlignmentCenter;
        textField.lb_delegate = self;
        textField.delegate = self;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.returnKeyType = UIReturnKeyDone;
        
        
        if (_config.inputType == LBMulitTextFieldInputType_Number) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
        } else {
            textField.keyboardType = UIKeyboardTypeASCIICapable;
        }

        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.font = _config.textFont;
        textField.tintColor = _config.inputTintColor;
        textField.textColor = _config.inputtingTextColor;
        [textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldTap:)];
        [textField addGestureRecognizer:tap];
        
        CGFloat x = (inputBoxWidth-_config.underLineSize.width)/2.0;
        CGFloat y = (inputBoxHeight-_config.underLineSize.height);
        CGRect frame = CGRectMake(x, y, _config.underLineSize.width, _config.underLineSize.height);
        UIView *lineView = [[UIView alloc] init];
        lineView.frame = frame;
        
        if ([_config.prepTextIndexArray containsObject:@(i)]) {
            textField.text = [NSString stringWithFormat:@"%c", [_config.rigthText characterAtIndex:i]];
            textField.textColor = _config.prepTextColor;
            textField.userInteractionEnabled = NO;
            lineView.backgroundColor = [UIColor clearColor];
        } else {
            lineView.backgroundColor = _config.inputtingLineColor;
        }
        
        [self.lineArray addObject:lineView];
        [textField addSubview:lineView];

        [self addSubview:textField];
        
        [self.textFieldArray addObject:textField];
    }
    
    self.qmui_height = CGRectGetMaxY(self.textFieldArray.lastObject.frame);
    
    if (_config.autoShowKeyboard) {
        [self.textFieldArray[[self.editArray[_currentEditIndex] integerValue]] becomeFirstResponder];
        self.currentIndex = [self.editArray[_currentEditIndex] integerValue];
    }
}


// 输入
- (void)textFieldChanged:(LBMulitCustomTextField *)textField {
    
    if (textField.text.length > 1) {
        textField.text = [textField.text substringToIndex:1];
    }
    
    // ------------- 限制输入
    if (textField.text.length > 0) {
        unichar c = [textField.text characterAtIndex:0];

        if (_config.inputType == LBMulitTextFieldInputType_Letter) {
            if (!((c >= 'A' && c <= 'Z') ||
                (c >= 'a' && c <= 'z') ||
                (c == ' '))) {
                if (self.inputError) self.inputError([NSString stringWithFormat:@"%c",c]);
                [self confineTextFieldInput:textField];
                return;
            }
        } else if (_config.inputType == LBMulitTextFieldInputType_Number) {
            if (!((c >= '0' && c <= '9')||
                  (c == ' '))) {
                if (self.inputError) self.inputError([NSString stringWithFormat:@"%c",c]);
                [self confineTextFieldInput:textField];
                return;
            }
        } else if (_config.inputType == LBMulitTextFieldInputType_Number_Letter) {
            if (!((c >= '0' && c <= '9') ||
                (c >= 'A' && c <= 'Z') ||
                (c >= 'a' && c <= 'z') ||
                (c == ' '))) {
                if (self.inputError) self.inputError([NSString stringWithFormat:@"%c",c]);
                [self confineTextFieldInput:textField];
                return;
            }
        }
    }
    
    // ---------- 跳下一输入框
    if (textField.text.length > 0 && _currentIndex < [self.editArray.lastObject integerValue]) {
        if (_currentText.length <= 0 || ![textField.text isEqualToString:@" "]) {
            // 如果当前输入框没有字母, 或者输入了字母, 直接跳下一个
            _currentEditIndex += 1;
            _currentIndex = [self.editArray[_currentEditIndex] integerValue];
            
            LBMulitCustomTextField *cTextField = self.textFieldArray[_currentIndex];
            _currentText = cTextField.text;
            [cTextField becomeFirstResponder];
            if (cTextField.text.length > 0) {
                [self setSelectTextRange:NSMakeRange(cTextField.text.length, 1)];
            }
        } else if ([textField.text isEqualToString:@" "]) {
            // 如果当前输入框有字母, 且输入了空格, 删除当前字母
            textField.text = @"";
            _currentText = @"";
            textField.backgroundColor = [UIColor clearColor];
        }
    }
    
    if ([textField.text isEqualToString:@" "]) {
        textField.text = @"";
    }
    
    // ------- 是否已经全部输入
    __weak typeof (self) weakSelf = self;
    __block BOOL isAllFinished = YES;
    [self.textFieldArray enumerateObjectsUsingBlock:^(LBMulitCustomTextField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.text.length > 0) { // 已经输入
            obj.tintColor = [self.config.inputBoxSelectBgColor colorWithAlphaComponent:0];
            if ([weakSelf.config.prepTextIndexArray containsObject:@(idx)]) {
                obj.textColor = weakSelf.config.prepTextColor;
                weakSelf.lineArray[idx].backgroundColor = [UIColor clearColor];
            } else {
                obj.textColor = weakSelf.config.inputtedTextColor;
                weakSelf.lineArray[idx].backgroundColor = weakSelf.config.inputtedLineColor;
            }
        } else { // 还没输入
            obj.tintColor = self.config.inputTintColor;
            obj.textColor = weakSelf.config.inputtingTextColor;
            weakSelf.lineArray[idx].backgroundColor = weakSelf.config.inputtingLineColor;
            
            isAllFinished = NO;
        }
    }];
    
    if (_currentText.length > 0) {
        self.textFieldArray[_currentIndex].textColor = _config.inputtingTextColor;
        self.textFieldArray[_currentIndex].backgroundColor = _config.inputBoxSelectBgColor;
        self.lineArray[_currentIndex].backgroundColor = _config.inputtingLineColor;
    }
    
    // textField为上一个输入框
    textField.backgroundColor = [UIColor clearColor];
    textField.tintColor = _config.inputTintColor;
    textField.textColor = _config.inputtedTextColor;
    
    if (self.textFieldChanged) {
        self.textFieldChanged([self getInputText], isAllFinished);
    }
}

// 点击返回键
- (void)lb_textFieldDeleteBackward:(LBMulitCustomTextField *)textField {
    
    if (textField.text.length <= 0 && _currentEditIndex > 0) {
        _currentEditIndex -= 1;
        NSLog(@"edit = %ld",_currentEditIndex);
        NSLog(@"curr = %ld",_currentIndex);
        
        _currentIndex = [self.editArray[_currentEditIndex] integerValue];
    
        LBMulitCustomTextField *cTextField = self.textFieldArray[_currentIndex];
        _currentText = cTextField.text;
        [cTextField becomeFirstResponder];
        
        if (_currentText.length > 0) {
            cTextField.textColor = _config.inputtingTextColor;
            cTextField.backgroundColor = _config.inputBoxSelectBgColor;
            cTextField.tintColor = [_config.inputBoxSelectBgColor colorWithAlphaComponent:0];
            self.lineArray[_currentIndex].backgroundColor = _config.inputtingLineColor;
            [self setSelectTextRange:NSMakeRange(cTextField.text.length, 1)];
        }
    }
    
    if (textField.text.length > 0) {
        textField.backgroundColor = [UIColor clearColor];
        _currentText = @"";
    }
}

// 点击输入框
- (void)textFieldTap:(UITapGestureRecognizer *)sender {
    
    LBMulitCustomTextField *textField = (LBMulitCustomTextField *)sender.view;
    
    __weak typeof (self) weakSelf = self;
    [self.textFieldArray enumerateObjectsUsingBlock:^(LBMulitCustomTextField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == textField) { // 当前输入框
            weakSelf.currentIndex = idx;
            weakSelf.currentText = obj.text;
            weakSelf.currentEditIndex = [weakSelf.editArray indexOfObject:@(idx)];
            [obj becomeFirstResponder];
            
            if (obj.text.length > 0) {
                obj.tintColor = [self.config.inputBoxSelectBgColor colorWithAlphaComponent:0];
                obj.backgroundColor = weakSelf.config.inputBoxSelectBgColor;
                [self setSelectTextRange:NSMakeRange(obj.text.length, 1)];
            }
            // 设置正在输入的颜色
            obj.textColor = weakSelf.config.inputtingTextColor;
            weakSelf.lineArray[idx].backgroundColor = weakSelf.config.inputtingLineColor;
            
        } else if (obj.text.length > 0) { // 其他已输入
            obj.backgroundColor = [UIColor clearColor];
            
            if ([weakSelf.config.prepTextIndexArray containsObject:@(idx)]) {
                obj.textColor = weakSelf.config.prepTextColor;
                weakSelf.lineArray[idx].backgroundColor = [UIColor clearColor];
            } else {
                obj.textColor = weakSelf.config.inputtedTextColor;
                weakSelf.lineArray[idx].backgroundColor = weakSelf.config.inputtedLineColor;
            }
        } else if (obj.text.length <= 0) { // 其他没输入
            obj.backgroundColor = [UIColor clearColor];
        }
    }];
}


- (void)confineTextFieldInput:(LBMulitCustomTextField *)textField {
    if (_currentText.length > 0) { // 如果原输入框有字母, 替换成原来的
        textField.text = _currentText;
        [self setSelectTextRange:NSMakeRange(textField.text.length, 1)];
    } else { // 没有就删除
        textField.text = @"";
    }
}

- (void)setSelectTextRange:(NSRange)range {
    LBMulitCustomTextField *textField = self.textFieldArray[_currentIndex];
    UITextPosition* beginning = textField.beginningOfDocument;
    UITextPosition* startPosition = [textField positionFromPosition:beginning offset:range.location];
    UITextPosition* endPosition = [textField positionFromPosition:beginning offset:range.location + range.length];
    UITextRange* selectionRange = [textField textRangeFromPosition:startPosition toPosition:endPosition];
    [textField setSelectedTextRange:selectionRange];
}

- (NSMutableArray<LBMulitCustomTextField *> *)textFieldArray {
    if (!_textFieldArray) {
        _textFieldArray = [[NSMutableArray alloc] init];
    }
    return _textFieldArray;
}

- (NSMutableArray<UIView *> *)lineArray {
    if (!_lineArray) {
        _lineArray = [[NSMutableArray alloc] init];
    }
    return _lineArray;
}

- (void)editArrayConfig {
    
    NSMutableArray *testArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _config.rigthText.length; i++) {
        [testArray addObject:@(i)];
    }
    if (_config.blankIndexArray.count) {
        NSArray *tempArray = [testArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF in %@)", _config.blankIndexArray]];
        _config.prepTextIndexArray = tempArray;
    }
    NSArray *filterArray = [testArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF in %@)", _config.prepTextIndexArray]];
    _editArray = filterArray.mutableCopy;
}

- (NSMutableArray *)editArray {
    
    if (!_editArray) {
        _editArray = [NSMutableArray array];
    }
    return _editArray;
}

// 获取输入字符串, 如果已经输入但没输入完成, 没输入的会用空格代替
- (NSString *)getInputText {
    
    __block NSString *text = @"";
    [self.textFieldArray enumerateObjectsUsingBlock:^(LBMulitCustomTextField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.text.length <= 0) {
            text = [text stringByAppendingString:@" "];
        } else {
            text = [text stringByAppendingString:obj.text];
        }
    }];
    return text;
}

// UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    if (self.shouldReturn) {
        self.shouldReturn([self getInputText]);
    }
    
    //[self.textFieldArray[_currentIndex] resignFirstResponder];

    /*
    __weak typeof (self) weakSelf = self;
    [self.textFieldArray enumerateObjectsUsingBlock:^(LBMulitCustomTextField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.text.length > 0) { // 已经输入
            obj.textColor = weakSelf.config.inputtedTextColor;
            if ([weakSelf.config.prepTextIndexArray containsObject:@(idx)]) {
                weakSelf.lineArray[idx].backgroundColor = [UIColor clearColor];
            } else {
                weakSelf.lineArray[idx].backgroundColor = weakSelf.config.inputtedLineColor;
            }
        } else { // 还没输入
            obj.textColor = weakSelf.config.inputtingTextColor;
            weakSelf.lineArray[idx].backgroundColor = weakSelf.config.inputtingLineColor;
        }
        obj.backgroundColor = [UIColor clearColor];
    }];*/
    
    return YES;
}

- (BOOL)compareAnswer {
    
    return [self compareAnswerWitchInputText:[self getInputText]];
}

- (BOOL)compareAnswerWitchInputText:(NSString *)inputText {
    
    NSMutableArray *indexArray = [self getErrorIndexWithRigthString:_config.rigthText inputString:inputText];
    [self setErrorInputBoxColorWithErrorIndexArray:indexArray];
    
    for (int i = 0; i < self.textFieldArray.count; i++) {
        if (i < inputText.length) {
            NSString *text = [NSString stringWithFormat:@"%c",[inputText characterAtIndex:i]];
            self.textFieldArray[i].text = text;
        }
        self.textFieldArray[i].backgroundColor = [UIColor clearColor];
    }
    
    if (indexArray.count > 0) {
        return NO;
    } else {
        return YES;
    }
}

- (void)showKeyboard {
    [self.textFieldArray[[self.editArray[_currentEditIndex] integerValue]] becomeFirstResponder];
}

- (void)mulitTextFieldShouldReturn:(void (^) (NSString *inputText))shouldReturn; {
    self.shouldReturn = shouldReturn;
}

- (void)mulitTextFieldChange:(void (^) (NSString *text, BOOL isFinished))change {
    self.textFieldChanged = change;
}

- (void)mulitTextFieldInputError:(void (^) (NSString *errorText))inputError {
    self.inputError = inputError;
}

// 设置正确错误对应颜色
- (void)setErrorInputBoxColorWithErrorIndexArray:(NSMutableArray *)errorIndexArray {
    
    if (errorIndexArray.count <= 0) {
        for (int i = 0; i < self.textFieldArray.count; i++) {
            if (![_config.prepTextIndexArray containsObject:@(i)]) {
                self.textFieldArray[i].textColor = _config.rigthColor;
                self.lineArray[i].backgroundColor = _config.inputtedLineColor;
            } else {
                self.textFieldArray[i].textColor = _config.prepTextColor;
                self.lineArray[i].backgroundColor = [UIColor clearColor];
            }
        }
    } else {
        int beginIndex = 0;
        for (int j = 0; j < errorIndexArray.count; j++) {
            int errorIndex = [errorIndexArray[j] intValue];
            for (int i = beginIndex; i < self.textFieldArray.count; i++) {
                if (i == errorIndex) {
                    self.textFieldArray[i].textColor = _config.errorColor;
                    self.lineArray[i].backgroundColor = _config.inputtedLineColor;
                    beginIndex = i+1;
                } else {
                    if (![_config.prepTextIndexArray containsObject:@(i)]) {
                        self.textFieldArray[i].textColor = _config.rigthColor;
                        self.lineArray[i].backgroundColor = _config.inputtedLineColor;
                    } else {
                        self.textFieldArray[i].textColor = _config.prepTextColor;
                        self.lineArray[i].backgroundColor = [UIColor clearColor];
                    }
                }
            }
        }
    }
}

// 获取输入错误的下标
- (NSMutableArray *)getErrorIndexWithRigthString:(NSString *)rigthString inputString:(NSString *)inputString {
    
    NSMutableArray *indexArray = [[NSMutableArray alloc] init];
    
    if (rigthString.length <= 0) return indexArray;
    
    if (inputString.length <= 0) {
        for (int i = 0; i < rigthString.length; i++) {
            [indexArray addObject:@(i)];
        }
        return indexArray;
    }
    
    NSMutableString *rigthStr = rigthString.mutableCopy;
    NSMutableString *inputStr = inputString.mutableCopy;
    
    if (!self.config.isMatchCase) {
        rigthStr = [rigthStr lowercaseString].mutableCopy;
        inputStr = [rigthStr lowercaseString].mutableCopy;
    }
    
    
    if (rigthStr.length > inputStr.length) {
        NSInteger minLength = rigthStr.length - inputStr.length;
        for (int i = 0; i < minLength; i++) {
            [inputStr appendString:@" "];
        }
    } else if (rigthStr.length < inputStr.length) {
        NSInteger minLength = inputStr.length - rigthStr.length;
        for (int i = 0; i < minLength; i++) {
            [rigthStr appendString:@" "];
        }
    }
    
    for (int i = 0; i < rigthStr.length; i++) {
        unichar baseC = [rigthStr characterAtIndex:i];
        unichar inputC = [inputStr characterAtIndex:i];
        if (baseC != inputC) {
            [indexArray addObject:@(i)];
        }
    }
    
    return indexArray;
}

@end


