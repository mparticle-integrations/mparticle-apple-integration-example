Pod::Spec.new do |s|
    s.name             = "mParticle-FollowAnalytics"
    s.version          = "7.7.3"
    s.summary          = "FollowAnalytics integration for mParticle"

    s.description      = <<-DESC
                       This is the FollowAnalytics integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-followanalytics.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"

    s.ios.deployment_target = "9.0"
    s.ios.source_files      = 'mParticle-Example/*.{h,m}'
    s.ios.dependency 'mParticle-Apple-SDK', '~> 7'
    s.ios.dependency 'FollowAnalytics', '~> 6.0.0'
end
