Pod::Spec.new do |s|
    s.name             = "mParticle-ROKOMobi"
    s.version          = "1.0.0"
    s.summary          = "ROKOMobi integration for mParticle"

    s.description      = <<-DESC
                       This is the ROKOMobi integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/ROKOLabs/mparticle-apple-integration-example.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/rokolabs"

    s.ios.deployment_target = "8.0"
    s.ios.source_files      = 'mParticle-ROKOMobi/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle'
    s.ios.dependency 'ROKO.Mobi'
end
