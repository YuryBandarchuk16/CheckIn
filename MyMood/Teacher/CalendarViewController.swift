//
//  CalendarViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 18/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit
import RSDayFlow

class CalendarViewController: UIViewController, RSDFDatePickerViewDelegate, RSDFDatePickerViewDataSource {

    
    public var previousViewController: ClassPeriodViewController!
    
    private var lastDateSelected: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let datePicker = RSDFDatePickerView(frame: self.view.bounds)
        datePicker.delegate = self
        datePicker.dataSource = self
        datePicker.backgroundColor = self.view.backgroundColor
        self.view.addSubview(datePicker)
    }
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        if let choosenDate = lastDateSelected {
            previousViewController.dateToDisplay = Utils.getAnyDateString(date: choosenDate)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            Utils.showAlertOnError(title: "Error", text: "Please, select the date firstly.", viewController: self)
        }
    }
    
    func datePickerView(_ view: RSDFDatePickerView, shouldHighlight date: Date) -> Bool {
        return true
    }
    
    func datePickerView(_ view: RSDFDatePickerView, shouldSelect date: Date) -> Bool {
        return true
    }
    
    func datePickerView(_ view: RSDFDatePickerView, didSelect date: Date) {
        lastDateSelected = date
    }
    
}

