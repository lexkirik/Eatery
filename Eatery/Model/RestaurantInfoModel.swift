//
//  RestaurantInfoModel.swift
//  Eatery
//
//  Created by Test on 11.06.24.
//

import Foundation
import GooglePlaces

class RestaurantInfoModel {
    var name = ""
    var description = ""
    var rating = ""
    var priceLevel = 0
    var address = ""
    var website = ""
    var phoneNumber = ""
    var url = URL(string: "")
    var openingHoursArray = [""]
    var coordinate = CLLocationCoordinate2D()
    
    static var shared = RestaurantInfoModel()
    
    init(name: String = "", description: String = "", rating: String = "", priceLevel: Int = 0, address: String = "", website: String = "", phoneNumber: String = "", url: URL? = nil, openingHoursArray: [String] = [""], coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()) {
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
