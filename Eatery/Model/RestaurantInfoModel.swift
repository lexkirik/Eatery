//
//  RestaurantInfoModel.swift
//  Eatery
//
//  Created by Test on 11.06.24.
//

import Foundation
import GooglePlaces

struct RestaurantInfoModel {
    static var name = ""
    static var description = ""
    static var rating = ""
    static var priceLevel = 0
    static var address = ""
    static var website = ""
    static var phoneNumber = ""
    static var url = URL(string: "")
    static var openingHoursArray = [String]()
    static var coordinate = CLLocationCoordinate2D()
    
    init(place: GMSPlace) {
        RestaurantInfoModel.name = place.name ?? "no information"
        RestaurantInfoModel.address = place.formattedAddress ?? "no information"
        RestaurantInfoModel.website = place.website?.description ?? "no information"
        RestaurantInfoModel.phoneNumber = place.phoneNumber ?? "no information"
        RestaurantInfoModel.description = place.editorialSummary ?? ""
        RestaurantInfoModel.priceLevel = place.priceLevel.rawValue
        RestaurantInfoModel.rating = place.rating.description
        RestaurantInfoModel.url = place.website
        RestaurantInfoModel.openingHoursArray = place.openingHours?.weekdayText ?? [""]
        RestaurantInfoModel.coordinate = place.coordinate
    }
}
