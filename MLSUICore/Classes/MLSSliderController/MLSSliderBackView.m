//
//  MLSSliderBackView.m
//  IQKeyboardManager
//
//  Created by 007 on 2018/5/16.
//

#import "MLSSliderBackView.h"
#import "MLSTipClass.h"
#import <Masonry/Masonry.h>

@interface MLSSliderBackView ()

@property (nonatomic, strong) UIButton *sliderBtn;

@end
@implementation MLSSliderBackView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
        [self addSubview:self.sliderBtn];
        [self.sliderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.centerX.equalTo(self);
            make.width.equalTo(@(85));
            make.height.equalTo(@(23));
        }];
        
        UIView *containerView = [[UIView alloc] init];
        self.sliderContainerView = containerView;
        [self addSubview:containerView];
        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.sliderBtn.mas_bottom);
            make.left.right.bottom.equalTo(self);
        }];
    }
    return self;
}

- (void)sliderBtnClickAction {
    [MLSTipClass showText:@"拖动看看"];
}

- (void)panGuestrueAction:(UIPanGestureRecognizer *)pan {
    if (self.panGetstureBlock) {
        self.panGetstureBlock(pan);
    }
}

- (UIButton *)sliderBtn {
    if (!_sliderBtn) {
        _sliderBtn = [[UIButton alloc] init];
        [_sliderBtn addTarget:self action:@selector(sliderBtnClickAction) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGuestrueAction:)];
        [_sliderBtn addGestureRecognizer:pan];
        
    }
    return _sliderBtn;
}

- (void)setDragImg:(UIImage *)dragImg {
    _dragImg = dragImg;
    [self.sliderBtn setBackgroundImage:dragImg forState:UIControlStateNormal];
}
@end
