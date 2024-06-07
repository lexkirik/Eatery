//
//  SignUpField.swift
//  Eatery
//
//  Created by Test on 31.05.24.
//

import UIKit

class SignUpElement {
    
    static func setTextLabel(name: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = true
        label.text = name
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }
    
    static func setTextField(name: String) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = true
        textField.placeholder = name
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0, alpha: 0.1)
        return textField
    }
    
    static func setButton(name: String, function: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(name, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.layer.cornerRadius = 3
        button.backgroundColor = .blue
        button.addTarget(nil, action: function, for: .touchUpInside)
        return button
    }
}
