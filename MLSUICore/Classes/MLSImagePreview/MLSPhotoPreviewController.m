//
//  MLSPhotoPreviewController.m
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//

#import "MLSPhotoPreviewController.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#import "MLSConfigurationDefine.h"
#import "MLSFontUtils.h"
#import "MLSTipClass.h"
#import <SDWebImage/SDWebImage.h>
@implementation MLSPhotoPreviewController (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance];
    });
}

static MLSPhotoPreviewController *imagePreviewViewControllerAppearance;
+ (instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!imagePreviewViewControllerAppearance) {
            imagePreviewViewControllerAppearance = [[MLSPhotoPreviewController alloc] init];
            imagePreviewViewControllerAppearance.backgroundColor = [UIColor blackColor];
        }
    });
    return imagePreviewViewControllerAppearance;
}

@end

@interface MLSPhotoPreviewController ()

@property(nonatomic, strong) UIWindow *previewWindow;
@property(nonatomic, assign) BOOL shouldStartWithFading;
@property(nonatomic, assign, readwrite) CGRect previewFromRect;
@property(nonatomic, assign) CGFloat transitionCornerRadius;
@property(nonatomic, strong) UIImageView *transitionImageView;
@property(nonatomic, strong) UIColor *backgroundColorTemporarily;
@property(nonatomic, strong, readwrite) QMUILabel *contentLabel;
@property(nonatomic, strong, readwrite) UIPageControl *pageControl;
@end

@implementation MLSPhotoPreviewController

@synthesize imagePreviewView = _imagePreviewView;

