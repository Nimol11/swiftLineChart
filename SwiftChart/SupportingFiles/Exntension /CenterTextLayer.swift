//
//  CenterTextLayer.swift
//  SwiftAnimation
//
//  Created by Nimol on 22/7/24.
//

import UIKit


public class CenterTextLayer: CATextLayer {
    
    public override init() {
        super.init()
        self.setup()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        self.setup()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(layer: aDecoder)
        self.setup()
    }
    
    public override func draw(in ctx: CGContext) {
       
        let multiplier = CGFloat(1)
        let yDiff = (bounds.size.height - ((string as? NSAttributedString)?.size().height ?? fontSize)) / 2 * multiplier
        ctx.saveGState()
        
        ctx.translateBy(x: 0.0, y: yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
    
    fileprivate func setup() {
        isWrapped = true
        alignmentMode = .center
        allowsEdgeAntialiasing = true
        contentsScale = UIScreen.main.scale
    }
}
