//
//  FriendsRestaurantListVC.swift
//  Eatery
//
//  Created by Test on 10.06.24.
//

import UIKit
import SnapKit

class FriendsRestaurantListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Constants
    
    private var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(FriendsTableViewCell.self, forCellReuseIdentifier: FriendsTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = true
        return table
    }()
    private var models = [FriendRestaurantOption]()
    private var friendsArray = ["Fred", "Bob", "Anna", "Emily"]
    private var restaurantArray = ["Restaurant 1", "Restaurant 2", "Restaurant 3", "Restaurant 4"]
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        setTableViewConstraints()
        view.backgroundColor = .white
    }
    
    // MARK: - TableView functions
    
    private func configure() {
        for number in 0...(friendsArray.count - 1) {
            models.append(FriendRestaurantOption(friendName: friendsArray[number], friendsRestaurant: restaurantArray[number]))
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendsTableViewCell.identifier, for: indexPath) as? FriendsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: model)
        return cell
    }
    
    private func setTableViewConstraints() {
        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
}
