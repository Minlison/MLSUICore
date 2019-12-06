//
//  MLSSingleImagePickerPreviewViewController.h
//  qmuidemo
//
//  Created by Kayo Lee on 15/5/17.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>
@class MLSSingleImagePickerPreviewViewController;


@protocol MLSSingleImagePickerPreviewViewControllerDelegate <QMUIImagePickerPreviewViewControllerDelegate>

@required
- (void)imagePickerPreviewViewController:(MLSSingleImagePickerPreviewViewController *)imagePickerPreviewViewController didSelectImageWithImagesAsset:(QMUIAsset *)imageAsset;

@end

@interface MLSSingleImagePickerPreviewViewController : QMUIImagePickerPreviewViewController

@property(nonatomic, weak) id<MLSSingleImagePickerPreviewViewControllerDelegate> delegate;
@property(nonatomic, strong) QMUIAssetsGroup *assetsGroup;
@end
