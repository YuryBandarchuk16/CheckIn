//
//  ShowImageViewController.swift
//  MyMood
//
//  Created by Юрий Бондарчук on 23/11/2017.
//  Copyright © 2017 Yury Bandarchuk. All rights reserved.
//

import UIKit

class ShowImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    public var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = imageData {
            imageView.image = UIImage(data: data)
        }
    }

}
