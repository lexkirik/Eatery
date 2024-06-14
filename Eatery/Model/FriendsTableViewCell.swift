//
//  FriendsTableViewCell.swift
//  Eatery
//
//  Created by Test on 10.06.24.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {

    // MARK: - Constants
    
    static let identifier = "FriendsTableViewCell"
    
    private let friendName: UILabel = {
        let name = UILabel()
        name.numberOfLines = 1
        return name
    }()
    
    private let friendsRestaurant: UILabel = {
        let restaurant = UILabel()
        restaurant.numberOfLines = 2
        return restaurant
    }()
    
    // MARK: - Functions
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(friendName)
        contentView.addSubview(friendsRestaurant)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        friendName.frame = CGRect(x: 25, y: 0, width: contentView.frame.size.width - 15, height: contentView.frame.size.height)
        friendsRestaurant.frame = CGRect(x: contentView.frame.size.width / 2, y: 0, width: contentView.frame.size.width - 15, height: contentView.frame.size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        friendName.text = nil
        friendsRestaurant.text = nil
    }
    
    public func configure(with model: FriendRestaurantOption) {
        friendName.text = model.friendName
        friendsRestaurant.text = model.friendsRestaurant
    }
}
