//
//  CountryDetailVC.swift
//  Atlas
//
//  Created by Andrey Trotsko on 4/18/19.
//  Copyright © 2019 Mr.Storm lab. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

final class CountryDetailVC: UIViewController {

    @IBOutlet private weak var countryImageView: UIImageView!
    @IBOutlet private weak var countryImageLabel: UILabel!
    @IBOutlet private weak var currenciesIco: UIImageView!
    @IBOutlet private weak var languageIco: UIImageView!
    @IBOutlet private weak var currenciesLabel: UILabel!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet private weak var map: MKMapView!
    @IBOutlet private weak var tableView: UITableView!

    private var borderData: [CountryDetail] = []

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

    var data: CountryDetail = CountryDetail()
    var flag: String = ""

    private var localData: Set <Country> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()

    }

    private func setupData() {
        cleanData()
        setupView()
        initCell()
        setupMap()
        fetchBorder(codes: data.borders ?? [])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.activityIndicator.stopAnimating()
    }

    private func setupView() {

        navigationItem.title = data.name

        languageLabel.text = data.languages?.compactMap{$0.name}.joined(separator: ",")
        currenciesLabel.text = data.currencies?.compactMap{$0.name}.joined(separator: ",")
        countryImageLabel.text = flag

        ////For load SVG image
        //countryImageView.sd_setImage(with: URL(string: country.flag ?? ""))
    }

    private func initCell() {
        tableView.register(UINib(nibName: CountryListCell.identifier, bundle: nil), forCellReuseIdentifier: CountryListCell.identifier)
    }

    private func fetchBorder (codes:[String]) {
        activityIndicator.startAnimating()

        let countriesArray = Country.getData()

        countriesArray.forEach{ [unowned self] country in
            self.localData.insert(country)
        }

        let group = DispatchGroup()
        codes.forEach { (code) in
            group.enter()
            Services.shared.fetchCountry(by: code, returnObject: { [weak self] (data, error) in
                guard let data = data else {
                    group.leave()
                    return
                }

                self?.borderData.append(data)
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.tableView.reloadData()
        }
    }

    private func cleanData() {
        borderData = []
        map.removeAnnotations(map.annotations)
    }
}

// MARK: - MKMapView delegate

extension CountryDetailVC: MKMapViewDelegate {
    private func setupMap() {

        let latDelta:CLLocationDegrees = 7.0
        let longDelta:CLLocationDegrees = 7.0

        let theSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let pointLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(data.latlng?.first ?? 0, data.latlng?.last ?? 0)

        let region:MKCoordinateRegion = MKCoordinateRegion(center: pointLocation, span: theSpan)
        map.setRegion(region, animated: true)

        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(data.latlng?.first ?? 0, data.latlng?.last ?? 0)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = data.name
        map.addAnnotation(objectAnnotation)
    }
}

// MARK: - Table view data source

extension CountryDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return borderData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.borderData[indexPath.row]
        let flag = self.localData.filter {$0.code == data.alpha2Code }.first?.emoji ?? ""

        let cell = tableView.dequeueReusableCell(withIdentifier: CountryListCell.identifier, for: indexPath) as! CountryListCell
        cell.fill(by: data, flag: flag)

        return cell
    }
}

// MARK: - Table view delegate

extension CountryDetailVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard borderData.count < indexPath.row else { return }

        data = borderData[indexPath.row]
        flag = localData.filter {$0.code == data.alpha2Code }.first?.emoji ?? ""

        setupData()
    }
}
