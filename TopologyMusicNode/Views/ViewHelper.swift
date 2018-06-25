//
//  File.swift
//  TopologyMusicNode
//
//  Created by Pofat Tseng on 2018/3/19.
//  Copyright © 2018年 Pofat. All rights reserved.
//

import UIKit


/// Compare two nodes and give a tuple to indicate where we should start and end their linked edge
///
/// - Parameters:
///   - from: source node view
///   - to: destination node view
/// - Returns: All points that this line travles
func pointPositionHelper(from: CircleView, to: CircleView, allViewCache cache: [Int: CircleView]) -> [CGPoint] {//(from: CGPoint, to: CGPoint, through: [CGPoint]) {
    // To is at right side ( --> )
    if to.frame.minX > from.frame.minX {
        var result: [CGPoint] = [CGPoint(x: from.frame.maxX, y: from.center.y)]
        
        // XXX: find from next node to end if there's any intersection, kinda workaround
        for i in (from.tag + 1) ... 515 {
            let view = cache[i]!
            if !view.isHidden {
                let intersectionPoints = nearestVertext(segmentStart: CGPoint(x: from.frame.maxX, y: from.center.y), segmentEnd: CGPoint(x: to.frame.minX, y: to.center.y), with: view.frame)
                if !intersectionPoints.isEmpty {
                    result.append(contentsOf: intersectionPoints)
                }
            }
        }
        
        result.append(CGPoint(x: to.frame.minX, y: to.center.y))
        return result
    } else if to.frame.minY > from.frame.minY { // arrow donw( V )
        var result: [CGPoint] = [CGPoint(x: from.center.x, y: from.frame.maxY)]
        if to.tag - from.tag > 1 { // one node between
            let middleView = cache[(to.tag + from.tag)/2]!
            if !middleView.isHidden {
                // Give two most right vertices
                result.append(CGPoint(x: middleView.frame.maxX, y: middleView.frame.minY))
                result.append(CGPoint(x: middleView.frame.maxX, y: middleView.frame.maxY))
            }
        }
        result.append(CGPoint(x: to.center.x, y: to.frame.minY))
        return result
    } else if to.frame.minY < from.frame.minY { // arrow up ( ^ )
        var result: [CGPoint] = [CGPoint(x: from.center.x, y: from.frame.minY)]
        if from.tag - to.tag > 1 { // one node between
            let middleView = cache[(to.tag + from.tag)/2]!
            if !middleView.isHidden {
                // Give two most right vertices
                result.append(CGPoint(x: middleView.frame.maxX, y: middleView.frame.maxY))
                result.append(CGPoint(x: middleView.frame.maxX, y: middleView.frame.minY))

            }
        }
        result.append(CGPoint(x: to.center.x, y: to.frame.maxY))
        return result
    } else { // Two nodes at same poistion
        return []
    }
}


/// Find if a segment intersects with a rectangle and return the points for bezier path to byass this rectangle
///
/// - Parameters:
///   - from: segment start
///   - to: segment end
///   - rect:  target rectangle
///   - passAbove: if the path go up to avoid rect
/// - Returns: Empty means no intersection.
func nearestVertext(segmentStart from: CGPoint, segmentEnd to: CGPoint, with rect: CGRect, passAbove: Bool = false) -> [CGPoint] {
    enum Position: String {
        case top, left, right, bottom
    }

    // 矩形頂點，從左上開始順時針方向
    let vertices = [CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.maxY), CGPoint(x: rect.minX, y: rect.maxY)]
    // four edges of the rect
    let edgesOfRect: [(from: CGPoint, to: CGPoint, pos: Position)] = [
        (vertices[0], vertices[1], .top), // top
        (vertices[0], vertices[3], .left), // left
        (vertices[1], vertices[2], .right), // right
        (vertices[2], vertices[3], .bottom)  // bottom
    ]
    
    var intersection: Set<Position> = []
    
    for edge in edgesOfRect {
        let d = (to.x - from.x) * (edge.to.y - edge.from.y) - (to.y - from.y) * (edge.to.x - edge.from.x)
        if d == 0 {
            // parallel
            continue
        }
        
        let u = ((edge.from.x - from.x) * (edge.to.y - edge.from.y) - (edge.from.y - from.y) * (edge.to.x - edge.from.x)) / d
        let v = ((edge.from.x - from.x) * (to.y - from.y) - (edge.from.y - from.y) * (to.x - from.x)) / d
        if u < 0.0 || u > 1.0 {
            // intersection not between segmentation
            continue
        }
        
        if v < 0.0 || v > 1.0 {
            // intersection not between rect edge
            continue
        }
        
        intersection.insert(edge.pos)
    }
    
    if intersection.isEmpty { return [] }
    
    if intersection.contains(.left) && intersection.contains(.top) {
        return [vertices[0]]
    } else if intersection.contains(.left) && intersection.contains(.bottom) {
        return [vertices[3]]
    } else if intersection.contains(.right) && intersection.contains(.top) {
        return [vertices[1]]
    } else if intersection.contains(.right) && intersection.contains(.bottom) {
        return [vertices[2]]
    } else if intersection.contains(.left) && intersection.contains(.right) {
        return passAbove ? [vertices[0], vertices[1]] : [vertices[3], vertices[2]]
    } else {
        return []
    }
    
}


struct Constants {
    static let lineWidth: CGFloat = 1.0
    static let arrowHeadWidth: CGFloat = 6.0
    static let arrowHeadLength: CGFloat = 6.0
}



extension UIBezierPath {

    // Generate an arrow path
    static func arrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> UIBezierPath {
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength
        
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }
        let points: [CGPoint] = [
            p(0, tailWidth / 2),
            p(tailLength, tailWidth / 2),
            p(tailLength, headWidth / 2),
            p(length, 0),
            p(tailLength, -headWidth / 2),
            p(tailLength, -tailWidth / 2),
            p(0, -tailWidth / 2)
        ]
        
        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)
        
        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        path.closeSubpath()
        
        return self.init(cgPath: path)
    }
    
}
