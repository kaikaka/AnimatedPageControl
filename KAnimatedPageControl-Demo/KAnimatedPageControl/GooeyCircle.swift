//
//  GooeyCircle.swift
//  KAnimatedPageControl-Demo
//
//  Created by KaiKing on 2019/2/25.
//  Copyright © 2019 K. All rights reserved.
//

import UIKit

/// 圆形

class GooeyCircle: Indicator {
    //@NSManaged修饰符 来声明自动生成方法。(必须加这个否则动画监听不到factor的值的变化,为了找到原因我查了3个小时资料)
    @NSManaged var factor:CGFloat
    
    var beginGooeyAnim:Bool = false
    override init(layer: Any) {
        super.init(layer: layer)
        let aLayer = layer as! GooeyCircle
        self.indicatorSize = aLayer.indicatorSize;
        self.indicatorColor = aLayer.indicatorColor;
        self.currentRect = aLayer.currentRect;
        self.lastContentOffset = aLayer.lastContentOffset;
        self.scrollDirection = aLayer.scrollDirection;
        self.factor = aLayer.factor;
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(in ctx: CGContext) {
        
        let offset = self.currentRect.size.width / 3.6
        let extra = (self.currentRect.size.width * 0.36 ) * factor
        
        /// 注意坐标系 是[0,0]
        let rectCenter = CGPoint.init(x: self.currentRect.origin.x + self.currentRect.size.width / 2, y: self.currentRect.origin.y + self.currentRect.size.height / 2)
        
        /// A点变化，当移动时 A点需要向中心点靠拢 A的y的最大值 outsideRect.origin.y + outsideRect.size.height / 2,同时x 跟随矩形的x变化
        let pointA = CGPoint.init(x: rectCenter.x, y: self.currentRect.origin.y + extra)
        /// D点不动情况下，移动的点是Point_B， B的x的值随着移动的变化,反之不会变化
        let pointB = CGPoint.init(x: self.scrollDirection == ScrollDirection.Right ? rectCenter.x + self.currentRect.size.width / 2 + extra * 2 : rectCenter.x + self.currentRect.size.width / 2, y: rectCenter.y)
        /// C点变化，同A点类似
        let pointC = CGPoint.init(x: rectCenter.x, y: rectCenter.y + self.currentRect.size.height / 2 - extra)
        /// D点变化，同B点类似
        let pointD = CGPoint.init(x: self.scrollDirection == ScrollDirection.Right ? self.currentRect.origin.x  : self.currentRect.origin.x - extra * 2, y: rectCenter.y)
        
        let c1 = CGPoint.init(x: pointA.x + offset, y: pointA.y)
        let c2 = CGPoint.init(x: pointB.x, y: pointB.y - offset )
        
        let c3 = CGPoint.init(x: pointB.x, y: pointB.y + offset)
        let c4 = CGPoint.init(x: pointC.x + offset, y: pointC.y)
        
        let c5 = CGPoint.init(x: pointC.x - offset, y: pointC.y)
        let c6 = CGPoint.init(x: pointD.x, y:pointD.y + offset)
        
        let c7 = CGPoint.init(x: pointD.x, y:pointD.y - offset )
        let c8 = CGPoint.init(x: pointA.x - offset, y: pointA.y)
        
        
        // 圆的边界
        let ovalPath = UIBezierPath.init()
        ovalPath.move(to: pointA)
        ovalPath.addCurve(to: pointB, controlPoint1: c1, controlPoint2: c2)
        ovalPath.addCurve(to: pointC, controlPoint1: c3, controlPoint2: c4)
        ovalPath.addCurve(to: pointD, controlPoint1: c5, controlPoint2: c6)
        ovalPath.addCurve(to: pointA, controlPoint1: c7, controlPoint2: c8)
        ovalPath.close()
        
        ctx.addPath(ovalPath.cgPath)
        ctx.setFillColor(self.indicatorColor.cgColor)
        ctx.fillPath()
    }
    
    override func animateIndicatorWithScrollView(_ scrollView: UIScrollView, pgctl: KAnimatedPageControl) {
        
        // scrollView.contentOffset.x - self.lastContentOffset >= 0 表示方向，
        if scrollView.contentOffset.x - self.lastContentOffset >= 0 && scrollView.contentOffset.x - self.lastContentOffset <= scrollView.frame.size.width / 2 {
            self.scrollDirection = ScrollDirection.Left
        } else if scrollView.contentOffset.x - self.lastContentOffset <= 0 &&
            scrollView.contentOffset.x - self.lastContentOffset >= -(scrollView.frame.size.width) / 2 {
            self.scrollDirection = ScrollDirection.Right
        }
        
        if !beginGooeyAnim {
            factor = min(1, max(0, abs(scrollView.contentOffset.x - self.lastContentOffset) / scrollView.frame.size.width))
        }
        
        /// 计算矩形x坐标点
        let originX:CGFloat = scrollView.contentOffset.x / CGFloat(scrollView.frame.size.width) * CGFloat(((pgctl.frame.size.width - pgctl.ballDiameter * 2) / CGFloat((pgctl.pageCount - 1))))
        
        /// 防止越界
        if originX - self.indicatorSize / 2 <= 0 {
            self.currentRect = CGRect.init(x: 0, y: self.frame.size.height / 2 - self.indicatorSize / 2, width: self.indicatorSize, height: self.indicatorSize)
        } else if originX - self.indicatorSize / 2 >= self.frame.size.width - self.indicatorSize {
            self.currentRect = CGRect.init(x: self.frame.size.width - self.indicatorSize , y: self.frame.size.height / 2 - self.indicatorSize / 2, width: self.indicatorSize, height: self.indicatorSize)
        } else {
            /// min(originX, self.frame.size.width - self.indicatorSize) 最大的时候滑动要保持不动
            self.currentRect = CGRect.init(x: min(originX, self.frame.size.width - self.indicatorSize), y: self.frame.size.height / 2 - self.indicatorSize / 2, width: self.indicatorSize, height: self.indicatorSize)
        }
        self.setNeedsDisplay()
    }
    
    override func restoreAnimation(_ howmanydistance: Any) {
        
        let disNum = howmanydistance as? NSNumber
        let anim = KSpringLayerAnimation.sharedAnimManager.createSpringAnima("factor", duration: 0.8,
                                                                             usingSpringWithDamping: 0.5,
                                                                             initialSpringVelocity: 3,
                                                                             fromValue: NSNumber.init(value: 0.5 + (disNum?.floatValue)! * 1.5),
                                                                             toValue: NSNumber.init(value: 0))

        anim.delegate = self
        self.factor = 0
        self.add(anim, forKey: "restoreAnimation")
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "factor" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        beginGooeyAnim = true
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            beginGooeyAnim = false
            self.removeAllAnimations()
            /// 这里必须置为零 因为removeAllAnimations后回再次回调draw方法
            self.factor = 0
        }
    }
}
