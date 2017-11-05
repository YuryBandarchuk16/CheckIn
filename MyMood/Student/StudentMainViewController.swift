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

class StudentMainViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    private var keyboardAdjusted = false
    private var visibleLocation: CGFloat!
    private var lastKeyboardOffset: CGFloat = 0.0
    private let animationDuration: TimeInterval = 0.5
    
    private var sadImage: UIImage!
    private var sadImageColored: UIImage!
    
    private var smileImage: UIImage!
    private var smileImageColored: UIImage!
    
    private var happyImage: UIImage!
    private var happyImageColored: UIImage!
    
    @IBOutlet weak var teacherCheckInSwitch: UISwitch!
    
    @IBOutlet weak var sadImageView: UIImageView!
    @IBOutlet weak var smileImageView: UIImageView!
    @IBOutlet weak var happyImageView: UIImageView!
    
    private var currentButtonMask: Int = 0
    
    @IBOutlet weak var happyButton: UIButton! // 0th
    @IBOutlet weak var hopefulButton: UIButton! // 1st
    @IBOutlet weak var madButton: UIButton! // 2nd
    @IBOutlet weak var anxiousButton: UIButton! // 3rd
    @IBOutlet weak var excitedButton: UIStackView! // 4th
    @IBOutlet weak var sadButton: UIButton! //5th
    @IBOutlet weak var confusedButton: UIButton! //6th
    @IBOutlet weak var worriedButton: UIButton! // 7th
    
    @IBOutlet weak var writeItTextView: UITextView!
    
    @IBOutlet weak var drawItImageView: UIImageView!
    
    private var checked: UIImage!
    private var unchecked: UIImage!
    
    @IBOutlet weak var feelingWordView: UIView!
    @IBOutlet weak var writeItView: UIView!
    @IBOutlet weak var drawItView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checked = UIImage(named: "checkbox")!
        unchecked = UIImage(named: "checkboxbasic")!
        writeItTextView.delegate = self
        visibleLocation = teacherCheckInSwitch.frame.origin.y
        setupViews()
        setupEmojiImages()
    }
    
    private func setupViews() {
        feelingWordView.isHidden = false
        writeItView.isHidden = true
        drawItView.isHidden = true
    }
    
    private func setupEmojiImages() {
        sadImage = UIImage(named: "sad")
        sadImageColored = UIImage(named: "sad_colored")
        smileImage = UIImage(named: "smile")
        smileImageColored = UIImage(named: "smile_colored")
        happyImage = UIImage(named: "happy")
        happyImageColored = UIImage(named: "happy_colored")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayDate()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        self.view.endEditing(true)
        if (sender.selectedSegmentIndex == 0) {
            writeItView.isHidden = true
            feelingWordView.isHidden = false
            drawItView.isHidden = true
        } else if (sender.selectedSegmentIndex == 2) {
            writeItView.isHidden = false
            feelingWordView.isHidden = false
            drawItView.isHidden = true
        } else if (sender.selectedSegmentIndex == 1) {
            writeItView.isHidden = false
            feelingWordView.isHidden = false
            drawItView.isHidden = false
        }
    }
    
    @IBAction func sliderValueUpdated(_ sender: UISlider) {
        let currentValue = sender.value
        if currentValue <= 0.35 {
            sadImageView.image = sadImageColored
            smileImageView.image = smileImage
            happyImageView.image = happyImage
        } else if (currentValue > 0.35 && currentValue <= 0.75) {
            sadImageView.image = sadImage
            smileImageView.image = smileImageColored
            happyImageView.image = happyImage
        } else if currentValue > 0.75 {
            sadImageView.image = sadImage
            smileImageView.image = smileImage
            happyImageView.image = happyImageColored
        }
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
            sender.setImage(unchecked, for: .normal)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification: notification)
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.frame.origin.y -= self.lastKeyboardOffset
            })
            keyboardAdjusted = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if keyboardAdjusted == true {
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.frame.origin.y += self.lastKeyboardOffset
            })
            keyboardAdjusted = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let needHeight = visibleLocation + keyboardSize.cgRectValue.height
        let result = max(0, needHeight - UIScreen.main.bounds.height)
        return result
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.drawItSegue.rawValue {
            if let destinationViewController = segue.destination as? DrawItViewController {
                destinationViewController.drawItImageView = drawItImageView
            }
        }
    }
    
    private enum Segues: String {
        case drawItSegue
    }
    
}
