//
//  AuthLogic.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 01/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthLogic {
    
    init () {
    }
    
    private static var sharedObject: AuthLogic?
    
    public static func sharedInstance() -> AuthLogic {
        if let instance = sharedObject {
            return instance
        } else {
            sharedObject = AuthLogic()
            return sharedObject!
        }
    }
    
    public func logInWith(email: String, password: String, returnCallBack: @escaping (_ user: FirebaseAuth.User?, _ error: Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            returnCallBack(user, error)
        }
    }
    
    public func registerWith(email: String, password: String, returnCallBack: @escaping (_ user: FirebaseAuth.User?, _ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            returnCallBack(user, error)
        }
    }
    
}
