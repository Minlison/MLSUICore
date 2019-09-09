//
//  MLSProgressView.h
//  MLSPageController
//
//  Created by minlison on 18/5/9.
//  Copyright (c) 2018年 minlison. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface MLSProgressView : UIView
@property (nonatomic, strong) NSArray *itemFrames;
@property (nonatomic, assign) CGColorRef color;
@property (nonatomic, assign) CGFloat progress;
/** 进度条的速度因数，默认为 15，越小越快， 大于 0 */
@property (nonatomic, assign) CGFloat speedFactor;
@property (nonatomic, assign) CGFloat cornerRadius;
/// 调皮属性，用于实现新腾讯视频效果
@property (nonatomic, assign) BOOL naughty;
@property (nonatomic, assign) BOOL isTriangle;
@property (nonatomic, assign) BOOL hollow;
@property (nonatomic, assign) BOOL hasBorder;

- (void)setProgressWithOutAnimate:(CGFloat)progress;
- (void)moveToPostion:(NSInteger)pos;

@end
NS_ASSUME_NONNULL_END
