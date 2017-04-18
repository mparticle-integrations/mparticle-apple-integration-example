Pod::Spec.new do |s|
    s.name             = "mParticle-Iterable"
    s.version          = "6.11.0"
    s.summary          = "Iterable integration for mParticle"

    s.description      = "This is the Iterable integration for mParticle."

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-iterable.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"

    s.ios.deployment_target = "8.0"
    s.ios.source_files      = 'mParticle-Iterable/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 6.11.0'
    s.ios.dependency 'IterableSDK', '4.3.0'
end
