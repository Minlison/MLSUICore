//
//  MLSImagePickerViewController.m
//  MinLison
//
//  Created by MinLison on 2017/11/6.
//  Copyright © 2017年 minlison. All rights reserved.
//

// 500px
#define k500pxConsumerKey               @"9sUVdra51AYawcQwQjFaQA7ueUqpaXLEZQJT7Pzy"
#define k500pxConsumerSecret            @"CmmZmHfSu1xi9BfVq4cS5RcAAhnR9UylGzPJQjqc"

// Flickr
#define kFlickrConsumerKey              @"8c96746e0818c4ceb119c13c1eb1b05e"
#define kFlickrConsumerSecret           @"f35bf89a60e411a5"

// Instagram
#define kInstagramConsumerKey           @"16759bba4b7e4831b80bf3412e7dcb16"
#define kInstagramConsumerSecret        @"701c5a99144a401c8285b0c9df999509"

// Google Images
#define kGoogleImagesConsumerKey        @"AIzaSyBiRs6vQmTVseUnMqUtJwpaJX-m5o9Djr0"
#define kGoogleImagesSearchEngineID     @"018335320449571565407:tg2a0fkobws"        //cx

// Bing Images
#define kBingImagesAccountKey           @"9V3Rg6PgTrQno6t7pKpT9dLppEaVwVyucUwmHXZXlUo" //5000 request per month (free account)

// Giphy
#define kGiphyConsumerKey               @"dc6zaTOxFJmzC"
#import <UIKit/UIKit.h>
#import "MLSImagePickerViewController.h"
#import "DZNPhotoPickerController.h"
#import "UIImagePickerController+Edit.h"
#import "UIImagePickerController+Block.h"
#import "MLSSingleImagePickerPreviewViewController.h"
//#import "MLSUICore.h"
#import "MLSConfigurationDefine.h"
#import <QMUIKit/QMUIKit.h>
#import "MLSFontUtils.h"
#if __has_include("UINavigationController+FDFullscreenPopGesture.h")
#import "UINavigationController+FDFullscreenPopGesture.h"
#elif __has_include("<FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>")
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#endif
#import "QMUIAlertController+MLSUICore.h"

@interface MLSImagePickerViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,QMUIAlbumViewControllerDelegate,QMUIImagePickerViewControllerDelegate,MLSSingleImagePickerPreviewViewControllerDelegate>
@property(nonatomic, copy) MLSImagePickerSuccessBlock successBlock;
@property(nonatomic, copy) MLSImagePickerFailedBlock failedBlock;
@property(nonatomic, strong) NSDictionary *photoPayload;
@property(nonatomic, copy) NSString *rootImgPath;
@property(nonatomic, strong) UIImage *editImage;
@property(nonatomic, weak) UIViewController *parentVC;
@property(nonatomic, assign) MLSImagePickerType type;
@end

@implementation MLSImagePickerViewController
+ (void)initialize
{
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerService500px
                                      consumerKey:k500pxConsumerKey
                                   consumerSecret:k500pxConsumerSecret];
    
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceFlickr
                                      consumerKey:kFlickrConsumerKey
                                   consumerSecret:kFlickrConsumerSecret];
    
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceInstagram
                                      consumerKey:kInstagramConsumerKey
                                   consumerSecret:kInstagramConsumerSecret];
    
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceGoogleImages
                                      consumerKey:kGoogleImagesConsumerKey
                                   consumerSecret:kGoogleImagesSearchEngineID];
    
    //Bing does not require a secret. Rather just an "Account Key"
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceBingImages
                                      consumerKey:kBingImagesAccountKey
                                   consumerSecret:nil];
    
    [DZNPhotoPickerController registerFreeService:DZNPhotoPickerControllerServiceGiphy
                                      consumerKey:kGiphyConsumerKey
                                   consumerSecret:nil];
}

