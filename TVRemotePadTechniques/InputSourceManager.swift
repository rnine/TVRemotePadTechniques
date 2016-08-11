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
    static let DidConnect = Notification.Name("InputSourceManagerDidConnectNotification")
    static let DidDisconnect = Notification.Name("InputSourceManagerDidDisconnectNotification")
    static let SlideModeChanged = Notification.Name("InputSourceManagerSlideModeChangedNotification")
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
        NotificationCenter.default.addObserver(self,
            selector: #selector(InputSourceManager.handleControllerDidConnectNotification(_:)),
            name: NSNotification.Name.GCControllerDidConnect,
            object: nil
        )

        NotificationCenter.default.addObserver(self,
            selector: #selector(InputSourceManager.handleControllerDidDisconnectNotification(_:)),
            name: NSNotification.Name.GCControllerDidDisconnect,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.GCControllerDidConnect,
            object: nil
        )

        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.GCControllerDidDisconnect,
            object: nil
        )
    }

    // MARK: GCGameController Notification Handling

    @objc private func handleControllerDidConnectNotification(_ notification: Notification) {
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

                NotificationCenter.default.post(name: InputSourceManagerNotification.SlideModeChanged,
                    object: connectedGameController
                )
            }
        }

        NotificationCenter.default.post(name: InputSourceManagerNotification.DidConnect,
            object: connectedGameController
        )
    }

    @objc private func handleControllerDidDisconnectNotification(_ notification: Notification) {
        let disconnectedGameController = notification.object as! GCController

        NotificationCenter.default.post(name: InputSourceManagerNotification.DidDisconnect,
            object: disconnectedGameController
        )
    }
}
