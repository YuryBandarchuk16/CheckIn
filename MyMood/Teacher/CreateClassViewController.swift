//
//  CreateClassViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 19/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class CreateClassViewController: UIViewController {

    
    @IBOutlet weak var classNameTextField: UITextField!
    
    @IBOutlet weak var classCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func hideProgressBar() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    private func showProgressBar() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }

    @IBAction func createClassButtonClicked(_ sender: UIButton) {
        if let className = classNameTextField.text,
            let classCode = classCodeTextField.text {
            if className.characters.count == 0 {
                Utils.showAlertOnError(title: "Error", text: "Class Name can not be empty.", viewController: self)
            }
            if classCode.characters.count < 6 {
                Utils.showAlertOnError(title: "Error", text: "Class Code should be at least 6 characters.", viewController: self)
                return
            }
            showProgressBar()
            let storage = Firestore.firestore()
            storage.collection("classes").whereField("class_code", isEqualTo: classCode).limit(to: 1).getDocuments(completion: { (snapshot, error) in
                if error != nil {
                    self.hideProgressBar()
                    Utils.showAlertOnError(title: "Error", text: "Unable to make sure that class code is unique.\nPlease, try again later.", viewController: self)
                } else {
                    let documentsCount = snapshot!.documents.count
                    if documentsCount > 0 {
                        print("FAIL!")
                        self.hideProgressBar()
                        Utils.showAlertOnError(title: "Error", text: "The class with such class code has been already created.\nPlease, choose another class code.", viewController: self)
                    } else {
                        var classRef: DocumentReference!
                        classRef = storage.collection("classes").addDocument(data: [
                            "class_code": classCode,
                            "class_name": className
                        ])  { err in
                            if err != nil {
                                self.hideProgressBar()
                                Utils.showAlertOnError(title: "Error", text: "Error while creating new class occured.\nPlease, try again later.", viewController: self)
                            } else {
                                self.hideProgressBar()
                                self.assignClassToCurrentTeacher(classId: classRef.documentID)
                            }
                        }
                    }
                }
            })
        }
    }
    
    private func assignClassToCurrentTeacher(classId: String) {
        let storage = Firestore.firestore()
        storage.collection("users").whereField("user_id", isEqualTo: Utils.getUserId()).getDocuments(completion: { (snapshot, error) in
            if let error = error {
                self.hideProgressBar()
                Utils.showAlertOnError(title: "Error", text: error.localizedDescription, viewController: self)
            } else {
                var ref: DocumentReference?
                for document in snapshot!.documents {
                    let data = document.data()
                    guard let userId = data["user_id"] as? String
                        else { return }
                    if userId == Utils.getUserId() {
                        ref = document.reference
                    }
                }
                if let docRef = ref {
                    docRef.collection("my_classes").addDocument(data: [
                        "class_id": classId
                    ]) { err in
                        if err != nil {
                            self.hideProgressBar()
                            Utils.showAlertOnError(title: "Error", text: "Error while creating new class occured.\nPlease, try again later.", viewController: self)
                        } else {
                            self.hideProgressBar()
                            Utils.showAlertOnError(title: "Success", text: "New class group has been successfully created!", viewController: self)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                self.navigationController?.popViewController(animated: true)
                            })
                        }
                    }
                }
            }
        })
    }
}
