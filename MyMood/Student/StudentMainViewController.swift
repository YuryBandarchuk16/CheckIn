//
//  StudentMainViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 01/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit
import Firebase
import Foundation

class StudentMainViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    private var currentButtonMask: Int = 0
    
    @IBOutlet weak var happyButton: UIButton! // 0th
    @IBOutlet weak var hopefulButton: UIButton! // 1st
    @IBOutlet weak var madButton: UIButton! // 2nd
    @IBOutlet weak var anxiousButton: UIButton! // 3rd
    @IBOutlet weak var excitedButton: UIStackView! // 4th
    @IBOutlet weak var sadButton: UIButton! //5th
    @IBOutlet weak var confusedButton: UIButton! //6th
    @IBOutlet weak var worriedButton: UIButton! // 7th
    
    private var checked: UIImage!
    private var unchecked: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checked = UIImage(named: "checkbox")!
        unchecked = UIImage(named: "checkboxbasic")!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayDate()
    }
    
    private func displayDate() {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let day = Utils.convertIntegerToDay(components.day!)
        let monthName = Utils.months[components.month! - 1]
        let year = components.year!
        dateLabel.text = "\(day) \(monthName) \(year)"
    }

    @IBAction func feelingWordCheckBoxClicked(_ sender: UIButton) {
        var buttonId: Int = 0
        switch sender {
        case happyButton: buttonId = 0; break
        case hopefulButton: buttonId = 1; break
        case madButton: buttonId = 2; break
        case anxiousButton: buttonId = 3; break
        case excitedButton: buttonId = 4; break
        case sadButton: buttonId = 5; break
        case confusedButton: buttonId = 6; break
        case worriedButton: buttonId = 7; break
        default:
            break
        }
        let currentImage = (currentButtonMask & (1 << buttonId))
        print(currentButtonMask)
        currentButtonMask ^= (1 << buttonId)
        print(currentButtonMask)
        if currentImage == 0 {
            sender.setImage(checked, for: .normal)
        } else {
            sender.setImage(checked, for: .normal)
        }
    }
}