+ (void)show:(MLSImagePickerType)type inController:(nullable UIViewController *)vc editImage:(nullable UIImage *)editImage success:(MLSImagePickerSuccessBlock)success failed:(MLSImagePickerFailedBlock)failed
{
    UIViewController *showVC = vc;
    if (showVC == nil)
    {
        showVC = __CURRENT_WINDOW__.rootViewController;
    }
    MLSImagePickerViewController *imagePicker = [[MLSImagePickerViewController alloc] init];
    [imagePicker show:type inController:showVC editImage:editImage success:success failed:failed];
}
- (void)show:(MLSImagePickerType)type inController:(nullable UIViewController *)vc editImage:(nullable UIImage *)editImage success:(MLSImagePickerSuccessBlock)success failed:(MLSImagePickerFailedBlock)failed
{
    [self willMoveToParentViewController:vc];
    [vc addChildViewController:self];
    [self didMoveToParentViewController:vc];
    self.type = type;
    self.parentVC = vc;
    self.successBlock = success;
    self.failedBlock = failed;
    [self authorizationPresentAlbumViewController];
}
- (void)authorizationPresentAlbumViewController {
    __weak __typeof(self)weakSelf = self;
    if ([QMUIAssetsManager authorizationStatus] == QMUIAssetAuthorizationStatusNotDetermined) {
        [QMUIAssetsManager requestAuthorization:^(QMUIAssetAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakSelf)strongSelf = weakSelf;
                [strongSelf presentAlbumViewController];
            });
        }];
    }
    else
    {
        [self presentAlbumViewController];
    }
}
- (void)presentAlbumViewController
{
    if (!self.parentVC)
    {
        return;
    }
    self.editImage ? [self editShowImage] : [self importImage];
}

- (void)importImage
{
    [self showImportActionSheet];
}

- (void)editShowImage
{
    [self showEditActionSheet];
}


#pragma mark - ViewController methods

- (void)showImportActionSheet
{
    QMUIAlertController *alert = [QMUIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(QMUIAlertControllerStyleActionSheet)];
    alert.maskColor = [UIColor colorWithWhite:0 alpha:0.7];
    alert.sheetButtonAttributes = @{
                                    NSFontAttributeName : MLSSystem16Font,
                                    NSForegroundColorAttributeName : UIColorHex(0x0178FF),
                                    };
    alert.sheetCancelButtonAttributes = @{
                                          NSFontAttributeName : MLSBoldSystem16Font,
                                          NSForegroundColorAttributeName : UIColorHex(0x0178FF),
                                          };
    typedef void (^AlertActionBlock)(void);
    
    AlertActionBlock alertActionBlock;
    if (self.type & MLSImagePickerTypeTakePhoto)
    {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
        {
            QMUIAlertAction *action = [QMUIAlertAction actionWithTitle:@"拍照" style:(QMUIAlertActionStyleDefault) handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
                [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
                
            }];
            [alert addAction:action];
            alertActionBlock = ^{
                [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            };
        }
    }
    if (self.type & MLSImagePickerTypeChoseImage)
    {
        QMUIAlertAction *action = [QMUIAlertAction actionWithTitle:@"从手机相册选择" style:(QMUIAlertActionStyleDefault) handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//                                            [self presentQMAlbumViewController];
            
        }];
        [alert addAction:action];
        alertActionBlock = ^{
            [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        };
    }
    if (self.type & MLSImagePickerTypeSearchImage)
    {
        QMUIAlertAction *action = [QMUIAlertAction actionWithTitle:@"搜索照片" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            [self presentPhotoSearch];
        }];
        [alert addAction:action];
        alertActionBlock = ^{
            [self presentPhotoSearch];
        };
    }
    
    if ( alert.actions.count > 1 )
    {
        [alert addAction:[QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:NULL]];
        [alert showWithAnimated:YES];
    }
    else
    {
        alertActionBlock();
    }
}

- (void)showEditActionSheet
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"编辑照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self presentPhotoEditor];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"删除照片" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self resetContent];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)presentPhotoSearch
{
    DZNPhotoPickerController *picker = [[DZNPhotoPickerController alloc] init];
    picker.supportedServices =  DZNPhotoPickerControllerService500px | DZNPhotoPickerControllerServiceFlickr | DZNPhotoPickerControllerServiceGiphy;
    picker.allowsEditing = YES;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeCircular;
    //        picker.initialSearchTerm = @"Chile";
    picker.enablePhotoDownload = YES;
    picker.allowAutoCompletedSearch = YES;
    picker.infiniteScrollingEnabled = YES;
    picker.cropSize = CGSizeMake(160, 160);
    
    picker.title = @"搜索";
    
    [picker setFinalizationBlock:^(DZNPhotoPickerController *picker, NSDictionary *info){
        [self updateImageWithPayload:info];
        [self dismissController:picker];
    }];
    
    [picker setFailureBlock:^(DZNPhotoPickerController *picker, NSError *error){
BeginIgnoreDeprecatedWarning
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"失败"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
EndIgnoreDeprecatedWarning
    }];
    
    [picker setCancellationBlock:^(DZNPhotoPickerController *picker){
        [self dismissController:picker];
    }];
    
    [self presentController:picker];
}

