//
//  Utils.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 01/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class Utils {
    
    private static var currentUserId: String = "###"
    private static var isAdmin: Bool = false
    
    private static var currentUsername: String!
    
    public static let months: [String] = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    ]
    
    private static var currentStudentClass: String?
    private static var currentStudentClassRef: DocumentReference?
    
    public static func setCurrentStudentClass(className: String?) {
        Utils.currentStudentClass = className
    }
    
    public static func getCurrentStudentClassName() -> String? {
        return Utils.currentStudentClass
    }
    
    public static func setCurrentStudentClassRef(ref: DocumentReference?) {
        Utils.currentStudentClassRef = ref
    }
    
    public static func getCurrentStudentClassRef() -> DocumentReference? {
        return Utils.currentStudentClassRef
    }
    
    public static func resetCurrentStudentClass() {
        Utils.currentStudentClass = nil
        Utils.currentStudentClassRef = nil
    }
    
    public static func setUsername(name: String) {
        Utils.currentUsername = name
    }
    
    public static func getUsername() -> String {
        return Utils.currentUsername
    }
    
    public static func getUserTodayResponseName() -> String {
        return Utils.currentUsername + "_" + Utils.getCurrentDateStringWithoutSpaces()
    }
    
    public static func getCurrentDate(date: Date) -> (year: String, month: String, day: String) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let day = Utils.convertIntegerToDay(components.day!)
        let monthName = Utils.months[components.month! - 1]
        let year = components.year!
        return (year: String(year), month: String(monthName), day: String(day))
    }
    
    public static func getAnyDateString(date: Date) -> String {
        let currentDate = Utils.getCurrentDate(date: date)
        let year = currentDate.year
        let month = currentDate.month
        let day = currentDate.day
        let result = "\(day) \(month) \(year)"
        return result
    }
    
    public static func getCurrentDateString() -> String {
        let currentDate = Utils.getCurrentDate(date: Date())
        let year = currentDate.year
        let month = currentDate.month
        let day = currentDate.day
        let result = "\(day) \(month) \(year)"
        return result
    }
    
    public static func getCurrentDateStringWithoutSpaces() -> String {
        let currentDate = Utils.getCurrentDate(date: Date())
        let year = currentDate.year
        let month = currentDate.month
        let day = currentDate.day
        let result = "\(day)\(month)\(year)"
        return result
    }
    
    public static func convertIntegerToDay(_ integer: Int) -> String {
        if integer < 10 {
            return "0\(integer)"
        }
        return "\(integer)"
    }
    
    public static func setUserId(id: String) {
        Utils.currentUserId = id
    }
    
    public static func getUserId() -> String {
        return Utils.currentUserId
    }
    
    public static func makeCurrentUserAdmin() {
        Utils.isAdmin = true
    }
    
    public static func makeCurrentUserNonAdmin() {
        Utils.isAdmin = false
    }
    
    public static func isCurrentUserAdmin() -> Bool {
        return Utils.isAdmin
    }
    
    public static func isValidEmail(email: String?) -> Bool {
        guard let email = email else {
            return false
        }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    public static func showAlertOnError(title: String, text: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .default) { (alert) in
        }
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
