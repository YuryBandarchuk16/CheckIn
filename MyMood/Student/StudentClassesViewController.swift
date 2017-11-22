//
//  StudentClassesViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 22/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class StudentClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let responseSubmitted: String = "Submitted"
    private let responseHaveNotSubmitted: String = "Have not submitted"
    
    private var classNames: Array<String> = Array<String>()
    private var classRefs: Array<DocumentReference> = Array<DocumentReference>()
    private var classSubmitted: Array<Bool> = Array<Bool>()
    
    private var selectedClassName: String!
    private var selectedClassRef: DocumentReference!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var classesLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    private func hideProgressBar() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    private func showProgressBar() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (!classesLoaded) {
            loadClasses()
            classesLoaded = true
        }
    }
    
    private func loadClasses() {
        showProgressBar()
        var newClassNames: Array<String> = Array<String>()
        var newClassRefs: Array<DocumentReference> = Array<DocumentReference>()
        var newClassCompletion: Array<Bool> = Array<Bool>()
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
                    docRef.collection("my_classes").getDocuments(completion: { (snapshot, error) in
                        if let error = error {
                            Utils.showAlertOnError(title: "Error", text: error.localizedDescription, viewController: self)
                        } else {
                            self.setAsyncTasks(amount: snapshot!.documents.count, callback: {
                                DispatchQueue.main.async {
                                    self.classRefs = newClassRefs
                                    self.classNames = newClassNames
                                    self.classSubmitted = newClassCompletion
                                    self.tableView.reloadData()
                                    print("RELOADED TABLE VIEW DATA!")
                                    self.hideProgressBar()
                                }
                            })
                            if snapshot!.documents.count == 0 {
                                self.hideProgressBar()
                                return
                            }
                            for document in snapshot!.documents {
                                let data = document.data()
                                guard let classId = data["class_id"] as? String
                                    else { return }
                                let storage = Firestore.firestore()
                                let currentClassRef = storage.collection("classes").document(classId)
                                let currentClassResponsesRef = currentClassRef.collection("responses").document(Utils.getUserTodayResponseName())
                                currentClassRef.getDocument(completion: { (document, error) in
                                    if error != nil {
                                        self.oneAsyncTaskDone()
                                        return
                                    } else {
                                        guard let data = document?.data(),
                                            let className = data["class_name"] as? String
                                            else { self.hideProgressBar(); return }
                                        print("YO, \(className)")
                                        currentClassResponsesRef.getDocument(completion: { (snapshot, error) in
                                            if error != nil {
                                                self.oneAsyncTaskDone()
                                                return
                                            }
                                            guard let data = document?.data()
                                                else { self.oneAsyncTaskDone(); return }
                                            if let _ = data["response_id"] as? String {
                                                newClassCompletion.append(true)
                                            } else {
                                                newClassCompletion.append(false)
                                            }
                                            newClassNames.append(className)
                                            newClassRefs.append(currentClassRef)
                                            self.oneAsyncTaskDone()
                                        })
                                    }
                                })
                            }
                        }
                    })
                }
            }
        })
    }
    
    private var asyncTasks: Int = 0
    private var asyncTasksDoneCallback: (() -> Void)!
    
    private func setAsyncTasks(amount: Int, callback: @escaping (() -> Void)) {
        self.asyncTasks = amount
        self.asyncTasksDoneCallback = callback
    }
    
    private func oneAsyncTaskDone() {
        self.asyncTasks -= 1
        if (self.asyncTasks == 0) {
            self.asyncTasksDoneCallback()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        Utils.setCurrentStudentClass(className: self.selectedClassName)
        Utils.setCurrentStudentClassRef(ref: self.selectedClassRef)
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        guard let _ = Utils.getCurrentStudentClassName(),
                let _ = Utils.getCurrentStudentClassRef()
            else { return }
        super.performSegue(withIdentifier: identifier, sender: sender)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier: String!
        var intercationEnabled: Bool!
        if classSubmitted[indexPath.row] {
            intercationEnabled = false
            identifier = ReusableIdentifiers.studentClassCellDone.rawValue
        } else {
            intercationEnabled = true
            identifier = ReusableIdentifiers.studentClassCellPending.rawValue
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.isUserInteractionEnabled = intercationEnabled
        if intercationEnabled {
            if let classNameLabel = cell.viewWithTag(102) as? UILabel {
                classNameLabel.text = classNames[indexPath.row]
            }
        } else {
            if let classNameLabel = cell.viewWithTag(101) as? UILabel {
                classNameLabel.text = classNames[indexPath.row]
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if classSubmitted[indexPath.row] {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            self.selectedClassName = classNames[indexPath.row]
            self.selectedClassRef = classRefs[indexPath.row]
            self.performSegue(withIdentifier: Segues.submitResponse.rawValue, sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    private enum Segues: String {
        case submitResponse
    }
    
    private enum ReusableIdentifiers: String {
        case studentClassCellDone
        case studentClassCellPending
    }

}
