//
//  MLSSliderViewController.m
//  IQKeyboardManager
//
//  Created by 007 on 2018/5/16.
//

#import "MLSSliderViewController.h"
#import "MLSSliderBackView.h"
#import <Masonry/Masonry.h>
#import "MLSConfigurationDefine.h"

#define Bottom_Btn_Height 49

#define MLSSlider_SliderBtn_To_Top_Max 100
#define MLSSlider_SliderBtn_To_BottomBtn_Min 80

#define MLSSlider_SliderBtn_Dufault 180
@interface MLSSliderViewController ()
@property (nonatomic, strong) MLSSliderBackView *sliderView;
@property (nonatomic, strong) UIView *quesView;
@property (nonatomic, assign) CGFloat questViewHeight;
@property (nonatomic, assign) CGFloat questViewMovedHeight;
@end

@implementation MLSSliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addChildViewController:self.bottomController];
    [self addChildViewController:self.sliderController];
    self.questViewHeight = __MAIN_SCREEN_HEIGHT__;
    [self.view addSubview:self.quesView];
    [self.view addSubview:self.sliderView];
    [self.view addSubview:self.bottomView];
    [self.quesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.top.equalTo(self.view);
        make.height.mas_equalTo(self.questViewHeight); // 设置顶部视图最低高度
    }];
    
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.view);
        make.top.mas_equalTo(self.quesView.mas_bottom).mas_offset(__MLSHeight(-23));
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11, *)) {
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft);
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
            make.right.left.bottom.equalTo(self.view);
        } else {
            make.right.left.bottom.equalTo(self.view);
        }
        make.height.equalTo(@(__MLSHeight(Bottom_Btn_Height)));
    }];
    
    [self.view bringSubviewToFront:self.quesView];
    [self.view bringSubviewToFront:self.bottomView];
    
    [self.quesView addSubview:self.bottomController.view];
    [self.bottomController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.quesView);
    }];

    [self.sliderView.sliderContainerView addSubview:self.sliderController.view];
    [self.sliderController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.sliderView.sliderContainerView);
    }];
}

- (void)panAction:(UIPanGestureRecognizer *)recognizer {
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateChanged: {
            CGFloat moved = [recognizer translationInView:self.view].y;
            CGFloat height = self.questViewHeight + moved;
            self.questViewMovedHeight = height;
            if (height <= MLSSlider_SliderBtn_To_Top_Max) {
                height = MLSSlider_SliderBtn_To_Top_Max;
            } else if (height >  CGRectGetHeight(self.view.bounds) - Bottom_Btn_Height -MLSSlider_SliderBtn_To_BottomBtn_Min){
                height = CGRectGetHeight(self.view.bounds) - Bottom_Btn_Height -MLSSlider_SliderBtn_To_BottomBtn_Min;
            }
            [self.quesView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.left.top.equalTo(self.view);
                make.height.mas_equalTo(__MLSHeight(height));
            }];
            
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            self.questViewHeight = self.questViewMovedHeight;
            self.questViewMovedHeight = 0;
        }
            break;
            
        default:
            break;
    }
}

- (void)showSliderViewWithType:(MLSSliderViewType)sliderViewType {
    
    if (!sliderViewType) {
        sliderViewType = MLSSliderViewTypeDefault;
    }
    
    switch (sliderViewType) {
        case MLSSliderViewTypeDefault:{
            self.questViewHeight = 300;
            [self.quesView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.left.top.equalTo(self.view);
                make.height.mas_equalTo(self.questViewHeight); // 设置顶部视图最低高度
            }];
            [self.view bringSubviewToFront:self.sliderView];
        }
            break;
        case MLSSliderViewTypeDissmiss:{
            [self.view bringSubviewToFront:self.quesView];
            self.questViewHeight = CGRectGetHeight(self.view.bounds) - 49;
            [self.quesView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.left.top.equalTo(self.view);
                make.height.mas_equalTo(self.questViewHeight); // 设置顶部视图最低高度
            }];
        }
            break;
        default:
            break;
    }
    
}


- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];

    }
    return _bottomView;
}

- (MLSSliderBackView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[MLSSliderBackView alloc] init];
        _sliderView.dragImg = self.sliderDragImg;
        __weak MLSSliderViewController *weakSelf = self;
        _sliderView.panGetstureBlock = ^(UIPanGestureRecognizer *pan) {
            [weakSelf panAction:pan];
        };
    }
    return _sliderView;
}
- (UIView *)quesView {
    if (!_quesView) {
        _quesView = [[UIView alloc] init];
        _quesView.backgroundColor = [UIColor lightGrayColor];
        
    }
    return _quesView;
}

- (void)setSliderDragImg:(UIImage *)sliderDragImg {
    _sliderDragImg = sliderDragImg;
    self.sliderView.dragImg = sliderDragImg;
}
//- (void)setBottomController:(UIViewController *)bottomController {
//    _bottomController = bottomController;
//
//    [self.quesView addSubview:bottomController.view];
//    [bottomController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.quesView);
//    }];
//}
//
//- (void)setSliderController:(UIViewController *)sliderController {
//    _sliderController = sliderController;
//
//    [self.sliderView.sliderContainerView addSubview:sliderController.view];
//    [sliderController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.sliderView.sliderContainerView);
//    }];
//}

@end
