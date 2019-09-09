//
//  MLSMarkableLabel.m
//  MLSUICore
//
//  Created by minlison on 2018/5/24.
//

#import "MLSMarkableLabel.h"
#import "MLSRegexKitLite.h"
@interface MLSMarkItem ()
@property (nonatomic, strong) NSMutableDictionary *resetAttr;
@property (nonatomic, copy, readwrite) NSAttributedString *markAttrString;
@end
@implementation MLSMarkItem
- (NSDictionary *)markAttr {
    if (!_markAttr) {
        UIColor *wordColor = [UIColor colorWithRed:1 green:136.0/255.0 blue:0 alpha:0.2];
        YYTextBorder *border = [YYTextBorder borderWithFillColor:wordColor cornerRadius:0.0];
        
        _markAttr = @{
                      YYTextBackgroundBorderAttributeName : border,
                      }.mutableCopy;
    }
    return _markAttr;
}
- (NSMutableDictionary *)resetAttr {
    if (!_resetAttr) {
        _resetAttr = [[NSMutableDictionary alloc] init];
    }
    return _resetAttr;
}
@end
@interface MLSMarkableLabel ()
@property (nonatomic, strong) NSMutableArray <MLSMarkItem *> *innerMarkItems;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *indexKeyGetWords;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *rangeKeyGetWords;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *indexKeyGetRange;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *rangeKeyGetIndex;
@property (nonatomic, strong) UIColor *oldTextColor;
@property (nonatomic, weak) id <YYTextParser> innerTextParser;
@property (nonatomic, assign) BOOL resetMarkItems;
@property (nonatomic, assign) BOOL resetAttrText;
@end
@implementation MLSMarkableLabel
@synthesize markItems = _markItems;
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _InitMarkLabel];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _InitMarkLabel];
    }
    return self;
}

- (void)_InitMarkLabel {
    self.regexString = @"[^A-Za-z0-9_$’'-]+";
    self.innerMarkItems = [NSMutableArray array];
    self.markEnable = YES;
}

- (void)setTextColor:(UIColor *)textColor {
    self.oldTextColor = textColor;
    [super setTextColor:textColor];
}

- (void)setTextParser:(id<YYTextParser>)textParser {
    self.innerTextParser = textParser;
}

- (void)setMarkItems:(NSArray<MLSMarkItem *> *)markItems {
    if (_markItems != markItems) {
        _markItems = markItems;
        self.resetMarkItems = YES;
        self.resetAttrText = YES;
        [self.innerMarkItems removeAllObjects];
        [self.innerMarkItems addObjectsFromArray:markItems];
        // 重新刷新所有属性
        if (self.resetAttrText) {
            self.text = self.attributedText.string;
        }
    }
}

- (NSArray<MLSMarkItem *> *)markItems {
    return [NSArray arrayWithArray:self.innerMarkItems];
}

- (void)addMarkItem:(MLSMarkItem *)item {
    [self.innerMarkItems addObject:item];
    _markItems = self.innerMarkItems;
    if (!self.attributedText) {
        return;
    }
    [self _resetAttr:[[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText]];
}

- (void)delMarkItem:(MLSMarkItem *)item {
    
    if ([self.innerMarkItems containsObject:item]) {
        [self.innerMarkItems removeObject:item];
        if (self.MLSMarkAbleMarkBlock) {
            self.MLSMarkAbleMarkBlock(self.markItems);
        }
    } else {
        __block MLSMarkItem *tmp = nil;
        [self.innerMarkItems enumerateObjectsUsingBlock:^(MLSMarkItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ((obj.markRange.location == item.markRange.location) && (obj.markRange.length == item.markRange.length)) {
                tmp = obj;
                *stop = YES;
            }
        }];
        item = tmp;
        [self.innerMarkItems removeObject:item];
    }
    if (self.MLSMarkAbleMarkBlock) {
        self.MLSMarkAbleMarkBlock(self.markItems);
    }
    _markItems = [NSArray arrayWithArray:self.innerMarkItems];
    [super setAttributedText:[self removeItemAttr:item]];
    
}
- (NSMutableAttributedString *)removeItemAttr:(MLSMarkItem *)item {
    if (!item || !self.attributedText) {
        return self.attributedText;
    }
    
    NSMutableAttributedString *_innerAttr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [item.markAttr enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [_innerAttr removeAttribute:key range:item.markRange];
    }];
    [_innerAttr yy_setColor:self.oldTextColor range:item.markRange];
    return _innerAttr;
}
- (void)setText:(NSString *)text {
    if (text.length <= 0) {
        return;
    }
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    attr.yy_font = self.font;
    attr.yy_color = self.oldTextColor;
    attr.yy_shadow = [self _markShadowFromProperties];
    attr.yy_alignment = self.textAlignment;
    attr.yy_lineSpacing = self.attributedText.yy_lineSpacing;
    switch (self.lineBreakMode) {
        case NSLineBreakByWordWrapping:
        case NSLineBreakByCharWrapping:
        case NSLineBreakByClipping: {
            attr.yy_lineBreakMode = self.lineBreakMode;
        } break;
        case NSLineBreakByTruncatingHead:
        case NSLineBreakByTruncatingTail:
        case NSLineBreakByTruncatingMiddle: {
            attr.yy_lineBreakMode = NSLineBreakByWordWrapping;
        } break;
        default: break;
    }
    [self _analysisAndSetAttributeText:attr];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (attributedText.length <= 0) {
        return;
    }
    if (!self.oldTextColor) {
        self.oldTextColor = [attributedText.yy_attributes objectForKey:NSForegroundColorAttributeName];
    }
    [self _analysisAndSetAttributeText:[[NSMutableAttributedString alloc] initWithAttributedString:attributedText]];
}

