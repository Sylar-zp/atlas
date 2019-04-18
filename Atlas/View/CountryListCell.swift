//
//  CountryListCell.swift
//  Atlas
//
//  Created by Andrey Trotsko on 4/18/19.
//  Copyright © 2019 Mr.Storm lab. All rights reserved.
//

import UIKit
import SDWebImage

final class CountryListCell: UITableViewCell {

    @IBOutlet private weak var countryImageView: UIImageView!
    @IBOutlet private weak var countryFlagEmoji: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var nativeNameLabel: UILabel!

    func fill(by country: CountryDetail, flag: String) {

        //For load SVG image
        //countryImageView.sd_setImage(with: URL(string: country.flag ?? ""))

        countryFlagEmoji.text = flag
        nameLabel.text = country.name
        nativeNameLabel.text = country.nativeName
    }
}
