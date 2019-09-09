//
//  MLSTransition.m
//  minlison
//
//  Created by minlison on 2018/4/24.
//  Copyright © 2018年 minlison. All rights reserved.
//

#import "MLSTransition.h"
#import "CEBaseInteractionController.h"
#import "CEReversibleAnimationController.h"
#import "CEVerticalSwipeInteractionController.h"
static NSMutableDictionary *registerControllers;

typedef CEReversibleAnimationController *(^TransitionBlock)(void);
typedef CEBaseInteractionController *(^InteractionBlock)(void);
void(^RegisterTransition)(Class VCClass, TransitionBlock transition, InteractionBlock interaction) = ^(Class VCClass, TransitionBlock transition, InteractionBlock interaction) {
	if (registerControllers == nil)
        {
		registerControllers = [NSMutableDictionary dictionary];
	}
	NSObject *transitioner = transition();
	if (transitioner != nil)
        {
		[registerControllers setObject:transitioner forKey:[NSString stringWithFormat:@"trans_%@",NSStringFromClass(VCClass)]];
		NSObject *inter = interaction();
		if (inter != nil)
                {
			[registerControllers setObject:inter forKey:[NSString stringWithFormat:@"inter_%@",NSStringFromClass([transitioner class])]];
		}
	}
};

@interface MLSTransition()

@end

@implementation MLSTransition
+ (instancetype)shared {
	static MLSTransition *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (registerControllers == nil) {
			registerControllers = [NSMutableDictionary dictionary];
		}
		instance = [[self alloc] init];
	});
	return instance;
}
- (instancetype)init{
	if (self = [super init]) {
		[self registerAllAnimations];
	}
	return  self;
}
- (void)registerAllAnimations {
//        RegisterTransition(class,  ^CEReversibleAnimationController *(){
//                return [MLSNormalAnimationController container];
//        }, ^CEBaseInteractionController *() {
//                return nil; // 会导致内存泄露, 暂时没有解决
//        });
}
- (void)registerTransitionForControllerClass:(Class)classType animationType:(MLSControllerAnimationType)animationType interactionType:(MLSControllerInteractionType)interactionType {
//        RegisterTransition(classType,  ^CEReversibleAnimationController *(){
//                return [self getAnimationFromType:animationType];
//        }, ^CEBaseInteractionController *() {
//                return [self getInteractionFromType:interactionType]; // 手势，会导致内存泄露, 暂时没有解决
//        });
}
- (CEReversibleAnimationController *)getAnimationFromType:(MLSControllerAnimationType)animationType {
        id animationObj = nil;
        switch (animationType)
        {
                case MLSControllerAnimationTypeNone:
                        animationObj = nil;
                        break;
                default:
                        animationObj = nil;
                        break;
        }
        return animationObj;
}
- (CEBaseInteractionController *)getInteractionFromType:(MLSControllerInteractionType)interactionType {
        id interactionObj = nil;
        switch (interactionType)
        {
                case MLSControllerInteractionTypeNone:
                        interactionObj = nil;
                        break;
                default:
                        interactionObj = nil;
                        break;
        }
        return nil;
}
- (void)judegCanRegisterClass:(Class)obj {
        NSString *trans_key = [NSString stringWithFormat:@"trans_%@",NSStringFromClass(obj)];
        id animationObj = [registerControllers objectForKey:trans_key];
        NSString *interaction_key = [NSString stringWithFormat:@"inter_%@",NSStringFromClass(obj)];
        id interactionObj = [registerControllers objectForKey:interaction_key];
        
        if ( (!animationObj || !interactionObj) && [obj conformsToProtocol:@protocol(MLSTransitionProtocol)])
        {
                MLSControllerInteractionType interactionType = MLSControllerInteractionTypeNone;
                MLSControllerAnimationType animationType = MLSControllerAnimationTypeNone;
                Class <MLSTransitionProtocol>transObj = obj;
                
                if ([obj respondsToSelector:@selector(interactionType)])
                {
                        interactionType = [transObj interactionType];
                }
                
                if ([obj respondsToSelector:@selector(transitionAnimationType)])
                {
                        animationType = [transObj transitionAnimationType];
                }
                
                [self registerTransitionForControllerClass:obj animationType:animationType interactionType:interactionType];
        }
}
- (CEBaseInteractionController *)interaction:(Class)obj {
        [self judegCanRegisterClass:obj];
	NSString *key = [NSString stringWithFormat:@"inter_%@",NSStringFromClass(obj)];
	return [registerControllers objectForKey:key];
}
- (CEReversibleAnimationController *)animation:(Class)obj {
        [self judegCanRegisterClass:obj];
	NSString *key = [NSString stringWithFormat:@"trans_%@",NSStringFromClass(obj)];
	return [registerControllers objectForKey:key];
}
/// View Controller
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
	CEReversibleAnimationController *animation = [self animation:[presented class]];
	if ([presented isKindOfClass:[UINavigationController class]])
	{
		animation = [self animation:[[(UINavigationController *)presented topViewController] class]];
	}
	CEBaseInteractionController *interaction = [self interaction:[animation class]];
	
	if (interaction != nil)
	{
		if ([presented isKindOfClass:[UINavigationController class]])
		{
			[interaction wireToViewController:[(UINavigationController *)presented topViewController] forOperation:(CEInteractionOperationDismiss)];
		}
		else {
			[interaction wireToViewController:presented forOperation:(CEInteractionOperationDismiss)];
		}
	}
	
	animation.reverse = NO;
	return animation;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
//        CEReversibleAnimationController *animation = [self animation:[dismissed class]];
//        if ([dismissed isKindOfClass:[UINavigationController class]])
//        {
//                animation = [self animation:[[(UINavigationController *)dismissed topViewController] class]];
//        }
//        animation.reverse = YES;
//        return animation;
        return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
	CEBaseInteractionController *interaction = [self interaction:[animator class]];
	if (interaction.interactionInProgress) {
		return interaction;
	}
	return nil;
}

/// Nav ViewController
- (void)wirePopInteractionControllerTo:(UIViewController *)viewController {
	
	CEReversibleAnimationController *animation = [self animation:[viewController class]];
	CEBaseInteractionController *interaction = [self interaction:[animation class]];
        if (interaction)
        {
                [interaction wireToViewController:viewController forOperation:(CEInteractionOperationPop)];
        }
	
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if (navigationController.childViewControllers.firstObject == viewController)
        {
		return;
	}
	[self wirePopInteractionControllerTo:viewController];
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
				   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
	CEBaseInteractionController *interaction = [self interaction:[animationController class]];
	if (interaction.interactionInProgress) {
		return interaction;
	}
	return nil;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
					    animationControllerForOperation:(UINavigationControllerOperation)operation
							 fromViewController:(UIViewController *)fromVC
							   toViewController:(UIViewController *)toVC {
	CEReversibleAnimationController *animation = nil;
	if (operation == UINavigationControllerOperationPush) {
		animation = [self animation:[toVC class]];
		animation.reverse = NO;
	}
        else if (operation == UINavigationControllerOperationPop)
	{
//                animation = [self animation:[fromVC class]];
//                animation.reverse = YES;
                return nil;
	}
	return animation;
}
@end
