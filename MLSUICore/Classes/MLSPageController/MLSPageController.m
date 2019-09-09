//
//  MLSPageController.m
//  MLSPageController
//
//  Created by minlison on 18/5/9.
//  Copyright (c) 2018年 minlison. All rights reserved.
//

#import "MLSPageController.h"
#import "MLSMenuView.h"
#import "MLSPageScrollView.h"
#import <QMUIKit/UIView+QMUI.h>

NSString *const MLSControllerDidAddToSuperViewNotification = @"MLSControllerDidAddToSuperViewNotification";
NSString *const MLSControllerDidFullyDisplayedNotification = @"MLSControllerDidFullyDisplayedNotification";

static NSInteger const kMLSUndefinedIndex = -1;
static NSInteger const kMLSControllerCountUndefined = -1;
@interface MLSPageController () {
    CGFloat _viewHeight, _viewWidth, _viewX, _viewY, _targetX, _superviewHeight;
    CGRect  _contentViewFrame, _menuViewFrame;
    BOOL    _hasInited, _shouldNotScroll, _isTabBarHidden;;
    NSInteger _initializedIndex, _controllerCount, _markedSelectIndex;
}
@property (nonatomic, strong, readwrite) UIViewController *currentViewController;
// 用于记录子控制器view的frame，用于 scrollView 上的展示的位置
@property (nonatomic, strong) NSMutableArray *childViewFrames;
// 当前展示在屏幕上的控制器，方便在滚动的时候读取 (避免不必要计算)
@property (nonatomic, strong) NSMutableDictionary *displayVC;
// 用于记录销毁的viewController的位置 (如果它是某一种scrollView的Controller的话)
@property (nonatomic, strong) NSMutableDictionary *posRecords;
// 用于缓存加载过的控制器
@property (nonatomic, strong) NSCache *memCache;
@property (nonatomic, strong) NSMutableDictionary *backgroundCache;
// 收到内存警告的次数
@property (nonatomic, assign) int memoryWarningCount;
@property (nonatomic, readonly) NSInteger childControllersCount;
@property (nonatomic, assign) BOOL callDidEnter;
@end

@implementation MLSPageController

#pragma mark - Lazy Loading
- (NSMutableDictionary *)posRecords {
    if (_posRecords == nil) {
        _posRecords = [[NSMutableDictionary alloc] init];
    }
    return _posRecords;
}

- (NSMutableDictionary *)displayVC {
    if (_displayVC == nil) {
        _displayVC = [[NSMutableDictionary alloc] init];
    }
    return _displayVC;
}

- (NSMutableDictionary *)backgroundCache {
    if (_backgroundCache == nil) {
        _backgroundCache = [[NSMutableDictionary alloc] init];
    }
    return _backgroundCache;
}

#pragma mark - Public Methods
+ (instancetype)defaultPageControllerWithTitles:(NSArray<NSString *> *)titles {
    MLSPageController *pageController = [[MLSPageController alloc] init];
    pageController.delegate = pageController;
    pageController.dataSource = pageController;
    pageController.showMenuView = YES;
    pageController.pageAnimatable = YES;
    pageController.menuHeight = 50;
    pageController.menuViewStyle = MLSMenuViewStyleLine;
    pageController.menuViewLayoutMode = MLSMenuViewLayoutModeScatter;
    pageController.progressHeight = 1;
    pageController.progressColor = [UIColor colorWithRed:255.0/255.0 green:136.0/255.0 blue:0 alpha:1];
    pageController.titleSizeNormal = 16;
    pageController.menuBGColor = [UIColor whiteColor];
    pageController.titleColorNormal = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1];
    pageController.titleColorSelected = [UIColor colorWithRed:255.0/255.0 green:136.0/255.0 blue:0 alpha:1];
    pageController.progressBgColor = [UIColor clearColor];
    pageController.menuSeparateWidth = 1;
    pageController.menuSeparateColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
    pageController.menuSeparateInset = UIEdgeInsetsMake(10, 0, 10, 0);
    pageController.menuBottomLineWidth = 1;
    pageController.menuBottomLineColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1];
    pageController.titles = titles;
    pageController.menuItemWidth = titles.count != 0 ? CGRectGetWidth(UIScreen.mainScreen.bounds) / titles.count : 50;
    return pageController;
}
- (instancetype)initWithViewControllerClasses:(NSArray<Class> *)classes andTheirTitles:(NSArray<NSString *> *)titles {
    if (self = [super init]) {
        NSParameterAssert(classes.count == titles.count);
        _viewControllerClasses = [NSArray arrayWithArray:classes];
        _titles = [NSArray arrayWithArray:titles];
        
        [self MLS_setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self MLS_setup];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self MLS_setup];
    }
    return self;
}
- (void)setEdgesForExtendedLayout:(UIRectEdge)edgesForExtendedLayout {
    if (self.edgesForExtendedLayout == edgesForExtendedLayout) return;
    [super setEdgesForExtendedLayout:edgesForExtendedLayout];
    
    if (_hasInited) {
        _hasInited = NO;
        [self viewDidLayoutSubviews];
    }
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self MLS_setup];
    }
    return self;
}

- (void)forceLayoutSubviews {
    _hasInited = NO;
    if (!self.childControllersCount) return;
    // 计算宽高及子控制器的视图frame
    [self MLS_calculateSize];
    [self MLS_adjustScrollViewFrame];
    [self MLS_adjustMenuViewFrame];
    [self MLS_adjustDisplayingViewControllersFrame];
}

- (void)setScrollEnable:(BOOL)scrollEnable {
    _scrollEnable = scrollEnable;
    
    if (!self.scrollView) return;
    self.scrollView.scrollEnabled = scrollEnable;
}

- (void)setProgressViewCornerRadius:(CGFloat)progressViewCornerRadius {
    _progressViewCornerRadius = progressViewCornerRadius;
    if (self.menuView) {
        self.menuView.progressViewCornerRadius = progressViewCornerRadius;
    }
}

