//
//  Country.swift
//  Atlas
//
//  Created by Andrey Trotsko on 4/18/19.
//  Copyright © 2019 Mr.Storm lab. All rights reserved.
//

import Foundation

struct Country: Decodable, Hashable {
    let code: String
    let emoji: String
    let unicode: String
    let name: String
    let title: String
}

extension Country {
    static func getData() -> [Country] {
        if let path = Bundle.main.path(forResource: "data", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let model = try JSONDecoder().decode([Country].self, from: data)

                return model

            } catch { }
        }
        return []
    }
}
