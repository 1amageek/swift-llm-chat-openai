//
//  URLProtocolMock.swift
//  LLMChatOpenAI
//
//  Created by Kevin Hermawan on 9/28/24.
//

import Foundation

final class URLProtocolMock: URLProtocol {
    static var mockData: Data?
    static var mockStreamData: [String]?
    static var mockError: Error?
    static var mockStatusCode: Int?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let client = client else { return }
        
        if let error = URLProtocolMock.mockError {
            client.urlProtocol(self, didFailWithError: error)
            return
        }
        
        if let streamData = URLProtocolMock.mockStreamData, let url = request.url {
            let response = HTTPURLResponse(url: url, statusCode: URLProtocolMock.mockStatusCode ?? 200, httpVersion: nil, headerFields: ["Content-Type": "text/event-stream"])!
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            
            for line in streamData {
                client.urlProtocol(self, didLoad: Data(line.utf8))
            }
        } else if let data = URLProtocolMock.mockData, let url = request.url {
            let response = HTTPURLResponse(url: url, statusCode: URLProtocolMock.mockStatusCode ?? 200, httpVersion: nil, headerFields: nil)!
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client.urlProtocol(self, didLoad: data)
        } else {
            return
        }
        
        client.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
    static func reset() {
        mockData = nil
        mockStreamData = nil
        mockError = nil
        mockStatusCode = nil
    }
}
