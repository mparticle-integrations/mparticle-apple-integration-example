Pod::Spec.new do |s|
    s.name             = "mParticle-Responsys"
    s.version          = "1.0.0"
    s.summary          = "Oracle Responsys Push integration for mParticle"

    s.description      = <<-DESC
                       This is the Oracle Responsys Push integration for mParticle
                       DESC

    s.homepage         = "https://docs.oracle.com/cloud/latest/marketingcs_gs/OMCFB/"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-responsys.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"

    s.ios.deployment_target = "9.0"
    s.ios.source_files      = 'mParticle-Responsys/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 7.5.0'
end