- (void)setMenuViewLayoutMode:(MLSMenuViewLayoutMode)menuViewLayoutMode {
    _menuViewLayoutMode = menuViewLayoutMode;
    if (self.menuView.superview) {
        [self MLS_resetMenuView];
    }
}

- (void)setCachePolicy:(MLSPageControllerCachePolicy)cachePolicy {
    _cachePolicy = cachePolicy;
    if (cachePolicy != MLSPageControllerCachePolicyDisabled) {
        self.memCache.countLimit = _cachePolicy;
    }
}

- (void)setSelectIndex:(int)selectIndex {
    if (selectIndex < 0) {
        selectIndex = 0;
    }
    self.callDidEnter = NO;
    _selectIndex = selectIndex;
    _markedSelectIndex = kMLSUndefinedIndex;
    if (self.menuView && _hasInited) {
        [self.menuView selectItemAtIndex:selectIndex];
    } else {
        _markedSelectIndex = selectIndex;
    }
}
- (void)setSelectIndex:(int)selectIndex animation:(BOOL)animation {
    BOOL oldAnimation = self.pageAnimatable;
    self.pageAnimatable = animation;
    [self setSelectIndex:selectIndex];
    self.pageAnimatable = oldAnimation;
}
- (void)setProgressViewIsNaughty:(BOOL)progressViewIsNaughty {
    _progressViewIsNaughty = progressViewIsNaughty;
    if (self.menuView) {
        self.menuView.progressViewIsNaughty = progressViewIsNaughty;
    }
}

- (void)setProgressWidth:(CGFloat)progressWidth {
    _progressWidth = progressWidth;
    self.progressViewWidths = ({
        NSMutableArray *tmp = [NSMutableArray array];
        for (int i = 0; i < self.childControllersCount; i++) {
            [tmp addObject:@(progressWidth)];
        }
        tmp.copy;
    });
}

- (void)setProgressViewWidths:(NSArray *)progressViewWidths {
    _progressViewWidths = progressViewWidths;
    if (self.menuView) {
        self.menuView.progressWidths = progressViewWidths;
    }
}

- (void)setMenuViewContentMargin:(CGFloat)menuViewContentMargin {
    _menuViewContentMargin = menuViewContentMargin;
    if (self.menuView) {
        self.menuView.contentMargin = menuViewContentMargin;
    }
}

- (void)setViewFrame:(CGRect)viewFrame {
    if (CGRectEqualToRect(viewFrame, _viewFrame)) return;
    
    _viewFrame = viewFrame;
    if (self.menuView) {
        _hasInited = NO;
        [self viewDidLayoutSubviews];
    }
}

- (void)reloadPageController {
    [self MLS_clearDatas];
    
    if (!self.childControllersCount) return;
    [self MLS_calculateSize];
    [self MLS_resetScrollView];
    [self.memCache removeAllObjects];
    [self MLS_resetMenuView];
    [self viewDidLayoutSubviews];
    [self didEnterController:self.currentViewController atIndex:self.selectIndex];
}

- (void)updateTitle:(NSString *)title atIndex:(NSInteger)index {
    [self.menuView updateTitle:title atIndex:index andWidth:NO];
}

- (void)updateAttributeTitle:(NSAttributedString * _Nonnull)title atIndex:(NSInteger)index {
    [self.menuView updateAttributeTitle:title atIndex:index andWidth:NO];
}

- (void)updateTitle:(NSString *)title andWidth:(CGFloat)width atIndex:(NSInteger)index {
    if (self.itemsWidths && index < self.itemsWidths.count) {
        NSMutableArray *mutableWidths = [NSMutableArray arrayWithArray:self.itemsWidths];
        mutableWidths[index] = @(width);
        self.itemsWidths = [mutableWidths copy];
    } else {
        NSMutableArray *mutableWidths = [NSMutableArray array];
        for (int i = 0; i < self.childControllersCount; i++) {
            CGFloat itemWidth = (i == index) ? width : self.menuItemWidth;
            [mutableWidths addObject:@(itemWidth)];
        }
        self.itemsWidths = [mutableWidths copy];
    }
    [self.menuView updateTitle:title atIndex:index andWidth:YES];
}
- (void)setDirection:(MLSPageControllerScrollDirection)direction {
    if (_direction == direction) {
        return;
    }
    _direction = direction;
    [self forceLayoutSubviews];
}
- (void)setShowMenuView:(BOOL)showMenuView {
    if (_showMenuView == showMenuView) {
        return;
    }
    _showMenuView = showMenuView;
    [self forceLayoutSubviews];
}
- (void)setShowOnNavigationBar:(BOOL)showOnNavigationBar {
    if (_showOnNavigationBar == showOnNavigationBar) {
        return;
    }
    
    _showOnNavigationBar = showOnNavigationBar;
    if (self.menuView) {
        [self.menuView removeFromSuperview];
        [self MLS_addMenuView];
        [self forceLayoutSubviews];
        [self.menuView slideMenuAtProgress:self.selectIndex];
    }
}

