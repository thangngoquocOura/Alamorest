//
//  JSONPlaceholderAPI.swift
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
import Alamorest
import Promises

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
        return server.json(Request(path: "posts", method: .get))
    }
    
    func post(id: Int) -> Promise<Post> {
        return server.json(Request(path: "posts/\(id)", method: .get))
    }
    
    func createPost(title: String, body: String, userId: Int) -> Promise<Post> {
        struct Payload: Encodable {
            let title: String
            let body: String
            let userId: Int
        }
        let object = Payload(title: title, body: body, userId: userId)
        return server.json(JSONRequest(object: object, path: "posts", method: .post))
    }
    
}

