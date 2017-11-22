//
//  StudentClassesViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 22/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit
import Firebase

class StudentClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let responseSubmitted: String = "Submitted"
    private let responseHaveNotSubmitted: String = "Have not submitted"
    
    private var classNames: Array<String> = Array<String>()
    private var classRefs: Array<DocumentReference> = Array<DocumentReference>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    private enum Segues: String {
        case submitResponse
    }

}