#pragma mark - Notification
- (void)willResignActive:(NSNotification *)notification {
    for (int i = 0; i < self.childControllersCount; i++) {
        id obj = [self.memCache objectForKey:@(i)];
        if (obj) {
            [self.backgroundCache setObject:obj forKey:@(i)];
        }
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    for (NSNumber *key in self.backgroundCache.allKeys) {
        if (![self.memCache objectForKey:key]) {
            [self.memCache setObject:self.backgroundCache[key] forKey:key];
        }
    }
    [self.backgroundCache removeAllObjects];
}

#pragma mark - Delegate
- (NSDictionary *)infoWithIndex:(NSInteger)index {
    NSString *title = [self titleAtIndex:index];
    return @{@"title": title ?: @"", @"index": @(index)};
}

- (void)willCachedController:(UIViewController *)vc atIndex:(NSInteger)index {
    if (self.childControllersCount && [self.delegate respondsToSelector:@selector(pageController:willCachedViewController:withInfo:)]) {
        NSDictionary *info = [self infoWithIndex:index];
        [self.delegate pageController:self willCachedViewController:vc withInfo:info];
    }
}

- (void)willEnterController:(UIViewController *)vc atIndex:(NSInteger)index {
    _selectIndex = (int)index;
    self.callDidEnter = NO;
    if (self.childControllersCount && [self.delegate respondsToSelector:@selector(pageController:willEnterViewController:withInfo:)]) {
        NSDictionary *info = [self infoWithIndex:index];
        [self.delegate pageController:self willEnterViewController:vc withInfo:info];
    }
}

// 完全进入控制器 (即停止滑动后调用)
- (void)didEnterController:(UIViewController *)vc atIndex:(NSInteger)index {
    if (!self.childControllersCount) return;
    
    // Post FullyDisplayedNotification
    [self MLS_postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
    
    NSDictionary *info = [self infoWithIndex:index];
    if (_selectIndex != index || !self.callDidEnter) {
        self.callDidEnter = YES;
        if ([self.delegate respondsToSelector:@selector(pageController:didEnterViewController:withInfo:)]) {
            [self.delegate pageController:self didEnterViewController:vc withInfo:info];
        }
    }
    
    
    // 当控制器创建时，调用延迟加载的代理方法
    if (_initializedIndex == index && [self.delegate respondsToSelector:@selector(pageController:lazyLoadViewController:withInfo:)]) {
        [self.delegate pageController:self lazyLoadViewController:vc withInfo:info];
        _initializedIndex = kMLSUndefinedIndex;
    }
    
    // 根据 preloadPolicy 预加载控制器
    if (self.preloadPolicy == MLSPageControllerPreloadPolicyNever) return;
    int length = (int)self.preloadPolicy;
    int start = 0;
    int end = (int)self.childControllersCount - 1;
    if (index > length) {
        start = (int)index - length;
    }
    if (self.childControllersCount - 1 > length + index) {
        end = (int)index + length;
    }
    for (int i = start; i <= end; i++) {
        // 如果已存在，不需要预加载
        if (![self.memCache objectForKey:@(i)] && !self.displayVC[@(i)]) {
            [self MLS_addViewControllerAtIndex:i callWillEnter:YES];
            [self MLS_postAddToSuperViewNotificationWithIndex:i];
        }
    }
    _selectIndex = (int)index;
}

#pragma mark - Data source
- (NSInteger)childControllersCount {
    if (_controllerCount == kMLSControllerCountUndefined) {
        if ([self.dataSource respondsToSelector:@selector(numbersOfChildControllersInPageController:)]) {
            _controllerCount = [self.dataSource numbersOfChildControllersInPageController:self];
        } else {
            _controllerCount = self.viewControllerClasses.count;
        }
    }
    return _controllerCount;
}

- (UIViewController * _Nonnull)initializeViewControllerAtIndex:(NSInteger)index {
    if ([self.dataSource respondsToSelector:@selector(pageController:viewControllerAtIndex:)]) {
        return [self.dataSource pageController:self viewControllerAtIndex:index];
    }
    return [[self.viewControllerClasses[index] alloc] init];
}

- (NSString * _Nonnull)titleAtIndex:(NSInteger)index {
    NSString *title = nil;
    if ([self.dataSource respondsToSelector:@selector(pageController:titleAtIndex:)]) {
        title = [self.dataSource pageController:self titleAtIndex:index];
    } else {
        title = self.titles[index];
    }
    return (title ?: @"");
}
/// MARK: - QMUI
- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view {
    if ([self.currentViewController isKindOfClass:[MLSBaseViewController class]]) {
        return [(MLSBaseViewController *)self.currentViewController shouldHideKeyboardWhenTouchInView:view];
    }
    return YES;
}
#pragma mark - Private Methods

- (void)MLS_resetScrollView {
    if (self.scrollView) {
        [self.scrollView removeFromSuperview];
    }
    [self MLS_addScrollView];
    [self MLS_addViewControllerAtIndex:self.selectIndex callWillEnter:YES];
    self.currentViewController = self.displayVC[@(self.selectIndex)];
}

- (void)MLS_clearDatas {
    self.callDidEnter = NO;
    _controllerCount = kMLSControllerCountUndefined;
    _hasInited = NO;
    NSUInteger maxIndex = (self.childControllersCount - 1 > 0) ? (self.childControllersCount - 1) : 0;
    _selectIndex = self.selectIndex < self.childControllersCount ? self.selectIndex : (int)maxIndex;
    if (self.progressWidth > 0) { self.progressWidth = self.progressWidth; }
    
    NSArray *displayingViewControllers = self.displayVC.allValues;
    for (UIViewController *vc in displayingViewControllers) {
        [vc.view removeFromSuperview];
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
    self.memoryWarningCount = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(MLS_growCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(MLS_growCachePolicyToHigh) object:nil];
    self.currentViewController = nil;
    [self.posRecords removeAllObjects];
    [self.displayVC removeAllObjects];
}

// 当子控制器init完成时发送通知
- (void)MLS_postAddToSuperViewNotificationWithIndex:(int)index {
    if (!self.postNotification) return;
    NSDictionary *info = @{
                           @"index":@(index),
                           @"title":[self titleAtIndex:index]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:MLSControllerDidAddToSuperViewNotification
                                                        object:self
                                                      userInfo:info];
}

// 当子控制器完全展示在user面前时发送通知
- (void)MLS_postFullyDisplayedNotificationWithCurrentIndex:(int)index {
    if (!self.postNotification) return;
    NSDictionary *info = @{
                           @"index":@(index),
                           @"title":[self titleAtIndex:index]
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:MLSControllerDidFullyDisplayedNotification
                                                        object:self
                                                      userInfo:info];
}

// 初始化一些参数，在init中调用
- (void)MLS_setup {
    _titleSizeSelected  = 18.0f;
    _titleSizeNormal    = 15.0f;
    _titleColorSelected = [UIColor colorWithRed:168.0/255.0 green:20.0/255.0 blue:4/255.0 alpha:1];
    _titleColorNormal   = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    _menuBGColor   = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
    _menuHeight    = 30.0f;
    _menuItemWidth = 65.0f;
    _menuSeparateInset = UIEdgeInsetsMake(10, 0, 10, 0);
    _menuSeparateWidth = 0.5;
    _menuSeparateColor = [UIColor colorWithWhite:0 alpha:0.1];
    _menuBottomLineColor = [UIColor colorWithWhite:0 alpha:0.1];
    _menuBottomLineWidth = 0.5;
    _progressColor = [UIColor colorWithWhite:0 alpha:0.1];
    _progressBgColor = [UIColor colorWithWhite:0 alpha:0.1];
    
    _memCache = [[NSCache alloc] init];
    _initializedIndex = kMLSUndefinedIndex;
    _markedSelectIndex = kMLSUndefinedIndex;
    _controllerCount  = kMLSControllerCountUndefined;
    _scrollEnable = YES;
    _showMenuView = YES;
    self.automaticallyCalculatesItemWidths = NO;
    
    self.preloadPolicy = MLSPageControllerPreloadPolicyNever;
    self.cachePolicy = MLSPageControllerCachePolicyNoLimit;
    
    self.delegate = self;
    self.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

// 包括宽高，子控制器视图 frame
- (void)MLS_calculateSize {
    
    CGFloat navigationHeight = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    UIView *tabBar = [self MLS_bottomView];
    CGFloat height = (tabBar && !tabBar.hidden) ? CGRectGetHeight(tabBar.frame) : 0;
    CGFloat tarBarHeight = (self.hidesBottomBarWhenPushed == YES) ? 0 : height;
    // 计算相对 window 的绝对 frame (self.view.window 可能为 nil)
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    CGRect absoluteRect = [self.view convertRect:self.view.bounds toView:mainWindow];
    navigationHeight -= absoluteRect.origin.y;
    tarBarHeight -= mainWindow.frame.size.height - CGRectGetMaxY(absoluteRect);
    
    if (self.showMenuView) {
        if ([self.dataSource respondsToSelector:@selector(pageController:preferredFrameForMenuView:)]) {
            _menuViewFrame = [self.dataSource pageController:self preferredFrameForMenuView:self.menuView];
            self.menuHeight = CGRectGetHeight(_menuViewFrame);
        } else {
            _menuViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.menuHeight);
        }
    } else {
        _menuViewFrame = CGRectMake(0, 0, self.view.frame.size.width, 0.0f);
    }
    
    _viewX = self.viewFrame.origin.x;
    _viewY = self.viewFrame.origin.y;
    if (CGRectEqualToRect(self.viewFrame, CGRectZero)) {
        _viewWidth = self.view.frame.size.width;
        _viewHeight = self.view.frame.size.height;
        if (self.showMenuView) {
             _viewHeight = _viewHeight - _menuViewFrame.size.height - self.menuViewBottomSpace;
            _viewY += (_menuViewFrame.size.height + self.menuViewBottomSpace);
        }
    } else {
        _viewWidth = self.viewFrame.size.width;
        _viewHeight = self.viewFrame.size.height;
        if (self.showMenuView) {
            _viewHeight = _viewHeight - _menuViewFrame.size.height - self.menuViewBottomSpace;
            _viewY += (_menuViewFrame.size.height + self.menuViewBottomSpace);
        }
    }
    
    if (self.showOnNavigationBar && self.navigationController.navigationBar) {
        _viewHeight += (_menuViewFrame.size.height + self.menuViewBottomSpace);
        _viewY -= (_menuViewFrame.size.height + self.menuViewBottomSpace);
    }
    
    
    if ([self.dataSource respondsToSelector:@selector(pageController:preferredFrameForContentView:)]) {
        _contentViewFrame = [self.dataSource pageController:self preferredFrameForContentView:self.scrollView];
    } else {
        _contentViewFrame = CGRectMake(_viewX, _viewY, self.view.frame.size.width, _viewHeight);
    }
    
    _childViewFrames = [NSMutableArray array];
    if (self.direction == MLSPageControllerScrollDirectionHorizontal) {
        for (int i = 0; i < self.childControllersCount; i++) {
            CGRect frame = CGRectMake(i * _contentViewFrame.size.width, 0, _contentViewFrame.size.width, _contentViewFrame.size.height);
            [_childViewFrames addObject:[NSValue valueWithCGRect:frame]];
        }
    }
    else if (self.direction == MLSPageControllerScrollDirectionVertical) {
        for (int i = 0; i < self.childControllersCount; i++) {
            CGRect frame = CGRectMake(0, i * _contentViewFrame.size.height, _contentViewFrame.size.width, _contentViewFrame.size.height);
            [_childViewFrames addObject:[NSValue valueWithCGRect:frame]];
        }
    }
}

- (void)MLS_addScrollView {
    MLSPageScrollView *scrollView = [[MLSPageScrollView alloc] init];
    scrollView.scrollsToTop = NO;
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = self.bounces;
    scrollView.scrollEnabled = self.scrollEnable;
    scrollView.directionalLockEnabled = YES;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    if (!self.navigationController) return;
    for (UIGestureRecognizer *gestureRecognizer in scrollView.gestureRecognizers) {
        [gestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
}

- (void)MLS_addMenuView {
    
    CGFloat menuY = _viewY;
    if (self.showOnNavigationBar && self.navigationController.navigationBar) {
        CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat menuHeight = self.menuHeight > navHeight ? navHeight : self.menuHeight;
        menuY = (navHeight - menuHeight) / 2;
    }
    
    CGRect frame = CGRectMake(_viewX, menuY, _viewWidth, self.menuHeight);
    _menuViewFrame = frame;
    MLSMenuView *menuView = [[MLSMenuView alloc] initWithFrame:frame];
	menuView.backgroundColor = self.menuBGColor;
    menuView.progressBgColor = self.progressBgColor;
    menuView.delegate = self;
    menuView.dataSource = self;
    menuView.style = self.menuViewStyle;
    menuView.layoutMode = self.menuViewLayoutMode;
    menuView.progressHeight = self.progressHeight;
    menuView.contentMargin = self.menuViewContentMargin;
    menuView.progressViewBottomSpace = self.progressViewBottomSpace;
    menuView.progressWidths = self.progressViewWidths;
    menuView.progressViewIsNaughty = self.progressViewIsNaughty;
    menuView.progressViewCornerRadius = self.progressViewCornerRadius;
    menuView.qmui_borderPosition = QMUIViewBorderPositionBottom;
    menuView.qmui_borderColor = self.menuBottomLineColor;
    menuView.qmui_borderWidth = self.menuBottomLineWidth;
    menuView.separateColor = self.menuSeparateColor;
    menuView.separateInset = self.menuSeparateInset;
    menuView.separateWidth = self.menuSeparateWidth;
    menuView.separateHeight = self.menuSeparateHeight;
    if (self.titleFontName) {
        menuView.fontName = self.titleFontName;
    }
    if (self.progressColor) {
        menuView.lineColor = self.progressColor;
    }
    if (self.showOnNavigationBar && self.navigationController.navigationBar) {
        self.navigationItem.titleView = menuView;
    } else {
        [self.view addSubview:menuView];
    }
    self.menuView = menuView;
}

- (void)MLS_layoutChildViewControllers {
    int currentPage = 0;
    if (self.direction == MLSPageControllerScrollDirectionHorizontal) {
        currentPage = (int)(self.scrollView.contentOffset.x / _contentViewFrame.size.width);
    } else if (self.direction == MLSPageControllerScrollDirectionVertical) {
        currentPage = (int)(self.scrollView.contentOffset.y / _contentViewFrame.size.height);
    }
    int length = (int)self.preloadPolicy;
    int left = currentPage - length - 1;
    int right = currentPage + length + 1;
    for (int i = 0; i < self.childControllersCount; i++) {
        UIViewController *vc = [self.displayVC objectForKey:@(i)];
        CGRect frame = [self.childViewFrames[i] CGRectValue];
        if (!vc) {
            if ([self MLS_isInScreen:frame]) {
                [self MLS_initializedControllerWithIndexIfNeeded:i callWillEnter:YES];
            }
        } else if (i <= left || i >= right) {
            if (![self MLS_isInScreen:frame]) {
                [self MLS_removeViewController:vc atIndex:i];
            }
        }
    }
}

// 创建或从缓存中获取控制器并添加到视图上
- (void)MLS_initializedControllerWithIndexIfNeeded:(NSInteger)index callWillEnter:(BOOL)callWillEnter {
    // 先从 cache 中取
    UIViewController *vc = [self.memCache objectForKey:@(index)];
    if (vc) {
        // cache 中存在，添加到 scrollView 上，并放入display
        [self MLS_addCachedViewController:vc atIndex:index callWillEnter:callWillEnter];
    } else {
        // cache 中也不存在，创建并添加到display
        [self MLS_addViewControllerAtIndex:(int)index callWillEnter:callWillEnter];
    }
    [self MLS_postAddToSuperViewNotificationWithIndex:(int)index];
}

- (void)MLS_addCachedViewController:(UIViewController *)viewController atIndex:(NSInteger)index callWillEnter:(BOOL)callWillEnter{
    [self addChildViewController:viewController];
    viewController.view.frame = [self.childViewFrames[index] CGRectValue];
    [viewController didMoveToParentViewController:self];
    [self.scrollView addSubview:viewController.view];
    if (callWillEnter) {
        [self willEnterController:viewController atIndex:index];
    }
    [self.displayVC setObject:viewController forKey:@(index)];
}

// 创建并添加子控制器
- (void)MLS_addViewControllerAtIndex:(int)index callWillEnter:(BOOL)callWillEnter{
    _initializedIndex = index;
    UIViewController *viewController = [self initializeViewControllerAtIndex:index];
    if (self.values.count == self.childControllersCount && self.keys.count == self.childControllersCount) {
        [viewController setValue:self.values[index] forKey:self.keys[index]];
    }
    [self addChildViewController:viewController];
    CGRect frame = self.childViewFrames.count ? [self.childViewFrames[index] CGRectValue] : self.view.frame;
    viewController.view.frame = frame;
    [viewController didMoveToParentViewController:self];
    [self.scrollView addSubview:viewController.view];
    if (callWillEnter) {
        [self willEnterController:viewController atIndex:index];
    }
    [self.displayVC setObject:viewController forKey:@(index)];
    
    [self MLS_backToPositionIfNeeded:viewController atIndex:index];
}

// 移除控制器，且从display中移除
- (void)MLS_removeViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    [self MLS_rememberPositionIfNeeded:viewController atIndex:index];
    [viewController.view removeFromSuperview];
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    [self.displayVC removeObjectForKey:@(index)];
    
    // 放入缓存
    if (self.cachePolicy == MLSPageControllerCachePolicyDisabled) {
        return;
    }
    
    if (![self.memCache objectForKey:@(index)]) {
        [self willCachedController:viewController atIndex:index];
        [self.memCache setObject:viewController forKey:@(index)];
    }
}

- (void)MLS_backToPositionIfNeeded:(UIViewController *)controller atIndex:(NSInteger)index {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if (!self.rememberLocation) return;
#pragma clang diagnostic pop
    if ([self.memCache objectForKey:@(index)]) return;
    UIScrollView *scrollView = [self MLS_isKindOfScrollViewController:controller];
    if (scrollView) {
        NSValue *pointValue = self.posRecords[@(index)];
        if (pointValue) {
            CGPoint pos = [pointValue CGPointValue];
            [scrollView setContentOffset:pos];
        }
    }
}

- (void)MLS_rememberPositionIfNeeded:(UIViewController *)controller atIndex:(NSInteger)index {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    if (!self.rememberLocation) return;
#pragma clang diagnostic pop
    UIScrollView *scrollView = [self MLS_isKindOfScrollViewController:controller];
    if (scrollView) {
        CGPoint pos = scrollView.contentOffset;
        self.posRecords[@(index)] = [NSValue valueWithCGPoint:pos];
    }
}

- (UIScrollView *)MLS_isKindOfScrollViewController:(UIViewController *)controller {
    UIScrollView *scrollView = nil;
    if ([controller.view isKindOfClass:[UIScrollView class]]) {
        // Controller的view是scrollView的子类(UITableViewController/UIViewController替换view为scrollView)
        scrollView = (UIScrollView *)controller.view;
    } else if (controller.view.subviews.count >= 1) {
        // Controller的view的subViews[0]存在且是scrollView的子类，并且frame等与view得frame(UICollectionViewController/UIViewController添加UIScrollView)
        UIView *view = controller.view.subviews[0];
        if ([view isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)view;
        }
    }
    return scrollView;
}

- (BOOL)MLS_isInScreen:(CGRect)frame {
    if (self.direction == MLSPageControllerScrollDirectionHorizontal) {
        
        CGFloat x = frame.origin.x;
        CGFloat screenWidth = self.scrollView.frame.size.width;
        
        CGFloat contentOffsetX = self.scrollView.contentOffset.x;
        if (CGRectGetMaxX(frame) > contentOffsetX && x - contentOffsetX < screenWidth) {
            return YES;
        } else {
            return NO;
        }
    } else if (self.direction == MLSPageControllerScrollDirectionVertical) {
        CGFloat x = frame.origin.y;
        CGFloat screenHeight = self.scrollView.frame.size.height;
        
        CGFloat contentOffsetY = self.scrollView.contentOffset.y;
        if (CGRectGetMaxY(frame) > contentOffsetY && x - contentOffsetY < screenHeight) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

- (void)MLS_resetMenuView {
    if (!self.menuView) {
        [self MLS_addMenuView];
    } else {
        [self.menuView reload];
        if (self.menuView.userInteractionEnabled == NO) {
            self.menuView.userInteractionEnabled = YES;
        }
        if (self.selectIndex != 0) {
            [self.menuView selectItemAtIndex:self.selectIndex];
        }
        [self.view bringSubviewToFront:self.menuView];
    }
}

- (void)MLS_growCachePolicyAfterMemoryWarning {
    self.cachePolicy = MLSPageControllerCachePolicyBalanced;
    [self performSelector:@selector(MLS_growCachePolicyToHigh) withObject:nil afterDelay:2.0 inModes:@[NSRunLoopCommonModes]];
}

- (void)MLS_growCachePolicyToHigh {
    self.cachePolicy = MLSPageControllerCachePolicyHigh;
}

- (UIView *)MLS_bottomView {
    return self.tabBarController.tabBar ? self.tabBarController.tabBar : self.navigationController.toolbar;
}

#pragma mark - Adjust Frame
- (void)MLS_adjustScrollViewFrame {
    // While rotate at last page, set scroll frame will call `-scrollViewDidScroll:` delegate
    // It's not my expectation, so I use `_shouldNotScroll` to lock it.
    // Wait for a better solution.
    _shouldNotScroll = YES;
    if (self.direction == MLSPageControllerScrollDirectionHorizontal) {
        CGFloat oldContentOffsetX = self.scrollView.contentOffset.x;
        CGFloat contentWidth = self.scrollView.contentSize.width;
        self.scrollView.frame = _contentViewFrame;
        self.scrollView.contentSize = CGSizeMake(self.childControllersCount * _contentViewFrame.size.width, _contentViewFrame.size.height);
        CGFloat xContentOffset = contentWidth == 0 ? self.selectIndex * _contentViewFrame.size.width : oldContentOffsetX / contentWidth * self.childControllersCount * _contentViewFrame.size.width;
        [self.scrollView setContentOffset:CGPointMake(xContentOffset, 0)];
    } else if (self.direction == MLSPageControllerScrollDirectionVertical) {
        CGFloat oldContentOffsetY = self.scrollView.contentOffset.y;
        CGFloat contentHeight = self.scrollView.contentSize.height;
        self.scrollView.frame = _contentViewFrame;
        self.scrollView.contentSize = CGSizeMake(_contentViewFrame.size.width, self.childControllersCount * _contentViewFrame.size.height);
        CGFloat yContentOffset = contentHeight == 0 ? self.selectIndex * _contentViewFrame.size.height : oldContentOffsetY / contentHeight * self.childControllersCount * _contentViewFrame.size.height;
        [self.scrollView setContentOffset:CGPointMake(0, yContentOffset)];
    }
    _shouldNotScroll = NO;
}

- (void)MLS_adjustDisplayingViewControllersFrame {
    [self.displayVC enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIViewController * _Nonnull vc, BOOL * _Nonnull stop) {
        NSInteger index = key.integerValue;
        CGRect frame = [self.childViewFrames[index] CGRectValue];
        vc.view.frame = frame;
    }];
}

- (void)MLS_adjustMenuViewFrame {
    if (self.showMenuView)
    {
        self.menuView.hidden = NO;
        // 根据是否在导航栏上展示调整frame
        CGFloat menuHeight = self.menuHeight;
        __block CGFloat menuX = _viewX;
        __block CGFloat menuY = _viewY;
        __block CGFloat rightWidth = 0;
        if (self.showOnNavigationBar && self.navigationController.navigationBar) {
            [self.navigationController.navigationBar.subviews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
                if (![obj isKindOfClass:[MLSMenuView class]] && obj.alpha != 0 && obj.hidden == NO) {
                    CGFloat maxX = CGRectGetMaxX(obj.frame);
                    if (maxX < self->_viewWidth / 2) {
                        CGFloat leftWidth = maxX;
                        menuX = menuX > leftWidth ? menuX : leftWidth;
                    }
                    CGFloat minX = CGRectGetMinX(obj.frame);
                    if (minX > self->_viewWidth / 2) {
                        CGFloat width = (self->_viewWidth - minX);
                        rightWidth = rightWidth > width ? rightWidth : width;
                    }
                }
            }];
            CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
            menuHeight = self.menuHeight > navHeight ? navHeight : self.menuHeight;
            menuY = (navHeight - menuHeight) / 2;
        }
        
        CGFloat menuWidth = _viewWidth - menuX - rightWidth;
        CGFloat oriWidth = self.menuView.frame.size.width;
        self.menuView.frame = _menuViewFrame;
        [self.menuView resetFrames];
        if (oriWidth != menuWidth) {
            [self.menuView refreshContenOffset];
        }
    }
    else
    {
        self.menuView.hidden = YES;
        self.menuView.frame = CGRectMake(_menuViewFrame.origin.x, _menuViewFrame.origin.y, _menuViewFrame.size.width, 0);
    }
    
}

- (CGFloat)MLS_calculateItemWithAtIndex:(NSInteger)index {
    NSString *title = [self titleAtIndex:index];
    UIFont *titleFont = self.titleFontName ? [UIFont fontWithName:self.titleFontName size:self.titleSizeSelected] : [UIFont systemFontOfSize:self.titleSizeSelected];
    NSDictionary *attrs = @{NSFontAttributeName: titleFont};
    CGFloat itemWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attrs context:nil].size.width;
    if (self.menuViewStyle == MLSMenuViewStyleFlood || self.menuViewStyle == MLSMenuViewStyleFloodHollow) {
        itemWidth += 2 * self.progressViewCornerRadius;
    }
    return ceil(itemWidth);
}

- (void)MLS_delaySelectIndexIfNeeded {
    if (_markedSelectIndex != kMLSUndefinedIndex) {
        self.selectIndex = (int)_markedSelectIndex;
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (!self.childControllersCount) return;
    [self MLS_calculateSize];
    [self MLS_addScrollView];
    [self MLS_addViewControllerAtIndex:self.selectIndex callWillEnter:YES];
    self.currentViewController = self.displayVC[@(self.selectIndex)];
    [self MLS_addMenuView];
    [self didEnterController:self.currentViewController atIndex:self.selectIndex];
}



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!self.childControllersCount) return;
    
    CGFloat oldSuperviewHeight = _superviewHeight;
    _superviewHeight = self.view.frame.size.height;
    BOOL oldTabBarIsHidden = _isTabBarHidden;
    _isTabBarHidden = [self MLS_bottomView].hidden;
    
    BOOL shouldNotLayout = (_hasInited && _superviewHeight == oldSuperviewHeight && _isTabBarHidden == oldTabBarIsHidden);
    if (shouldNotLayout) return;
    [self forceLayoutSubviews];
    _hasInited = YES;
    [self.view layoutIfNeeded];
    [self MLS_delaySelectIndexIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.childControllersCount) return;
    
    [self MLS_postFullyDisplayedNotificationWithCurrentIndex:self.selectIndex];
    [self didEnterController:self.currentViewController atIndex:self.selectIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.memoryWarningCount++;
    self.cachePolicy = MLSPageControllerCachePolicyLowMemory;
    // 取消正在增长的 cache 操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(MLS_growCachePolicyAfterMemoryWarning) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(MLS_growCachePolicyToHigh) object:nil];
    
    [self.memCache removeAllObjects];
    [self.posRecords removeAllObjects];
    self.posRecords = nil;
    
    // 如果收到内存警告次数小于 3，一段时间后切换到模式 Balanced
    if (self.memoryWarningCount < 3) {
        [self performSelector:@selector(MLS_growCachePolicyAfterMemoryWarning) withObject:nil afterDelay:3.0 inModes:@[NSRunLoopCommonModes]];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:MLSPageScrollView.class]) return;
    
    if (_shouldNotScroll || !_hasInited) return;
    
    [self MLS_layoutChildViewControllers];
    if (_startDragging) {
        CGFloat rate = 0.0;
        if (self.direction == MLSPageControllerScrollDirectionHorizontal) {
            CGFloat contentOffsetX = scrollView.contentOffset.x;
            if (contentOffsetX < 0) {
                contentOffsetX = 0;
            }
            if (contentOffsetX > scrollView.contentSize.width - _contentViewFrame.size.width) {
                contentOffsetX = scrollView.contentSize.width - _contentViewFrame.size.width;
            }
            rate = contentOffsetX / _contentViewFrame.size.width;
            [self.menuView slideMenuAtProgress:rate];
            // Fix scrollView.contentOffset.y -> (-20) unexpectedly.
            if (scrollView.contentOffset.y == 0) return;
            CGPoint contentOffset = scrollView.contentOffset;
            contentOffset.y = 0.0;
            scrollView.contentOffset = contentOffset;
            
        } else if (self.direction == MLSPageControllerScrollDirectionVertical) {
            CGFloat contentOffsetY = scrollView.contentOffset.y;
            if (contentOffsetY < 0) {
                contentOffsetY = 0;
            }
            if (contentOffsetY > scrollView.contentSize.height - _contentViewFrame.size.height) {
                contentOffsetY = scrollView.contentSize.height - _contentViewFrame.size.height;
            }
            rate = contentOffsetY / _contentViewFrame.size.height;
            [self.menuView slideMenuAtProgress:rate];
            // Fix scrollView.contentOffset.y -> (-20) unexpectedly.
            if (scrollView.contentOffset.y == 0) return;
            CGPoint contentOffset = scrollView.contentOffset;
            contentOffset.x = 0.0;
            scrollView.contentOffset = contentOffset;
        }
    }
    
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:MLSPageScrollView.class]) return;
    CGPoint movePoint = [scrollView.panGestureRecognizer translationInView:scrollView];
    int index = 0;
    if (self.direction == MLSPageControllerScrollDirectionHorizontal) {
        index = movePoint.x < 0 ? _selectIndex + 1 : _selectIndex - 1;
    } else if (self.direction == MLSPageControllerScrollDirectionVertical) {
        index = movePoint.y < 0 ? _selectIndex + 1 : _selectIndex - 1;
    }
    index = (int)MIN(MAX(0, index), self.childControllersCount-1);
    if (index == self.selectIndex) {
        return;
    }
    NSDictionary *info = [self infoWithIndex:index];
    if ([self.displayVC objectForKey:@(index)] == nil) {
        [self MLS_initializedControllerWithIndexIfNeeded:index callWillEnter:NO];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageController:shouldEnterViewController:withInfo:)]) {
        if (![self.delegate pageController:self shouldEnterViewController:self.displayVC[@(index)] withInfo:info]) {
            CGPoint contentOffset = scrollView.contentOffset;
            scrollView.panGestureRecognizer.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                scrollView.panGestureRecognizer.enabled = YES;
                [scrollView setContentOffset:contentOffset];
            });
            return;
        }
    }
    
    [self MLS_layoutChildViewControllers];
    [self willEnterController:self.displayVC[@(index)] atIndex:index];
    
    _startDragging = YES;
    self.menuView.userInteractionEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:MLSPageScrollView.class]) return;
    
    self.menuView.userInteractionEnabled = YES;
    if (self.direction == MLSPageControllerScrollDirectionHorizontal) {
        _selectIndex = (int)(scrollView.contentOffset.x / _contentViewFrame.size.width);
    } else if (self.direction == MLSPageControllerScrollDirectionVertical) {
        _selectIndex = (int)(scrollView.contentOffset.y / _contentViewFrame.size.height);
    }
    self.currentViewController = self.displayVC[@(self.selectIndex)];
    self.callDidEnter = NO;
    [self didEnterController:self.currentViewController atIndex:self.selectIndex];
    [self.menuView deselectedItemsIfNeeded];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (![scrollView isKindOfClass:MLSPageScrollView.class]) return;
    
    self.currentViewController = self.displayVC[@(self.selectIndex)];
    self.callDidEnter = NO;
    [self didEnterController:self.currentViewController atIndex:self.selectIndex];
    [self.menuView deselectedItemsIfNeeded];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (![scrollView isKindOfClass:MLSPageScrollView.class]) return;
    
    if (!decelerate) {
        self.menuView.userInteractionEnabled = YES;
        CGFloat rate = _targetX / _contentViewFrame.size.width;
        [self.menuView slideMenuAtProgress:rate];
        [self.menuView deselectedItemsIfNeeded];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (![scrollView isKindOfClass:MLSPageScrollView.class]) return;
    
    _targetX = targetContentOffset->x;
}

