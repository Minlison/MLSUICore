//
//  MLSUIHelper.h
//  qmuidemo
//
//  Created by ZhoonChen on 15/6/2.
//  Copyright (c) 2015年 MLS Team. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QMUIEmotion;

@interface MLSUIHelper : NSObject

+ (void)forceInterfaceOrientationPortrait;

@end


@interface MLSUIHelper (MLSMoreOperationAppearance)

+ (void)customMoreOperationAppearance;

@end


@interface MLSUIHelper (MLSAlertControllerAppearance)

+ (void)customAlertControllerAppearance;

@end

@interface MLSUIHelper (MLSDialogViewControllerAppearance)

+ (void)customDialogViewControllerAppearance;

@end


@interface MLSUIHelper (QMUIEmotionView)

+ (void)customEmotionViewAppearance;
@end


@interface MLSUIHelper (MLSImagePicker)

+ (void)customImagePickerAppearance;

@end


@interface MLSUIHelper (UITabBarItem)

+ (UITabBarItem *)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage tag:(NSInteger)tag;

@end



@interface MLSUIHelper (Emotion)

+ (NSArray<QMUIEmotion *> *)qmuiEmotions;

/// 用于主题更新后，更新表情 icon 的颜色
+ (void)updateEmotionImages;
@end


@interface MLSUIHelper (SavePhoto)

+ (void)showAlertWhenSavedPhotoFailureByPermissionDenied;

@end


@interface MLSUIHelper (Calculate)

+ (NSString *)humanReadableFileSize:(long long)size;
    
@end


@interface MLSUIHelper (Theme)

+ (UIImage *)navigationBarBackgroundImageWithThemeColor:(UIColor *)color;
@end


@interface NSString (Code)

- (void)enumerateCodeStringUsingBlock:(void (^)(NSString *codeString, NSRange codeRange))block;

@end

