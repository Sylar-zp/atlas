//
//  Constants.swift
//  Kiddzy
//
//  Created by Andrey Trotsko on 11/2/18.
//  Copyright © 2018 InTouch mena. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
import ObjectMapper

let windowSize = (UIApplication.shared.keyWindow?.frame.size)
let documentsDirectory : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

let kBaseAPIUrl          = "https://restcountries.eu/rest/v2/"        // for IPV6 Network

enum APIEndPoints: Int {

    case fetchCounties
    case fetchByRegion
    case getCountyDataByCode
    case search

    var urlSufix: String {
        switch self {
            case .fetchCounties:            return "all"
            case .getCountyDataByCode:      return "alpha/"
            case .fetchByRegion:            return "region/"
            case .search:                   return "name/"
        }
    }

    var description: String {
        return String(describing: self)
    }

    var bodyParams: [String] {
        return []
    }

    var requestMethod: Alamofire.HTTPMethod{
        switch self {

        case .fetchCounties,
             .fetchByRegion,
             .search,
             .getCountyDataByCode:
            return .get
        }
    }

    var headerParams: [String: String]? { return nil }
    var accessTokenRequared: Bool { return true }
    var keyPath: String{ return "" }

    var objectType: Bool{
        switch self {
        case .fetchCounties,
             .search,
             .fetchByRegion:
            return false
        default:
            return true }
    }
}

enum APIUploadFileType: Int {
    case Image = 0
    case Video
    case Audio

    var fileName: String {
        switch self {
        case .Image:
            return "\(NSUUID().uuidString).jpg"
        case .Video:
            return "\(NSUUID().uuidString).mp4"
        case .Audio:
            return "\(NSUUID().uuidString)).mp3"
        }
    }

    var mimeName: String {
        switch self {
        case .Image:
            return "image/jpeg"
        case .Video:
            return "video/mp4"
        case .Audio:
            return "audio/mp3"
        }
    }
}

