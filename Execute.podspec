Pod::Spec.new do |spec|
  spec.name = 'Execute'
  spec.version = '0.1.0'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage = 'https://github.com/SwiftCLI/Execute'
  spec.authors = { 'Jason Nam' => 'contact@jasonnam.com' }
  spec.summary = 'Run and manage shell processes.'
  spec.source = { :git => 'https://github.com/SwiftCLI/Execute.git', :tag => spec.version.to_s }
  spec.swift_version = '5.1'
  spec.osx.deployment_target = '10.13'
  spec.source_files = 'Sources/Execute/**/*.swift'
end
