//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by CS193p Instructor on 4/26/21.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import Foundation

extension EmojiArtModel {
    enum Background: Equatable,Codable {
        case blank
        case url(URL)
        case imageData(Data)
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
        
//        init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            if let url = try? container.decode(URL.self, forKey: .url) {
//                self = .url(url)
//            } else
//            if let data = try? container.decode(Data.self, forKey: .imageData){
//                self = .imageData(data)
//            } else {
//                self = .blank
//            }
//        }
//
//        func encode(to encoder: Encoder) throws {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            switch self {
//            case .url(let url):
//                try container.encode(url, forKey: .url)
//            case .imageData(let data):
//                try container.encode(data, forKey: .imageData)
//            case .blank:
//                break
//            }
//        }
        
        //Swift 5.5
        enum CodingKeys: String,CodingKey {
            case blank
            case url
            case imageData
        }
        
        enum UrlCodingKeys: String,CodingKey {
            case _0 = "url"
        }
    }
}
