//
//  EateryTests.swift
//  EateryTests
//
//  Created by Test on 22.07.24.
//

import XCTest

@testable import Eatery

final class EateryTests: XCTestCase {

    var userAuthorizer: UserAuthorizer?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        userAuthorizer = UserAuthorizer()
    }

    override func tearDownWithError() throws {
        userAuthorizer = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        let guessEmail = "qwerty@mail.com"
        let guessPassword = "123456789"
        
        userAuthorizer?.signInUser(email: guessEmail, password: guessPassword, completion: { result in
            XCTAssertEqual(SignInResult.success, .error(SignInResult.SignInError.missingSignInData), "Error")
            XCTAssertEqual(SignInResult.success, .error(SignInResult.SignInError.failedSigningInUser), "Error")
            XCTAssertEqual(SignInResult.success, .success, "Success")
        })
    }

    func testPerformanceExample() throws {
        let guessEmail = "qwerty@mail.com"
        let guessPassword = "123456"
        
        measure {
            userAuthorizer?.signInUser(email: guessEmail, password: guessPassword, completion: { result in
                if result == .success {
                    print("success")
                } else {
                    print("error")
                }
            })
        }
    }

}
