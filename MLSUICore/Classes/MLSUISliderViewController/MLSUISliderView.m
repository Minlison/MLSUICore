//
//  MLSSliderView.m
//  MLSLearnCenter
//
//  Created by minlison on 2018/5/28.
//  Copyright © 2018年 minlison. All rights reserved.
//

#import "MLSUISliderView.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#import "MLSBaseViewController.h"
#import "MLSConfigurationDefine.h"
@interface MLSUISliderDragView : UIView
@property (nonatomic, strong) UIImageView *handleView;
@property (nonatomic, strong) UIView *dragView;
@property (nonatomic, strong) UIView *containerView;
@end
@implementation MLSUISliderDragView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}
- (void)setupView {
    self.handleView = [[UIImageView alloc] init];
    self.handleView.backgroundColor = [UIColor clearColor];
    
    self.dragView = [[UIView alloc] init];
    self.dragView.backgroundColor = [UIColor clearColor];
    
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor clearColor];
    
    [self.dragView addSubview:self.handleView];
    [self.handleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.centerX.mas_equalTo(self.dragView);
        make.width.mas_equalTo(__MLSWidth(85));
    }];
    
    [self addSubview:self.dragView];
    [self.dragView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo(__MLSHeight(23)).priorityLow();
    }];
    
    [self addSubview:self.containerView];
    [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dragView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self);
    }];
    self.dragView.qmui_borderPosition = QMUIViewBorderPositionBottom;
    self.dragView.qmui_borderColor = [UIColor colorWithWhite:0 alpha:0.1];
    self.dragView.qmui_borderWidth = 1;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.dragView.frame, point)) {
        CGRect handleViewRect = [self convertRect:self.handleView.frame toView:self];
        return CGRectContainsPoint(handleViewRect, point);
    }
    return [super pointInside:point withEvent:event];
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.dragView.frame, point)) {
        CGRect handleViewRect = [self convertRect:self.handleView.frame toView:self];
        if (CGRectContainsPoint(handleViewRect, point) )
        {
            return self.handleView;
        }
        return nil;
    }
    return [super hitTest:point withEvent:event];
}
@end

@interface MLSUISliderView ()
@property (nonatomic, assign) CGFloat topViewHeightCache;
@property (nonatomic, assign) CGFloat topViewHeight;
@property (nonatomic, assign) CGFloat topViewMaxHeight;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIView *innerTopView;
@property (nonatomic, strong) MLSUISliderDragView *innerBottomView;
@property (nonatomic, strong) UIView *innerBottomActionView;
@end
@implementation MLSUISliderView

- (void)setupView {
    [self _InitSliderView];
}

- (void)_InitSliderView {
    _topMinHeight = __MLSHeight(45) + __MLSHeight(30) + __MLSHeight(23);
    _bottomMinHeight = __MLSHeight(104);
    _bottomActionViewHeight = 0;
    _topViewHeight = _topMinHeight;
    _defaultTopHeight = __MLSHeight(180);
    [self _InitSubViews];
}
- (void)_InitSubViews {
    self.innerTopView = [[UIView alloc] init];
    self.innerTopView.backgroundColor = [UIColor clearColor];
    
    self.innerBottomView = [[MLSUISliderDragView alloc] init];
    self.innerBottomView.backgroundColor = [UIColor clearColor];
    
    self.innerBottomActionView = [[UIView alloc] init];
    self.innerBottomActionView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.innerTopView];
    [self addSubview:self.innerBottomView];
    [self addSubview:self.innerBottomActionView];
    
    [self showBottomAnimation:NO];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    self.innerBottomView.handleView.userInteractionEnabled = YES;
    [self.innerBottomView.handleView addGestureRecognizer:self.panGesture];
}
- (void)_layoutViewsHideBottom:(BOOL)hideBottom animation:(BOOL)animation {
    if (hideBottom) {
        [self.innerTopView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11, *)) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
            } else {
                make.top.equalTo(self.controller.mas_topLayoutGuideBottom);
                make.left.right.equalTo(self);
            }
        }];
        
        [self.innerBottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.innerTopView);
            make.top.equalTo(self.innerTopView.mas_bottom);
            make.height.mas_equalTo(0);
        }];
        
        [self.innerBottomActionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.innerTopView);
            make.top.equalTo(self.innerBottomView.mas_bottom);
            make.height.mas_equalTo(self.bottomActionViewHeight);
            if (@available(iOS 11, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
            }else {
                make.bottom.equalTo(self.controller.mas_bottomLayoutGuideTop);
            }
        }];
    } else {
        [self.innerTopView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11, *)) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
                make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
            } else {
                make.top.equalTo(self.controller.mas_topLayoutGuideBottom);
                make.left.right.equalTo(self);
            }
            make.height.mas_equalTo(self.defaultTopHeight).priorityHigh();
        }];
        
        [self.innerBottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.innerTopView);
            make.top.equalTo(self.innerTopView.mas_bottom).offset(-__MLSHeight(23));
        }];
        
        [self.innerBottomActionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.innerTopView);
            make.top.equalTo(self.innerBottomView.mas_bottom);
            make.height.mas_equalTo(self.bottomActionViewHeight);
            if (@available(iOS 11, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
            } else {
                make.bottom.equalTo(self.controller.mas_bottomLayoutGuideTop);
            }
        }];
    }
    if (animation) {
        [UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:5.0f options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
            self.innerBottomActionView.alpha = hideBottom ? 0 : 1;
            [self setNeedsLayout];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.innerBottomActionView.alpha = hideBottom ? 0 : 1;
            self.innerBottomActionView.hidden = hideBottom;
        }];
    } else {
        self.innerBottomActionView.alpha = hideBottom ? 0 : 1;
        self.innerBottomActionView.hidden = hideBottom;
    }
    
}
- (void)hideBottomAnimation:(BOOL)animation {
    [self _layoutViewsHideBottom:YES animation:animation];
}
- (void)showBottomAnimation:(BOOL)animation {
    [self _layoutViewsHideBottom:NO animation:animation];
}

