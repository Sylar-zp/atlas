//
//  CountryDetail.swift
//  Atlas
//
//  Created by Andrey Trotsko on 4/18/19.
//  Copyright © 2019 Mr.Storm lab. All rights reserved.
//

import Foundation
import ObjectMapper

class CountryDetail: NSObject, Codable, Mappable {
    
    var name: String?
    var alpha2Code: String?
    var region: String?
    var nativeName: String?
    var flag: String?
    var latlng: [Double]?
    var currencies: [Currencies]?
    var languages: [Languages]?
    var borders: [String]?

    init(name: String, alpha2Code: String, region: String, nativeName: String, flag:String?, latlng: [Double], currencies: [Currencies], languages: [Languages]?, borders: [String]?) {
        
        self.name = name
        self.alpha2Code = alpha2Code
        self.region = region
        self.nativeName = nativeName
        self.flag = flag
        self.latlng = latlng
        self.currencies = currencies
        self.languages = languages
        self.borders = borders
    }
        
    
    override init() {
        super.init()
    }
    
    required public init?(map: Map){
        
    }
    
    open func mapping(map: Map) {
        name <- map[CodingKeys.name.value]
        alpha2Code <- map[CodingKeys.alpha2Code.value]
        region <- map[CodingKeys.region.value]
        nativeName <- map[CodingKeys.nativeName.value]
        flag <- map[CodingKeys.flag.value]
        latlng <- map[CodingKeys.latlng.value]
        currencies <- map[CodingKeys.currencies.value]
        languages <- map[CodingKeys.languages.value]
        borders <- map[CodingKeys.borders.value]

    }
}
