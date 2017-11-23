//
//  FeelingWordTableViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 23/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit

class FeelingWordTableViewController: UITableViewController {

    private var students: Array<String> = Array<String>()
    private var wordsForStudent: Array<Int> = Array<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        let data = Utils.loadedResponses
        for entry in data {
            var name = "Error getting student name"
            var value: Int = 0
            if let realName = entry["name"] as? String {
                name = realName
            }
            if let realValue = entry["feelingWord"] as? Int {
                value = realValue
            }
            self.students.append(name)
            self.wordsForStudent.append(value)
        }
    }
    
    private let feelingWords = ["Happy", "Hopeful", "Mad", "Anxious", "Excited", "Sad", "Confused", "Worried"]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "By Feeling Word"
        } else {
            return "By Student"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.feelingWords.count
        } else {
            return self.students.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        var value = self.feelingWords[indexPath.row]
        if indexPath.section == 1 {
            value = self.students[indexPath.row]
        }
        
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = value
        }

        return cell
    }
    
    private var dataToPass: Array<String> = Array<String>()

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dataToPass = []
        if indexPath.section == 0 {
            let row = indexPath.row
            for i in 0..<self.wordsForStudent.count {
                let currentValue = self.wordsForStudent[i]
                if ((currentValue & (1 << row)) != 0) {
                    self.dataToPass.append(self.students[i])
                }
            }
        } else {
            for i in 0..<self.feelingWords.count {
                let currentValue = self.wordsForStudent[indexPath.row]
                if ((currentValue & (1 << i)) != 0) {
                    self.dataToPass.append(self.feelingWords[i])
                }
            }
        }
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let destinationViewController = segue.destination as? ShowDetailForWordTableViewController {
                destinationViewController.data = dataToPass
            }
        }
    }

}
