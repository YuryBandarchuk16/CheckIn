//
//  UIViewController+Extension.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 01/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit
import Foundation

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Character {
    func unicodeScalarCodePoint() -> UInt32 {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
}

