//
//  MLSPageScrollView.m
//  MLSPageController
//
//  Created by lh on 18/5/9.
//  Copyright (c) 2018年 minlison. All rights reserved.
//

#import "MLSPageScrollView.h"

@implementation MLSPageScrollView

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //MARK: UITableViewCell 删除手势
    if ([NSStringFromClass(otherGestureRecognizer.view.class) isEqualToString:@"UITableViewWrapperView"] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}
- (void)setContentOffset:(CGPoint)contentOffset {
    if (self.panGestureRecognizer && (self.panGestureRecognizer.state == UIGestureRecognizerStateCancelled)) {
        return;
    }
    [super setContentOffset:contentOffset];
}

@end
