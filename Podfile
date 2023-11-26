
# Disable sending stats
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

# inhibit_all_warnings!

# 部分不支持 macCatalyst 的 pod，可用以下方案处理
# https://github.com/fermoya/CatalystPodSupport

target 'B9ChatAI' do
    platform :ios, '15.0'

    pod 'RFKit', :subspecs => [
        'Category/NSDate',
        'Category/NSDateFormatter',
        'Category/NSFileManager',
    ]
    pod 'RFAlpha', :subspecs => [
        'RFButton',
        'RFContainerView',
        'RFDrawImage',
        'RFNavigationController',
        'RFTableViewPullToFetchPlugin',
        'RFViewApperance/RFLine',
        'RFWindow',
    ]
    pod 'RFDelegateChain', :subspecs => [
        'UITextFieldDelegate',
        'UITextViewDelegate',
    ]
    pod 'RFKeyboard'
    pod 'RFSegue', :subspecs => ['Async']
    pod 'MBAppKit', :path => 'Frameworks/MBAppKit', :subspecs => [
        'Input',
    ]
end

target 'UnitTests' do
  inherit! :search_paths
end

post_install do |pi|
    # 临时修正 deployment target 不支持的问题，并且让 Pod 跟随 App 支持的版本进行编译
    # https://github.com/CocoaPods/CocoaPods/issues/7314#issuecomment-422283045
    fix_deployment_target(pi)
end

def fix_deployment_target(pod_installer)
    if !pod_installer
        return
    end
    puts "Make the pods deployment target version the same as our target"
    
    project = pod_installer.pods_project
    deploymentMap = {}
    project.build_configurations.each do |config|
        deploymentMap[config.name] = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
    end
    # p deploymentMap
    
    project.targets.each do |t|
        puts "  #{t.name}"
        t.build_configurations.each do |config|
            oldTarget = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
            newTarget = deploymentMap[config.name]
            if oldTarget == newTarget
                next
            end
            puts "    #{config.name} deployment target: #{oldTarget} => #{newTarget}"
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = newTarget
        end
    end
end
