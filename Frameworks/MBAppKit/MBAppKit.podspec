Pod::Spec.new do |s|
  s.name     = 'MBAppKit'
  s.version  = '1.0.0'
  s.author   = 'BB9z'
  s.license  = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.homepage = 'https://github.com/RFUI/MBAppKit'
  s.summary  = '通用项目基础套件'
  s.source   = {
    :git => 'https://github.com/RFUI/MBAppKit.git',
    :tag => s.version.to_s
  }
  
  s.requires_arc = true
  s.ios.deployment_target = '13.0'
  s.macos.deployment_target = '11.0'

  s.pod_target_xcconfig = {
  }

  s.default_subspec = 'Core'
  s.subspec 'Core' do |ss|
    ss.dependency 'RFKit', '~> 2.0'
    ss.dependency 'RFAlpha/RFSwizzle'

    ss.ios.source_files = ['MBAppKit/**/*.{h,m}']
    ss.ios.exclude_files = '**/macos/*'
    ss.ios.public_header_files = 'MBAppKit/**/*.h'

    ss.macos.source_files = [
      'MBAppKit/MBApplicationDelegate/macos/*.{h,m}',
    ]
    ss.macos.public_header_files = [
      'MBAppKit/MBApplicationDelegate/macos/*.h',
    ]
  end

  # Components
  s.subspec 'Input' do |ss|
    ss.ios.deployment_target = '9.0'

    ss.dependency 'MBAppKit/Core'
    ss.dependency 'RFInitializing'
    ss.dependency 'RFKit/RFGeometry'
    ss.dependency 'RFKit/Category/UIResponder'
    ss.dependency 'RFDelegateChain/UITextFieldDelegate'
    ss.source_files = 'Components/Input/*.{h,m}'
    ss.public_header_files = 'Components/Input/*.h'
  end
end
