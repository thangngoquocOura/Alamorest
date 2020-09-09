Pod::Spec.new do |spec|
  spec.name             = 'Alamorest'
  spec.version          = '1.4.1'
  spec.summary          = "Alamorest provides an easy way to interface with RESTful services using Alamofire and Promises."
  spec.homepage         = 'https://github.com/anlaital/Alamorest'
  spec.license          = 'MIT'
  spec.authors          = { 'Antti Laitala' => 'antti.o.laitala@gmail.com' }
  spec.source           = { :git => 'https://github.com/anlaital/Alamorest.git', :tag => 'v1.4.1' }

  spec.ios.deployment_target = '11.0'
  spec.swift_version = '5.2'

  spec.source_files = 'Alamorest/*.swift'
  
  spec.dependency 'Alamofire', '~> 5.2.0'
  spec.dependency 'PromisesSwift', '~> 1.2.0'

  spec.default_subspec = 'Lite'

  spec.subspec 'Lite' do |lite|
    # Minimal implementation without additional dependencies.
  end

  spec.subspec 'Protobuf' do |protobuf|
    protobuf.dependency 'SwiftProtobuf', '~> 1.9.0'
  end
end
