platform :ios, '9.3'

inhibit_all_warnings!
use_frameworks!

target "GetWell" do
  pod 'Fabric'
  pod 'TwitterKit'
  pod 'TwitterCore'
  pod 'Crashlytics'
  pod 'Localytics'
  pod 'Mapbox-iOS-SDK'
  pod 'RealmSwift'
  pod 'Intercom'
  pod 'PermissionScope'
  pod 'iCarousel'
  pod 'Lock', '~> 1.21'
  pod 'Lock-Facebook', '~> 2.1'
  pod 'Alamofire', '~> 3.0'
  pod 'AFNetworking'
  pod 'SimpleKeychain', '~> 0.3'
  pod 'PhoneNumberKit', '~> 0.7'
  pod 'MXParallaxHeader'
  pod 'SDWebImage'
  pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
end

post_install do |installer|
    installer.pods_project.build_configurations.each { |bc|
        bc.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    }
end
