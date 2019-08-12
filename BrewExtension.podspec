Pod::Spec.new do |s|
  s.name = 'BrewExtension'
  s.platform = :osx
  s.osx.deployment_target = "10.13"

  s.version = '1.0.0'
  s.summary = 'HomeBrew Extension'
  s.description = 'Provide extended ability to homebrew'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.swift_version = '5.0'
  s.author = 'Zehua Chen'
  s.homepage = 'https://github.com/Zehua-Chen/brew-extension'
  s.source = { :git => 'https://github.com/Zehua-Chen/brew-extension.git', :tag => s.version.to_s }

  s.subspec 'Brew' do |hb|
    hb.name = 'Brew'
    hb.source_files = 'Sources/Brew/**/*.swift'
  end

  s.subspec 'BrewExtension' do |hbext|
    hbext.name = 'BrewExtension'
    hbext.dependency 'BrewExtension/Brew'
    hbext.source_files = 'Sources/BrewExtension/**/*.swift'
  end
end

