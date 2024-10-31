//
//  RestaurantInfoModel.swift
//  Eatery
//
//  Created by Test on 11.06.24.
//

import Foundation
import GooglePlaces

struct RestaurantInfoModel {
    let name: String
    let description: String
    let rating: String
    let priceLevel: Int
    let address: String
    let website: String
    let phoneNumber: String
    let url: URL?
    let openingHoursArray: [String]
    let coordinate: CLLocationCoordinate2D
    
    init(name: String, description: String, rating: String, priceLevel: Int, address: String, website: String, phoneNumber: String, url: URL? = nil, openingHoursArray: [String], coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.description = description
        self.rating = rating
        self.priceLevel = priceLevel
        self.address = address
        self.website = website
        self.phoneNumber = phoneNumber
        self.url = url
        self.openingHoursArray = openingHoursArray
        self.coordinate = coordinate
    }
}
