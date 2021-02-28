//
//  HTTPClient.swift
//  ArcBlock_Code_Test
//
//  Created by HanLiu on 2021/2/27.
//

import UIKit

enum HTTPFetchResult<T> {
    case success(T)
    case failure(RequestError)
}

enum HTTPMethod {
    case get
    case post
}

struct HTTPFetchResponse<T: Codable>: Codable {
    let code: Int
    let msg: String
    let data: T
}

class HTTPClient {
    
    static let shared = HTTPClient()

    private var session = URLSession.shared
    
    private let cache = NSCache<NSString, UIImage>()
    
    init() { }
    
    /// Send HTTP Request
    /// - Parameters:
    ///   - url: request url
    ///   - method: HTTP method : get/post
    ///   - completion: return response data
    func sendRequest(url: URL, method: HTTPMethod, completion: @escaping (HTTPFetchResult<Data>) -> Void) {
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let data = data {
                do {
                    let fetchResponse = try JSONDecoder().decode(HTTPFetchResponse<Data>.self, from: data)
                    //with no error code
                    if fetchResponse.code == 0 {
                        let result = HTTPFetchResult.success(fetchResponse.data)
                        completion(result)
                    } else {
                        let error = RequestError.other(errorMsg: fetchResponse.msg)
                        completion(HTTPFetchResult.failure(error))
                    }
                } catch {
                    let error = RequestError.dataParseError
                    completion(HTTPFetchResult.failure(error))
                }
            } else {
                let error = RequestError.NoData
                completion(HTTPFetchResult.failure(error))
            }
        }
        task.resume()
    }
    
    /// Download Image
    /// There is a cache to optimize image load cost.
    /// - Parameters:
    ///   - imageUrlStr: image url
    ///   - completion: return UIImage as result
    func downloadImage(imageUrlStr: String, completion: @escaping (HTTPFetchResult<UIImage>) -> Void) {
        guard let imageURL = URL(string: imageUrlStr) else { return }
        if let image = cache.object(forKey: imageUrlStr as NSString) {
            completion(HTTPFetchResult.success(image))
            return
        }
        let urlRequest = URLRequest(url: imageURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
        let task = session.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if let data = data {
                if let image = UIImage(data: data) {
                    self.cache.setObject(image, forKey: imageUrlStr as NSString)
                    let result = HTTPFetchResult.success(image)
                    completion(result)
                } else {
                    completion(HTTPFetchResult.failure(RequestError.other(errorMsg: "convert image data fail")))
                }
            } else {
                if let error = error {
                    completion(HTTPFetchResult.failure(RequestError.with(error: error)))
                }
            }
        }
        task.resume()
    }
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
    */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
    */
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}
