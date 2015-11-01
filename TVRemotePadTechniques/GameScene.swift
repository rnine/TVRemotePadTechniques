//
//  GameScene.swift
//  FourCornerPad
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

        // Enable continuous dpad reading
        microGamePad.valueChangedHandler = { [unowned self] microGamePad, movement in
            if let dpad = movement as? GCControllerDirectionPad {

                switch (dpad.xAxis.value, dpad.yAxis.value) {
                case (0, 0):
                    if self.lastPressedCorner != .None {
                        // Touch finished

                        if let nodeForCorner = self.getNodeForCorner(self.lastPressedCorner) {
                            let unfadeAction = SKAction.fadeAlphaTo(1.0, duration: 0.15)
                            nodeForCorner.runAction(unfadeAction)
                        }

                        self.lastPressedCorner = .None
                    }
                default:
                    if self.lastPressedCorner == .None {
                        // Touch began

                        self.lastPressedCorner = self.handleDPad(dpad)

                        if let nodeForCorner = self.getNodeForCorner(self.lastPressedCorner) {
                            let fadeAction = SKAction.fadeAlphaTo(0.5, duration: 0.15)
                            nodeForCorner.runAction(fadeAction)
                        }
                    }
                }
            }
        }
    }

    @objc func handleControllerDidDisconnectNotification(notification: NSNotification) {
        // NO-OP
    }

    // MARK: Private Functions

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

    private func handleDPad(dpad: GCControllerDirectionPad) -> PressedCorner {
        print("D-pad x: \(dpad.xAxis.value), y: \(dpad.yAxis.value)")

        // Naive 4-corner detection
        switch (dpad.xAxis.value, dpad.yAxis.value) {
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
}
