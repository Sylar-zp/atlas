//
//  Services.swift
//  Atlas
//
//  Created by Andrey Trotsko on 4/18/19.
//  Copyright © 2019 Mr.Storm lab. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class Services {

    static let shared = Services()
    private init() {}

    //MARK: - get Region Country
    @objc func fetchCountries(by region: String, returnObject: @escaping ([CountryDetail]?, _ error: Error?) -> ()){

        ServerManager.shared.fetchDataWithEndPoint(
            type: CountryDetail.init(),
            endPoint: .fetchByRegion,
            urlParams: [region]) { (data, error) in

            // Temporary fix to guarantee execution of the completion block on the main thread.
            let completionBlock:() -> Void = {
                if error == nil {
                    debugPrint(data as? [CountryDetail] != nil ? "✅ List is taken" : "⚠️ List not taken")
                    returnObject(data as? [CountryDetail], nil)
                } else {
                    returnObject(nil, error)
                }
            }

            guard Thread.isMainThread else { return DispatchQueue.main.async { completionBlock() } }
            completionBlock()
        }
    }

    //MARK: - get Country
    @objc func fetchCountry(by code: String, returnObject: @escaping (CountryDetail?, _ error: Error?) -> ()){

        ServerManager.shared.fetchDataWithEndPoint(
            type: CountryDetail.init(),
            endPoint: .getCountyDataByCode,
            urlParams: [code]) { (data, error) in

                // Temporary fix to guarantee execution of the completion block on the main thread.
                let completionBlock:() -> Void = {
                    if error == nil {
                        debugPrint(data as? CountryDetail != nil ? "✅ List is taken" : "⚠️ List not taken")
                        returnObject(data as? CountryDetail, nil)
                    } else {
                        returnObject(nil, error)
                    }
                }

                guard Thread.isMainThread else { return DispatchQueue.main.async { completionBlock() } }
                completionBlock()
        }
    }

    //MARK: - get Country
    @objc func search(by name: String, returnObject: @escaping ([CountryDetail]?, _ error: Error?) -> ()){

        ServerManager.shared.fetchDataWithEndPoint(
            type: CountryDetail.init(),
            endPoint: .search,
            urlParams: [name]) { (data, error) in

                // Temporary fix to guarantee execution of the completion block on the main thread.
                let completionBlock:() -> Void = {
                    if error == nil {
                        debugPrint(data as? [CountryDetail] != nil ? "✅ List is taken" : "⚠️ List not taken")
                        returnObject(data as? [CountryDetail], nil)
                    } else {
                        returnObject(nil, error)
                    }
                }

                guard Thread.isMainThread else { return DispatchQueue.main.async { completionBlock() } }
                completionBlock()
        }
    }
}
