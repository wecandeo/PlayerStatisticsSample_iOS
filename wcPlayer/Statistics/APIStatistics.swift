//
//  APIStatistics.swift
//  wcPlayer
//
//  Created by 서상민 on 2020/07/27.
//  Copyright © 2020 서상민. All rights reserved.
//

import Foundation
import UIKit

struct RequestInfo {
    var url: String
    var method: HttpMethod
    var body: [String: Any?]
}

class APIStatistics {
    
    static let `default` = APIStatistics() 
    
    func fetchData<Element: Decodable>(_ info: RequestInfo, completion: @escaping (_ data: Element?) -> Void) {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        
        let session = URLSession(configuration: configuration)
        var request: URLRequest?
        
        switch info.method {
        case .GET:
            var components = URLComponents(string: info.url)
            components?.queryItems = info.body.map { (key, value) in
                let _value = value as? String ?? ""
                return URLQueryItem(name: key, value: _value)
            }
            
            guard let url = components?.url else { fatalError("Request URL: \(components?.url?.absoluteString ?? "-")") }
            request = URLRequest(url: url)
        case .POST:
            guard let url = URL(string: info.url) else { fatalError("Request URL: \(info.url)") }
            request = URLRequest(url: url)
            request?.httpBody = try? JSONSerialization.data(withJSONObject: info.body, options: .prettyPrinted)
        default:
            break
        }
        
        request?.timeoutInterval = 3
        request?.httpMethod = info.method.rawValue
        
        let ua = String(format: "(%@; iOS %@) App/%@",
                        UIDevice.current.model,
                        UIDevice.current.systemVersion,
                        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
        request?.addValue(ua, forHTTPHeaderField: "User-Agent")
        
        guard let req = request else { fatalError("URLRequest is NULL!") }
        session.dataTask(with: req) { (data, res, error) in
            if let error = error { fatalError("Request: \(info) Failed: \(error.localizedDescription)") }
            
            guard let resHttp = res as? HTTPURLResponse else { fatalError() }
            guard 200..<300 ~= resHttp.statusCode else { fatalError("HTTPURLResponse: \(resHttp)") }
            guard let data = data, let strData = String(data: data, encoding: .utf8) else { fatalError("Data is Error") }
            
            if data.isEmpty {
                completion(nil)
            } else {
                print("Response Data: \(strData)")
                
                let decode = try? JSONDecoder().decode(Element.self, from: data)
                completion(decode)
            }
        }.resume()
    }
}