- (void)relayoutSliderView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
- (void)panGesture:(UIPanGestureRecognizer *)panGesture {
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            [self endEditing:YES];
            self.topViewMaxHeight = CGRectGetHeight(self.bounds) - self.bottomActionViewHeight - self.bottomMinHeight;
            self.topViewHeight = CGRectGetHeight(self.innerTopView.bounds);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat moved = [panGesture translationInView:self].y;
            CGFloat height = self.topViewHeight + moved;
            height = MAX(MIN(height, self.topViewMaxHeight), self.topMinHeight);
            self.topViewHeightCache = height;
            [self.innerTopView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
            }];
            [self relayoutSliderView];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            self.topViewHeight = self.topViewHeightCache;
        }
            break;
            
        default:
            break;
    }
}
- (UIImageView *)dragHandleImgView {
    return self.innerBottomView.handleView;
}
- (void)setBottomMinHeight:(CGFloat)bottomMinHeight {
    if (_bottomMinHeight != bottomMinHeight) {
        _bottomMinHeight = bottomMinHeight;
        [self relayoutSliderView];
    }
}
- (void)setTopMinHeight:(CGFloat)topMinHeight {
    if (_topMinHeight != topMinHeight) {
        _topMinHeight = topMinHeight + __MLSHeight(23); // 加上手柄高度
        [self relayoutSliderView];
    }
}
- (void)setBottomActionViewHeight:(CGFloat)bottomActionViewHeight {
    if (_bottomActionViewHeight != bottomActionViewHeight) {
        _bottomActionViewHeight = bottomActionViewHeight;
        [self.innerBottomActionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(bottomActionViewHeight);
        }];
        [self relayoutSliderView];
    }
}
- (void)setTopView:(UIView *)topView {
    if (_topView != topView && topView) {
        [_topView removeFromSuperview];
        _topView = topView;
        [self.innerTopView addSubview:topView];
        [topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.innerTopView);
        }];
        [self relayoutSliderView];
    }
}
- (void)setBottomView:(UIView *)bottomView {
    if (_bottomView != bottomView && bottomView) {
        [_bottomView removeFromSuperview];
        _bottomView = bottomView;
        [self.innerBottomView.containerView addSubview:bottomView];
        [bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.innerBottomView.containerView);
        }];
        [self relayoutSliderView];
    }
}
- (void)setBottomActionView:(UIView *)bottomActionView {
    if (_bottomActionView != bottomActionView && bottomActionView) {
        [_bottomActionView removeFromSuperview];
        _bottomActionView = bottomActionView;
        [self.innerBottomActionView addSubview:bottomActionView];
        [bottomActionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.innerBottomActionView);
        }];
        [self relayoutSliderView];
    }
}
@end
