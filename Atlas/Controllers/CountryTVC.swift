//
//  CountryTVC.swift
//  Atlas
//
//  Created by Andrey Trotsko on 4/18/19.
//  Copyright © 2019 Mr.Storm lab. All rights reserved.
//

import UIKit

final class CountryTVC: UITableViewController {

    private let identifier = "CellCountry"

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Table view data source
extension CountryTVC {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Regions.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        cell.textLabel?.text = Regions.allCases[indexPath.row].rawValue.capitalized
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

// MARK: - Table view delegate
extension CountryTVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: Identifiers.Storyboard.main, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: Identifiers.Controller.countriesByRegion) as! CountyListTVC
        controller.region = Regions.allCases[indexPath.row].rawValue
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

private struct Identifiers {
    enum Storyboard {
        static let main = "Main"
    }
    enum Controller {
        static let countriesByRegion = "CountyListTVC"
    }
}
