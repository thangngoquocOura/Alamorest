//
//  Alamorest+JSON.swift
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

import Foundation
import Alamofire
import Promises

open class JSONRequestBase: Request {
    
    public override init(path: String, method: HTTPMethod) {
        super.init(path: path, method: method)
        
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
    }
    
}

open class JSONRequest<Object: Encodable>: JSONRequestBase {
    
    public let object: Object
    
    public init(object: Object, path: String, method: HTTPMethod) {
        self.object = object
        
        super.init(path: path, method: method)
    }
    
    open var encoder: JSONEncoder {
        return JSONEncoder()
    }
    
    override public func createURLRequest(baseURL: URL, headers: HTTPHeaders) throws -> URLRequest {
        var request = try super.createURLRequest(baseURL: baseURL, headers: headers)
        request.httpBody = try encoder.encode(object)
        return request
    }
    
}

open class JSONResponseDecoder<T: Decodable>: ResponseDecoder {
    
    public init() { }
    
    open var decoder: JSONDecoder {
        return JSONDecoder()
    }
    
    public func decode(from data: Data) throws -> T {
        return try decoder.decode(T.self, from: data)
    }
    
}

public extension Server {
    
    /// Submits a JSON request to the server, decoding the response using the default `JSONResponseDecoder`.
    ///
    /// - Parameter request: Request to send.
    /// - Returns: Promise containing the decoded object on success.
    public func json<R: Request, O: Decodable>(_ request: R) -> Promise<O> {
        return startRequest(request, decoder: JSONResponseDecoder<O>())
    }
    
    public func json<R: Encodable, O: Decodable>(object: R, path: String, method: HTTPMethod) -> Promise<O> {
        return json(JSONRequest(object: object, path: path, method: method))
    }
    
    public func json<O: Decodable>(path: String, method: HTTPMethod) -> Promise<O> {
        return json(JSONRequestBase(path: path, method: method))
    }
    
    /// Submits a JSON request to the server, decoding no response.
    ///
    /// - Parameter request: Request to send.
    /// - Returns: Promise that is fulfilled when the request is completed.
    public func json<R: Request>(_ request: R) -> Promise<Void> {
        return startRequest(request)
    }
    
    ///
    public func json<R: Encodable>(object: R, path: String, method: HTTPMethod) -> Promise<Void> {
        return startRequest(JSONRequest(object: object, path: path, method: method))
    }
    
    ///
    public func json(path: String, method: HTTPMethod) -> Promise<Void> {
        return startRequest(JSONRequestBase(path: path, method: method))
    }
    
}