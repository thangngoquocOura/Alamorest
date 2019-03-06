# Alamorest

Alamorest provides an easy way to interface with RESTful services using Alamofire and Promises.

Provides out-of-the box support for JSON and (optionally) Protobuf requests.

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

## Usage

1. Implement the API (`struct` based approach preferred)

```swift 
struct JSONPlaceholderAPI {
    
    let server: Server
    
    init(baseURL: String) {
        server = Server(baseURL: URL(string: baseURL)!)
    }
    
    struct Post: Decodable {
        let body: String
        let id: Int
        let title: String
        let userId: Int
    }
    
    func posts() -> Promise<[Post]> {
        return server.json(path: "posts", method: .get)
    }
    
    func post(id: Int) -> Promise<Post> {
        return server.json(path: "posts/\(id)", method: .get)
    }
    
    func createPost(title: String, body: String, userId: Int) -> Promise<Post> {
        struct Payload: Encodable {
            let title: String
            let body: String
            let userId: Int
        }
        let object = Payload(title: title, body: body, userId: userId)
        return server.json(object: object, path: "posts", method: .post)
    }
    
}

```
2. Create a `Server` pointing to where the API resides

```swift
let server = Server(baseURL: URL("https://jsonplaceholder.typicode.com")!)
```

3. Start making requests

```swift
let api = JSONPlaceholderAPI(server: server)

api.posts().then {
  print($0) // Prints out the posts.
}.catch {
  print($0) // Prints out the error.
}
```
