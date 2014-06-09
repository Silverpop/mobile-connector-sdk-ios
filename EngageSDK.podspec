Pod::Spec.new do |s|
  s.name            = 'EngageSDK'
  s.version         = '0.2'
  s.summary         = 'Silverpop Engage SDK for iOS.'
  s.homepage        = 'https://github.com/Silverpop/engage-sdk-ios'
  s.authors         = { 'Silverpop Development' => 'engineeringmanagement@silverpop.com' }
  s.license         = { :type => 'Apache 2.0', :file => 'License.txt' }
  s.source          = { :git => 'https://github.com/Silverpop/engage-sdk-ios.git', :tag => '0.2' }
  s.ios.xcconfig    = { 'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(SDKROOT)/Developer/Library/Frameworks" "$(DEVELOPER_LIBRARY_DIR)/Frameworks"' }
  s.ios.deployment_target = '7.0'
  s.source_files = 'EngageSDK/*/*.{h,m}'
  s.public_header_files = 'EngageSDK/Public/*.h'
  s.requires_arc = true

  s.resources = ["EngageSDK/Supporting Files/MobileDeepLinkingConfig.json", "EngageSDK/Supporting Files/EngageConfigDefaults.plist"]

  s.resource_bundles = {
    'EngageConfigPlist' => ['EngageSDK/EngageConfig.plist']
  }
      
  s.subspec 'AFNetworking' do |net|
      net.dependency 'AFNetworking', '~> 2.2.3'
      net.dependency 'AFOAuth2Client@phoenixplatform', '~> 0.1'
      net.dependency 'MobileDeepLinking-iOS', '~> 0.2'
  end
  
end
