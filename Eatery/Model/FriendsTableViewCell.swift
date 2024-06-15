//
//  FriendsTableViewCell.swift
//  Eatery
//
//  Created by Test on 10.06.24.
//

import UIKit
import SnapKit

class FriendsTableViewCell: UITableViewCell {

    // MARK: - Constants
    
    static let identifier = "FriendsTableViewCell"
    
    private let friendNameLabel: UILabel = {
        let name = UILabel()
        name.numberOfLines = 1
        return name
    }()
    
    private let friendsRestaurantLabel: UILabel = {
        let restaurant = UILabel()
        restaurant.numberOfLines = 2
        return restaurant
    }()
    
    // MARK: - Functions
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(friendNameLabel)
        contentView.addSubview(friendsRestaurantLabel)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setConstraints() {
        friendNameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(50)
            make.width.equalTo(contentView.frame.width / 3)
        }
        
        friendsRestaurantLabel.snp.makeConstraints { make in
            make.top.equalTo(friendNameLabel.snp.top)
            make.leading.equalTo(friendNameLabel.snp.trailing).offset(10)
            make.height.equalTo(50)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        friendNameLabel.text = nil
        friendsRestaurantLabel.text = nil
    }
    
    func configure(with model: FriendRestaurantOption) {
        friendNameLabel.text = model.name
        friendsRestaurantLabel.text = model.restaurant
    }
}
