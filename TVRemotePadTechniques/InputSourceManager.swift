//
//  InputSourceManager.swift
//  TVRemotePadTechniques
//
//  Created by Ruben Nine on 02/11/15.
//  Copyright © 2015 9Labs. All rights reserved.
//

import UIKit
import GameController

struct InputSourceManagerNotification {
    static let DidConnect = "InputSourceManagerDidConnectNotification"
    static let DidDisconnect = "InputSourceManagerDidDisconnectNotification"
    static let SlideModeChanged = "InputSourceManagerSlideModeChanged"
}

class InputSourceManager: NSObject {

    var microGamepad: GCMicroGamepad?

    /**
     A singleton instance of `InputSourceManager`.
     */
    static let sharedManager = InputSourceManager()

    private override init() {
        super.init()
        registerForGameControllerNotifications()
    }

    /// Register for `GCGameController` pairing notifications.
    private func registerForGameControllerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleControllerDidConnectNotification:",
            name: GCControllerDidConnectNotification,
            object: nil
        )

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleControllerDidDisconnectNotification:",
            name: GCControllerDidDisconnectNotification,
            object: nil
        )
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: GCControllerDidConnectNotification,
            object: nil
        )

        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: GCControllerDidDisconnectNotification,
            object: nil
        )
    }

    // MARK: GCGameController Notification Handling

    @objc private func handleControllerDidConnectNotification(notification: NSNotification) {
        let connectedGameController = notification.object as! GCController

        microGamepad = connectedGameController.microGamepad

        // Enable absolute D-pad values (useful for 4-corner readings)
        // Disable to use slide mode
        microGamepad?.reportsAbsoluteDpadValues = true

        // Allow the controller to transpose D-pad input values 90 degress in landscape mode
        microGamepad?.allowsRotation = true

        // Handle A-button press (touchpad click)
        microGamepad?.buttonA.pressedChangedHandler = { _, _, pressed in
            if pressed {
                self.microGamepad!.reportsAbsoluteDpadValues = !self.microGamepad!.reportsAbsoluteDpadValues

                NSNotificationCenter.defaultCenter().postNotificationName(InputSourceManagerNotification.SlideModeChanged,
                    object: connectedGameController
                )
            }
        }

        NSNotificationCenter.defaultCenter().postNotificationName(InputSourceManagerNotification.DidConnect,
            object: connectedGameController
        )
    }

    @objc private func handleControllerDidDisconnectNotification(notification: NSNotification) {
        let disconnectedGameController = notification.object as! GCController

        NSNotificationCenter.defaultCenter().postNotificationName(InputSourceManagerNotification.DidDisconnect,
            object: disconnectedGameController
        )
    }
}