#pragma mark - MLSMenuView Delegate
- (void)menuView:(MLSMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
    if (!_hasInited) return;
    _selectIndex = (int)index;
    _startDragging = NO;
    self.callDidEnter = NO;
    [self willEnterController:self.displayVC[@(self.selectIndex)] atIndex:index];
    
    if (self.direction == MLSPageControllerScrollDirectionHorizontal) {
        CGPoint targetP = CGPointMake(_contentViewFrame.size.width * index, 0);
        [self.scrollView setContentOffset:targetP animated:self.pageAnimatable];
    } else if (self.direction == MLSPageControllerScrollDirectionVertical) {
        CGPoint targetP = CGPointMake(0, _contentViewFrame.size.height * index);
        [self.scrollView setContentOffset:targetP animated:self.pageAnimatable];
    }
    
    if (self.pageAnimatable) return;
    // 由于不触发 -scrollViewDidScroll: 手动处理控制器
    UIViewController *currentViewController = self.displayVC[@(currentIndex)];
    if (currentViewController) {
        [self MLS_removeViewController:currentViewController atIndex:currentIndex];
    }
    [self MLS_layoutChildViewControllers];
    self.currentViewController = self.displayVC[@(self.selectIndex)];
    
    [self didEnterController:self.currentViewController atIndex:index];
}