- (void)_resetAttr:(NSMutableAttributedString *)resetAttrStr {
    [self.innerMarkItems enumerateObjectsUsingBlock:^(MLSMarkItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.markRange.location == 0) {
            NSString *rangeStr = [self.indexKeyGetRange objectForKey:@(obj.wordIndex).stringValue];
            if (rangeStr) {
                obj.markRange = NSRangeFromString(rangeStr);
            }
        }
        if (obj.markRange.location + obj.markRange.length > resetAttrStr.length) {
            return ;
        }
        obj.markAttrString = [resetAttrStr attributedSubstringFromRange:obj.markRange];
        [obj.resetAttr setValuesForKeysWithDictionary:obj.markAttrString.yy_attributes];
        [obj.resetAttr setValuesForKeysWithDictionary:obj.markAttr];
        
        if ([obj.resetAttr objectForKey:NSFontAttributeName] == nil) {
            [obj.resetAttr setObject:self.font forKey:NSFontAttributeName];
        }
        
        if ([obj.resetAttr objectForKey:NSForegroundColorAttributeName] == nil) {
            [obj.resetAttr setObject:self.oldTextColor forKey:NSForegroundColorAttributeName];
        }
        
        [resetAttrStr setAttributes:obj.resetAttr range:obj.markRange];
    }];
    [super setAttributedText:resetAttrStr];
    self.resetAttrText = NO;
}

- (void)_analysisAndSetAttributeText:(NSMutableAttributedString *)attrText {
    if (attrText.length <= 0) {
        return;
    }
    [self.innerTextParser parseText:attrText selectedRange:NULL];
    
    /// 重置字符串
    if (![self.attributedText.string isEqualToString:attrText.string] && !self.resetMarkItems) {
        [self.innerMarkItems removeAllObjects];
        self.resetMarkItems = NO;
    }
    
    self.indexKeyGetWords = [NSMutableDictionary dictionary];
    self.rangeKeyGetWords = [NSMutableDictionary dictionary];
    self.indexKeyGetRange = [NSMutableDictionary dictionary];
    self.rangeKeyGetIndex = [NSMutableDictionary dictionary];
    __block NSInteger wordIndex = 0;
    
    NSMutableAttributedString *replaceAttrText = [[NSMutableAttributedString alloc] initWithAttributedString:attrText];
    
    if (self.regexString != nil) {
        __block NSInteger wordIndex = 0;
        [replaceAttrText.string enumerateStringsSeparatedByRegex:self.regexString usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
            for (int i = 0; i < captureCount; i++) {
                NSString *str = capturedStrings[i];
//                if (str.length > 0) {
                    [self _setWord:capturedStrings[i] range:capturedRanges[i] wordIndex:wordIndex];
                    [self _addTextHighlight:replaceAttrText range:capturedRanges[i] wordIndex:wordIndex];
                    wordIndex++;                    
//                }
            }
        }];
//        [replaceAttrText.string enumerateStringsMatchedByRegex:self.regexString usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
//            for (int i = 0; i < captureCount; i++) {
//                [self _setWord:capturedStrings[i] range:capturedRanges[i] wordIndex:wordIndex];
//                [self _addTextHighlight:replaceAttrText range:capturedRanges[i] wordIndex:wordIndex];
//                wordIndex++;
//            }
//        }];
    } else {
        __block NSInteger wordIndex = 0;
        [replaceAttrText.string enumerateSubstringsInRange:NSMakeRange(0, replaceAttrText.string.length) options:(NSStringEnumerationByWords) usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            [self _setWord:substring range:substringRange wordIndex:wordIndex];
            [self _addTextHighlight:replaceAttrText range:substringRange wordIndex:wordIndex];
            wordIndex++;
        }];
    }
    [self _resetAttr:replaceAttrText];
}

