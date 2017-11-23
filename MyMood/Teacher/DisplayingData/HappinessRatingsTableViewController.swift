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
        } else if (currentValue > 0.35 && currentValue <= 0.75) {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "happinessCell", for: indexPath)

        if let 

        return cell
    }


}
