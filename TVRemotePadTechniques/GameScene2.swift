//
//  GameScene.swift
//  TVRemotePadTechniques
//
//  Created by Ruben Nine on 01/11/15.
//  Copyright (c) 2015 9Labs. All rights reserved.
//

import SpriteKit
import GameController

class GameScene2: SKScene {

    private let padHandler = DPadSideHandler()

    override func didMoveToView(view: SKView) {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "controllerDidConnect:",
            name: InputSourceManagerNotification.DidConnect,
            object: nil
        )

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "controllerDidDisconnect:",
            name: InputSourceManagerNotification.DidDisconnect,
            object: nil
        )

        if let microGamepad = InputSourceManager.sharedManager.microGamepad {
            setupMicroGamepad(microGamepad)
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: InputSourceManagerNotification.DidConnect,
            object: nil
        )

        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: InputSourceManagerNotification.DidDisconnect,
            object: nil
        )
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }

    // MARK: Private Functions

    private func pressSide(side: PressedDPadSide) {
        if let nodeForSide = getNodeForSide(side) {
            let fadeAction = SKAction.fadeAlphaTo(0.60, duration: 0.15)
            let scaleAction = SKAction.scaleTo(0.95, duration: 0.15)
            let soundAction = SKAction.playSoundFileNamed("sword", waitForCompletion: false)
            let sequence = SKAction.group([fadeAction, scaleAction, soundAction])

            nodeForSide.runAction(sequence)
        }
    }

    private func unpressSide(side: PressedDPadSide) {
        if let nodeForSide = getNodeForSide(side) {
            let fadeAction = SKAction.fadeAlphaTo(1.0, duration: 0.15)
            let scaleAction = SKAction.scaleTo(1.0, duration: 0.15)
            let sequence = SKAction.group([fadeAction, scaleAction])

            nodeForSide.runAction(sequence)
        }
    }

    private func getNodeForSide(side: PressedDPadSide) -> SKNode? {
        switch side {
        case .Left:
            return childNodeWithName("LNode")
        case .Right:
            return childNodeWithName("RNode")
        case .Up:
            return childNodeWithName("UNode")
        case .Down:
            return childNodeWithName("DNode")
        case .None:
            return nil
        }
    }

    private func setupMicroGamepad(microGamepad: GCMicroGamepad) {
        // Enable continuous D-pad reading
        microGamepad.valueChangedHandler = { [unowned self] microGamePad, movement in
            if let dpad = movement as? GCControllerDirectionPad {
                self.padHandler.handlePress(xAxis: CGFloat(dpad.xAxis.value), yAxis: CGFloat(dpad.yAxis.value),
                    onPress: { side in
                        self.pressSide(side)
                    },
                    onRelease: { side in
                        self.unpressSide(side)
                    }
                )
            }
        }

        // Handle Y-button press (play/pause on the Siri Remote)
        microGamepad.buttonX.pressedChangedHandler = { _, _, pressed in
            if pressed {
                if let gvc = self.view?.window?.rootViewController as? GameViewController {
                    gvc.presentSceneNamed("GameScene", shouldTransition: true)
                }
            }
        }
    }

    @objc private func controllerDidConnect(notification: NSNotification) {
        if let microGamepad = InputSourceManager.sharedManager.microGamepad {
            setupMicroGamepad(microGamepad)
        }
    }

    @objc private func controllerDidDisconnect(notification: NSNotification) {
        // NO-OP
    }
}
