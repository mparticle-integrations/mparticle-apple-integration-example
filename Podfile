# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'mParticle-Swrve' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for mParticle-Swrve
  pod 'mParticle-Apple-SDK'
  pod 'SwrveSDK', '~> 5.3'

  target 'mParticle_SwrveTests' do
  	inherit! :search_paths
  	pod 'mParticle-Apple-SDK'
    pod 'SwrveSDK', '~> 5.3'
  end
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
            config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'SWRVE_NO_PUSH=1'
        end
    end
end