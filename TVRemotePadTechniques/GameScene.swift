//
//  GameScene.swift
//  TVRemotePadTechniques
//
//  Created by Ruben Nine on 01/11/15.
//  Copyright (c) 2015 9Labs. All rights reserved.
//

import SpriteKit
import GameController

class GameScene: SKScene {

    private let padHandler = DPadCornerHandler()

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

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "controllerSlideModeChanged:",
            name: InputSourceManagerNotification.SlideModeChanged,
            object: nil
        )

        if let microGamepad = InputSourceManager.sharedManager.microGamepad {
            setupMicroGamepad(microGamepad)

            if let label = childNodeWithName("SlideModeLabelNode") as? SKLabelNode {
                label.text = microGamepad.reportsAbsoluteDpadValues ? "slide mode off" : "slide mode on"
            }
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

        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: InputSourceManagerNotification.SlideModeChanged,
            object: nil
        )
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }

    // MARK: Private Functions

    private func pressCorner(corner: PressedDPadCorner) {
        if let nodeForCorner = getNodeForCorner(corner) {
            let fadeAction = SKAction.fadeAlphaTo(0.60, duration: 0.15)
            let scaleAction = SKAction.scaleTo(0.95, duration: 0.15)
            let soundAction = SKAction.playSoundFileNamed("sword", waitForCompletion: false)
            let sequence = SKAction.group([fadeAction, scaleAction, soundAction])

            nodeForCorner.runAction(sequence)
        }
    }

    private func unpressCorner(corner: PressedDPadCorner) {
        if let nodeForCorner = getNodeForCorner(corner) {
            let fadeAction = SKAction.fadeAlphaTo(1.0, duration: 0.15)
            let scaleAction = SKAction.scaleTo(1.0, duration: 0.15)
            let sequence = SKAction.group([fadeAction, scaleAction])

            nodeForCorner.runAction(sequence)
        }
    }

    private func getNodeForCorner(corner: PressedDPadCorner) -> SKNode? {
        switch corner {
        case .TopLeft:
            return childNodeWithName("TLNode")
        case .TopRight:
            return childNodeWithName("TRNode")
        case .BottomRight:
            return childNodeWithName("BRNode")
        case .BottomLeft:
            return childNodeWithName("BLNode")
        case .None:
            return nil
        }
    }

    private func setupMicroGamepad(microGamepad: GCMicroGamepad) {
        // Handle D-pad value changes
        microGamepad.valueChangedHandler = { [unowned self] microGamePad, movement in
            if let dpad = movement as? GCControllerDirectionPad {
                self.padHandler.handlePress(xAxis: CGFloat(dpad.xAxis.value), yAxis: CGFloat(dpad.yAxis.value),
                    onPress: { corner in
                        self.pressCorner(corner)
                    },
                    onRelease: { corner in
                        self.unpressCorner(corner)
                    }
                )
            }
        }

        // Handle X-button press (play/pause on the Siri Remote)
        microGamepad.buttonX.pressedChangedHandler = { _, _, pressed in
            if pressed {
                if let gvc = self.view?.window?.rootViewController as? GameViewController {
                    gvc.presentSceneNamed("GameScene2", shouldTransition: true)
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

    @objc private func controllerSlideModeChanged(notification: NSNotification) {
        if let microGamepad = InputSourceManager.sharedManager.microGamepad {
            if let label = childNodeWithName("SlideModeLabelNode") as? SKLabelNode {
                label.text = microGamepad.reportsAbsoluteDpadValues ? "slide mode off" : "slide mode on"
            }
        }
    }
}
