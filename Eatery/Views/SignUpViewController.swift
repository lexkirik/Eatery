//
//  SignUpViewController.swift
//  Eatery
//
//  Created by Test on 31.05.24.
//

import UIKit
import SnapKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    // MARK: - Constants
    
    private let labelApp = SignUpElement.setTextLabel(name: SignUpConstants.appName)
    private let emailTextField = SignUpElement.setTextField(name: SignUpConstants.email)
    private let usernameTextField = SignUpElement.setTextField(name: SignUpConstants.username)
    private let passwordTextField = SignUpElement.setTextField(name: SignUpConstants.password)
    private let signUpButton = SignUpElement.setButton(name: SignUpConstants.signUpButtonName, function: #selector(signUpClicked))
    private let signInButton = SignUpElement.setButton(name: SignUpConstants.signInButtonName, function: #selector(signInClicked))
    private let userAuthorizer = UserAuthorizer()
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setTextFieldsAndButtons()
    }
    
    // MARK: - UIView elements and constraints
    
    private func setTextFieldsAndButtons() {
        let stackFields = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField])
        stackFields.axis = .vertical
        stackFields.spacing = 20
        stackFields.translatesAutoresizingMaskIntoConstraints = true
        stackFields.distribution = .fillEqually
        
        let stackButtons = UIStackView(arrangedSubviews: [signInButton, signUpButton])
        stackButtons.axis = .horizontal
        stackButtons.spacing = 20
        stackButtons.translatesAutoresizingMaskIntoConstraints = true
        stackButtons.distribution = .fillEqually
        
        view.addSubview(stackFields)
        view.addSubview(stackButtons)
        view.addSubview(labelApp)
        
        labelApp.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(stackFields.snp.top).offset(-50)
        }
        
        stackFields.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(200)
            make.trailing.equalToSuperview().offset(-50)
        }
        
        stackButtons.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(stackFields.snp.bottom).offset(20)
            make.trailing.equalTo(stackFields)
            make.leading.equalTo(stackFields)
        }
    }
    
    // MARK: - Sign up / sign in  functions
    
    @objc func signUpClicked(_ sender: UIButton) {
        sender.showAnimation {
            self.userAuthorizer.signUpUser(
                email: self.emailTextField.text!,
                name: self.usernameTextField.text!,
                password: self.passwordTextField.text!
            ) { result in
                if result == .success {
                    self.presentMainViewController()
                }
            }
        }
    }
    
    @objc func signInClicked(_ sender: UIButton) {
        sender.showAnimation {
            self.userAuthorizer.signInUser(
                email: self.emailTextField.text!,
                password: self.passwordTextField.text!
            ) { result in
                if result == .success {
                    self.presentMainViewController()
                }
            }
        }
    }
    
    private func presentMainViewController() {
        let destinationVC = ViewController()
        destinationVC.modalPresentationStyle = .fullScreen
        destinationVC.modalTransitionStyle = .crossDissolve
        self.present(destinationVC, animated: true, completion: nil)
    }
}

private enum SignUpConstants {
    static let appName = "Eatery"
    static let email = "Email"
    static let username = "Username"
    static let password = "Password"
    static let signUpButtonName = "Sign Up"
    static let signInButtonName = "Sign In"
}
