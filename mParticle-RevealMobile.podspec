Pod::Spec.new do |s|
    s.name             = "mParticle-RevealMobile"
    s.version          = "1.3.7"
    s.summary          = "Reveal Mobile provides audience understanding for your mobile apps."

    s.description      = <<-DESC
                       Reveal Mobile is a mobile audience platform.  We provide app publishers with the ability to understand the demographics, behaviors, interests, and political leanings of their mobile app audience.
                       DESC

    s.homepage         = "https://www.mparticle.com"
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { "Reveal Mobile" => "support@revealmobile.com", "Sean Doherty" => "sean.doherty@crosscomm.net", "Bobby Skinner" => "bobby.skinner@crosscomm.net" }
    #s.source           = { :git => "https://github.com/mparticle-integrations/mparticle-apple-integration-RevealMobile.git", :tag => s.version.to_s }
    s.source           = { :git => "https://github.com/bobbyski/mparticle-apple-integration-example.git", :tag => s.version.to_s }
    #s.social_media_url = "https://twitter.com/mparticles"

    s.ios.deployment_target = "8.0"
    s.ios.source_files      = 'mParticle-CompanyName/*.{h,m,mm}'
    s.ios.dependency 'mParticle-Apple-SDK/mParticle', '~> 6.7'
    s.ios.dependency 'Reveal', '~> 1.3'
    s.source_files = 'mParticle-RevealMobile/**/*'
    s.requires_arc = true
    #s.ios.dependency 'CompanyName', '9.9.9'


end
