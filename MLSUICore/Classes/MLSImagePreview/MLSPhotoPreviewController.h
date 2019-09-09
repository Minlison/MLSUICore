//
//  MLSPhotoPreviewController.h
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//

#import "MLSBaseViewController.h"
#import <QMUIKit/QMUIImagePreviewView.h>
#import <QMUIKit/QMUILabel.h>

@interface MLSPhotoPreviewController : MLSBaseViewController  <QMUIImagePreviewViewDelegate>
@property (nonatomic, weak) id <QMUIImagePreviewViewDelegate> delegate;
// UIImage , NSURL, NSString
@property (nonatomic, strong) NSArray *imgs;
@property(nonatomic, strong, readonly) QMUIImagePreviewView *imagePreviewView;
@property(nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign, readonly) CGRect previewFromRect;
@property(nonatomic, strong, readonly) QMUILabel *contentLabel;
@property(nonatomic, strong, readonly) UIPageControl *pageControl;
@property (nonatomic, assign) BOOL enableLongPressSaveImg;
@end

/**
 *  以 UIWindow 的形式来预览图片，优点是能盖住界面上所有元素（包括状态栏），缺点是无法进行 viewController 的界面切换（因为被 UIWindow 盖住了）
 */
@interface MLSPhotoPreviewController (UIWindow)

/**
 *  从指定 rect 的位置以动画的形式进入预览
 *  @param rect 在当前屏幕坐标系里的 rect，注意传进来的 rect 要做坐标系转换，例如：[view.superview convertRect:view.frame toView:nil]
 *  @param cornerRadius 做打开动画时是否要从某个圆角渐变到 0
 */
- (void)startPreviewFromRectInScreen:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

/**
 *  从指定 rect 的位置以动画的形式进入预览，不考虑圆角
 *  @param rect 在当前屏幕坐标系里的 rect，注意传进来的 rect 要做坐标系转换，例如：[view.superview convertRect:view.frame toView:nil]
 */
- (void)startPreviewFromRectInScreen:(CGRect)rect;

/**
 *  将当前图片缩放到指定 rect 的位置，然后退出预览
 *  @param rect 在当前屏幕坐标系里的 rect，注意传进来的 rect 要做坐标系转换，例如：[view.superview convertRect:view.frame toView:nil]
 */
- (void)endPreviewToRectInScreen:(CGRect)rect;

/**
 *  以渐现的方式开始图片预览
 */
- (void)startPreviewFading;

/**
 *  使用渐隐的动画退出图片预览
 */
- (void)endPreviewFading;
@end

@interface MLSPhotoPreviewController (UIAppearance)

+ (instancetype)appearance;
@end

