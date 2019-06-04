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

/// Base class for all JSON requests.
open class JSONRequestBase: Request {
    
    public override init(path: String, method: HTTPMethod) {
        super.init(path: path, method: method)
        
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
    }
    
}

open class JSONRequest<Object: Encodable>: JSONRequestBase {
    
    public let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    public let object: Object

    public init(object: Object, path: String, method: HTTPMethod) {
        self.object = object
        
        super.init(path: path, method: method)
    }
    
    override public func createURLRequest(baseURL: URL, headers: HTTPHeaders) throws -> URLRequest {
        var request = try super.createURLRequest(baseURL: baseURL, headers: headers)
        request.httpBody = try encoder.encode(object)
        return request
    }
    
}

open class JSONResponseDecoder<T: Decodable>: ResponseDecoder {
    
    public let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    public init() { }
    
    public func decode(from data: Data) throws -> T {
        return try decoder.decode(T.self, from: data)
    }
    
}

public extension Server {
    
    /// Submits a JSON request to the server, decoding the response using the default `JSONResponseDecoder`.
    ///
    /// - Parameter request: Request to send.
    /// - Returns: Promise containing the decoded object on success.
    func json<R: Request, O: Decodable>(_ request: R) -> Promise<O> {
        return startRequest(request, decoder: JSONResponseDecoder<O>())
    }
    
    func json<R: Encodable, O: Decodable>(object: R, path: String, method: HTTPMethod) -> Promise<O> {
        return json(JSONRequest(object: object, path: path, method: method))
    }
    
    func json<O: Decodable>(path: String, method: HTTPMethod) -> Promise<O> {
        return json(JSONRequestBase(path: path, method: method))
    }
    
    /// Submits a JSON request to the server, decoding no response.
    ///
    /// - Parameter request: Request to send.
    /// - Returns: Promise that is fulfilled when the request is completed.
    func json<R: Request>(_ request: R) -> Promise<Void> {
        return startRequest(request)
    }
    
    /// Submits a JSON request to the server, decoding no response.
    ///
    /// - Parameter object: Object to send that is encoded using the default `JSONEncoder`.
    /// - Parameter path: Path of the request.
    /// - Parameter method: HTTP method of the request.
    /// - Returns: Promise that is fulfilled when the request is completed.
    func json<R: Encodable>(object: R, path: String, method: HTTPMethod) -> Promise<Void> {
        return startRequest(JSONRequest(object: object, path: path, method: method))
    }
    
    /// Submits an empty JSON request to the server, decoding no response.
    ///
    /// - Parameter path: Path of the request.
    /// - Parameter method: HTTP method of the request.
    /// - Returns: Promise that is fulfilled when the request is completed.
    func json(path: String, method: HTTPMethod) -> Promise<Void> {
        return startRequest(JSONRequestBase(path: path, method: method))
    }
    
}
