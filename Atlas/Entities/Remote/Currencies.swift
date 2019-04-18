//
//  Currencies.swift
//  Atlas
//
//  Created by Andrey Trotsko on 4/18/19.
//  Copyright © 2019 Mr.Storm lab. All rights reserved.
//

import Foundation
import ObjectMapper

class Currencies: NSObject, Codable, Mappable {

    var name: String?
    var code: String?
    var symbol: String?


    init(name: String, code: String, symbol: String) {
        self.name = name
        self.code = code
        self.symbol = symbol
    }


    override init() {
        super.init()
    }

    required public init?(map: Map){

    }

    open func mapping(map: Map) {
        name <- map[CodingKeys.name.value]
        code <- map[CodingKeys.code.value]
        symbol <- map[CodingKeys.symbol.value]
    }
}