- (CGFloat)menuView:(MLSMenuView *)menu widthForItemAtIndex:(NSInteger)index {
    if (self.automaticallyCalculatesItemWidths) {
        return [self MLS_calculateItemWithAtIndex:index];
    }
    
    if (self.itemsWidths.count == self.childControllersCount) {
        return [self.itemsWidths[index] floatValue];
    }
    return self.menuItemWidth;
}

- (CGFloat)menuView:(MLSMenuView *)menu itemMarginAtIndex:(NSInteger)index {
    if (self.itemsMargins.count == self.childControllersCount + 1) {
        return [self.itemsMargins[index] floatValue];
    }
    return self.itemMargin;
}

- (CGFloat)menuView:(MLSMenuView *)menu titleSizeForState:(MLSMenuItemState)state atIndex:(NSInteger)index {
    switch (state) {
        case MLSMenuItemStateSelected: {
            return self.titleSizeSelected;
            break;
        }
        case MLSMenuItemStateNormal: {
            return self.titleSizeNormal;
            break;
        }
    }
}

- (UIColor *)menuView:(MLSMenuView *)menu titleColorForState:(MLSMenuItemState)state atIndex:(NSInteger)index {
    switch (state) {
        case MLSMenuItemStateSelected: {
            return self.titleColorSelected;
            break;
        }
        case MLSMenuItemStateNormal: {
            return self.titleColorNormal;
            break;
        }
    }
}

