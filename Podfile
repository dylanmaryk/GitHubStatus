platform :osx, '10.15'

target 'GitHubStatus' do
  use_frameworks!

  pod 'Sparkle', '~> 1.23.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete('ARCHS')
    end
  end
end
