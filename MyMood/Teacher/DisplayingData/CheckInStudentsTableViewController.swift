//
//  CheckInStudentsTableViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 23/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit

class CheckInStudentsTableViewController: UITableViewController {

    private var students: Array<String> = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loadedData = Utils.loadedResponses
        for response in loadedData {
            guard let tin = response["tin"] as? Bool,
                    let name = response["name"] as? String
                else { continue }
            if (tin) {
                students.append(name)
            }
        }
        self.tableView.tableFooterView = UIView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if students.count > 0 {
            return 1
        } else {
            TableViewHelper.EmptyMessage(message: "No students have asked for in-person check-in", viewController: self)
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkInCell", for: indexPath)

        if let nameLabel = cell.viewWithTag(35) as? UILabel {
            nameLabel.text = students[indexPath.row]
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

class TableViewHelper {
    
    class func EmptyMessage(message:String, viewController:UITableViewController) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewController.view.bounds.size
            .width, height: viewController.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Raleway", size: 20)
        messageLabel.sizeToFit()
        
        viewController.tableView.backgroundView = messageLabel
        viewController.tableView.separatorStyle = .none
    }
}
