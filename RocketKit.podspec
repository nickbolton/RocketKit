Pod::Spec.new do |spec|
  spec.name = 'RocketKit'
  spec.version = '0.0.1'
  spec.license = 'Apache2.0'
  spec.summary = 'Rocket runtime library.'
  spec.homepage = 'http://www.rocketapp.com'
  spec.author = {'Nick Bolton' => 'rocket@darkpixel.io'}
  spec.source = {:git => 'https://github.com/nickbolton/RocketKit.git'}

  spec.ios.deployment_target = '10.0'
  spec.osx.deployment_target = '10.11'

  spec.source_files = 'Source/**/*.swift'
  spec.ios.exclude_files = 'Source/osx'
  spec.osx.exclude_files = 'Source/ios'

  spec.requires_arc = true

  spec.dependency 'Cache', '4.1.2'
end 
