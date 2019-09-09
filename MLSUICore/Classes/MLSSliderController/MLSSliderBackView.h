//
//  MLSSliderBackView.h
//  IQKeyboardManager
//
//  Created by 007 on 2018/5/16.
//

#import <UIKit/UIKit.h>

typedef void(^panActionBlock)(UIPanGestureRecognizer *);
@interface MLSSliderBackView : UIView
@property (nonatomic, strong) UIView *sliderContainerView;
@property (nonatomic, copy) panActionBlock panGetstureBlock;

/** dragImage */
@property (nonatomic, strong) UIImage *dragImg;
@end