- (void)didInitialize {
    [super didInitialize];
    if (@available(iOS 11, *)) {
        self.imagePreviewView.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if (imagePreviewViewControllerAppearance) {
        self.backgroundColor = [MLSPhotoPreviewController appearance].backgroundColor;
    }
}

- (QMUIImagePreviewView *)imagePreviewView {
    if (@available(iOS 9.0, *)) {
        [self loadViewIfNeeded];
    } else {
        // Fallback on earlier versions
    }
    return _imagePreviewView;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    if ([self isViewLoaded]) {
        self.view.backgroundColor = backgroundColor;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.backgroundColor;
}

- (void)initSubviews {
    [super initSubviews];
    _imagePreviewView = [[QMUIImagePreviewView alloc] initWithFrame:self.view.bounds];
    _imagePreviewView.delegate = self.delegate?:self;
    if ( @available(iOS 11.0, *) ) {
        self.imagePreviewView.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:self.imagePreviewView];
    self.contentLabel = [[QMUILabel alloc] initWithFrame:CGRectZero];
    self.contentLabel.clipsToBounds = YES;
    self.contentLabel.textAlignment = NSTextAlignmentLeft;
    self.contentLabel.textColor = [UIColor whiteColor];
    self.contentLabel.font = [UIFont boldSystemFontOfSize:16];
//    self.contentLabel.minimumLineHeight = 20;
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.userInteractionEnabled = NO;
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.bounds = CGRectMake(0, 0, __MAIN_SCREEN_WIDTH__, 15);
    self.pageControl.userInteractionEnabled = NO;
    [self layoutSubViews];
}

- (void)layoutSubViews {
    [self.view addSubview:self.contentLabel];
    [self.view addSubview:self.pageControl];
    
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0,*))
        {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-__MAIN_SCREEN_HEIGHT__*0.05);
            make.left.equalTo(self.view.mas_safeAreaLayoutGuideLeft).offset(20);
            make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).offset(-20);
            make.height.mas_equalTo(120);
        } else
        {
            make.bottom.equalTo(self.view.mas_bottom).offset(-__MAIN_SCREEN_HEIGHT__*0.05);
            make.left.equalTo(self.view).offset(-20);
            make.right.equalTo(self.view).offset(20);
            make.height.mas_equalTo(120);
        }
    }];
    
    [self.pageControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-__MLSHeight(5));
        make.height.mas_equalTo(__MLSHeight(15));
    }];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.imagePreviewView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.imagePreviewView.collectionView reloadData];
    
    if (self.previewWindow && !self.shouldStartWithFading) {
        // 为在 viewDidAppear 做动画做准备
        self.imagePreviewView.collectionView.hidden = YES;
    } else {
        self.imagePreviewView.collectionView.hidden = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 配合 MLSPhotoPreviewController (UIWindow) 使用的
    if (self.previewWindow) {
        
        if (self.shouldStartWithFading) {
            [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
                self.view.alpha = 1;
            } completion:^(BOOL finished) {
                self.imagePreviewView.collectionView.hidden = NO;
                self.shouldStartWithFading = NO;
            }];
            return;
        }
        
        QMUIZoomImageView *zoomImageView = [self.imagePreviewView zoomImageViewAtIndex:self.imagePreviewView.currentImageIndex];
        if (!zoomImageView) {
            NSAssert(NO, @"第 %@ 个 zoomImageView 不存在，可能当前还处于非可视区域", @(self.imagePreviewView.currentImageIndex));
        }
        CGRect transitionFromRect = self.previewFromRect;
        CGRect transitionToRect = [self.view convertRect:[zoomImageView contentViewRectInZoomImageView] fromView:zoomImageView.superview];
        
        self.transitionImageView.contentMode = zoomImageView.imageView.contentMode;
        self.transitionImageView.image = zoomImageView.imageView.image;
        self.transitionImageView.frame = transitionFromRect;
        self.transitionImageView.clipsToBounds = YES;
        self.transitionImageView.layer.cornerRadius = self.transitionCornerRadius;
        [self.view addSubview:self.transitionImageView];
        
        [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.transitionImageView.frame = transitionToRect;
            self.transitionImageView.layer.cornerRadius = 0;
            self.view.backgroundColor = self.backgroundColorTemporarily;
        } completion:^(BOOL finished) {
            [self.transitionImageView removeFromSuperview];
            self.imagePreviewView.collectionView.hidden = NO;
            self.backgroundColorTemporarily = nil;
        }];
    }
}
#pragma mark - imagePreview 代理
- (NSUInteger)numberOfImagesInImagePreviewView:(QMUIImagePreviewView *)imagePreviewView {
    return self.imgs.count;
}
- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView renderZoomImageView:(QMUIZoomImageView *)zoomImageView atIndex:(NSUInteger)index {
    zoomImageView.reusedIdentifier = @(index);
    id img = [self.imgs objectAtIndex:index];
    if ([img isKindOfClass:[UIImage class]]) {
        zoomImageView.image = img;
    } else if ([img isKindOfClass:[NSString class]]) {
        NSString *imgStr = img;
        if ([imgStr hasPrefix:@"http"]) {
            [zoomImageView showLoading];
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:imgStr] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if ([zoomImageView.reusedIdentifier isEqual:@(index)]) {
                    [zoomImageView hideEmptyView];
                    if (error) {
                        [zoomImageView showEmptyViewWithText:error.localizedDescription];
                    } else {
                        zoomImageView.image = image;
                    }
                }
            }];
        } else {
            zoomImageView.image = [UIImage imageWithContentsOfFile:imgStr];
        }
    } else if ([img isKindOfClass:NSURL.class]) {
        [zoomImageView showLoading];
        [SDWebImageManager.sharedManager loadImageWithURL:img options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if ([zoomImageView.reusedIdentifier isEqual:@(index)]) {
                [zoomImageView hideEmptyView];
                if (error) {
                    [zoomImageView showEmptyViewWithText:error.localizedDescription];
                } else {
                    zoomImageView.image = image;
                }
            }
        }];
    }
}
// 返回要展示的媒体资源的类型（图片、live photo、视频），如果不实现此方法，则 QMUIImagePreviewView 将无法选择最合适的 cell 来复用从而略微增大系统开销
- (QMUIImagePreviewMediaType)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView assetTypeAtIndex:(NSUInteger)index {
    return QMUIImagePreviewMediaTypeImage;
}
- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView didScrollToIndex:(NSUInteger)index {
    
}
- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView willScrollHalfToIndex:(NSUInteger)index {
    
}
- (void)singleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location {
    [self endPreviewToRectInScreen:self.previewFromRect];
}
- (void)longPressInZoomingImageView:(QMUIZoomImageView *)zoomImageView {
    if (!self.enableLongPressSaveImg) {
        return;
    }
    QMUIAlertController *alertVC = [QMUIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(QMUIAlertControllerStyleActionSheet)];
    QMUIAlertAction*action = [QMUIAlertAction actionWithTitle:@"保存图片" style:(QMUIAlertActionStyleDefault) handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        [self saveImageToAlbum:zoomImageView.image];
    }];
    [alertVC addAction:action];
    [alertVC addAction:[QMUIAlertAction actionWithTitle:@"取消" style:(QMUIAlertActionStyleCancel) handler:nil]];
    alertVC.sheetButtonHeight = __MLSHeight(50.0f);
    alertVC.sheetContentCornerRadius = 0;
    alertVC.sheetButtonBackgroundColor = [UIColor whiteColor];
    alertVC.sheetHeaderInsets = UIEdgeInsetsZero;
    alertVC.sheetHeaderInsets = UIEdgeInsetsZero;
    alertVC.sheetContentMargin = UIEdgeInsetsZero;
    alertVC.sheetSeparatorColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
