//
//  Request.swift
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

open class Request {
    
    public let path: String
    public let method: HTTPMethod
    
    /// HTTP headers for the request.
    ///
    /// These are merged with the server headers.
    public var headers = HTTPHeaders()
    
    /// HTTP parameters for the request.
    public var parameters = Parameters()
    
    /// Specifies the timeout interval in seconds for the request.
    public var timeoutInterval: TimeInterval?
    
    /// Key that can be used when querying for the underlying `DataRequest` by using `Server.dataRequest(forKey:)` method.
    ///
    /// This is mostly useful for implementing the cancellation of pending requests.
    public var dataRequestKey: String?
    
    public init(path: String, method: HTTPMethod) {
        self.path = path
        self.method = method
    }
    
    public func createURLRequest(baseURL: URL, headers: HTTPHeaders) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        
        let headersDict = self.headers.dictionary.merging(headers.dictionary) {
            current, _ in current
        }
        let mergedHeaders = HTTPHeaders(headersDict)
                
        var request = try URLRequest(url: url, method: method, headers: mergedHeaders)
        
        if let timeoutInterval = timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        
        return try URLEncoding.default.encode(request, with: parameters)
    }

}
