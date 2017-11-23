//
//  DrawItTableViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 23/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseStorage
import MBProgressHUD

class DrawItTableViewController: UITableViewController {
    
    private var names: Array<String> = Array<String>()
    private var imageData: Array<Data> = Array<Data>()
    
    private var needToLoadData: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if let loadedData = Utils.getPhotosByClass(className: Utils.teacherClassName) {
            names = []
            imageData = []
            for entry in loadedData {
                names.append(entry.key)
                imageData.append(entry.value)
            }
        } else {
            self.needToLoadData = true
        }
        self.tableView.tableFooterView = UIView()
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
        if (self.needToLoadData) {
            self.needToLoadData = false
            self.showProgressBar()
            var newNames: [String] = []
            var newData: [Data] = []
            let responses = Utils.loadedResponses
            var imageIds: [String] = []
            for response in responses {
                guard let imageId = response["image_id"] as? String
                    else { continue }
                if imageId.characters.count <= 1 {
                    continue
                }
                var name: String = "Error getting student name"
                if let realName = response["name"] as? String {
                    name = realName
                }
                newNames.append(name)
                imageIds.append(imageId)
            }
            if imageIds.count == 0 {
                self.hideProgressBar()
                return
            }
            let storage = Storage.storage()
            let storageRef = storage.reference()
            var custom: [String: Data] = [String: Data]()
            self.setAsyncTasks(amount: imageIds.count, callback: {
                self.names = newNames
                for i in 0..<imageIds.count {
                    let id = imageIds[i]
                    let imageRef = storageRef.child("images/\(id)")
                    let itsName = imageRef.name
                    if let d = custom[itsName] {
                        newData.append(d)
                    } else {
                        newData.append(Data())
                    }
                }
                self.imageData = newData
                self.hideProgressBar()
                self.tableView.reloadData()
                var got: [String: Data] = [String: Data]()
                for i in 0..<self.names.count {
                    got[self.names[i]] = self.imageData[i]
                }
                Utils.addPhotosForClass(className: Utils.teacherClassName, dict: got)
            })
            for id in imageIds {
                let imageRef = storageRef.child("images/\(id)")
                imageRef.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                    if error != nil || data == nil {
                        self.oneAsyncTaskDone()
                    } else {
                        custom[imageRef.name] = data!
                        self.oneAsyncTaskDone()
                    }
                })
            }
        }
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        if names.count == 0 {
            TableViewHelper.EmptyMessage(message: "No students have uploaded photos", viewController: self)
            return 0
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)

        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = names[indexPath.row]
        }
        if let imageView = cell.viewWithTag(2) as? UIImageView {
            imageView.image = UIImage(data: imageData[indexPath.row])
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    private var dataToPass: Data!
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dataToPass = self.imageData[indexPath.row]
        self.performSegue(withIdentifier: Segues.detailedImage.rawValue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.detailedImage.rawValue {
            if let destinationViewController = segue.destination as? ShowImageViewController {
                destinationViewController.imageData = dataToPass
            }
        }
    }
    
    private enum Segues: String {
        case detailedImage
    }

}
