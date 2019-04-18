//
//  SearchTVC.swift
//  Atlas
//
//  Created by Andrey Trotsko on 4/18/19.
//  Copyright © 2019 Mr.Storm lab. All rights reserved.
//

import UIKit

final class SearchTVC: UITableViewController {

    private let identifier = "CellCountry"
    private var data:[CountryDetail] = []
    private let searchController = UISearchController(searchResultsController: nil)

    private var localData: Set <Country> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        initCell()
        setupView()
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupView() {
        let countriesArray = Country.getData()

        countriesArray.forEach{ [unowned self] country in
            self.localData.insert(country)
        }
    }

    private func initCell() {
        tableView.register(UINib(nibName: CountryListCell.identifier, bundle: nil), forCellReuseIdentifier: CountryListCell.identifier)
    }
}

// MARK: - Table view data source
extension SearchTVC {

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

extension SearchTVC {
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

extension SearchTVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }

        Services.shared.search(by: text) { [weak self] (data, error) in
            guard let data = data else { return }
            self?.data = data
            self?.tableView.reloadData()
        }
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
