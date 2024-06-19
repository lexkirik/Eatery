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

class SignUpViewController: UIViewController {
    
    // MARK: - Constants
    
    private let labelApp = SignUpElement.setTextLabel(name: "Eatery")
    private let emailTextField = SignUpElement.setTextField(name: "Email")
    private let usernameTextField = SignUpElement.setTextField(name: "Username")
    private let passwordTextField = SignUpElement.setTextField(name: "Password")
    private let signUpButton = SignUpElement.setButton(name: "Sign Up", function: #selector(signUpClicked))
    private let signInButton = SignUpElement.setButton(name: "Sign In", function: #selector(signInClicked))
    
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
            if self.emailTextField.text != "" && self.passwordTextField.text != "" && self.usernameTextField.text != nil {
                CurrentUser.user = self.usernameTextField.text ?? "user"
                Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { authdata, error in
                    
                    if error != nil {
                        self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error!")
                    } else {
                        let destinationVC = ViewController()
                        destinationVC.modalPresentationStyle = .fullScreen
                        destinationVC.modalTransitionStyle = .crossDissolve
                        self.present(destinationVC, animated: true, completion: nil)
                    }
                }
                
            } else {
                self.makeAlert(titleInput: "Error", messageInput: "Missing email/password")
            }
        }
    }
    
    @objc func signInClicked(_ sender: UIButton) {
        sender.showAnimation {
            
            if self.emailTextField.text != "" && self.passwordTextField.text != nil && self.usernameTextField.text != nil {
                CurrentUser.user = self.usernameTextField.text ?? "user"
                Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { authdata, error in
                    
                    if error != nil {
                        self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error!")
                    } else {
                        let destinationVC = ViewController()
                        destinationVC.modalPresentationStyle = .fullScreen
                        destinationVC.modalTransitionStyle = .crossDissolve
                        self.present(destinationVC, animated: true, completion: nil)
                    }
                }
                
            } else {
                self.makeAlert(titleInput: "Error", messageInput: "Missing email/password")
            }
        }
    }
    
    private func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
}

struct CurrentUser {
    static var user = ""
}
