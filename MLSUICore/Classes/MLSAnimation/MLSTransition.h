//
//  MLSTransition.h
//  minlison
//
//  Created by minlison on 2018/4/24.
//  Copyright © 2018年 minlison. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,MLSControllerAnimationType) {
        MLSControllerAnimationTypeNone,
};

typedef NS_ENUM(NSInteger,MLSControllerInteractionType) {
        MLSControllerInteractionTypeNone,
};

@protocol MLSTransitionProtocol <NSObject>

@optional
/**
 转场动画效果

 @return 转场动画效果 默认为 MLSControllerAnimationTypeNone
 */
+ (MLSControllerAnimationType)transitionAnimationType;

/**
  手势效果
  暂未实现
 @return 手势 MLSControllerInteractionTypeNone
 */
+ (MLSControllerInteractionType)interactionType;

@end

/**
 全局过度动画管理工具
 */
@interface MLSTransition : NSObject <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

/**
 全局过度动画管理工具

 @return 单例
 */
+ (instancetype)shared;

@end
