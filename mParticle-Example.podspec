Pod::Spec.new do |s|
    s.name             = "mParticle-Example"
    s.version          = "8.0.0"
    s.summary          = "Example integration for mParticle"

    s.description      = <<-DESC
                       This is the Example integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-example.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticle"

    s.ios.deployment_target = "9.0"
    s.ios.source_files      = 'mParticle-Example/*.{h,m}'
    s.ios.dependency 'mParticle-Apple-SDK', '~> 8.1.1'
    #s.ios.dependency 'Example', '~> 1.2'
end
