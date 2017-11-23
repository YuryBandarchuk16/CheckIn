//
//  TeacherPickMoodAreaViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 10/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit

class TeacherPickMoodAreaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sadImageView: UIImageView!
    @IBOutlet weak var smileImageView: UIImageView!
    @IBOutlet weak var happyImageView: UIImageView!
    
    private var sadImage: UIImage!
    private var sadImageColored: UIImage!
    
    private var smileImage: UIImage!
    private var smileImageColored: UIImage!
    
    private var happyImage: UIImage!
    private var happyImageColored: UIImage!
    
    let titles = ["Happiness rating", "Feeling Word", "Draw It", "Write It", "Check In"]
    
    private var sliderValueForever: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slider.value = Float(Utils.sumValues / Utils.count)
        sliderValueForever = slider.value
        tableView.tableFooterView = UIView()
        setupEmojiImages()
        setCorrectImageForSlider()
    }
    
    private func setupEmojiImages() {
        sadImage = UIImage(named: "sad")
        sadImageColored = UIImage(named: "sad_colored")
        smileImage = UIImage(named: "smile")
        smileImageColored = UIImage(named: "smile_colored")
        happyImage = UIImage(named: "happy")
        happyImageColored = UIImage(named: "happy_colored")
    }
    
    private func setCorrectImageForSlider() {
        let currentValue = self.slider.value
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
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        sender.value = self.sliderValueForever
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: Segues.showValues.rawValue, sender: self)
        } else if indexPath.row == 3 {
            self.performSegue(withIdentifier: Segues.textInfo.rawValue, sender: self)
        } else if indexPath.row == 4 {
            self.performSegue(withIdentifier: Segues.checkInSegue.rawValue, sender: self)
        } else if indexPath.row == 2 {
            self.performSegue(withIdentifier: Segues.showImages.rawValue, sender: self)
        } else if indexPath.row == 1 {
            self.performSegue(withIdentifier: Segues.feelingWordSegue.rawValue, sender: self)
        }
    }
    
    private enum Segues: String {
        case showValues
        case textInfo
        case checkInSegue
        case showImages
        case feelingWordSegue
    }

}
