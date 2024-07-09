//
//  RestaurantDetail.swift
//  Eatery
//
//  Created by Test on 12.06.24.
//

import UIKit

struct Section {
    let title: String
    let options: [RestaurantDetail]
}

struct RestaurantDetail {
    let icon: UIImage?
    let iconBackgroundColor = UIColor(.blue)
    let detail: String
}
