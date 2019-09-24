Pod::Spec.new do |s|
    s.name             = "mParticle-Swrve"
    s.version          = "1.0"
    s.summary          = "Swrve integration for mParticle"

    s.description      = <<-DESC
                       This is the Swrve integration for mParticle.
                       DESC

    s.homepage         = "https://www.swrve.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "Swrve" => "support@swrve.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-example.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/Swrve_Inc"

    s.ios.deployment_target = "6.0"
    s.ios.source_files      = 'mParticle-Swrve/*.{h,m}'
    s.ios.dependency 'mParticle-Apple-SDK', '~> 7'
    s.ios.dependency 'SwrveSDK', '~> 5.3'
end
