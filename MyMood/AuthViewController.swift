//
//  ViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 01/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit
import FirebaseAuth
import MBProgressHUD

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func updateErrorDescription(description: String) -> String {
        if description.contains("no user") {
            let result = "There is no user record corresponding to this identifier. Check username and password and try again."
            return result
        }
        return description
    }

    @IBAction func signInButtonClicked(_ sender: UIButton) {
        let email = (usernameTextField.text ?? "") + "@mymoodapp.com"
        let password = (passwordTextField.text ?? "")
        if (!Utils.isValidEmail(email: email)) {
            Utils.showAlertOnError(title: "Incorrect username", text: "The username you entered contains error, please, try again.", viewController: self)
            return
        }
        let auth = AuthLogic.sharedInstance()
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        auth.logInWith(email: email, password: password) { (user, error) in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            if let error = error {
                let message = self.updateErrorDescription(description: error.localizedDescription)
                Utils.showAlertOnError(title: "Error", text: message, viewController: self)
            } else {
                if let user = user {
                    Utils.showAlertOnError(title: "Success", text: "User id is \(user.uid)", viewController: self)
                }
            }
        }
    }
    
}

