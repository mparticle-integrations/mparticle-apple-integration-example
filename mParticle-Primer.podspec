Pod::Spec.new do |s|
    s.name             = "mParticle-Primer"
    s.version          = "0.0.1"
    s.summary          = "Primer integration for mParticle"

    s.description      = <<-DESC
                       This is the Primer integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "Primer" => "support@goprimer.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-primer.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/goprimer"

    s.ios.deployment_target = "8.0"
    s.ios.source_files      = 'mParticle-Primer/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 6.2'
    s.ios.dependency 'Primer', '3.1.0'
end
