//
//  GameViewController.swift
//  Check In
//
//  Created by Юрий Бондарчук on 13/12/2017.
//  Copyright © 2017 Samantha Parola. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var scene: GameScene!
    var level: Level!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure the view
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        let randomNum: UInt32 = arc4random_uniform(100) % 5
        
        level = Level(filename: "Level_\(randomNum)")
        scene.level = level
        scene.addTiles()
        scene.swipeHandler = handleSwipe
        
        // present the scene
        skView.presentScene(scene)
        
        beginGame()
    }
    
    func beginGame() {
        shuffle()
    }
    
    func shuffle() {
        let newCookies = level.shuffle()
        scene.addSprites(for: newCookies)
    }
    
    func handleSwipe(swap: Swap) {
        view.isUserInteractionEnabled = false
        print("Swap = \(swap)")
        if level.isPossibleSwap(swap) {
            level.performSwap(swap: swap)
            scene.animate(swap) {
                self.view.isUserInteractionEnabled = true
            }
            let cookieA = swap.cookieA
            let cookieB = swap.cookieB
            let resultA = level.getChainAt(column: cookieA.column, row: cookieA.row)
            let resultB = level.getChainAt(column: cookieB.column, row: cookieB.row)
            if (resultA.count >= 3) {
                scene.addNewCookies(location: resultA)
            }
            if (resultB.count >= 3) {
                scene.addNewCookies(location: resultB)
            }
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
}
