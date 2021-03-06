//
// Copyright 2011-2014 NimbusKit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "NITableViewActions.h"

#import "NICellFactory.h"
#import "NimbusCore.h"
#import "NIActions+Subclassing.h"
#import <objc/runtime.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

@interface NITableViewActions()
@property (nonatomic, strong) NSMutableSet* forwardDelegates;
@end

@implementation NITableViewActions



- (id)initWithTarget:(id)target {
  if ((self = [super initWithTarget:target])) {
    _forwardDelegates = NICreateNonRetainingMutableSet();
    _tableViewCellSelectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}
#pragma mark - 兼容 MLSPlayer 的 Method Hock
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self shouldForwardSelector:@selector(scrollViewDidEndDecelerating:)]) {
        for (id delegate in self.forwardDelegates) {
            if ([delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
                [delegate scrollViewDidEndDecelerating:scrollView];
            }
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self shouldForwardSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        for (id delegate in self.forwardDelegates) {
            if ([delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
                [delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
            }
        }
    }
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([self shouldForwardSelector:@selector(scrollViewDidScrollToTop:)]) {
        for (id delegate in self.forwardDelegates) {
            if ([delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
                [delegate scrollViewDidScrollToTop:scrollView];
            }
        }
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self shouldForwardSelector:@selector(scrollViewWillBeginDragging:)]) {
        for (id delegate in self.forwardDelegates) {
            if ([delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
                [delegate scrollViewWillBeginDragging:scrollView];
            }
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self shouldForwardSelector:@selector(scrollViewDidScroll:)]) {
        for (id delegate in self.forwardDelegates) {
            if ([delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
                [delegate scrollViewDidScroll:scrollView];
            }
        }
    }
}
#pragma mark - Forward Invocations


- (BOOL)shouldForwardSelector:(SEL)selector {
  struct objc_method_description description;
  description = protocol_getMethodDescription(@protocol(NIUITableViewDelegate), selector, NO, YES);
  return (description.name != NULL && description.types != NULL);
}

- (BOOL)respondsToSelector:(SEL)selector {
  if ([super respondsToSelector:selector]) {
    return YES;
    
  } else if ([self shouldForwardSelector:selector]) {
    for (id delegate in self.forwardDelegates) {
      if ([delegate respondsToSelector:selector]) {
        return YES;
      }
    }
  }
  return NO;
}
- (id)forwardingTargetForSelector:(SEL)aSelector
{
        for (id delegate in self.forwardDelegates) {
                if ([delegate respondsToSelector:aSelector]) {
                        return delegate;
                }
        }
        return [super forwardingTargetForSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
  NSMethodSignature *signature = [super methodSignatureForSelector:selector];
  if (signature == nil) {
    for (id delegate in self.forwardDelegates) {
      if ([delegate respondsToSelector:selector]) {
        signature = [delegate methodSignatureForSelector:selector];
      }
    }
  }
  return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  BOOL didForward = NO;
  
  if ([self shouldForwardSelector:invocation.selector]) {
    for (id delegate in self.forwardDelegates) {
      if ([delegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:delegate];
        didForward = YES;
        break;
      }
    }
  }
  
  if (!didForward) {
    [super forwardInvocation:invocation];
  }
}

- (id<NIUITableViewDelegate>)forwardingTo:(id<NIUITableViewDelegate>)forwardDelegate {
  [self.forwardDelegates addObject:forwardDelegate];
  return self;
}

- (void)removeForwarding:(id<NIUITableViewDelegate>)forwardDelegate {
  [self.forwardDelegates removeObject:forwardDelegate];
}

#pragma mark - Object State

- (UITableViewCellAccessoryType)accessoryTypeForObject:(id)object {
  NIObjectActions* action = [self actionForObjectOrClassOfObject:object];
  // Detail disclosure indicator takes precedence over regular disclosure indicator.
  if (nil != action.detailAction || nil != action.detailSelector) {
    return UITableViewCellAccessoryDetailDisclosureButton;

  } else if (nil != action.navigateAction || nil != action.navigateSelector) {
    return  UITableViewCellAccessoryDisclosureIndicator;

  }
  // We must maintain consistency of modifications to the accessoryType within this call due
  // to the fact that cells will be reused.
  return UITableViewCellAccessoryNone;
}

- (UITableViewCellSelectionStyle)selectionStyleForObject:(id)object {
  // If the cell is tappable, reflect that in the selection style.
  NIObjectActions* action = [self actionForObjectOrClassOfObject:object];
  if (action.navigateAction || action.tapAction
      || action.navigateSelector || action.tapSelector) {
    return self.tableViewCellSelectionStyle;

  }
  return UITableViewCellSelectionStyleNone;
}

#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  NIDASSERT([tableView.dataSource conformsToProtocol:@protocol(NIActionsDataSource)]);
  if ([tableView.dataSource conformsToProtocol:@protocol(NIActionsDataSource)]) {
    id object = [(id<NIActionsDataSource>)tableView.dataSource objectAtIndexPath:indexPath];
    if ([self isObjectActionable:object]) {
      cell.accessoryType = [self accessoryTypeForObject:object];
      cell.selectionStyle = [self selectionStyleForObject:object];
    } else {
      cell.accessoryType = UITableViewCellAccessoryNone;
      cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
  }

  // Forward the invocation along.
  for (id<NIUITableViewDelegate> delegate in self.forwardDelegates) {
    if ([delegate respondsToSelector:_cmd]) {
      [delegate tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NIDASSERT([tableView.dataSource conformsToProtocol:@protocol(NIActionsDataSource)]);

  // On iOS 8 and below, UITableViewDelegate is marked "assign". This means that the delegate
  // (i.e. self) is not retained before delegate methods (such as this one) are invoked.
  // Therefore, if any of the actions ends up removing a reference to self, we may become
  // dealloc'd before the end of this method invocation. So we create a strong reference to self
  // to make sure all actions are carried out as expected.
      NITableViewActions *strongSelf = self;

  if ([tableView.dataSource conformsToProtocol:@protocol(NIActionsDataSource)]) {
    id object = [(id<NIActionsDataSource>)tableView.dataSource objectAtIndexPath:indexPath];

    if ([self isObjectActionable:object]) {
      NIObjectActions* action = [self actionForObjectOrClassOfObject:object];

      BOOL shouldDeselect = NO;
      if (action.tapAction) {
        // Tap actions can deselect the row if they return YES.
        shouldDeselect = action.tapAction(object, strongSelf.target, indexPath);
      }
      if (action.tapSelector && [strongSelf.target respondsToSelector:action.tapSelector]) {
        NSMethodSignature *methodSignature = [strongSelf.target methodSignatureForSelector:action.tapSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        invocation.selector = action.tapSelector;
        if (methodSignature.numberOfArguments >= 3) {
          [invocation setArgument:&object atIndex:2];
        }
        if (methodSignature.numberOfArguments >= 4) {
          [invocation setArgument:&indexPath atIndex:3];
        }
        [invocation invokeWithTarget:strongSelf.target];

        NSUInteger length = invocation.methodSignature.methodReturnLength;
        if (length > 0) {
          char *buffer = (void *)malloc(length);
          memset(buffer, 0, sizeof(char) * length);
          [invocation getReturnValue:buffer];
          for (NSUInteger index = 0; index < length; ++index) {
            if (buffer[index]) {
              shouldDeselect = YES;
              break;
            }
          }
          free(buffer);
        }
      }
      if (shouldDeselect) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
      }

      if (action.navigateAction) {
        action.navigateAction(object, strongSelf.target, indexPath);
      }
      if (action.navigateSelector && [strongSelf.target respondsToSelector:action.navigateSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [strongSelf.target performSelector:action.navigateSelector withObject:object withObject:indexPath];
#pragma clang diagnostic pop
      }
    }
  }

  // Forward the invocation along.
  for (id<NIUITableViewDelegate> delegate in strongSelf.forwardDelegates) {
    if ([delegate respondsToSelector:_cmd]) {
      [delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
  }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  NIDASSERT([tableView.dataSource conformsToProtocol:@protocol(NIActionsDataSource)]);
  if ([tableView.dataSource conformsToProtocol:@protocol(NIActionsDataSource)]) {
    id object = [(id<NIActionsDataSource>)tableView.dataSource objectAtIndexPath:indexPath];

    if ([self isObjectActionable:object]) {
      NIObjectActions* action = [self actionForObjectOrClassOfObject:object];

      if (action.detailAction) {
        action.detailAction(object, self.target, indexPath);
      }
      if (action.detailSelector && [self.target respondsToSelector:action.detailSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:action.detailSelector withObject:object withObject:indexPath];
#pragma clang diagnostic pop
      }
    }
  }

  // Forward the invocation along.
  for (id<NIUITableViewDelegate> delegate in self.forwardDelegates) {
    if ([delegate respondsToSelector:_cmd]) {
      [delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
  }
}

@end
