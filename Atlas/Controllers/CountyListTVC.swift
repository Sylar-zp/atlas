//
//  CountyListTVC.swift
//  Atlas
//
//  Created by Andrey Trotsko on 4/18/19.
//  Copyright © 2019 Mr.Storm lab. All rights reserved.
//

import UIKit

final class CountyListTVC: UITableViewController {

    var region: String = ""

    private var data:[CountryDetail] = []
    private let identifier = "CellCountry"
    private var localData: Set <Country> = []

    private lazy var activityIndicator: UIActivityIndicatorView = {

        let indicator = UIActivityIndicatorView(frame: CGRect.zero)
        indicator.center = navigationController?.view.center ?? view.center
        indicator.hidesWhenStopped = true
        indicator.style = .gray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        func createConstraint(toView: UIView, attr: NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
            return NSLayoutConstraint(item: indicator,
                                      attribute: attr,
                                      relatedBy: .equal,
                                      toItem: toView,
                                      attribute: attr,
                                      multiplier: 1,
                                      constant: 0)
        }

        if navigationController == nil {
            view.addSubview(indicator)
            let xConstraint = createConstraint(toView: view, attr: .centerX)
            let yConstraint = createConstraint(toView: view, attr: .centerY)
            view.addConstraint(xConstraint)
            view.addConstraint(yConstraint)
            xConstraint.isActive = true
            yConstraint.isActive = true
        } else {
            navigationController?.view.addSubview(indicator)
            let xConstraint = createConstraint(toView: navigationController!.view, attr: .centerX)
            let yConstraint = createConstraint(toView: navigationController!.view, attr: .centerY)
            navigationController?.view.addConstraints([xConstraint, yConstraint])
            xConstraint.isActive = true
            yConstraint.isActive = true
        }

        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        initCell()
        navigationItem.title = region.capitalized
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.activityIndicator.stopAnimating()
    }

    private func initCell(){
        tableView.register(UINib(nibName: CountryListCell.identifier, bundle: nil), forCellReuseIdentifier: CountryListCell.identifier)
    }

    private func fetchData(){
        activityIndicator.startAnimating()

        let countriesArray = Country.getData()

        countriesArray.forEach{ [unowned self] country in
            self.localData.insert(country)
        }

        Services.shared.fetchCountries(by: region) { [weak self] (data, error) in
            self?.data = data ?? []
            self?.tableView.reloadData()
            self?.activityIndicator.stopAnimating()
        }
    }
}

// MARK: - Table view data source

extension CountyListTVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.data[indexPath.row]
        let flag = self.localData.filter {$0.code == data.alpha2Code }.first?.emoji ?? ""

        let cell = tableView.dequeueReusableCell(withIdentifier: CountryListCell.identifier, for: indexPath) as! CountryListCell
        cell.fill(by: data, flag: flag)

        return cell
    }
}

// MARK: - Table view delegate

extension CountyListTVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.data[indexPath.row]
        let flag = self.localData.filter {$0.code == data.alpha2Code }.first?.emoji ?? ""

        let storyboard = UIStoryboard(name: Identifiers.Storyboard.main, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: Identifiers.Controller.country) as! CountryDetailVC
        controller.flag = flag
        controller.data = data
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

private struct Identifiers {
    enum Storyboard {
        static let main = "Main"
    }
    enum Controller {
        static let country = "CountryDetailVC"
    }
}
