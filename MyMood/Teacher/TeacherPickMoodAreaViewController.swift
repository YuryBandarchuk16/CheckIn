//
//  TeacherPickMoodAreaViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 10/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit

class TeacherPickMoodAreaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let titles = ["Feeling Word", "Draw It", "Write It", "Check In"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "typeCell") else {
            return UITableViewCell()
        }
        if let label = cell.viewWithTag(101) as? UILabel {
            label.text = titles[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
