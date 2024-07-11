//
//  RestaurantInfoPostMaker.swift
//  Eatery
//
//  Created by Test on 4.07.24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class RestaurantInfoPostMaker: RestaurantInfoPostMakerProtocol {
    private let firestoreDatabase = Firestore.firestore()
    private var firestoreReference: DocumentReference? = nil
    private let timeNow = Date().timeIntervalSince1970
    
    func addRestaurauntInfoPost() {
        
        let firestorePost = [
            RestaurantInfoPost.friendEmail : Auth.auth().currentUser?.email ?? "email",
            RestaurantInfoPost.friendName : CurrentUser.shared.username,
            RestaurantInfoPost.restaurant : RestaurantInfoModel.shared.name,
            RestaurantInfoPost.date : timeNow,
            RestaurantInfoPost.latitude : RestaurantInfoModel.shared.coordinate.latitude,
            RestaurantInfoPost.longitude : RestaurantInfoModel.shared.coordinate.longitude
        ] as [String : Any]
        
        firestoreReference = firestoreDatabase.collection(RestaurantInfoPost.collectionName).addDocument(data: firestorePost, completion: { (error) in
            if error != nil {
                print(error?.localizedDescription ?? "error")
            }
        })
    }
    
    func getDataFromRestaurantInfoPostForLast12Hours(completion: @escaping (_ result: DataFromRestaurantInfoPost) -> ()) {
        let time12HoursBeforeNow = timeNow - 12 * 60 * 60
        
        firestoreDatabase.collection(RestaurantInfoPost.collectionName).whereField(RestaurantInfoPost.date, isGreaterThan: time12HoursBeforeNow).addSnapshotListener { snapshot, error in
            if error != nil {
                completion(.error)
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    for document in snapshot!.documents {
                        if let name = document.get(RestaurantInfoPost.friendName) as? String, let rest = document.get(RestaurantInfoPost.restaurant) as? String {
                            if name != CurrentUser.shared.username {
                                if let longitude = document.get(RestaurantInfoPost.longitude) as? Double, let latitude = document.get(RestaurantInfoPost.latitude) as? Double {
                                    FriendRestaurantOption.shared = FriendRestaurantOption(
                                        friendName: name,
                                        restaurant: rest,
                                        longitude: longitude,
                                        latitude: latitude
                                    )
                                    completion(.success)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private enum RestaurantInfoPost {
    static var collectionName = "Restaurants"
    static var friendEmail = "friendEmail"
    static var friendName = "friendName"
    static var restaurant = "restaurant"
    static var date = "date"
    static var latitude = "latitude"
    static var longitude = "longitude"
}
