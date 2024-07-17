//
//  UserAuthorizer.swift
//  Eatery
//
//  Created by Test on 3.07.24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

private enum UserInfoPost {
    static var collectionName = "Users"
    static var username = "username"
    static var userEmail = "userEmail"
}

class UserAuthorizer: UserAuthorizerProtocol {
    
    private let firestoreDatabase = Firestore.firestore()
    private var firestoreReference: DocumentReference? = nil
    
    func signUpUser(email: String, name: String, password: String, completion: @escaping (_ result: SignUpResult) -> ()) {
        if email != "" && name != "" && password != "" {
            
            Auth.auth().createUser(withEmail: email, password: password) { authdata, error in
               
                let firestoreUserInfoPost = [UserInfoPost.username : name, UserInfoPost.userEmail : email]
                
                self.firestoreReference = self.firestoreDatabase.collection(UserInfoPost.collectionName).addDocument(data: firestoreUserInfoPost as [String : Any], completion: { _ in
                    if error != nil {
                        completion(.error(.failedComposingUserInfoPost))
                    }
                })
                
                if error != nil {
                    completion(.error(.failedSigningUpUser))
                } else {
                    CurrentUser.shared.name = name
                    completion(.success)
                }
            }
        } else {
            completion(.error(.missingSignUpData))
        }
    }
    
    func signInUser(email: String, password: String, completion: @escaping (_ result: SignInResult) -> ()) {
        if email != "" && password != "" {
            Auth.auth().signIn(withEmail: email, password: password) { authdata, error in
                if error != nil {
                    completion(.error(.failedSigningInUser))
                } else {
                    self.getCurrentUserName()
                    completion(.success)
                }
            }
        } else {
            completion(.error(.missingSignInData))
        }
    }
    
    func getCurrentUserName() {
        firestoreDatabase.collection(UserInfoPost.collectionName).whereField(UserInfoPost.userEmail, isEqualTo: Auth.auth().currentUser?.email as Any).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "error")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    for document in snapshot!.documents {
                        if let name = document.get(UserInfoPost.username) as? String {
                            CurrentUser.shared.name = name
                        }
                    }
                }
            }
        }
    }
}
