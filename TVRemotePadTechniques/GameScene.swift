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

    override func didMove(to view: SKView) {
        NotificationCenter.default.addObserver(self,
            selector: #selector(GameScene.controllerDidConnect(_:)),
            name: InputSourceManagerNotification.DidConnect,
            object: nil
        )

        NotificationCenter.default.addObserver(self,
            selector: #selector(GameScene.controllerDidDisconnect(_:)),
            name: InputSourceManagerNotification.DidDisconnect,
            object: nil
        )

        NotificationCenter.default.addObserver(self,
            selector: #selector(GameScene.controllerSlideModeChanged(_:)),
            name: InputSourceManagerNotification.SlideModeChanged,
            object: nil
        )

        if let microGamepad = InputSourceManager.sharedManager.microGamepad {
            setupMicroGamepad(microGamepad)

            if let label = childNode(withName: "SlideModeLabelNode") as? SKLabelNode {
                label.text = microGamepad.reportsAbsoluteDpadValues ? "slide mode off" : "slide mode on"
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
            name: InputSourceManagerNotification.DidConnect,
            object: nil
        )

        NotificationCenter.default.removeObserver(self,
            name: InputSourceManagerNotification.DidDisconnect,
            object: nil
        )

        NotificationCenter.default.removeObserver(self,
            name: InputSourceManagerNotification.SlideModeChanged,
            object: nil
        )
    }

    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }

    // MARK: Private Functions

    private func pressCorner(_ corner: PressedDPadCorner) {
        if let nodeForCorner = getNodeForCorner(corner) {
            let fadeAction = SKAction.fadeAlpha(to: 0.60, duration: 0.15)
            let scaleAction = SKAction.scale(to: 0.95, duration: 0.15)
            let soundAction = SKAction.playSoundFileNamed("sword", waitForCompletion: false)
            let sequence = SKAction.group([fadeAction, scaleAction, soundAction])

            nodeForCorner.run(sequence)
        }
    }

    private func unpressCorner(_ corner: PressedDPadCorner) {
        if let nodeForCorner = getNodeForCorner(corner) {
            let fadeAction = SKAction.fadeAlpha(to: 1.0, duration: 0.15)
            let scaleAction = SKAction.scale(to: 1.0, duration: 0.15)
            let sequence = SKAction.group([fadeAction, scaleAction])

            nodeForCorner.run(sequence)
        }
    }

    private func getNodeForCorner(_ corner: PressedDPadCorner) -> SKNode? {
        switch corner {
        case .topLeft:
            return childNode(withName: "TLNode")
        case .topRight:
            return childNode(withName: "TRNode")
        case .bottomRight:
            return childNode(withName: "BRNode")
        case .bottomLeft:
            return childNode(withName: "BLNode")
        case .none:
            return nil
        }
    }

    private func setupMicroGamepad(_ microGamepad: GCMicroGamepad) {
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


    @objc private func controllerDidConnect(_ notification: Notification) {
        if let microGamepad = InputSourceManager.sharedManager.microGamepad {
            setupMicroGamepad(microGamepad)
        }
    }

    @objc private func controllerDidDisconnect(_ notification: Notification) {
        // NO-OP
    }

    @objc private func controllerSlideModeChanged(_ notification: Notification) {
        if let microGamepad = InputSourceManager.sharedManager.microGamepad {
            if let label = childNode(withName: "SlideModeLabelNode") as? SKLabelNode {
                label.text = microGamepad.reportsAbsoluteDpadValues ? "slide mode off" : "slide mode on"
            }
        }
    }
}
