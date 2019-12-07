Pod::Spec.new do |s|
    s.name         = "MLSUICore"
    s.version      = "1.0.2"
    s.summary      = "MLSUICore"
    s.description  = <<-DESC
                        MLSUICore 核心UI组件库
                        DESC
    
    s.homepage     = "https://github.com/Minlison/MLSUICore.git"
    s.license      = "MIT"
    s.author       = { "Minlison" => "yuanhang@minlison.com" }
    s.platform     = :ios, "9.0"
    s.source       = { :git => "https://github.com/Minlison/MLSUICore.git", :tag => "v#{s.version}" }
    s.documentation_url = "https://github.com/Minlison/MLSUICore.git"
    s.requires_arc = true
    s.static_framework = true
#    s.default_subspec = 'Core'
    qmuikit_version = '>= 4.0.0'
    masonry_version = '>= 1.1.0'
    afnetworking_version = '>= 3.2.0'
    sdwebimage_version = '>= 5.0.0'
    dznemptydataset_version = '>= 1.8.1'
    yytext_version = '>= 1.0.7'
    
    s.subspec 'PublicHeader' do |ss|
        ss.source_files     = 'MLSUICore/MLSUICore.h'
        ss.public_header_files = 'MLSUICore/MLSUICore.h'
    end
    
    s.subspec 'Core' do |ss|
        ss.source_files = 'MLSUICore/Classes/Core/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/Core/**/*.h'
        ss.dependency 'QMUIKit/QMUIMainFrame', qmuikit_version
        ss.dependency 'QMUIKit/QMUIComponents/QMUITableViewCell', qmuikit_version
#        ss.dependency 'QMUIKit/QMUIComponents/QMUIScrollAnimator', qmuikit_version
        ss.dependency 'Masonry', masonry_version
        ss.dependency 'MLSUICore/MLSTips'
        ss.dependency 'MLSUICore/MLSUnits'
        ss.dependency 'MLSUICore/MLSProtocols'
        ss.dependency 'MLSUICore/PublicHeader'
        ss.dependency 'MLSUICore/MLSCategories'
        ss.resource_bundles = {
            'MLSUICore' => ['MLSUICore/Resources/img/*.png']
        }
    end
