//
//  DPadSideHandler.swift
//  TVRemotePadTechniques
//
//  Created by Ruben Nine on 02/11/15.
//  Copyright © 2015 9Labs. All rights reserved.
//

import UIKit

enum PressedDPadCorner {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case none
}

typealias DPadCornerHandlerPressBlock = (PressedDPadCorner) -> Void

class DPadCornerHandler: NSObject {

    private var lastPressedCorner: PressedDPadCorner = .none

    func handlePress(xAxis: CGFloat, yAxis: CGFloat, onPress: DPadCornerHandlerPressBlock, onRelease: DPadCornerHandlerPressBlock) {
        let pressedCorner = findPressedCorner(xAxis, yAxis: yAxis)

        if lastPressedCorner != .none && pressedCorner != lastPressedCorner {
            // Touch ended
            onRelease(lastPressedCorner)
            lastPressedCorner = .none
        }

        if pressedCorner != .none {
            if lastPressedCorner == .none {
                // Touch began
                lastPressedCorner = pressedCorner
                onPress(lastPressedCorner)
            }
        }
    }

    // MARK: Private Functions

    // Read D-Pad and return the active corner out of the 4 possible corners
    private func findPressedCorner(_ xAxis: CGFloat, yAxis: CGFloat) -> PressedDPadCorner {
        switch (xAxis, yAxis) {
        case (0, 0):
            return .none
        case (-1..<0, 0...1):
            return .topLeft
        case (0...1, 0...1):
            return .topRight
        case (0...1, -1..<0):
            return .bottomRight
        case (-1..<0, -1..<0):
            return .bottomLeft
        default:
            return .none
        }
    }
}
