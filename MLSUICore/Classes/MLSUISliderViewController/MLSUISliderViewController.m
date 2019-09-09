//
//  MLSSliderViewController.m
//  MLSLearnCenter
//
//  Created by minlison on 2018/5/28.
//  Copyright © 2018年 minlison. All rights reserved.
//

#import "MLSUISliderViewController.h"

@interface MLSUISliderViewController ()
@property (nonatomic, strong, readwrite) __kindof  MLSBaseViewController *topViewController;
@property (nonatomic, strong, readwrite) __kindof  MLSBaseViewController *bottomViewController;
@property (nonatomic, strong, readwrite) __kindof  UIView *bottomActionView;
@property (nonatomic, assign) BOOL hideBottom;
@property (nonatomic, strong) MLSUISliderView *sliderView;
@end

@implementation MLSUISliderViewController

- (void)initSubviews {
    [super initSubviews];
    self.sliderView = [[MLSUISliderView alloc] init];
    self.sliderView.controller = self;
    [self.sliderView setupView];
    if (_hideBottom) {
        [self.sliderView hideBottomAnimation:NO];
    } else {
        [self.sliderView showBottomAnimation:NO];
    }
    [self reloadSliderController];
}

- (void)reloadSliderController {
    if (self.isViewLoaded) {
        self.sliderView.dragHandleImgView.image = self.dragHandleImage;
        [self _loadDataFormDataSource];
        [self _loadDataFormDelegate];
    }
}

- (void)reloadData {
    [self.topViewController reloadData];
    [self.bottomViewController reloadData];
}

- (void)setHiddenBottomView:(BOOL)hidden animation:(BOOL)animation {
    self.hideBottom = hidden;
    hidden ? [self hideBottomControllerAnimation:animation] : [self showBottomControllerAnimation:animation];
}

- (void)hideBottomControllerAnimation:(BOOL)animation {
    if (self.isViewLoaded) {
        [self.sliderView hideBottomAnimation:animation];
    }
}

- (void)showBottomControllerAnimation:(BOOL)animation {
    if (self.isViewLoaded) {
        [self.sliderView showBottomAnimation:animation];
    }
}

- (void)_addChildController {
    
    if (self.topViewController) {
        [self.topViewController willMoveToParentViewController:self];
        [self addChildViewController:self.topViewController];
        self.sliderView.topView = self.topViewController.view;
        [self.topViewController didMoveToParentViewController:self];
    }
    
    if (self.bottomViewController) {
        [self.bottomViewController willMoveToParentViewController:self];
        [self addChildViewController:self.bottomViewController];
        self.sliderView.bottomView = self.bottomViewController.view;
        [self.bottomViewController didMoveToParentViewController:self];
    }
}

- (void)_removeChildController {
    [self.topViewController willMoveToParentViewController:nil];
    [self.topViewController removeFromParentViewController];
    [self.topViewController didMoveToParentViewController:nil];
    
    [self.bottomViewController willMoveToParentViewController:nil];
    [self.bottomViewController removeFromParentViewController];
    [self.bottomViewController didMoveToParentViewController:nil];
}

- (void)_loadDataFormDataSource {
    [self _removeChildController];
    
    if ([self.dataSource respondsToSelector:@selector(topViewController:)]) {
        self.topViewController = [self.dataSource topViewController:self];
    }
    if ([self.dataSource respondsToSelector:@selector(bottomViewController:)]) {
        self.bottomViewController = [self.dataSource bottomViewController:self];
    }
    if ([self.dataSource respondsToSelector:@selector(bottomActionView:)]) {
        self.sliderView.bottomActionView = [self.dataSource bottomActionView:self];
        self.bottomActionView = self.sliderView.bottomActionView;
    }
    [self _addChildController];
}

- (void)_loadDataFormDelegate {
    if ([self.delegate respondsToSelector:@selector(topMinHeight:)]) {
        self.sliderView.topMinHeight = [self.delegate topMinHeight:self];
    }
    if ([self.delegate respondsToSelector:@selector(bottomMinHeight:)]) {
        self.sliderView.bottomMinHeight = [self.delegate bottomMinHeight:self];
    }
    if ([self.delegate respondsToSelector:@selector(topDefaultHeight:)]) {
        self.sliderView.defaultTopHeight = [self.delegate topDefaultHeight:self];
    }
    if ([self.delegate respondsToSelector:@selector(bottomActionViewHeight:)]) {
        self.sliderView.bottomActionViewHeight = [self.delegate bottomActionViewHeight:self];
    }
}

//// Status Bar
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.bottomViewController.preferredStatusBarStyle;
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.bottomViewController;
}
- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.bottomViewController;
}
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return self.bottomViewController.preferredStatusBarUpdateAnimation;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.bottomViewController.supportedInterfaceOrientations;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.bottomViewController.preferredInterfaceOrientationForPresentation;
}
- (BOOL)shouldAutorotate {
    return self.bottomViewController.shouldAutorotate;
}
- (BOOL)prefersStatusBarHidden {
    return self.bottomViewController.prefersStatusBarHidden;
}
@end
