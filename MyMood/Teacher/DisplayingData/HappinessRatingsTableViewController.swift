//
//  HappinessRatingsTableViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 23/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit

class HappinessRatingsTableViewController: UITableViewController {
    
    private var sadImage: UIImage!
    private var sadImageColored: UIImage!
    
    private var smileImage: UIImage!
    private var smileImageColored: UIImage!
    
    private var happyImage: UIImage!
    private var happyImageColored: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupEmojiImages()
        tableView.tableFooterView = UIView()
    }
    
    private func setupEmojiImages() {
        sadImage = UIImage(named: "sad")
        sadImageColored = UIImage(named: "sad_colored")
        smileImage = UIImage(named: "smile")
        smileImageColored = UIImage(named: "smile_colored")
        happyImage = UIImage(named: "happy")
        happyImageColored = UIImage(named: "happy_colored")
    }
    
    private func getImageByValue(value: Float) -> UIImage {
        if value <= 0.35 {
            return sadImageColored
        } else if (value > 0.35 && value <= 0.75) {
            return smileImageColored
        } else {
            return happyImageColored
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Utils.loadedResponses.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "happinessCell", for: indexPath)

        var name: String = "Error getting student name"
        var rating: String = "Error getting student happiness rating"
        var image = sadImageColored
        
        if let realName = Utils.loadedResponses[indexPath.row]["name"] as? String {
            name = realName
        }
        if let realRating = Utils.loadedResponses[indexPath.row]["value"] as? Double {
            let value = Int(realRating * 100.0)
            let nowRating = Float(value) / 10.0
            rating = "Happiness rating: \(nowRating)"
            image = self.getImageByValue(value: Float(realRating))
        }
        
        if let nameLabel = cell.viewWithTag(10) as? UILabel {
            nameLabel.text = name
        }
        if let ratingLabel = cell.viewWithTag(11) as? UILabel {
            ratingLabel.text = rating
        }
        if let emojiImageView = cell.viewWithTag(12) as? UIImageView {
            emojiImageView.image = image
        }

        return cell
    }


}
