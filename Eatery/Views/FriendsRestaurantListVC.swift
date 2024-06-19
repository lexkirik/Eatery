//
//  FriendsRestaurantListVC.swift
//  Eatery
//
//  Created by Test on 10.06.24.
//

import UIKit
import SnapKit
import FirebaseFirestore

class FriendsRestaurantListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Constants
    
    private var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(FriendsTableViewCell.self, forCellReuseIdentifier: FriendsTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = true
        return table
    }()
    
    private var models = [FriendRestaurantOption]()
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromFirestore()
        
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        setTableViewConstraints()
        view.backgroundColor = .white
    }
    
    // MARK: - TableView functions
    
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
    
    private func getDataFromFirestore() {
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("Restaurants").addSnapshotListener { snapshot, error in
            
            if error != nil {
                print(error?.localizedDescription ?? "error")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    for document in snapshot!.documents {
                        
                        if let name = document.get("friendName") as? String, let rest = document.get("restaurant") as? String {
                            FriendsInRestaurantNow.friends.append(name)
                            FriendsInRestaurantNow.restauraunts.append(rest)
                        }
                    }
                    var number = 0
                    repeat {
                        self.models.append(
                            FriendRestaurantOption(
                                name: FriendsInRestaurantNow.friends[number],
                                restaurant: FriendsInRestaurantNow.restauraunts[number]
                            )
                        )
                        number += 1
                    } while number < FriendsInRestaurantNow.friends.count
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
}

