# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'RxSwiftDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RxSwiftDemo
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SnapKit'

end

# 解决不同iOS版本的兼容性问题(不能乱修改,否则模拟器运行容易报错)
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
