Pod::Spec.new do |s|
    s.name             = "mParticle-Appsee"
    s.version          = "2.4.1"
    s.summary          = "Appsee integration for mParticle"

    s.description      = <<-DESC
                       This is the Appsee integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-appsee.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"

    s.ios.deployment_target = "6.0"
    s.ios.source_files      = 'mParticle-Appsee/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle'
    s.ios.dependency 'Appsee', '>= 2.4.1'
end
