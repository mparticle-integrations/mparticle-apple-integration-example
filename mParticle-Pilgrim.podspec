Pod::Spec.new do |s|
    s.name             = "mParticle-Pilgrim"
    s.version          = "7.7.3"
    s.summary          = "Pilgrim integration for mParticle"

    s.description      = <<-DESC
                       This is the Pilgrim integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-pilgrim.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"

    s.ios.deployment_target = "9.0"
    s.ios.source_files      = 'mParticle-Pilgrim/*.{h,m}'
    s.ios.dependency 'mParticle-Apple-SDK', '~> 7.8.4'
    s.ios.dependency 'Pilgrim', '~> 2.1'
end
