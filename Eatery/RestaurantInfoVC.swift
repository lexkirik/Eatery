//
//  RestaurantInfoVC.swift
//  Eatery
//
//  Created by Test on 11.06.24.
//

import UIKit
import GoogleMaps
import SnapKit

class RestaurantInfoVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Constants
    
    private let name: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = true
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 3
        return label
    }()
    
    private let summary: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = true
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 4
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(RestaurantInfoCell.self, forCellReuseIdentifier: RestaurantInfoCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = true
        return table
    }()
    
    private var models = [RestaurantDetail]()
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(name)
        view.addSubview(summary)
        setConstraints()
        name.text = RestaurantInfoModel.name
        summary.text = RestaurantInfoModel.description
        view.backgroundColor = .white
    }
    
    // MARK: - TableView functions
    
    private func configure() {
        models.append(RestaurantDetail(
            icon: UIImage(systemName: "star.fill"),
            detail: RestaurantInfoModel.rating))
        models.append(RestaurantDetail(
            icon: UIImage(systemName: "dollarsign"),
            detail: RestaurantInfoModel.priceLevel))
        models.append(RestaurantDetail(
            icon: UIImage(systemName: "mappin.and.ellipse"),
            detail: RestaurantInfoModel.address))
        models.append(RestaurantDetail(
            icon: UIImage(systemName: "clock.fill"),
            detail: RestaurantInfoModel.openingHours))
        models.append(RestaurantDetail(
            icon: UIImage(systemName: "globe.europe.africa.fill"),
            detail: RestaurantInfoModel.website))
        models.append(RestaurantDetail(
            icon: UIImage(systemName: "phone.fill"),
            detail: RestaurantInfoModel.phoneNumber))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.item]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantInfoCell.identifier, for: indexPath) as? RestaurantInfoCell else {
            return UITableViewCell()
        }
        cell.configureRestaurantInfoCell(with: model)
        return cell
    }
    
    // MARK: - Constraints
    
    private func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(summary.snp.bottom).offset(30)
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        name.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(50)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
        }
        
        summary.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(name.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().offset(-50)
        }
    }
}
