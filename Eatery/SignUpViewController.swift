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
    
    // MARK: - Function to set stackViews and constraints
    
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
            if self.emailTextField.text != "" && self.passwordTextField.text != "" {
                
                Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { authdata, error in
                    
                    if error != nil {
                        self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error!")
                    } else {
                        self.present(ViewController(), animated: true, completion: nil)
                    }
                }
                
            } else {
                self.makeAlert(titleInput: "Error", messageInput: "Missing email/password")
            }
        }
    }
    
    @objc func signInClicked(_ sender: UIButton) {
        sender.showAnimation {
            
            if self.emailTextField.text != "" && self.passwordTextField.text != nil {
                
                Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { authdata, error in
                    
                    if error != nil {
                        self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error!")
                    } else {
                        self.present(ViewController(), animated: true, completion: nil)
                    }
                }
                
            } else {
                self.makeAlert(titleInput: "Error", messageInput: "Missing email/password")
            }
        }
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Extension of UIView for animation

public extension UIView {
    func showAnimation(_ completionBlock: @escaping () -> Void) {
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear,
                       animations: { [weak self] in
            self?.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
        }) {  (done) in
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveLinear,
                           animations: { [weak self] in
                self?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { [weak self] (_) in
                self?.isUserInteractionEnabled = true
                completionBlock()
            }
        }
    }
}
