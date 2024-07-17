//
//  RestaurantInfoPostMakerProtocol.swift
//  Eatery
//
//  Created by Test on 4.07.24.
//

import Foundation

protocol RestaurantInfoPostMakerProtocol {
    func addRestaurauntInfoPost(name: String, latitude: Double, longitude: Double)
    func getDataFromRestaurantInfoPostForLast12Hours(completion: @escaping (_ result: DataFromRestaurantInfoPost) -> ())
}

enum DataFromRestaurantInfoPost: Error, Equatable {
    case success
    case error
}
