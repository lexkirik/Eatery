//
//  CurrentUser.swift
//  Eatery
//
//  Created by Test on 20.06.24.
//

import Foundation

class CurrentUser {
    static let shared = CurrentUser()
    var name = ""
    
    init(name: String = "") {
        self.name = name
    }
}
