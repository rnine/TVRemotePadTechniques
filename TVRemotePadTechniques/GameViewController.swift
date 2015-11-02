//
//  GameViewController.swift
//  TVRemotePadTechniques
//
//  Created by Ruben Nine on 01/11/15.
//  Copyright (c) 2015 9Labs. All rights reserved.
//

import UIKit
import SpriteKit
import GameController

class GameViewController: GCEventViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        presentSceneNamed("GameScene", shouldTransition: false)
    }

    func presentSceneNamed(name: String, shouldTransition: Bool) {
        if let scene = GameScene(fileNamed: name) {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true

            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill

            if shouldTransition {
                let transition = SKTransition.moveInWithDirection(.Right, duration: 0.35)
                skView.presentScene(scene, transition: transition)
            } else {
                skView.presentScene(scene)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
