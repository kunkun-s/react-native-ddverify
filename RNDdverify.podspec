

# :podspec文件必须在根仓库文件中
Pod::Spec.new do |s|
  s.name         = "RNDdverify"
  s.version      = "1.0.0"
  # pod简介
  s.summary      = "继承UMVerify"
  # 详细描述
  # spec.description

  s.description  = <<-DESC
                  RNDdverify
                   DESC
  s.homepage     = "https://github.com/kunkun-s/react-native-ddverify.git"
  # //许可证，除非源代码包含了LICENSE.*或者LICENCE.*文件，否则必须指定许可证文件。文件扩展名可以没有，或者是.txt,.md,.markdown
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  # pod库维护者的名车和邮箱
  # spec.authors = { 'Darth Vader' => 'darthvader@darkside.com', 'Wookiee'     => 'wookiee@aggrrttaaggrrt.com' }
  s.author             = { "author" => "author@domain.cn" }
  # 支持的swift版本
  # s.swift_version

  #  pod支持的平台，如果没有设置意味着支持所有平台,使用deployment_target支持选择多个平台
  s.platform     = :ios, "7.0"

  # 获取库的地址
    # git地址，tag:值以v开头，支持子模块
  s.source       = { :git => "https://github.com/kunkun-s/react-native-ddverify.git", :tag => "master" }
  
  # 加载文件
  s.source_files  = "ios/Class/**/*.{h,m}"
  # 排除文件
  # s.exclude_files = "Class/**/*.{storyboard,xib}"
  
  # 资源文件 将资源文件打包成bundle
  # resource_bundles = {   'XBPodSDK' => ['XBPodSDK/Assets/**'] }
  s.resource_bundles = { 'ATAuthSDK' => ['ios/libs/UMVerify/ATAuthSDK.bundle/*', ], 'RNDDverify' => ['ios/image/*', "ios/Class/**/*.{xib}"] }
  
  # 公共头文件,这些头文件将暴露给用户的项目。如果不设置，所有source_files的头文件将被暴露
  # s.public_header_files =
  
  # requires_arc: 指定私有库 文件是否 是ARC.默认是true,表示所有的 source_files是arc文件
    # 指定除了Arc文件下的是arc，其余的全还mrc，会添加-fno-objc-arc 编辑标记
    #  s.requires_arc = false       s.requires_arc = 'Classes/Arc'
    # 注意：spec.requires_arc 指定的路径表示是arc文件，不被指定才会被标记 -fno-objc-arc
  s.requires_arc = true
  # spec.static_framework = true
  # 使用系统framework
   s.framework = "CoreTelephony","SystemConfiguration"
  # 使用第三方framework
  s.vendored_frameworks = 'ios/libs/UMVerify/UMVerify.framework','ios/libs/UMVerify/YTXMonitor.framework',"ios/libs/UMVerify/YTXOperators.framework"
  # 使用系统.a 去除了前缀lib和后缀.tbd
   s.libraries = 'z'
  # 使用三方静态库 .a
  # s.vendored_libraries =
  
  
  # 私有库依赖的三方pod库
  s.dependency "React"
#  s.dependency "UMVerify"
 
  #  说明文档地址
  # s.documentation_url

  # 库是否废弃
  # s.deprecated = true

  #  废弃的pod名称
  # s.deprecated_in_favor_of = 'NewMoreAwesomePod'

end

  
