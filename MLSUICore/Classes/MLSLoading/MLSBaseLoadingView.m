//
//  MLSBaseLoadingView.m
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//

#import "MLSBaseLoadingView.h"
#import "MLSConfigurationDefine.h"
@interface MLSEvaluationLoadingView ()
@property (nonatomic, strong) UIImageView *animationView;
@end
@implementation MLSEvaluationLoadingView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.animationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, __MLSWidth(85), __MLSHeight(82))];
    NSMutableArray *animationImages = [NSMutableArray arrayWithCapacity:4];
    for (int i = 1 ; i <= 4; i++) {
        NSString *imgName = [NSString stringWithFormat:@"loading_%02d",i];
        [animationImages addObject:MLSUICoreBuldleImage(imgName)];
    }
    self.animationView.animationImages = animationImages;
    self.animationView.animationDuration = 0.2 * animationImages.count;
    [self addSubview:self.animationView];
}
- (void)startAnimating {
    [self.animationView startAnimating];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.animationView.frame = self.bounds;
}
@end

@interface MLSNormalLoadingView ()
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@end
@implementation MLSNormalLoadingView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backView = [[UIView alloc] init];
    self.backView.layer.cornerRadius = 6;
    self.backView.clipsToBounds = YES;
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    self.activityView.tintColor = [UIColor lightGrayColor];
    [self.backView addSubview:self.activityView];
    [self addSubview:self.backView];
}
- (void)startAnimating {
    [self.activityView startAnimating];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.backView.frame = self.bounds;
    self.activityView.center = CGPointMake(CGRectGetWidth(self.backView.bounds) * 0.5, CGRectGetHeight(self.backView.bounds) * 0.5);
}
@end