- (void)presentPhotoEditor
{
    UIImage *image = _photoPayload[UIImagePickerControllerOriginalImage];
    if (!image) image = self.editImage;
    
    DZNPhotoEditorViewControllerCropMode cropMode = [_photoPayload[DZNPhotoPickerControllerCropMode] integerValue];
    
    DZNPhotoEditorViewController *editor = [[DZNPhotoEditorViewController alloc] initWithImage:image];
    editor.cropMode = (cropMode != DZNPhotoEditorViewControllerCropModeNone) ? : DZNPhotoEditorViewControllerCropModeSquare;

    MLSBaseNavigationController *controller = [[MLSBaseNavigationController alloc] initWithRootViewController:editor];
    
    [editor setAcceptBlock:^(DZNPhotoEditorViewController *editor, NSDictionary *userInfo){
        [self updateImageWithPayload:userInfo];
        [self dismissController:editor];
    }];
    
    [editor setCancelBlock:^(DZNPhotoEditorViewController *editor){
        [self dismissController:editor];
    }];
    
    [self presentController:controller];
}
- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    __weak __typeof(self)weakSelf = self;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeNone;
    if (self.type & MLSImagePickerTypeMaskCrop) {
        picker.cropMode = DZNPhotoEditorViewControllerCropModeCircular;
    } else if (self.type & MLSImagePickerTypeMaskSquare) {
        picker.cropMode = DZNPhotoEditorViewControllerCropModeSquare;
    }
    picker.navigationBar.tintColor = UIColorBlack;
    picker.navigationBar.shadowImage = [UIImage qmui_imageWithColor:[UIColor colorWithWhite:0 alpha:0.1]];
    picker.cropSize = CGSizeMake(300, 300);
    picker.navigationBar.translucent = NO;
    picker.finalizationBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
        
        // Dismiss when the crop mode was disabled
        if (picker.cropMode == DZNPhotoEditorViewControllerCropModeNone)
        {
            [weakSelf handleImagePicker:picker withMediaInfo:info];
        }
    };
    
    picker.cancellationBlock = ^(UIImagePickerController *picker) {

        [weakSelf dismissController:picker];
    };
    
    [self presentController:picker];
}

