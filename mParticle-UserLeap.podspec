Pod::Spec.new do |s|
    s.name             = "mParticle-UserLeap"
    s.version          = "1.0.0"
    s.summary          = "UserLeap integration for mParticle"

    s.description      = <<-DESC
                       Please find updated documentation at https://docs.userleap.com/integrations/mparticle
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "UserLeap" => "support@userleap.com" }
    s.source           = { :git => "https://github.com/UserLeap/userleap-mparticle-ios-kit.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/userleap"

    s.ios.deployment_target = "10.3"
    s.ios.source_files      = 'mParticle-UserLeap/*.{h,m}'
    s.ios.dependency 'mParticle-Apple-SDK', '~> 8.2'
    s.ios.dependency 'UserLeapKit', '4.1.0'
    s.pod_target_xcconfig = { 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' 
    }
    s.user_target_xcconfig = { 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
end
