//
//  HTTPRequestManager.swift
//  ArcBlock_Code_Test
//
//  Created by HanLiu on 2021/2/27.
//

import Foundation

enum RequestError: Error {
    case InvaildUrl
    case NoData
    case dataParseError
    case other(errorMsg: String)
    case with(error: Error)
}

enum RequestType {
    case refresh
    case loadMore
}

class RequestManager {
    
    static let shared = RequestManager()
    
    private var session = URLSession.shared
    
    private var page: Int  = 0
    private var inCompleteResult = false
    
    init() {}
    
    /// Search user with keywork
    /// - Parameters:
    ///   - loadType: request type: refresh/loadMore
    ///   - completion: return a  list include users
    func getArcBlockNews(loadType: RequestType, completion: @escaping ([News]?)-> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let news = self.arcBlockMockNews()
            completion(news)
        }
        return
        
        guard var url = URL(string: APIManager.host + APIManager.Path.userList.rawValue) else {
            fatalError(RequestError.InvaildUrl.localizedDescription)
        }
        switch loadType {
        case .refresh:
            page = 1
        case .loadMore:
            page += 1
        }
        let URLParams = [
            "page": "\(page)",
        ]
        url = url.appendingQueryParameters(URLParams)
        
        HTTPClient.shared.sendRequest(url: url, method: .get) { [weak self] (result) in
            guard let self = self else { return }
            do {
                let data = try self.parseCommonFetchResult(result)
                do {
                    let news = try JSONDecoder().decode([News].self, from: data)
                    DispatchQueue.main.async {
                        completion(news)
                    }
                } catch let error {
                    debugPrint("decode error = \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func arcBlockMockNews() -> [News]? {
        guard let path = Bundle.main.path(forResource: "News", ofType: "json") else  { fatalError("mock json file not found") }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! Dictionary<String, Any>
            let arrJson = json["data"] as! [ [String:Any]]
            do {
                let arrData = try JSONSerialization.data(withJSONObject: arrJson, options: .prettyPrinted)
                let news = try JSONDecoder().decode([News].self, from: arrData)
                return news
            } catch let error {
                debugPrint(error)
                return nil
            }

        } catch let error {
            debugPrint(error)
            return nil
        }
    }
}

extension RequestManager {
    private func parseCommonFetchResult(_ result: HTTPFetchResult<Data>) throws -> Data {
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw RequestError.other(errorMsg: error.localizedDescription)
        }
    }
}
