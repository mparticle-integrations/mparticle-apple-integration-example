Pod::Spec.new do |s|
    s.name             = "mParticle-UserLeap"
    s.version          = "1.0.0"
    s.summary          = "UserLeap integration for mParticle"

    s.description      = <<-DESC
                       Please find updated documentation at https://docs.userleap.com/integrations/mparticle
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-userleap.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"

    s.ios.deployment_target = "9.0"
    s.ios.source_files      = 'mParticle-UserLeap/*.{h,m}'
    s.ios.dependency 'mParticle-Apple-SDK', '~> 8.2'
    s.ios.dependency 'UserLeapKit', '4.1.0'
end
