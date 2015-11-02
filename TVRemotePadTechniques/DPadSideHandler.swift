//
//  DPadSideHandler.swift
//  TVRemotePadTechniques
//
//  Created by Ruben Nine on 02/11/15.
//  Copyright © 2015 9Labs. All rights reserved.
//

import UIKit

enum PressedDPadSide {
    case Left
    case Right
    case Up
    case Down
    case None
}

private struct Triangle {
    let p1: CGPoint
    let p2: CGPoint
    let p3: CGPoint
}

typealias DPadSideHandlerPressBlock = PressedDPadSide -> Void

class DPadSideHandler: NSObject {

    private var lastPressedSide: PressedDPadSide = .None

    // Up triangle: (-1, 1), (1, 1), (0, 0)
    private let upTriangle = Triangle(p1: CGPoint(x: -1, y: 1), p2: CGPoint(x: 1, y: 1), p3: CGPoint(x: 0, y: 0))

    // Down triangle: (-1, -1), (1, -1), (0, 0)
    private let downTriangle = Triangle(p1: CGPoint(x: -1, y: -1), p2: CGPoint(x: 1, y: -1), p3: CGPoint(x: 0, y: 0))

    // Left triangle: (-1, 1), (-1, -1), (0, 0)
    private let leftTriangle = Triangle(p1: CGPoint(x: -1, y: 1), p2: CGPoint(x: -1, y: -1), p3: CGPoint(x: 0, y: 0))

    // Right triangle: (1, 1), (1, -1), (0, 0)
    private let rightTriangle = Triangle(p1: CGPoint(x: 1, y: 1), p2: CGPoint(x: 1, y: -1), p3: CGPoint(x: 0, y: 0))

    func handlePress(xAxis xAxis: CGFloat, yAxis: CGFloat, onPress: DPadSideHandlerPressBlock, onRelease: DPadSideHandlerPressBlock) {
        let pressedSide = findPressedSide(xAxis, yAxis: yAxis)

        if lastPressedSide != .None && pressedSide != lastPressedSide {
            // Touch ended
            onRelease(lastPressedSide)
            lastPressedSide = .None
        }

        if pressedSide != .None {
            if lastPressedSide == .None {
                // Touch began
                lastPressedSide = pressedSide
                onPress(lastPressedSide)
            }
        }
    }

    // MARK: Private Functions

    // Read D-Pad and return the active side out of the 4 possible sides
    private func findPressedSide(xAxis: CGFloat, yAxis: CGFloat) -> PressedDPadSide {
        let point = CGPoint(x: xAxis, y: yAxis)

        if (isPointInsideTriangle(point, triangle: upTriangle)) {
            return .Up
        }

        if (isPointInsideTriangle(point, triangle: downTriangle)) {
            return .Down
        }

        if (isPointInsideTriangle(point, triangle: leftTriangle)) {
            return .Left
        }

        if (isPointInsideTriangle(point, triangle: rightTriangle)) {
            return .Right
        }
        
        return .None
    }

    // Function based on "John Bananas" response for
    // http://stackoverflow.com/questions/2049582/how-to-determine-a-point-in-a-triangle
    private func isPointInsideTriangle(point: CGPoint, triangle: Triangle) -> Bool {
        let as_x = point.x - triangle.p1.x
        let as_y = point.y - triangle.p1.y
        let bs_x = point.x - triangle.p2.x
        let bs_y = point.y - triangle.p2.y

        let s_ab_1 = (triangle.p2.x - triangle.p1.x) * as_y
        let s_ab_2 = (triangle.p2.y - triangle.p1.y) * as_x
        let s_ab = (s_ab_1 - s_ab_2) > 0

        let s_ca_1 = (triangle.p3.x - triangle.p1.x) * as_y
        let s_ca_2 = (triangle.p3.y - triangle.p1.y) * as_x
        let s_ca = (s_ca_1 - s_ca_2) > 0

        let s_cb_1 = (triangle.p3.x - triangle.p2.x) * bs_y
        let s_cb_2 = (triangle.p3.y - triangle.p2.y) * bs_x
        let s_cb = (s_cb_1 - s_cb_2) > 0

        if s_ca == s_ab {
            return false
        }

        if s_cb != s_ab {
            return false
        }
        
        return true
    }
}