#    s.subspec 'MLSConfig' do |ss|
#        ss.source_files = 'MLSUICore/Classes/MLSConfig/**/*.{h,m}'
#        ss.public_header_files = 'MLSUICore/Classes/MLSConfig/**/*.h'
#        ss.dependency 'MLSUICore/PublicHeader'
#        ss.dependency 'MLSUICore/MLSUnits'
#        ss.dependency 'QMUIKit/QMUIComponents/QMUILabel', qmuikit_version
#        ss.dependency 'QMUIKit/QMUIComponents/QMUIButton', qmuikit_version
#    end
    # 协议
    s.subspec 'MLSProtocols' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSProtocols/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSProtocols/*.h'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    # 一些基本配置
    s.subspec 'MLSUnits' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSUnits/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/Units/**/*.h'
        ss.dependency 'MLSUICore/PublicHeader'
        ss.dependency 'QMUIKit/QMUICore', qmuikit_version
    end
    
    # tip
    s.subspec 'MLSTips' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSTipClass/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/TipClass/**/*.h'
        ss.dependency 'QMUIKit/QMUIComponents/QMUITips', qmuikit_version
        ss.dependency 'MLSUICore/PublicHeader'
        ss.dependency 'Masonry', masonry_version
        ss.dependency 'MLSUICore/MLSUnits'
    end
    
    
    # Animations
    s.subspec 'MLSAnimation' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSAnimation/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSAnimation/**/*.h'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    # ProgressPopUpView
    # 上弹框
    s.subspec 'MLSPopUpView' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSPopUpView/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSPopUpView/**/*.h'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    # Categories
    s.subspec 'MLSCategories' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSCategories/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSCategories/**/*.h'
        ss.dependency 'MLSUICore/PublicHeader'
        ss.dependency 'QMUIKit/QMUICore', qmuikit_version
        ss.dependency 'QMUIKit/QMUIComponents/QMUIButton' , qmuikit_version
        ss.xcconfig = {
            'OTHER_LDFLAGS' => '$(inherited) -ObjC'
        }
    end
    # 底部评论框
    s.subspec 'MLSCommentToolBar' do |ss|
        ss.subspec 'Normal' do |sss|
            sss.source_files = 'MLSUICore/Classes/MLSCommentToolBar/*.{h,m}'
            sss.public_header_files = 'MLSUICore/Classes/MLSCommentToolBar/*.h'
            sss.dependency 'MLSUICore/QMUIKit_MLSCategroies/TextField'
            sss.dependency 'MLSUICore/QMUIKit_MLSCategroies/TextView'
            sss.dependency 'QMUIKit/QMUIComponents/QMUIButton', qmuikit_version
            sss.dependency 'MLSUICore/MLSProtocols'
            sss.dependency 'MLSUICore/MLSUnits'
            sss.dependency 'MLSUICore/PublicHeader'
            sss.dependency 'Masonry', masonry_version
        end
        ss.subspec 'Emotion' do |sss|
            sss.dependency 'MLSUICore/MLSCommentToolBar/Normal'
            sss.dependency 'QMUIKit/QMUIComponents/QMUIEmotionInputManager', qmuikit_version
            sss.dependency 'MLSUICore/PublicHeader'
            sss.xcconfig = {
                'GCC_PREPROCESSOR_DEFINITIONS' => 'MLSCommentToolBarUseEmotion=1'
            }
        end
    end
    
    s.subspec 'QMUIKit_MLSCategroies' do |ss|
        ss.subspec 'Alert' do |sss|
            sss.source_files = 'MLSUICore/Classes/QMUIKit+Categroies/QMUIAlertController+MLSUICore.{h,m}'
            sss.public_header_files = 'MLSUICore/Classes/QMUIKit+Categroies/QMUIAlertController+MLSUICore.h'
            sss.dependency 'QMUIKit/QMUIComponents/QMUIAlertController', qmuikit_version
            sss.dependency 'MLSUICore/PublicHeader'
        end
        ss.subspec 'TextField' do |sss|
            sss.source_files = 'MLSUICore/Classes/QMUIKit+Categroies/QMUITextField+MLSUICore.{h,m}'
            sss.public_header_files = 'MLSUICore/Classes/QMUIKit+Categroies/QMUITextField+MLSUICore.h'
            sss.dependency 'QMUIKit/QMUIComponents/QMUITextField', qmuikit_version
            sss.dependency 'MLSUICore/PublicHeader'
        end
        ss.subspec 'TextView' do |sss|
            sss.source_files = 'MLSUICore/Classes/QMUIKit+Categroies/QMUITextView+MLSUICore.{h,m}'
            sss.public_header_files = 'MLSUICore/Classes/QMUIKit+Categroies/QMUITextView+MLSUICore.h'
            sss.dependency 'QMUIKit/QMUIComponents/QMUITextView', qmuikit_version
            sss.dependency 'MLSUICore/PublicHeader'
        end
    end
    
    # Alert
    s.subspec 'MLSAlert' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSAlert/*.{h,m}'
        ss.dependency 'MLSUICore/QMUIKit_MLSCategroies/Alert'
        ss.dependency 'MLSUICore/MLSUnits'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    # extobjc
    s.subspec 'MLSExtobjc' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSExtobjc/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSExtobjc/*.h'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    # ImagePicker
    s.subspec 'MLSImagePicker' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSImagePicker/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSImagePicker/**/*.h'
        ss.dependency 'MLSUICore/Core'
        ss.dependency 'QMUIKit/QMUIComponents/QMUIImagePickerLibrary', qmuikit_version
        ss.dependency 'SDWebImage', sdwebimage_version
        ss.dependency 'DZNEmptyDataSet', dznemptydataset_version
        ss.dependency 'AFNetworking', afnetworking_version
        ss.dependency 'MLSUICore/QMUIKit_MLSCategroies/Alert'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    # MLSImagePreview
    s.subspec 'MLSImagePreview' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSImagePreview/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSImagePreview/**/*.h'
        ss.dependency 'MLSUICore/Core'
        ss.dependency 'QMUIKit/QMUIComponents/QMUIImagePreviewView', qmuikit_version
        ss.dependency 'QMUIKit/QMUIComponents/QMUILabel', qmuikit_version
        ss.dependency 'QMUIKit/QMUIComponents/QMUIZoomImageView', qmuikit_version
        ss.dependency 'MLSUICore/MLSUnits'
        ss.dependency 'MLSUICore/MLSAlert'
        ss.dependency 'MLSUICore/PublicHeader'
        ss.dependency 'SDWebImage', sdwebimage_version
    end
    s.subspec 'MLSPageController' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSPageController/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSPageController/**/*.h'
        ss.dependency 'MLSUICore/Core'
        ss.dependency 'MLSUICore/MLSUnits'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    s.subspec 'MLSProtocolInterceptor' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSProtocolInterceptor/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSProtocolInterceptor/**/*.h'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    s.subspec 'MLSUISliderController' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSUISliderViewController/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSUISliderViewController/**/*.h'
        ss.dependency 'MLSUICore/Core'
        ss.dependency 'MLSUICore/MLSUnits'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    s.subspec 'MLSSliderController' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSSliderController/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSSliderController/**/*.h'
        ss.dependency 'MLSUICore/Core'
        ss.dependency 'MLSUICore/MLSUnits'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    s.subspec 'MLSLoading' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSLoading/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSLoading/**/*.h'
        ss.dependency 'MLSUICore/Core'
        ss.dependency 'MLSUICore/MLSUnits'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    s.subspec 'MLSRegexKitLite' do |ss|
        ss.requires_arc = false
        ss.source_files = 'MLSUICore/Classes/MLSRegexKitLite/*.{h,m}'
        ss.frameworks = 'CoreFoundation', 'Foundation'
        ss.libraries = 'icucore'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    # MLSMarkLabel
    s.subspec 'MLSMarkLabel' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSMarkLabel/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSMarkLabel/**/*.h'
        ss.dependency 'YYText', yytext_version
        ss.dependency 'MLSUICore/MLSRegexKitLite'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    # MLSNimbus
    s.subspec 'MLSNimbus' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSNimbus/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSNimbus/**/*.h'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    # MLSSegment
    s.subspec 'MLSSegment' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSSegment/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSSegment/**/*.h'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    # MLSPopup
    s.subspec 'MLSPopup' do |ss|
        ss.source_files = 'MLSUICore/Classes/MLSPopup/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/MLSPopup/**/*.h'
        ss.frameworks = 'UIKit', 'Foundation'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    # JXCategoryView
    s.subspec 'JXCategoryView' do |ss|
        ss.source_files = 'MLSUICore/Classes/JXCategoryView/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/JXCategoryView/**/*.h'
        ss.frameworks = 'UIKit', 'Foundation'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    # JXCategoryView
    s.subspec 'JXPagerView' do |ss|
        ss.source_files = 'MLSUICore/Classes/JXPagerView/**/*.{h,m}'
        ss.public_header_files = 'MLSUICore/Classes/JXPagerView/**/*.h'
        ss.frameworks = 'UIKit', 'Foundation'
        ss.dependency 'MLSUICore/JXCategoryView'
        ss.dependency 'MLSUICore/PublicHeader'
    end
    
    non_arc_files = 'MLSUICore/Classes/YYCategories/Foundation/NSObject+YYAddForARC.{h,m}', 'MLSUICore/Classes/YYCategories/Foundation/NSThread+YYAdd.{h,m}'
    
    s.subspec 'YYCategoriesNoArc' do |sna|
        sna.requires_arc = false
        sna.source_files = non_arc_files
        sna.public_header_files = 'MLSUICore/Classes/YYCategories/Foundation/NSObject+YYAddForARC.h', 'MLSUICore/Classes/YYCategories/Foundation/NSThread+YYAdd.h'
        sna.dependency 'MLSUICore/PublicHeader'
    end
    
    s.subspec 'YYCategories' do |ss|
        no_arc_and_macro_files = 'MLSUICore/Classes/YYCategories/Foundation/NSObject+YYAddForARC.{h,m}', 'MLSUICore/Classes/YYCategories/Foundation/NSThread+YYAdd.{h,m}', 'MLSUICore/Classes/YYCategories/YYCategoriesMacro.h'
        
        ss.subspec 'Macro' do |macro|
            macro.source_files = 'MLSUICore/Classes/YYCategories/YYCategoriesMacro.h'
            macro.public_header_files = 'MLSUICore/Classes/YYCategories/YYCategoriesMacro.h'
            macro.dependency 'MLSUICore/PublicHeader'
        end
        
        ss.subspec 'Core' do |core|
            core.exclude_files = no_arc_and_macro_files
            core.source_files = 'MLSUICore/Classes/YYCategories/**/*.{h,m}'
            core.public_header_files = 'MLSUICore/Classes/YYCategories/Foundation/**/*.h','MLSUICore/Classes/YYCategories/Quartz/**/*.h','MLSUICore/Classes/YYCategories/UIKit/**/*.h', 'MLSUICore/Classes/YYCategories/YYCategories.h'
            core.dependency 'MLSUICore/PublicHeader'
            core.dependency 'MLSUICore/YYCategoriesNoArc'
            core.dependency 'MLSUICore/YYCategories/Macro'
        end
    end
    
end
