//
//  LoginController.swift
//  Instagram
//
//  Created by AHMED on 1/22/20.
//  Copyright © 2020 AHMED. All rights reserved.
//

import UIKit
import Firebase
class LoginController:UIViewController {
    let dontHaveAccountButton:UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.lightGray])
        button.setAttributedTitle(attributedTitle, for: .normal)
        attributedTitle.append(NSAttributedString(string: " Sign Up", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.rgb(red: 17, green: 154, blue: 237 )]))
        button.addTarget(self, action: #selector(handleDontHaveAccount), for: .touchUpInside)
        return button
    }()
    let loadingIndicator:UIActivityIndicatorView = {
       let LI = UIActivityIndicatorView()
        LI.tintColor = .gray
        return LI
    }()
    @objc func handleDontHaveAccount() {
        let SignUpController = signUpController()
        navigationController?.pushViewController(SignUpController,animated:true)
    }
    let logoContainerView :UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 0, green: 120, blue: 175)
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)]
            )
            logoImageView.translatesAutoresizingMaskIntoConstraints = false
            
            return view
    }()
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text!.count > 0 && passwordTextField.text!.count > 0
        if isFormValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            
        }
        else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    let loginButton :UIButton = {
          let button = UIButton(type: .system)
          button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
          button.layer.cornerRadius = 5
          button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
          button.setTitleColor(.white, for: .normal)
          button.setTitle("Login", for: .normal)
          button.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
          button.isEnabled = false
          return button
      }()
    @objc func handleLogIn() {
        loadingIndicator.startAnimating()
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if let err = err {
                print ("Failed to singin",err)
                return
            }
            print("Successfully logged in with user",Auth.auth().currentUser?.uid ?? "")
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
            mainTabBarController.setupViewControllers()
            mainTabBarController.tabBar.isHidden = false
            self.dismiss(animated: true, completion: nil)
            self.loadingIndicator.stopAnimating()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
        view.addSubview(dontHaveAccountButton)
        view.addSubview(logoContainerView)
        hideKeyboardWhenTappedAround()
        dontHaveAccountButton.setAnchor(top: nil, left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, paddingBottom: 10, paddingLeft: 0, paddingRight: 0, paddingTop: 0, height: 0, width: 0)
        logoContainerView .setAnchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 0, height: 150, width: 0)
       
        setupInputFields()
    }
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.setAnchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingBottom: 0, paddingLeft: 40, paddingRight: 40, paddingTop: 40, height: 140, width: 0)
        view.addSubview(loadingIndicator)
        loadingIndicator.setAnchor(top: stackView.bottomAnchor, left: nil, right: nil, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 20, height: 100, width: 100)
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

