//
//  DPadSideHandler.swift
//  TVRemotePadTechniques
//
//  Created by Ruben Nine on 02/11/15.
//  Copyright © 2015 9Labs. All rights reserved.
//

import UIKit

enum PressedDPadCorner {
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
    case None
}

typealias DPadCornerHandlerPressBlock = PressedDPadCorner -> Void

class DPadCornerHandler: NSObject {

    private var lastPressedCorner: PressedDPadCorner = .None

    func handlePress(xAxis xAxis: CGFloat, yAxis: CGFloat, onPress: DPadCornerHandlerPressBlock, onRelease: DPadCornerHandlerPressBlock) {
        let pressedCorner = findPressedCorner(xAxis, yAxis: yAxis)

        if lastPressedCorner != .None && pressedCorner != lastPressedCorner {
            // Touch ended
            onRelease(lastPressedCorner)
            lastPressedCorner = .None
        }

        if pressedCorner != .None {
            if lastPressedCorner == .None {
                // Touch began
                lastPressedCorner = pressedCorner
                onPress(lastPressedCorner)
            }
        }
    }

    // MARK: Private Functions

    // Read D-Pad and return the active corner out of the 4 possible corners
    private func findPressedCorner(xAxis: CGFloat, yAxis: CGFloat) -> PressedDPadCorner {
        switch (xAxis, yAxis) {
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
}
