//
//  UserAuthorizerProtocol.swift
//  Eatery
//
//  Created by Test on 3.07.24.
//

import Foundation

protocol UserAuthorizerProtocol {
    func signUpUser(email: String, name: String, password: String, completion: @escaping (_ result: SignUpResult) -> ())
    func signInUser(email: String, password: String, completion: @escaping (_ result: SignInResult) -> ())
}

enum SignUpResult: Error, Equatable {
    case success
    case error (SignUpError)
    
    enum SignUpError: LocalizedError {
        case failedComposingUserInfoPost
        case failedSigningUpUser
        case missingSignUpData
        
        var errorDescription: String {
            switch self {
            case .failedComposingUserInfoPost:
                return NSLocalizedString("Failed to compose a post", comment: "Failed to compose a post with user info in Firestore")
            case .failedSigningUpUser:
                return NSLocalizedString("Failed to sign up a user", comment: "Failed to sign up a user in Firebase")
            case .missingSignUpData:
                return NSLocalizedString("Missing sign-up data", comment: "Missing email, name or password")
            }
        }
    }
}

enum SignInResult: Error, Equatable {
    case success
    case error (SignInError)
    
    enum SignInError: LocalizedError {
        case failedSigningInUser
        case missingSignInData
        
        var errorDescription: String {
            switch self {
            case .failedSigningInUser:
                return NSLocalizedString("Failed to sign in a user", comment: "Failed to sign in a user in Firebase")
            case .missingSignInData:
                return NSLocalizedString("Missing sign-in data", comment: "Missing email or password")
            }
        }
    }
}
