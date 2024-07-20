//
//  FriendRestaurantOption.swift
//  Eatery
//
//  Created by Test on 12.06.24.
//

import Foundation

struct FriendRestaurantOption: Equatable {
    let friendName: String
    let restaurant: String
    let longitude: Double
    let latitude: Double
    
    init(friendName: String, restaurant: String, longitude: Double, latitude: Double) {
        self.friendName = friendName
        self.restaurant = restaurant
        self.longitude = longitude
        self.latitude = latitude
    }
}