//    alertVC.sheetButtonBackgroundColor = [UIColorHex(0xCDCDD1) colorWithAlphaComponent:0.8];
    alertVC.sheetTitleMessageSpacing = 0;
    alertVC.sheetCancelButtonMarginTop = __MLSHeight(6);
    alertVC.sheetContentMaximumWidth = __MAIN_SCREEN_WIDTH__;
    NSDictionary *titleAttribute = @{
                                     NSFontAttributeName : MLSSystem16Font,
                                     NSForegroundColorAttributeName : [UIColor blackColor]
                                     };
    alertVC.sheetTitleAttributes = titleAttribute;
    alertVC.sheetButtonAttributes = titleAttribute;
    alertVC.sheetButtonDisabledAttributes = titleAttribute;
    alertVC.sheetCancelButtonAttributes = titleAttribute;
    [alertVC showWithAnimated:YES];
}
- (void)saveImageToAlbum:(UIImage *)image {
    // 显示空相册，不显示智能相册
    __block QMUIAssetsGroup *saveAssetsGroup = nil;
    __block NSError *saveAssetsError = nil;
    [[QMUIAssetsManager sharedInstance] enumerateAllAlbumsWithAlbumContentType:QMUIAlbumContentTypeOnlyPhoto showEmptyAlbum:YES showSmartAlbumIfSupported:NO usingBlock:^(QMUIAssetsGroup *resultAssetsGroup) {
        if (saveAssetsGroup == nil && saveAssetsError == nil)
        {
            if (resultAssetsGroup)
            {
                saveAssetsGroup = resultAssetsGroup;
                QMUIImageWriteToSavedPhotosAlbumWithAlbumAssetsGroup(image, saveAssetsGroup, ^(QMUIAsset *asset, NSError *error) {
                    if (!error)
                    {
                        saveAssetsError = nil;
                        [MLSTipClass showSuccessWithText:@"已保存到相册" inView:self.view];
                    }
                    else
                    {
                        saveAssetsGroup = nil;
                        saveAssetsError = error;
                    }
                });
            }
            else
            {
                [MLSTipClass showErrorWithText:saveAssetsError.localizedDescription inView:self.view];
            }
        }
    }];
}
@end

@implementation MLSPhotoPreviewController (UIWindow)

- (void)startPreviewFromRectInScreen:(CGRect)rect cornerRadius:(CGFloat)cornerRadius {
    self.transitionCornerRadius = cornerRadius;
    [self startPreviewWithFadingAnimation:NO orFromRect:rect];
}

- (void)startPreviewFromRectInScreen:(CGRect)rect {
    [self startPreviewFromRectInScreen:rect cornerRadius:0];
}

- (void)endPreviewToRectInScreen:(CGRect)rect {
    [self endPreviewWithFadingAnimation:NO orToRect:rect];
    self.transitionCornerRadius = 0;
}

- (void)startPreviewFading {
    self.transitionCornerRadius = 0;
    [self startPreviewWithFadingAnimation:YES orFromRect:CGRectZero];
}

- (void)endPreviewFading {
    [self endPreviewWithFadingAnimation:YES orToRect:CGRectZero];
    self.transitionCornerRadius = 0;
}


#pragma mark - 动画

- (void)initPreviewWindowIfNeeded {
    if (!self.previewWindow) {
        self.previewWindow = [[UIWindow alloc] init];
        self.previewWindow.windowLevel = UIWindowLevelQMUIAlertView;
        self.previewWindow.backgroundColor = UIColorClear;
    }
}

- (void)removePreviewWindow {
    self.previewWindow.hidden = YES;
    self.previewWindow.rootViewController = nil;
    self.previewWindow = nil;
}

- (void)startPreviewWithFadingAnimation:(BOOL)isFading orFromRect:(CGRect)rect {
    self.shouldStartWithFading = isFading;
    
    if (isFading) {
        
        // 为动画做准备，先置为透明
        self.view.alpha = 0;
        
    } else {
        self.previewFromRect = rect;
        
        if (!self.transitionImageView) {
            self.transitionImageView = [[UIImageView alloc] init];
        }
        
        // 为动画做准备，先置为透明
        self.backgroundColorTemporarily = self.view.backgroundColor;
        self.view.backgroundColor = UIColorClear;
    }
    
    [self initPreviewWindowIfNeeded];
    
    self.previewWindow.rootViewController = self;
    self.previewWindow.hidden = NO;
}

- (void)endPreviewWithFadingAnimation:(BOOL)isFading orToRect:(CGRect)rect {
    
    if (isFading) {
        [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self removePreviewWindow];
            self.view.alpha = 1;
        }];
        return;
    }
    
    QMUIZoomImageView *zoomImageView = [self.imagePreviewView zoomImageViewAtIndex:self.imagePreviewView.currentImageIndex];
    CGRect transitionFromRect = [zoomImageView contentViewRectInZoomImageView];
    CGRect transitionToRect = rect;
    
    self.transitionImageView.image = zoomImageView.image;
    self.transitionImageView.frame = transitionFromRect;
    [self.view addSubview:self.transitionImageView];
    self.imagePreviewView.collectionView.hidden = YES;
    
    self.backgroundColorTemporarily = self.view.backgroundColor;
    
    [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
        self.transitionImageView.frame = transitionToRect;
        self.transitionImageView.layer.cornerRadius = self.transitionCornerRadius;
        self.view.backgroundColor = UIColorClear;
    } completion:^(BOOL finished) {
        [self removePreviewWindow];
        [self.transitionImageView removeFromSuperview];
        self.imagePreviewView.collectionView.hidden = NO;
        self.view.backgroundColor = self.backgroundColorTemporarily;
        self.backgroundColorTemporarily = nil;
    }];
}

@end
