//
//  ClassPeriodViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 10/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class ClassPeriodViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var calendarImageView: UIImageView!
    
    public var dateToDisplay: String!
    
    private var refreshControl: UIRefreshControl!

    private var classNames: Array<String> = Array<String>()
    private var classRefs: Array<DocumentReference> = Array<DocumentReference>()
    
    @IBOutlet weak var tableView: UITableView!
    
    private var isRefreshControlActive: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if dateToDisplay != nil {
            dateLabel.text = dateToDisplay
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateToDisplay = Utils.getCurrentDateString()
        setupCalendarTap()
        tableView.delegate = self
        tableView.dataSource = self
        let footerView = UIView()
        footerView.tintColor = self.view.backgroundColor
        footerView.backgroundColor = self.view.backgroundColor
        tableView.tableFooterView = footerView
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing the class list...")
        refreshControl.backgroundColor = self.view.backgroundColor
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        tableView.backgroundColor = self.view.backgroundColor
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = self.view.backgroundColor
    }
    
    @objc
    private func refresh(sender: AnyObject) {
        print("STARTED")
        isRefreshControlActive = true
        self.loadClasses()
        print("LOADED!")
        print("ENDED!")
    }
    
    private func hideProgressBar() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    private func showProgressBar() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    private var classesLoaded: Bool = false
    
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
                                    self.tableView.reloadData()
                                    print("RELOADED TABLE VIEW DATA!")
                                    self.hideProgressBar()
                                    if self.isRefreshControlActive {
                                        self.refreshControl.endRefreshing()
                                        self.isRefreshControlActive = false
                                    }
                                }
                            })
                            if snapshot!.documents.count == 0 {
                                self.hideProgressBar()
                                if self.isRefreshControlActive {
                                    self.refreshControl.endRefreshing()
                                }
                                return
                            }
                            for document in snapshot!.documents {
                                if (!document.exists) {
                                    self.oneAsyncTaskDone()
                                    continue
                                }
                                let data = document.data()
                                guard let classId = data["class_id"] as? String
                                    else { return }
                                let storage = Firestore.firestore()
                                let currentClassRef = storage.collection("classes").document(classId)
                                currentClassRef.getDocument(completion: { (document, error) in
                                    if error != nil {
                                        return
                                    } else {
                                        if (!document!.exists) {
                                            self.oneAsyncTaskDone()
                                            return
                                        }
                                        guard let data = document?.data(),
                                            let className = data["class_name"] as? String
                                            else { return }
                                        print("YO, \(className)")
                                        newClassNames.append(className)
                                        newClassRefs.append(currentClassRef)
                                        self.oneAsyncTaskDone()
                                    }
                                })
                            }
                        }
                    })
                }
            }
        })
    }
    
    private func getSelectedDateWithoutSpaces() -> String {
        var result: String = ""
        for character in self.dateToDisplay.characters {
            if character == " " {
                continue
            } else {
                result.append(character)
            }
        }
        print("Date built: \(result)")
        return result
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
    
    private func setupCalendarTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(calendarTapped))
        tap.numberOfTapsRequired = 1
        calendarImageView.isUserInteractionEnabled = true
        calendarImageView.addGestureRecognizer(tap)
    }
    
    @objc
    private func calendarTapped() {
        self.performSegue(withIdentifier: Segues.showCalendar.rawValue, sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classNames.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "classCell") else {
            return UITableViewCell()
        }
        if let label = cell.viewWithTag(101) as? UILabel {
            label.text = self.classNames[indexPath.row]
        }
        return cell
    }
    
    private func prepareResponseData() {
        let responses = Utils.getResponses()
        var ids: Array<String> = Array<String>()
        for response in responses {
            guard let id = response["response_id"] as? String
                else { continue }
            ids.append(id)
        }
        if ids.count == 0 {
            self.hideProgressBar()
            Utils.showAlertOnError(title: "Information Message", text: "Unfortunately, there are no records on selected date for this class.", viewController: self)
            return
        }
        self.hideProgressBar()
        Utils.showAlertOnError(title: "Information Message", text: "Please, wait a second while loading all the responses", viewController: self)
        self.showProgressBar()
        self.setAsyncTasks(amount: ids.count) {
            self.hideProgressBar()
            if Utils.loadedResponses.count == 0 || Utils.count == 0.0 {
                Utils.showAlertOnError(title: "Information Message", text: "Unfortunately, there are no records on selected date for this class or some error occured. Please, try again later.", viewController: self)
                return
            }
            self.performSegue(withIdentifier: Segues.showClassStatsSegue.rawValue, sender: self)
        }
        let storage = Firestore.firestore()
        Utils.sumValues = 0.0
        Utils.count = 0.0
        Utils.loadedResponses = Array<Dictionary<String, Any>>()
        for id in ids {
            storage.collection("responses").document(id).getDocument(completion: { (snapshot, error) in
                if error != nil || snapshot == nil {
                    self.oneAsyncTaskDone()
                } else {
                    let doc = snapshot!
                    if (!doc.exists) {
                        self.oneAsyncTaskDone()
                    } else {
                        let data = doc.data()
                        guard let value = data["value"] as? Double
                            else {
                                self.oneAsyncTaskDone()
                                return
                        }
                        Utils.count += 1.0
                        Utils.sumValues += value
                        Utils.loadedResponses.append(data)
                    }
                }
            })
        }
    }
    
    private func loadResponsesForClass(classRef: DocumentReference) {
        self.showProgressBar()
        var students: Array<String> = Array<String>()
        classRef.collection("class_students").getDocuments { (snapshot, error) in
            if error != nil {
                self.hideProgressBar()
                Utils.showAlertOnError(title: "Error", text: "Error occured when loading class students.", viewController: self)
                return
            } else {
                guard let documents = snapshot?.documents
                    else {
                        self.hideProgressBar()
                        Utils.showAlertOnError(title: "Error", text: "Error occured when loading class students.", viewController: self)
                        return
                }
                for document in documents {
                    if (!document.exists) {
                        continue
                    }
                    let data = document.data()
                    guard let studentId = data["user_id"] as? String
                        else { continue }
                    students.append(studentId)
                }
                let selectedDate = self.getSelectedDateWithoutSpaces()
                Utils.createNewResponses()
                self.setAsyncTasks(amount: students.count, callback: {
                    if Utils.getResponsesCount() == 0 {
                        self.hideProgressBar()
                        Utils.showAlertOnError(title: "Information Message", text: "Unfortunately, there are no records on selected date for this class.", viewController: self)
                    } else {
                        self.prepareResponseData()
                    }
                })
                if students.count == 0 {
                    self.hideProgressBar()
                    Utils.showAlertOnError(title: "Information Message", text: "Unfortunately, there are no records on selected date for this class.", viewController: self)
                    return
                }
                for student in students {
                    let responseKey = "\(student)_\(selectedDate)"
                    classRef.collection("responses").document(responseKey).getDocument(completion: { (resultDocument, error) in
                        if error != nil {
                            self.oneAsyncTaskDone()
                            return
                        } else {
                            guard let doc = resultDocument
                                else {
                                    self.oneAsyncTaskDone()
                                    return
                            }
                            if (!doc.exists) {
                                self.oneAsyncTaskDone()
                                return
                            }
                            Utils.addNewResponse(response: doc.data())
                            print("LOOOOK!");
                            print(doc.data())
                            self.oneAsyncTaskDone()
                        }
                    })
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.loadResponsesForClass(classRef: classRefs[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destionationViewController = segue.destination as? CalendarViewController {
            destionationViewController.previousViewController = self
        }
    }
    
    private enum Segues: String {
        case showCalendar
        case showClassStatsSegue
    }

}
