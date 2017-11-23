//
//  WriteItTableViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 23/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit

class WriteItTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Utils.loadedResponses.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    private var dict: [Int: String] = [Int: String]()
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath)
        
        var name: String = "Error getting student name"
        var text: String = "Error getting student text"
    
        
        if let realName = Utils.loadedResponses[indexPath.row]["name"] as? String {
            name = realName
        }
        if let realText = Utils.loadedResponses[indexPath.row]["text"] as? String {
            text = realText
        }
        
        self.dict[indexPath.row] = text
        
        if let nameLabel = cell.viewWithTag(77) as? UILabel {
            nameLabel.text = name
        }
        if let textLabel = cell.viewWithTag(78) as? UILabel {
            textLabel.text = text
        }
        
        return cell
    }
    
    private var selectedText: String?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedText = self.dict[indexPath.row]
        self.performSegue(withIdentifier: "showText", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showText" {
            if let destinationViewController = segue.destination as? ShowTextViewController {
                destinationViewController.textToDisplay = self.selectedText
            }
        }
    }

}
