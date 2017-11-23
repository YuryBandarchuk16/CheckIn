//
//  ShowDetailForWordTableViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 23/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit

class ShowDetailForWordTableViewController: UITableViewController {

    public var data: Array<String>  = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.data.count == 0 {
            TableViewHelper.EmptyMessage(message: "Oops, nothing to show", viewController: self)
            return 0
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = data[indexPath.row]
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
