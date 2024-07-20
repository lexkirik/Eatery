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
    static func == (lhs: DataFromRestaurantInfoPost, rhs: DataFromRestaurantInfoPost) -> Bool {
            switch(lhs, rhs) {
            case (.error, .error): 
                return true
            case (.error, .success), (.success, .error): 
                return false
            case(let .success(var1), let .success(var2)): 
                return var1 == var2
            }
        }

        var option: FriendRestaurantOption? {
            switch self {
            case let .success(option): 
                return option
            case .error: 
                return nil
            }
        }
    
    case success (FriendRestaurantOption)
    case error
}
