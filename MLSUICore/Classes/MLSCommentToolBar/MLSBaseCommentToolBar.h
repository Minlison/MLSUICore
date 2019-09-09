//
//  BaseCommentToolBar.h
//  MinLison
//
//  Created by MinLison on 2017/11/7.
//  Copyright © 2017年 minlison. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MLSBaseCommentToolBarProtocol.h"
@interface MLSBaseCommentToolBar : UIView <MLSBaseCommentToolBarProtocol>

/**
 输入框文字
 */
@property(nonatomic, copy) NSString *text;
/**
 代理
 */
@property(nonatomic, weak) id <MLSBaseCommentToolBarDelegate> delegate;

#ifdef MLSCommentToolBarUseEmotion
/**
 创建
 
 @param emotion 是否有表情符号
 @return  toolBar
 */
- (instancetype)initWithEmotion:(BOOL)emotion NS_DESIGNATED_INITIALIZER;
#endif
@end
