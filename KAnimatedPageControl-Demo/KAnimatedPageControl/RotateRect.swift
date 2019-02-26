//
//  RotateRect.swift
//  KAnimatedPageControl-Demo
//
//  Created by KaiKing on 2019/2/25.
//  Copyright © 2019 K. All rights reserved.
//

import UIKit

/// 方形
class RotateRect: Indicator {
    
    @NSManaged var indexRot:CGFloat
    
    override init(layer: Any) {
        super.init(layer: layer)
        let aLayer = layer as! RotateRect
        self.indicatorSize = aLayer.indicatorSize;
        self.indicatorColor = aLayer.indicatorColor;
        self.currentRect = aLayer.currentRect;
        self.lastContentOffset = aLayer.lastContentOffset;
        
        self.indexRot = aLayer.indexRot;
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "indexRot" {
            print("indexRot")
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override func animateIndicatorWithScrollView(_ scrollView: UIScrollView, pgctl: KAnimatedPageControl) {
        assert(pgctl.pageCount != 1, "ERROR:pageCount must be greater than one")
        
        let originX:CGFloat = scrollView.contentOffset.x / CGFloat(scrollView.frame.size.width) * CGFloat(((pgctl.frame.size.width - pgctl.ballDiameter * 2) / CGFloat((pgctl.pageCount - 1))))
        /// 改变索引
        indexRot = (scrollView.contentOffset.x / scrollView.frame.size.width)
        
        if originX - self.indicatorSize / 2 <= 0 {
            self.currentRect = CGRect.init(x: 0, y: self.frame.size.height / 2 - self.indicatorSize / 2, width: self.indicatorSize, height: self.indicatorSize)
        } else if originX - self.indicatorSize / 2 >= self.frame.size.width - self.indicatorSize {
            self.currentRect = CGRect.init(x: self.frame.size.width - self.indicatorSize , y: self.frame.size.height / 2 - self.indicatorSize / 2, width: self.indicatorSize, height: self.indicatorSize)
        } else {
            self.currentRect = CGRect.init(x: min(originX, self.frame.size.width - self.indicatorSize), y: self.frame.size.height / 2 - self.indicatorSize / 2, width: self.indicatorSize, height: self.indicatorSize)
        }
        self.setNeedsDisplay()
    }
    
    func createPathRotatedAroundBoundingBoxCenter(_ path:CGPath,radians:CGFloat) -> CGPath {
        let bounds = path.boundingBoxOfPath
        let center = CGPoint.init(x: bounds.origin.x + bounds.size.width / 2, y: bounds.origin.y + bounds.size.height / 2)
        
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: center.x, y: center.y)
        transform = transform.rotated(by: radians)
        transform = transform.translatedBy(x: -center.x, y: -center.y)
        
        return path.copy(using: &transform)!
    }
    
    override func draw(in ctx: CGContext) {
        
        let rectPath = UIBezierPath.init(rect: self.currentRect)
        let path = self.createPathRotatedAroundBoundingBoxCenter(rectPath.cgPath, radians: indexRot * CGFloat(Double.pi/2))
        rectPath.cgPath = path
        
        ctx.addPath(path)
        ctx.setFillColor(self.indicatorColor.cgColor)
        ctx.fillPath()
    }
    
    override func restoreAnimation(_ howmanydistance: Any) {
        
    }
}
