//
//  FriendRestaurantOption.swift
//  Eatery
//
//  Created by Test on 12.06.24.
//

import Foundation

struct FriendRestaurantOption: Equatable {
    var friendName = ""
    var restaurant = ""
    var longitude = 0.0
    var latitude = 0.0
    
    init(friendName: String = "", restaurant: String = "", longitude: Double = 0.0, latitude: Double = 0.0) {
        self.friendName = friendName
        self.restaurant = restaurant
        self.longitude = longitude
        self.latitude = latitude
    }
}
