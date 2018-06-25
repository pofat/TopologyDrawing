//
//  TopologyView.swift
//  TopologyMusicNode
//
//  Created by Pofat Tseng on 2018/3/18.
//  Copyright © 2018年 Pofat. All rights reserved.
//

import UIKit

class TopologyView: UIView {
    
    var isBlue = false
    var state: ViewController.State = .noTopology {
        didSet {
            DispatchQueue.main.async {
                self.layoutSubviews()
            }
        }
    }
    weak var topology: Topology? = nil
    var tagToViewCache: [Int: CircleView] = [:]
    var answer: [Node]? = nil
    
    private let cubicCurveHandler = CubicCurveHandler()

    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Build view cache so that we can access each view of node easily.
        if tagToViewCache.isEmpty {
            for i in -1...15 {
                let tag = 500 + i
                if let index = subviews.index(where: { $0.tag == tag }), let foundView = subviews[index] as? CircleView {
                    tagToViewCache[tag] = foundView
                }
            }
        }
        
        guard let topology = topology else {
            return
        }
        
        layer.sublayers?.forEach { layer in
            
            if let _ = layer.delegate as? CircleView {
                // do not remove CircleViews' layer
            } else {
                layer.removeFromSuperlayer()
            }
        }
        
        switch state {
        case .noTopology:
            return
        case .notCalculated:
            // Draw edges
            for n in topology.nodes {
                let fromView = tagToViewCache[n.id + 500]!
                for c in n.children {
                    let toView = tagToViewCache[c.id + 500]!
                    let points = pointPositionHelper(from: fromView, to: toView, allViewCache: tagToViewCache)
                    let layers = smoothArrowLayer(of: points)
                    layer.addSublayer(layers.line)
                    layer.addSublayer(layers.arrow)
                }
            }
        case .calculated:
            // Draw edgs
            for n in topology.nodes {
                let fromView = tagToViewCache[n.id + 500]!
                for c in n.children {
                    let toView = tagToViewCache[c.id + 500]!
                    let points = pointPositionHelper(from: fromView, to: toView, allViewCache: tagToViewCache)
                    let layers = smoothArrowLayer(of: points)
                    layer.addSublayer(layers.line)
                    layer.addSublayer(layers.arrow)
                }
            }
            
            // Mark result edges as red
            
            guard let answer = answer else {
                return
            }
            
            guard !answer.isEmpty else {
                return
            }
            
            for i in 0 ..< answer.count - 1 {
                let fromNode = answer[i]
                let toNode = answer[i + 1]
                
                let fromView = tagToViewCache[fromNode.id + 500]!
                let toView = tagToViewCache[toNode.id + 500]!
                
                let points = pointPositionHelper(from: fromView, to: toView, allViewCache: tagToViewCache)
                let layers = smoothArrowLayer(of: points, color: .red)
                layer.addSublayer(layers.line)
                layer.addSublayer(layers.arrow)
            }
        }
        
        layer.sublayers!.filter {
            if let _ = $0.delegate as? CircleView {
                return true
            } else { return false }
            }.forEach {
                $0.zPosition = 99
        }
        
    }
    
    private func smoothArrowLayer(of points: [CGPoint], color: UIColor = .black) -> (line: CAShapeLayer, arrow: CAShapeLayer) {
        
        guard points.count >= 2 else {
            // return empaty layers
            return (CAShapeLayer(), CAShapeLayer())
        }
        
        let linePath = UIBezierPath()
        
        if points.count > 2 { // curve
            let controlPoints = cubicCurveHandler.controlPoints(from: points)
            
            for i in 0 ..< points.count {
                
                let point = points[i];
                
                if i==0 {
                    linePath.move(to: point)
                } else {
                    let segment = controlPoints[i-1]
                    linePath.addCurve(to: point, controlPoint1: segment.firstControlPoint, controlPoint2: segment.secondControlPoint)
                }
            }
        } else { // straight line
            linePath.move(to: points.first!)
            linePath.addLine(to: points.last!)
        }
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = color.cgColor
        lineLayer.lineWidth = Constants.lineWidth
        
        let arrowStartPoint = calculateArrowStartPoistion(from: points[points.endIndex - 2], to: points.last!, arrowHeadLength: Constants.arrowHeadLength)
        let arrowLayer = CAShapeLayer()
        arrowLayer.path = UIBezierPath.arrow(from: arrowStartPoint, to: points.last!, tailWidth: Constants.lineWidth, headWidth: Constants.arrowHeadWidth, headLength: Constants.arrowHeadLength).cgPath
        arrowLayer.fillColor = color.cgColor
        
        return (lineLayer, arrowLayer)
    }
    
    
    // For debug, draw all the points.
    private func drawPoints(points: [CGPoint]) -> [CAShapeLayer] {

        var layers: [CAShapeLayer] = []
        for point in points {
            
            let circleLayer = CAShapeLayer()
            circleLayer.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
            circleLayer.path = UIBezierPath(ovalIn: circleLayer.bounds).cgPath
            circleLayer.fillColor = UIColor(white: 248.0/255.0, alpha: 0.5).cgColor
            circleLayer.position = point
            
            circleLayer.shadowColor = UIColor.black.cgColor
            circleLayer.shadowOffset = CGSize(width: 0, height: 2)
            circleLayer.shadowOpacity = 0.7
            circleLayer.shadowRadius = 3.0
            
            layers.append(circleLayer)
        }
        
        return layers
    }
    
    private func calculateArrowStartPoistion(from: CGPoint, to: CGPoint, arrowHeadLength: CGFloat) -> CGPoint {
        guard from != to else {
            return from
        }
        
        if from.x == to.x {
            return CGPoint(x: to.x, y: (from.y > to.y) ? to.y + arrowHeadLength : to.y - arrowHeadLength)
        } else if from.y == to.y {
            return CGPoint(x: (from.x > to.x) ? to.x + arrowHeadLength : to.x - arrowHeadLength, y: to.y)
        } else {
            // 用分點公式求箭頭起點位置
            let dist = CGFloat(sqrt(pow(Double(to.x - from.x), 2) + pow(Double(to.y - from.y), 2)))
            let x = ( (dist - arrowHeadLength) * to.x + arrowHeadLength * from.x ) / dist
            let y = ( (dist - arrowHeadLength) * to.y + arrowHeadLength * from.y ) / dist
            
            return CGPoint(x: x, y: y)
        }
        
    }

}


