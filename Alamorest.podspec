Pod::Spec.new do |spec|
  spec.name             = 'Alamorest'
  spec.version          = '1.2.0'
  spec.summary          = "Alamorest provides an easy way to interface with RESTful services using Alamofire and Promises."
  spec.homepage         = 'https://github.com/anlaital/Alamorest'
  spec.license          = 'MIT'
  spec.authors          = { 'Antti Laitala' => 'antti.o.laitala@gmail.com' }
  spec.source           = { :git => 'https://github.com/anlaital/Alamorest.git', :tag => 'v1.2.0' }

  spec.ios.deployment_target = '10.0'
  spec.swift_version = '5.0'

  spec.source_files = 'Alamorest/*.swift'
  
  spec.dependency 'Alamofire', '~> 4.8.1'
  spec.dependency 'PromisesSwift', '~> 1.2.8'

  spec.default_subspec = 'Lite'

  spec.subspec 'Lite' do |lite|
    # Minimal implementation without additional dependencies.
  end

  spec.subspec 'Protobuf' do |protobuf|
    protobuf.dependency 'SwiftProtobuf', '~> 1.5.0'
  end
end
