Pod::Spec.new do |s|
    s.name             = "mParticle-CompanyName"
    s.version          = "6.1.0"
    s.summary          = "CompanyName integration for mParticle"

    s.description      = <<-DESC
                       This is the CompanyName integration for mParticle.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
    s.author           = { "mParticle" => "support@mparticle.com" }
    s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-companyname.git", :tag => s.version.to_s }
    s.social_media_url = "https://twitter.com/mparticles"

    s.ios.deployment_target = "7.0"
    s.ios.source_files      = 'mParticle-CompanyName/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 6.1'
    #s.ios.dependency 'CompanyName', '9.9.9'
end