static QMUIAlbumContentType const kAlbumContentType = QMUIAlbumContentTypeAll;
- (void)presentQMAlbumViewController
{
    QMUIAlbumViewController *albumViewController = [[QMUIAlbumViewController alloc] init];
    albumViewController.albumViewControllerDelegate = self;
    albumViewController.contentType = kAlbumContentType;
    albumViewController.title = @"照片";
    
    MLSBaseNavigationController *navigationController = [[MLSBaseNavigationController alloc] initWithRootViewController:albumViewController];
    
    // 获取最近发送图片时使用过的相簿，如果有则直接进入该相簿
    QMUIAssetsGroup *assetsGroup = [QMUIImagePickerHelper assetsGroupOfLastPickerAlbumWithUserIdentify:nil];
    if (assetsGroup) {
        QMUIImagePickerViewController *imagePickerViewController = [self imagePickerViewControllerForAlbumViewController:albumViewController];
        
        [imagePickerViewController refreshWithAssetsGroup:assetsGroup];
        imagePickerViewController.title = [assetsGroup name];
        [navigationController pushViewController:imagePickerViewController animated:NO];
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - <QMUIAlbumViewControllerDelegate>

- (QMUIImagePickerViewController *)imagePickerViewControllerForAlbumViewController:(QMUIAlbumViewController *)albumViewController {
    QMUIImagePickerViewController *imagePickerViewController = [[QMUIImagePickerViewController alloc] init];
    imagePickerViewController.imagePickerViewControllerDelegate = self;
    imagePickerViewController.maximumSelectImageCount = 9;
    imagePickerViewController.view.tag = albumViewController.view.tag;
    imagePickerViewController.allowsMultipleSelection = NO;
    imagePickerViewController.minimumImageWidth = 65;
    return imagePickerViewController;
}
#pragma mark - <QMUIImagePickerViewControllerDelegate>
- (QMUIAlbumSortType)albumSortTypeForImagePickerViewController:(QMUIImagePickerViewController *)imagePickerViewController
{
    return QMUIAlbumSortTypeReverse;
}

- (void)imagePickerViewController:(QMUIImagePickerViewController *)imagePickerViewController didFinishPickingImageWithImagesAssetArray:(NSMutableArray<QMUIAsset *> *)imagesAssetArray {
    // 储存最近选择了图片的相册，方便下次直接进入该相册
    [QMUIImagePickerHelper updateLastestAlbumWithAssetsGroup:imagePickerViewController.assetsGroup ablumContentType:kAlbumContentType userIdentify:nil];
    
}

- (QMUIImagePickerPreviewViewController *)imagePickerPreviewViewControllerForImagePickerViewController:(QMUIImagePickerViewController *)imagePickerViewController {
    MLSSingleImagePickerPreviewViewController *imagePickerPreviewViewController = [[MLSSingleImagePickerPreviewViewController alloc] init];
    imagePickerPreviewViewController.delegate = self;
    imagePickerPreviewViewController.assetsGroup = imagePickerViewController.assetsGroup;
    imagePickerPreviewViewController.view.tag = imagePickerViewController.view.tag;
    return imagePickerPreviewViewController;
}

- (void)imagePickerPreviewViewController:(MLSSingleImagePickerPreviewViewController *)imagePickerPreviewViewController didSelectImageWithImagesAsset:(QMUIAsset *)imageAsset
{
    [self callBackWithImage:imageAsset.previewImage];
}


- (void)handleImagePicker:(UIImagePickerController *)picker withMediaInfo:(NSDictionary *)info
{
    [self updateImageWithPayload:info];
    [self dismissController:picker];
}

- (void)updateImageWithPayload:(NSDictionary *)payload
{
    _photoPayload = payload;
    UIImage *image = payload[UIImagePickerControllerEditedImage];
    if (!image) image = payload[UIImagePickerControllerOriginalImage];
    
    self.navigationItem.rightBarButtonItem.enabled = image ? YES : NO;
    
    [self callBackWithImage:image];
}
- (void)callBackWithImage:(UIImage *)image
{
    /// 压缩图片到 512KB 内大小
    NSData *imgData = [self compressImage:image toMaxLength:(1 << 19) maxWidth:__MAIN_SCREEN_WIDTH__];
    if (imgData)
    {
        image = [UIImage imageWithData:imgData];
    }
    if (image)
    {
        NSURL *fileUrl = [self saveImageToLocalPath:image];
        if (self.successBlock)
        {
            self.successBlock(fileUrl, image);
        }
    }
    else
    {
        if (self.failedBlock)
        {
            self.failedBlock([NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"错误"}]);
        }
    }
}
- (NSURL *)saveImageToLocalPath:(UIImage *)image
{
    NSString *localPath = [self.rootImgPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",image.description.qmui_md5]];
    if ([UIImagePNGRepresentation(image) writeToFile:localPath atomically:YES])
    {
        //                [self saveImage:image];
        return [NSURL fileURLWithPath:localPath];
    }
    return nil;
}
- (void)saveImage:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}

- (void)resetContent
{
    _photoPayload = nil;
    if (self.successBlock) {
        self.successBlock(nil, nil);
    }
}

- (void)presentController:(UIViewController *)controller
{
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)dismissController:(UIViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:^{
        [self willMoveToParentViewController:nil];
        [self clearBlock];
        [self removeFromParentViewController];
        [self didMoveToParentViewController:nil];
    }];
}

- (void)clearBlock
{
    self.failedBlock = nil;
    self.successBlock = nil;
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self handleImagePicker:picker withMediaInfo:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self handleImagePicker:picker withMediaInfo:nil];
}


/// MARK: -Lazy
- (NSString *)rootImgPath
{
    if (_rootImgPath == nil) {
        _rootImgPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    }
    return _rootImgPath;
}


- (NSData *)compressImage:(UIImage *)image toMaxLength:(NSInteger)maxLength maxWidth:(NSInteger)maxWidth{
    NSAssert(maxLength > 0, @"图片的大小必须大于 0");
    NSAssert(maxWidth > 0, @"图片的最大边长必须大于 0");
    
    CGSize newSize = [self scaleImage:image withLength:maxWidth];
    UIImage *newImage = [self resizeImage:image withNewSize:newSize];
    
    CGFloat compress = 0.9f;
    NSData *data = UIImageJPEGRepresentation(newImage, compress);
    
    while (data.length > maxLength && compress > 0.01) {
        compress -= 0.02f;
        
        data = UIImageJPEGRepresentation(newImage, compress);
    }
    return data;
}

- (UIImage *)resizeImage:(UIImage *) image withNewSize:(CGSize) newSize{
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (CGSize)scaleImage:(UIImage *) image withLength:(CGFloat) imageLength{
    
    CGFloat newWidth = 0.0f;
    CGFloat newHeight = 0.0f;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    if (width > imageLength || height > imageLength){
        
        if (width > height) {
            
            newWidth = imageLength;
            newHeight = newWidth * height / width;
            
        }else if(height > width){
            
            newHeight = imageLength;
            newWidth = newHeight * width / height;
            
        }else{
            
            newWidth = imageLength;
            newHeight = imageLength;
        }
        
    }else{
        return CGSizeMake(width, height);
    }
    
    return CGSizeMake(newWidth, newHeight);
}
@end
