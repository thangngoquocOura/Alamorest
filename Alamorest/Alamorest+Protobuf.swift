//
//  Alamorest+Protobuf.swift
//
//  Copyright (c) 2019 Antti Laitala (https://github.com/anlaital/Alamorest/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if canImport(SwiftProtobuf)

import Foundation
import Alamofire
import Promises
import SwiftProtobuf

open class ProtobufRequestBase: Request {
    
    public override init(path: String, method: HTTPMethod) {
        super.init(path: path, method: method)
        
        headers["Content-Type"] = "application/x-protobuf"
        headers["Accept"] = "application/x-protobuf"
    }
    
}

open class ProtobufRequest<Object: SwiftProtobuf.Message>: ProtobufRequestBase {
    
    public let object: Object
    
    public init(object: Object, path: String, method: HTTPMethod) {
        self.object = object
        
        super.init(path: path, method: method)
    }
    
    override public func createURLRequest(baseURL: URL, headers: HTTPHeaders) throws -> URLRequest {
        var request = try super.createURLRequest(baseURL: baseURL, headers: headers)
        request.httpBody = try object.serializedData()
        return request
    }
    
}

open class ProtobufResponseDecoder<T: SwiftProtobuf.Message>: ResponseDecoder {
    
    public init() { }
    
    public func decode(from data: Data) throws -> T {
        if data.isEmpty {
            // Protobuf objects can be constructed from empty data also.
            // Prevent this as we don't want to use the default constructor.
            throw Server.ServerError.emptyResponse
        }
        return try T(serializedData: data)
    }
    
}

public extension Server {
    
    /// Submits a protobuf request to the server decoding the response using the default `ProtobufResponseDecoder`.
    ///
    /// - Parameter request: Request to submit.
    func protobuf<R: Request, O: SwiftProtobuf.Message>(_ request: R) -> Promise<O> {
        return startRequest(request, decoder: ProtobufResponseDecoder<O>())
    }

    func protobuf<R: SwiftProtobuf.Message, O: SwiftProtobuf.Message>(object: R, path: String, method: HTTPMethod) -> Promise<O> {
        return protobuf(ProtobufRequest(object: object, path: path, method: method))
    }

    func protobuf<O: SwiftProtobuf.Message>(path: String, method: HTTPMethod) -> Promise<O> {
        return protobuf(ProtobufRequestBase(path: path, method: method))
    }

    ///
    func protobuf<R: Request>(_ request: R) -> Promise<Void> {
        return startRequest(request)
    }
    
    ///
    func protobuf<R: SwiftProtobuf.Message>(object: R, path: String, method: HTTPMethod) -> Promise<Void> {
        return startRequest(ProtobufRequest(object: object, path: path, method: method))
    }

    ///
    func protobuf(path: String, method: HTTPMethod) -> Promise<Void> {
        return startRequest(ProtobufRequestBase(path: path, method: method))
    }
    
}

#endif
