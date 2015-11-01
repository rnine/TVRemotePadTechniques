//
//  GameScene.swift
//  TVRemotePadTechniques
//
//  Created by Ruben Nine on 01/11/15.
//  Copyright (c) 2015 9Labs. All rights reserved.
//

import SpriteKit
import GameController

enum PressedCorner {
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
    case None
}

class GameScene: SKScene {

    var lastPressedCorner: PressedCorner = .None

    override func didMoveToView(view: SKView) {
        registerForGameControllerNotifications()
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }

    /// Register for `GCGameController` pairing notifications.
    func registerForGameControllerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleControllerDidConnectNotification:", name: GCControllerDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleControllerDidDisconnectNotification:", name: GCControllerDidDisconnectNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: GCControllerDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: GCControllerDidDisconnectNotification, object: nil)
    }

    // MARK: GCGameController Notification Handling

    @objc func handleControllerDidConnectNotification(notification: NSNotification) {
        let connectedGameController = notification.object as! GCController

        guard let microGamePad = connectedGameController.microGamepad else {
            return
        }

        // Enable absolute D-pad values (useful for 4-corner readings)
        microGamePad.reportsAbsoluteDpadValues = true

        // Allow the controller to transpose D-pad input values 90 degress in landscape mode
        microGamePad.allowsRotation = true

        // Enable continuous D-pad reading
        microGamePad.valueChangedHandler = { [unowned self] microGamePad, movement in
            if let dpad = movement as? GCControllerDirectionPad {
                let pressedCorner = self.findPressedDPadCorner(dpad)

                if self.lastPressedCorner != .None && pressedCorner != self.lastPressedCorner {
                    // Touch ended
                    self.unpressCorner(self.lastPressedCorner)
                    self.lastPressedCorner = .None
                }

                if pressedCorner != .None {
                    if self.lastPressedCorner == .None {
                        // Touch began
                        self.lastPressedCorner = pressedCorner
                        self.pressCorner(self.lastPressedCorner)
                    }
                }
            }
        }
    }

    @objc func handleControllerDidDisconnectNotification(notification: NSNotification) {
        // NO-OP
    }

    // MARK: Private Functions

    // Read D-Pad and return the active corner out of the 4 possible corners
    private func findPressedDPadCorner(dpad: GCControllerDirectionPad) -> PressedCorner {
        switch (dpad.xAxis.value, dpad.yAxis.value) {
        case (0, 0):
            return .None
        case (-1..<0, 0...1):
            return .TopLeft
        case (0...1, 0...1):
            return .TopRight
        case (0...1, -1..<0):
            return .BottomRight
        case (-1..<0, -1..<0):
            return .BottomLeft
        default:
            return .None
        }
    }

    private func pressCorner(corner: PressedCorner) {
        if let nodeForCorner = getNodeForCorner(corner) {
            let fadeAction = SKAction.fadeAlphaTo(0.60, duration: 0.15)
            let scaleAction = SKAction.scaleTo(0.95, duration: 0.15)
            let soundAction = SKAction.playSoundFileNamed("sword", waitForCompletion: false)
            let sequence = SKAction.group([fadeAction, scaleAction, soundAction])

            nodeForCorner.runAction(sequence)
        }
    }

    private func unpressCorner(corner: PressedCorner) {
        if let nodeForCorner = getNodeForCorner(corner) {
            let fadeAction = SKAction.fadeAlphaTo(1.0, duration: 0.15)
            let scaleAction = SKAction.scaleTo(1.0, duration: 0.15)
            let sequence = SKAction.group([fadeAction, scaleAction])

            nodeForCorner.runAction(sequence)
        }
    }

    private func getNodeForCorner(corner: PressedCorner) -> SKNode? {
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
}
