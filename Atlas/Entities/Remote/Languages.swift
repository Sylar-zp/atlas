//
//  Languages.swift
//  Atlas
//
//  Created by Andrey Trotsko on 4/18/19.
//  Copyright © 2019 Mr.Storm lab. All rights reserved.
//

import Foundation
import ObjectMapper

class Languages: NSObject, Codable, Mappable {

    var name: String?
    var nativeName: String?


    init(name: String, nativeName: String) {
        self.name = name
        self.nativeName = nativeName
    }


    override init() {
        super.init()
    }

    required public init?(map: Map){

    }

    open func mapping(map: Map) {
        name <- map[CodingKeys.name.value]
        nativeName <- map[CodingKeys.nativeName.value]
    }
}
