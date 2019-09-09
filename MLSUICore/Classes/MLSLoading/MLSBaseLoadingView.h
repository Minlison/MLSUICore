//
//  MLSBaseLoadingView.h
//  MLSUICore
//
//  Created by minlison on 2018/5/9.
//

#import <UIKit/UIKit.h>
#import "MLSBaseView.h"
#import <QMUIKit/QMUIEmptyView.h>
/// 测评的loading视图
@interface MLSEvaluationLoadingView : MLSBaseView <QMUIEmptyViewLoadingViewProtocol>

@end

@interface MLSNormalLoadingView : MLSBaseView <QMUIEmptyViewLoadingViewProtocol>

@end
