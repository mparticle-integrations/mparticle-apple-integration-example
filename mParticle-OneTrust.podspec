Pod::Spec.new do |s|
    s.name             = "mParticle-OneTrust"
    s.version          = "7.7.3"
    s.summary          = "OneTrust integration for mParticle"

    s.description      = <<-DESC
                       This is the OneTrust integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-example.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"

    
    s.ios.deployment_target = "9.0"
    s.ios.source_files      = 'mParticle-OneTrust/*.{h,m}'
    s.ios.dependency 'mParticle-Apple-SDK', '~> 7.7.0'

end
