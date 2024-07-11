//
//  RestaurantInfoPostMakerProtocol.swift
//  Eatery
//
//  Created by Test on 4.07.24.
//

import Foundation

protocol RestaurantInfoPostMakerProtocol {
    func addRestaurauntInfoPost()
    func getDataFromRestaurantInfoPostForLast12Hours(completion: @escaping (_ result: DataFromRestaurantInfoPost) -> ())
}

enum DataFromRestaurantInfoPost: Error, Equatable {
    case success
    case error
    
    var restarauntInfo: Any {
        switch self {
        case .success:
            return FriendRestaurantOption()
        case .error:
            print("error")
        }
        return self
    }
}
