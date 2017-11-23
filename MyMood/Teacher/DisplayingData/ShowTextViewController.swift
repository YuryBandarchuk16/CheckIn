//
//  ShowTextViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 23/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit

class ShowTextViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    public var textToDisplay: String? = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = textToDisplay
    }

}
