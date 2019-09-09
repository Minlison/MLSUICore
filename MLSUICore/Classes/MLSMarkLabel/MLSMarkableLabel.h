//
//  MLSMarkableLabel.h
//  MLSUICore
//
//  Created by minlison on 2018/5/24.
//

#import <YYText/YYText.h>

@interface MLSMarkItem : NSObject

/**
 标记的位置
 优先级高于 wordIndex， 二者有其一即可，如果两者都有，则取 markRange
 */
@property (nonatomic, assign) NSRange markRange;

/**
 单词位置索引  优先级低于 markRange， 二者有其一即可，如果两者都有，则取 markRange
 */
@property (nonatomic, assign) NSInteger wordIndex;

/**
 属性字符串属性 YYText
 默认 [YYTextBorder borderWithFillColor:wordColor cornerRadius:0.0]
 */
@property (nonatomic, strong) NSDictionary *markAttr;

/**
 是否是系统标记，是否允许删除
 默认不允许删除
 */
@property (nonatomic, assign) BOOL canDelAtrr;

/**
 标记的属性字符串
 */
@property (nonatomic, copy, readonly) NSAttributedString *markAttrString;


@end

typedef void(^MLSMarkAbleLabelMarkBlock)(NSArray *);

@interface MLSMarkableLabel : YYLabel

/**
 标记的位置
 */
@property (nonatomic, strong) NSArray <MLSMarkItem *> *markItems;

/**
 分词正则
 */
@property (nonatomic, copy) NSString *regexString;

/**
 是否可标记
 */
@property (nonatomic, assign) BOOL markEnable;
/**
 添加一个标记

 @param item 标记的位置
 */
- (void)addMarkItem:(MLSMarkItem *)item;

/**
 MLSMarkLabel mark 事件回调
 
 */
@property(nonatomic, copy) MLSMarkAbleLabelMarkBlock MLSMarkAbleMarkBlock;

/**
 删除标记

 @param item 标记
 */
- (void)delMarkItem:(MLSMarkItem *)item;

@end
