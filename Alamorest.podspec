Pod::Spec.new do |spec|
  spec.name             = 'Alamorest'
  spec.version          = '1.0.0'
  spec.summary          = "Alamorest provides an easy way to interface with RESTful services using Alamofire and Promises."
  spec.homepage         = 'https://github.com/anlaital/Alamorest'
  spec.license          = 'MIT'
  spec.authors          = { 'Antti Laitala' => 'antti.o.laitala@gmail.com' }
  spec.source           = { :git => 'https://github.com/anlaital/Alamorest.git', :tag => 'v1.0.0' }

  spec.ios.deployment_target = '10.0'
  spec.swift_version = '4.2'

  spec.source_files = 'Alamorest/*.swift'
  
  spec.dependency 'Alamofire', '~> 4.8.1'
  spec.dependency 'PromisesSwift', '~> 1.2.6'

  spec.subspec 'Protobuf' do |protobuf|
    protobuf.dependency 'SwiftProtobuf', '~> 1.3.1'
  end
end
