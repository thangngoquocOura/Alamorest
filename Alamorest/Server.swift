//
//  Server.swift
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

/// Provides interface for communicating with server APIs.
open class Server {
    
    public let baseURL: URL
    
    public var headers = HTTPHeaders()
    public var sessionManager = SessionManager.default
    
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    public enum ServerError: Error, CustomDebugStringConvertible {
        /// Request was cancelled.
        case cancelled
        /// Request timed out.
        case timeout
        /// Server was not reachable.
        case serverNotReachable
        /// Internet was not reachable.
        case internetNotReachable
        /// Request returned an empty response.
        ///
        /// This is used only when the request expected a response object to be returned.
        case emptyResponse
        /// Request finished with an HTTP status code indicating an error.
        /// - statusCode: HTTP status code of the error.
        case httpError(statusCode: Int)
        
        public var debugDescription: String {
            switch self {
            case .cancelled:
                return "Request was cancelled"
            case .timeout:
                return "Request timed out"
            case .serverNotReachable:
                return "Server is not reachable"
            case .internetNotReachable:
                return "Internet is not reachable"
            case .emptyResponse:
                return "Response was empty"
            case .httpError(let code):
                return "HTTP error code \(code)"
            }
        }
    }
    
    /// Resolves the error from a response.
    ///
    /// - parameter response: Response from which to resolve the error from.
    /// - returns: Resolved `Error` or nil if no error occurred.
    public func resolveError(from response: DefaultDataResponse) -> Error? {
        guard let error = response.error else {
            return nil
        }
        
        if let networkError = CFNetworkErrors(rawValue: Int32((error as NSError).code)) {
            switch networkError {
            case .cfurlErrorCancelled:
                return ServerError.cancelled
            case .cfNetServiceErrorTimeout,
                 .cfurlErrorTimedOut:
                return ServerError.timeout
            case .cfurlErrorCannotConnectToHost:
                return ServerError.serverNotReachable
            case .cfurlErrorNotConnectedToInternet,
                 .cfurlErrorNetworkConnectionLost,
                 .cfurlErrorDNSLookupFailed:
                return ServerError.internetNotReachable
            default:
                break
            }
        }
        
        if let code = response.response?.statusCode, !(200...299 ~= code) {
            return ServerError.httpError(statusCode: code)
        }
        
        return error
    }
    
    /// Cancels all pending network tasks.
    @discardableResult
    public func cancelAll() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        sessionManager.session.getAllTasks {
            tasks in
            tasks.forEach { $0.cancel() }
            promise.fulfill(())
        }
        return promise
    }
    
    /// Submits a request to the server, expecting no response object in return.
    ///
    /// This method is useful when you don't expect the server to respond to the request or are not
    /// generally interested in the response payload.
    public func submit<R: Request>(_ request: R) -> Promise<Void> {
        return startRequest(request)
    }

    /// Submits a request to the server decoding the response using the provided `decoder`.
    ///
    /// - Parameter request: Request to submit.
    /// - Parameter decoder: Decoder to use when decoding the server response.
    public func submit<R: Request, D: ResponseDecoder>(_ request: R, decoder: D) -> Promise<D.Object> {
        return startRequest(request, decoder: decoder)
    }

    // MARK: Internal
    
    func startRequest<Req: Request>(_ request: Req) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        do {
            let urlRequest = try request.createURLRequest(baseURL: baseURL, headers: headers)
            printRequest(urlRequest, error: nil)
            
            let dataRequest = sessionManager.request(urlRequest).validate().response {
                self.processResponse($0, request: request, promise: promise)
            }
        } catch {
            printRequest(nil, error: error)
            promise.reject(error)
        }
        return promise
    }
    
    func startRequest<R: Request, D: ResponseDecoder>(_ request: R, decoder: D) -> Promise<D.Object> {
        let promise = Promise<D.Object>.pending()
        do {
            let urlRequest = try request.createURLRequest(baseURL: baseURL, headers: headers)
            printRequest(urlRequest, error: nil)
            
            let dataRequest = sessionManager.request(urlRequest).validate().response {
                self.processResponse($0, decoder: decoder, request: request, promise: promise)
            }
        } catch {
            printRequest(nil, error: error)
            promise.reject(error)
        }
        return promise
    }
    
    // MARK: Private

    private func processResponse<R: Request>(_ response: DefaultDataResponse, request: R, promise: Promise<Void>) {
        if let error = self.resolveError(from: response) {
            printResponse(response, error: error)
            promise.reject(error)
        } else {
            printResponse(response, error: nil)
            promise.fulfill(())
        }
    }

    private func processResponse<R: Request, D: ResponseDecoder>(_ response: DefaultDataResponse, decoder: D, request: R, promise: Promise<D.Object>) {
        if let error = self.resolveError(from: response) {
            printResponse(response, error: error)
            promise.reject(error)
        } else {
            do {
                let data = response.data ?? Data()
                let result = try decoder.decode(from: data)
                printResponse(response, error: nil)
                promise.fulfill(result)
            } catch {
                printResponse(response, error: error)
                promise.reject(error)
            }
        }
    }

}

private func printRequest(_ request: URLRequest?, error: Error?) {
    guard let request = request else {
        RestLogger.print("Constructing request failed with error \(error.debugDescription)", level: .error)
        return
    }
    if let method = request.httpMethod, let url = request.url {
        RestLogger.print("> [\(method)] \(url)", level: .debug)
    }
    if let error = error {
        RestLogger.print(".error\n\(error)", level: .error)
    }
    if let headers = request.allHTTPHeaderFields {
        printHeaders(headers)
    }
    if let data = request.httpBody {
        printData(data)
    }
}

private func printResponse(_ response: DefaultDataResponse, error: Error?) {
    if let request = response.request, let method = request.httpMethod, let url = request.url, let code = response.response?.statusCode {
        RestLogger.print("< [\(method): \(code)] \(url) (\(Int(response.timeline.requestDuration * 1000)) ms)", level: .debug)
    }
    if let error = error {
        RestLogger.print("\n.error\n\(error)", level: .debug)
    }
    if let response = response.response {
        printHeaders(response.allHeaderFields)
    }
    if let data = response.data {
        printData(data)
    }
}

private func printHeaders(_ headers: [AnyHashable: Any]) {
    if RestLogger.shared.level < .verbose {
        return
    }
    if let data = try? JSONSerialization.data(withJSONObject: headers, options: .prettyPrinted), let string = String(data: data, encoding: .utf8) {
        RestLogger.print("\n.headers\n\(string)", level: .verbose)
    } else {
        RestLogger.print("\n.headers\n\(headers)", level: .verbose)
    }
}

private func printData(_ data: Data) {
    if RestLogger.shared.level < .verbose {
        return
    }
    var string = "\n.data\n"
    if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []), let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted), let jsonString = String(data: jsonData, encoding: .utf8) {
        string += jsonString
    } else if let utf8String = String(data: data, encoding: .utf8) {
        string += utf8String
    } else {
        string += "\(data)"
    }
    RestLogger.print(string, level: .verbose)
}
