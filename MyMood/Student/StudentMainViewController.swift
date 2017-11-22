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
import FirebaseStorage
import MBProgressHUD
import UIImage_ImageCompress

class StudentMainViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    private let maxImageSize: Double = 1.02 // in MB
    
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
    private var sliderValue: Float = 0.5
    
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
        dateLabel.text = Utils.getCurrentDateString()
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
        self.sliderValue = sender.value
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
        let result: CGFloat = keyboardSize.cgRectValue.height - 5
        return result
    }
    
    private func hideProgressBar() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    private func showProgressBar() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        self.showProgressBar()
        var image = self.drawItImageView.image
        if image != nil {
            if let uploadData = UIImagePNGRepresentation(image!) {
                let array = [UInt8](uploadData)
                let size: Double = Double(array.count) / Double(1024.0)
                let compressRatio = min(Float(1.0), Float(self.maxImageSize / size))
                if abs(compressRatio - 1.0) > 1e-7 {
                    image = UIImage.compressImage(image!, compressRatio: CGFloat(compressRatio))
                }
            }
        }
        let happinessValue = self.sliderValue
        let textUnwrapped = self.writeItTextView.text
        var text = ""
        if let goodText = textUnwrapped {
            text = goodText
        }
        let feelingWord = self.currentButtonMask
        var failed: Bool = false
        if image != nil {
            let imageStorage = Storage.storage()
            let imagePath = Utils.getUserTodayResponseName() + "_" +  Utils.getCurrentStudentClassName()!
            let imageRef = imageStorage.reference().child("images/\(imagePath)")
            let imageData = UIImagePNGRepresentation(image!)!
            _ = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                guard metadata != nil
                    else {
                        failed = true
                        self.hideProgressBar()
                        Utils.showAlertOnError(title: "Error", text: "Error occured while uploading a photo", viewController: self)
                        return
                }
                let storage = Firestore.firestore()
                let responseRef = storage.collection("responses").addDocument(data: [
                    "feelingWord": feelingWord,
                    "image_id": imagePath,
                    "text": text,
                    "value": happinessValue
                ]) { (error) in
                    self.hideProgressBar()
                    if error != nil {
                        failed = true
                        Utils.showAlertOnError(title: "Error", text: "Error saving you response. Please, try again later.", viewController: self)
                    } else {
                        Utils.showAlertOnError(title: "Success", text: "Your response has been successfully saved!", viewController: self)
                    }
                }
                if failed == false {
                    self.showProgressBar()
                    let classRef = Utils.getCurrentStudentClassRef()!
                    classRef.collection("responses").document(Utils.getUserTodayResponseName()).setData([
                        "response_id": responseRef.documentID
                    ]) { error in
                        self.hideProgressBar()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                            Utils.justSavedResponse()
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }
            }
        } else {
            let storage = Firestore.firestore()
            let responseRef = storage.collection("responses").addDocument(data: [
                "feelingWord": feelingWord,
                "image_id": "",
                "text": text,
                "value": happinessValue
            ]) { (error) in
                self.hideProgressBar()
                if error != nil {
                    failed = true
                    Utils.showAlertOnError(title: "Error", text: "Error saving you response. Please, try again later.", viewController: self)
                } else {
                    Utils.showAlertOnError(title: "Success", text: "Your response has been successfully saved!", viewController: self)
                }
            }
            if failed == false {
                self.showProgressBar()
                let classRef = Utils.getCurrentStudentClassRef()!
                classRef.collection("responses").document(Utils.getUserTodayResponseName()).setData([
                    "response_id": responseRef.documentID
                ]) { error in
                    self.hideProgressBar()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        Utils.justSavedResponse()
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
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