- (void)_setWord:(NSString *)word range:(NSRange)range wordIndex:(NSInteger)wordIndex {
    [self.indexKeyGetWords setObject:word.copy forKey:@(wordIndex).stringValue];
    [self.rangeKeyGetWords setObject:word.copy forKey:NSStringFromRange(range)];
    [self.indexKeyGetRange setObject:NSStringFromRange(range) forKey:@(wordIndex).stringValue];
    [self.rangeKeyGetIndex setObject:@(wordIndex).stringValue forKey:NSStringFromRange(range)];
}

- (void)_addTextHighlight:(NSMutableAttributedString *)attrText range:(NSRange)range wordIndex:(NSInteger)wordIndex {
    /// 判断当前是否已经添加过高亮点击
    if ( ![[attrText attributedSubstringFromRange:range].yy_attributes objectForKey:YYTextHighlightAttributeName] ) {
        __weak __typeof(self)weakSelf = self;
        [attrText yy_setTextHighlightRange:range color:self.oldTextColor backgroundColor:UIColor.clearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf textDidTapHighlightInContainerView:containerView
                                             highlightText:[text attributedSubstringFromRange:range]
                                        highlightTextRange:range
                                         highlightTextRect:rect];
            
        }];
    }
}

- (void)textDidTapHighlightInContainerView:(UIView *)containerView
                             highlightText:(NSAttributedString *)highlightText
                        highlightTextRange:(NSRange)highlightTextRange
                         highlightTextRect:(CGRect)highlightTextRect {
    if ( !self.markEnable ) {
        return;
    }
    [self _markOrUnMarkWord:highlightText.string atRange:highlightTextRange];
}

- (void)_markOrUnMarkWord:(NSString *)word atRange:(NSRange)range {
    
    /// 是否与文字颜色保持一致
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSDictionary *attributes = [[self.attributedText attributedSubstringFromRange:range] yy_attributes];
    NSMutableDictionary *attributesM = [NSMutableDictionary dictionary];
    [attributesM setObject:self.font forKey:NSFontAttributeName];
    [attributesM setObject:self.oldTextColor forKey:NSForegroundColorAttributeName];
    if (attributes) {
        [attributesM setValuesForKeysWithDictionary:attributes];
    }
    
//    UIColor *textColor = [attributes objectForKey:NSForegroundColorAttributeName]?:self.oldTextColor;
    
    /// 判断是否有下划线，或者高亮
    if ([attributesM objectForKey:YYTextBackgroundBorderAttributeName] ||
        [attributesM objectForKey:YYTextBlockBorderAttributeName]) {
        
        MLSMarkItem *item = [self _markItemAtRange:range];
        [attributesM removeObjectForKey:YYTextBackgroundBorderAttributeName];
        [attributesM removeObjectForKey:YYTextBlockBorderAttributeName];
        [attributesM removeObjectForKey:NSForegroundColorAttributeName];
        item.resetAttr = attributesM;
        /// 可以删除
        if (item.canDelAtrr) {
            [self delMarkItem:item];
        }
    } else {
        /// 增加 mark 属性
        MLSMarkItem *item = [[MLSMarkItem alloc] init];
        YYTextBorder *border = [YYTextBorder borderWithFillColor:nil cornerRadius:0];
        item.markAttr = @{
                          YYTextBlockBorderAttributeName : border,
                          NSForegroundColorAttributeName : [UIColor colorWithRed:1 green:136.0/255.0 blue:0 alpha:1],
                          (id)kCTForegroundColorAttributeName : (id)[UIColor colorWithRed:1 green:136.0/255.0 blue:0 alpha:1].CGColor,
                          };
        [attributesM setValuesForKeysWithDictionary:item.markAttr];
        
        item.markAttrString = [self.attributedText attributedSubstringFromRange:range];
        item.markRange = range;
        item.wordIndex = [self.rangeKeyGetIndex objectForKey:NSStringFromRange(range)].integerValue;
        item.canDelAtrr = YES;
        [self addMarkItem:item];
        
        if (self.MLSMarkAbleMarkBlock) {
            self.MLSMarkAbleMarkBlock(self.markItems);
        }
    }
}

- (MLSMarkItem *)_markItemAtRange:(NSRange)range {
    __block MLSMarkItem *tmp = nil;
    [self.innerMarkItems enumerateObjectsUsingBlock:^(MLSMarkItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ((obj.markRange.location == range.location) && (obj.markRange.length == range.length)) {
            tmp = obj;
            *stop = YES;
        }
    }];
    return tmp;
}
- (NSShadow *)_markShadowFromProperties {
    if (!self.shadowColor || self.shadowBlurRadius < 0) return nil;
    NSShadow *shadow = [NSShadow new];
    shadow.shadowColor = self.shadowColor;
    shadow.shadowOffset = self.shadowOffset;
    shadow.shadowBlurRadius = self.shadowBlurRadius;
    return shadow;
}

- (void)setMarkEnable:(BOOL)markEnable {
    _markEnable = markEnable;
    self.userInteractionEnabled = markEnable;
}
@end
