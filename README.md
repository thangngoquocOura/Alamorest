# Alamorest

Alamorest provides an easy way to interface with RESTful services using Alamofire and Promises.

## Requirements

- iOS 10.0+
- Swift 4.2+

## Dependencies

- [Alamofire](https://github.com/Alamofire/Alamofire) 
- [Promises](https://github.com/google/promises)
- [Protobuf](https://github.com/apple/swift-protobuf) (Optional)

## Installation

### CocoaPods

CocoaPods is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Alamorest into your Xcode project using CocoaPods, specify it in your Podfile:

`pod 'Alamorest', :git => 'git@github.com:anlaital/Alamorest.git'`

To add support for Protobuf, include the following subspec in your Podfile:

`pod 'Alamorest/Protobuf', :git => 'git@github.com:anlaital/Alamorest.git'`