#pragma mark - MLSMenuViewDataSource
- (NSInteger)numbersOfTitlesInMenuView:(MLSMenuView *)menu {
    return self.childControllersCount;
}

- (NSString *)menuView:(MLSMenuView *)menu titleAtIndex:(NSInteger)index {
    return [self titleAtIndex:index];
}


//// Status Bar
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.currentViewController.preferredStatusBarStyle;
}

- (nullable UIViewController *)childViewControllerForStatusBarStyle {
    return self.currentViewController;
}
- (nullable UIViewController *)childViewControllerForStatusBarHidden {
    return self.currentViewController;
}
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return self.currentViewController.preferredStatusBarUpdateAnimation;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.currentViewController.supportedInterfaceOrientations;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.currentViewController.preferredInterfaceOrientationForPresentation;
}
- (BOOL)shouldAutorotate {
    return self.currentViewController.shouldAutorotate;
}
- (BOOL)prefersStatusBarHidden {
    return self.currentViewController.prefersStatusBarHidden;
}

@end
// @{@"title": title ?: @"", @"index": @(index)};
@implementation NSDictionary (MLSPageController)
- (NSUInteger)infoIndexValue {
    id value = [self valueForKey:@"index"];
    if (!value || ![value isKindOfClass:[NSNumber class]]) {
        return 0;
    }
    return [value unsignedIntegerValue];
    
}
- (NSString *)infoTitleValue {
    id value = [self valueForKey:@"title"];
    if (![value isKindOfClass:[NSString class]]) {
        return nil;
    }
    return (NSString *)value;
}
@end
