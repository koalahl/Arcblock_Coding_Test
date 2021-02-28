//
//  User.swift
//  ArcBlock_Code_Test
//
//  Created by HanLiu on 2021/2/27.
//

import Foundation

struct News: Codable {
    enum NewsType: String, Codable {
        case text = "text"
        case img = "img"
        case textImg = "text-img"
        case link = "text-link"
    }
    let id: Int
    let type: NewsType
    let imgUrls: [String]?
    let content: String?
    let link: String?

}
