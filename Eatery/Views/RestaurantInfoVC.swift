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
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = true
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 3
        return label
    }()
    
    private let summaryLabel: UILabel = {
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
    
    private let buttonGoingToRestaurant: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.backgroundColor = .systemBlue
        button.setTitle(RestaurantInfoConstants.buttonGoingToRestaurantTitle, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(nil, action: #selector(addRestaurauntToList), for: .touchUpInside)
        return button
    }()
    
    private let ratingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: RestaurantInfoConstants.ratingImageName)
        return imageView
    }()
    
    private let ratingNumberLabel: UILabel = {
       let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = true
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private let priceLevelLabel: UILabel = {
       let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = true
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private var models = [Section]()
    private var imageForOpeningHours = UIImage(systemName: RestaurantInfoConstants.openingHoursImageName)
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(nameLabel)
        view.addSubview(summaryLabel)
        view.addSubview(buttonGoingToRestaurant)
        view.addSubview(ratingImageView)
        view.addSubview(ratingNumberLabel)
        view.addSubview(priceLevelLabel)
        nameLabel.text = RestaurantInfoModel.name
        summaryLabel.text = RestaurantInfoModel.description
        ratingNumberLabel.text = RestaurantInfoModel.rating
        priceLevelToDollarSymbol()
        
        setConstraints()
        view.backgroundColor = .white
    }
    
    // MARK: - TableView functions
    
    private func configure() {
        var openingHoursArray = [RestaurantDetail]()
        for num in 0...RestaurantInfoModel.openingHoursArray.count - 1 {
            openingHoursArray.append(RestaurantDetail(icon: imageForOpeningHours, detail: RestaurantInfoModel.openingHoursArray[num]))
        }
        models.append(Section(title: RestaurantInfoConstants.openingHoursTitle, options: openingHoursArray))
        
        models.append(Section(title: RestaurantInfoConstants.contactsTitle, options: [
            RestaurantDetail(
                icon: UIImage(systemName: RestaurantInfoConstants.addressImageName),
                detail: RestaurantInfoModel.address
            ),
            RestaurantDetail(
                icon: UIImage(systemName: RestaurantInfoConstants.websiteImageName),
                detail: RestaurantInfoModel.website
            ),
            RestaurantDetail(
                icon: UIImage(systemName: RestaurantInfoConstants.phoneNumberImageName),
                detail: RestaurantInfoModel.phoneNumber
            )
        ]))
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = models[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantInfoCell.identifier, for: indexPath) as? RestaurantInfoCell else {
            return UITableViewCell()
        }
        cell.configureRestaurantInfoCell(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            if let url = RestaurantInfoModel.url {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @objc private func addRestaurauntToList(_ sender: UIButton) {
        sender.showAnimation {
            let restaurantInfoPostMaker = RestaurantInfoPostMaker()
            restaurantInfoPostMaker.addRestaurauntInfoPost()
        }
    }
    
    private func priceLevelToDollarSymbol() {
        let level = RestaurantInfoModel.priceLevel
        
        switch level {
        case 1:
            priceLevelLabel.text = RestaurantInfoConstants.priceLevelLow
        case 2:
            priceLevelLabel.text = RestaurantInfoConstants.priceLevelMedium
        case 3:
            priceLevelLabel.text = RestaurantInfoConstants.priceLevelMediumHigh
        case 4:
            priceLevelLabel.text = RestaurantInfoConstants.priceLevelHigh
        default:
            priceLevelLabel.text = ""
        }
    }
    
    // MARK: - Constraints
    
    private func setConstraints() {
        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(buttonGoingToRestaurant.snp.bottom).offset(10)
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
        }
        
        summaryLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().offset(-25)
        }
        
        ratingImageView.snp.makeConstraints { make in
            make.top.equalTo(summaryLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(25)
            make.height.equalTo(20)
            make.width.equalTo(20)
        }
        
        ratingNumberLabel.snp.makeConstraints { make in
            make.bottom.equalTo(ratingImageView.snp.bottom)
            make.leading.equalTo(ratingImageView.snp.trailing).offset(10)
        }
        
        priceLevelLabel.snp.makeConstraints { make in
            make.bottom.equalTo(ratingNumberLabel.snp.bottom)
            make.leading.equalTo(ratingNumberLabel.snp.trailing).offset(20)
        }
        
        buttonGoingToRestaurant.snp.makeConstraints { make in
            make.bottom.equalTo(ratingNumberLabel.snp.bottom).offset(5)
            make.trailing.equalToSuperview().offset(-25)
            make.width.equalTo(200)
            make.height.equalTo(30)
        }
    }
}

private enum RestaurantInfoConstants {
    static let buttonGoingToRestaurantTitle = "I'm going to this place"
    static let ratingImageName = "star.fill"
    static let openingHoursImageName = "clock.fill"
    static let openingHoursTitle = "Opening hours"
    static let contactsTitle = "Contacts"
    static let addressImageName = "mappin.and.ellipse"
    static let websiteImageName = "globe.europe.africa.fill"
    static let phoneNumberImageName = "phone.fill"
    static let priceLevelLow = "$"
    static let priceLevelMedium = "$$"
    static let priceLevelMediumHigh = "$$$"
    static let priceLevelHigh = "$$$$"
}
