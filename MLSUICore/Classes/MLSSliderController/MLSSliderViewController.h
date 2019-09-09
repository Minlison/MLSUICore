//
//  MLSSliderViewController.h
//  IQKeyboardManager
//
//  Created by 007 on 2018/5/16.
//

#import "MLSBaseViewController.h"


typedef enum : NSUInteger {
    MLSSliderViewTypeDefault,
    MLSSliderViewTypeDissmiss
} MLSSliderViewType;

@interface MLSSliderViewController : MLSBaseViewController

/** 底部view的控制器 */
@property (nonatomic, strong) UIViewController *bottomController;
/** 滑动view的控制器 */
@property (nonatomic, strong) UIViewController *sliderController;
/** 底部操作view */
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIImage *sliderDragImg;
/**
    默认default
 */
- (void)showSliderViewWithType:(MLSSliderViewType) sliderViewType;
@end
