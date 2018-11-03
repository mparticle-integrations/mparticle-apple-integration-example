Pod::Spec.new do |s|
    s.name             = "mParticle-CleverTap"
    s.version          = "7.7.3"
    s.summary          = "CleverTap integration for mParticle"

    s.description      = <<-DESC
                       This is the CleverTap integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-clevertap.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"

    s.ios.deployment_target = "9.0"
    s.ios.source_files      = 'mParticle-CleverTap/*.{h,m}'
    s.ios.dependency 'mParticle-Apple-SDK', '~> 7.7.0'
    s.ios.dependency 'CleverTap-iOS-SDK', '~> 3.3.0'

    s.tvos.deployment_target = "9.0"
    s.tvos.source_files      = 'mParticle-CleverTap/*.{h,m}'
    s.tvos.dependency 'mParticle-Apple-SDK/mParticle', '~> 7.7.0'
    s.tvos.dependency 'CleverTap-iOS-SDK', '~> 3.3.0'
end
