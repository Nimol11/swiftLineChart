//
//  UIViewExtension.swift
//  SwiftChart
//
//  Created by Nimol on 30/7/24.
//

import UIKit
extension UIView {
    
 
     func line(from startPoint: CGPoint,
                          to endPoint: CGPoint,
                          frame: CGRect,
                          value: Double = 0,
                          color: UIColor = .black,
                          width: CGFloat = 1.0,
                          dashPatern: [NSNumber] = [],
                          _ dispatchQueue: DispatchQueue = .init(label: "line_queue"),
                          _ completion: @escaping (CALayer) -> Void) {
        
        dispatchQueue.async {
            var xStart = startPoint.x
            var yStart = startPoint.y
            if xStart.isNaN { xStart = 0 }
            if yStart.isNaN {
                if value != 0 {
                    yStart = 0
                } else {
                    yStart = frame.size.height - 22
                }
            }
            var xEnd = endPoint.x
            var yEnd = endPoint.y
            if xEnd.isNaN { xEnd = 0 }
            if yEnd.isNaN {
                if value != 0 {
                    yEnd = 0
                } else {
                    yEnd = frame.size.height - 22
                }
            }
            
            let line = CAShapeLayer()
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: xStart, y: yStart))
            linePath.addLine(to: CGPoint(x: xEnd, y: yEnd))
            
            line.path = linePath.cgPath
            line.strokeColor = color.cgColor
            line.lineWidth = width
            line.lineCap = .round
            line.lineDashPattern = dashPatern
            completion(line)
        }
    }
}
