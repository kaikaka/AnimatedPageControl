//
//  Line.swift
//  KAnimatedPageControl-Demo
//
//  Created by KaiKing on 2019/2/23.
//  Copyright © 2019 K. All rights reserved.
//

import UIKit
import QuartzCore

/// 线

class Line: CALayer,CAAnimationDelegate {
    ///page的个数 默认6
    lazy var pageCount:Int = 6
    ///当前选中的item
    var selectedPage:Int = 1 {
        didSet {
            self.initialSelectedLineLength = self.selectedLineLength
        }
    }
    ///是否开启进度显示
    lazy var shouldShowProgressLine:Bool = true
    ///pageControl线的高度
    lazy var lineHeight:CGFloat = 2
    ///小球的直径
    lazy var ballDiameter:CGFloat = 10
    ///未选中的颜色
    lazy var unSelectedColor:UIColor = UIColor.init(white: 0.9, alpha: 1)
    ///选中的颜色
    lazy var selectedColor:UIColor = UIColor.red
    ///选中的长度
    @NSManaged var selectedLineLength:CGFloat
    ///绑定的滚动视图
    var bindScrollView:UIScrollView?
    
    ///记录上一次选中的长度
    fileprivate var initialSelectedLineLength:CGFloat = 10
    ///记录上一次的contentOffSet.x
    fileprivate var lastContentOffsetX:CGFloat = 0
    
    ///属性默认值 用于第一次显示
    override init() {
        super.init()
        self.pageCount = 6
        self.selectedPage = 1
        self.shouldShowProgressLine = true
        self.lineHeight = 2
        self.ballDiameter = 10
        self.unSelectedColor = UIColor.init(white: 0.9, alpha: 1)
        self.selectedColor = UIColor.red
        
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        if let aLayer = layer as? Line {
            self.pageCount = aLayer.pageCount
            self.selectedPage = aLayer.selectedPage
            self.shouldShowProgressLine = aLayer.shouldShowProgressLine
            self.lineHeight = aLayer.lineHeight
            self.ballDiameter = aLayer.ballDiameter
            self.unSelectedColor = aLayer.unSelectedColor
            self.selectedColor = aLayer.selectedColor
            self.selectedLineLength = aLayer.selectedLineLength
            self.bindScrollView = aLayer.bindScrollView
            self.masksToBounds = aLayer.masksToBounds
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 覆盖类方法
    override class func needsDisplay(forKey key: String) -> Bool {
        
        if key == "selectedLineLength" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    func animateSelectedLineToNewIndex(_ newIndex:Int) {
        let newLineLength = CGFloat((newIndex - 1)) * self.getDistabce()
        let anim = KSpringLayerAnimation.sharedAnimManager.createHalfCurveAnima("selectedLineLength", duration: 0.8, fromValue: NSNumber.init(value: Float(self.selectedLineLength)), toValue: NSNumber.init(value: Float(newLineLength)))
        self.selectedLineLength = newLineLength
        anim.delegate = self
        anim.isRemovedOnCompletion = true
        self.add(anim, forKey: "lineAnimation")
        self.selectedPage = newIndex
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.initialSelectedLineLength = self.selectedLineLength
            lastContentOffsetX = self.selectedLineLength / self.getDistabce() * (self.bindScrollView?.frame.size.width)!
            self.removeAllAnimations()
        }
    }
    
    func animateSelectedLineWithScrollView(_ scrollView:UIScrollView) {
        if scrollView.contentOffset.x <= 0 {
            return
        }
        let offSetX = scrollView.contentOffset.x - lastContentOffsetX
        self.selectedLineLength = initialSelectedLineLength + (offSetX / scrollView.frame.size.width) * CGFloat(getDistabce())
        print(self.selectedLineLength,"self.selectedLineLength")
        self.setNeedsDisplay()
    }
    
    /// 邻近小球的距离 = 总长度 / (小球个数 - 1)
    func getDistabce() -> CGFloat {
        //self.ballDiameter * 2 因为ballDiameter是大圆的一半
        return CGFloat(self.frame.size.width - self.ballDiameter * 2) / CGFloat(self.pageCount - 1)
    }
    
    override func draw(in ctx: CGContext) {
        assert(self.selectedPage <= self.pageCount, "ERROR:PageCount can not less than selectedPage")
        assert(self.selectedPage != 0, "ERROR:SelectedPage can not be ZERO!")

        if self.pageCount == 1 {
            let linePath:CGMutablePath = CGMutablePath.init()
            linePath.move(to: CGPoint.init(x: self.frame.size.width / 2, y: self.frame.size.height / 2))
            let circleRect = CGRect.init(x: self.frame.size.width / 2 - self.ballDiameter / 2, y: self.frame.size.height / 2 - self.ballDiameter / 2, width: self.ballDiameter, height: self.ballDiameter)
            /// 规定矩形内画圆
            linePath.addEllipse(in: circleRect)
            
            ctx.addPath(linePath)
            /// 填充颜色
            ctx.setFillColor(self.selectedColor.cgColor)
            ctx.fillPath()
            
            return
        }
        let linePath = CGMutablePath.init()
        /// 开始点
        linePath.move(to: CGPoint.init(x: self.ballDiameter / 2, y: self.ballDiameter / 2))
        linePath.addRoundedRect(in: CGRect.init(x: self.ballDiameter / 2, y: self.frame.size.height/2 - self.lineHeight / 2, width: self.frame.size.width - self.ballDiameter, height: self.lineHeight), cornerWidth: 0, cornerHeight: 0)
        
        let distance:CGFloat = getDistabce()
        /// pageCount个 小圆
        var i = 0
        
        while i < self.pageCount {
            /// 计算出小圆的X坐标
            let rectX = CGFloat(0.0 + CGFloat(i) * distance + CGFloat(self.ballDiameter/2))
            
            let circleRect:CGRect = CGRect.init(x: rectX, y: CGFloat(self.frame.size.height / 2 - self.ballDiameter / 2), width: self.ballDiameter, height: self.ballDiameter)
            linePath.addEllipse(in: circleRect, transform: CGAffineTransform.identity)
            i = i + 1
        }
        ctx.addPath(linePath)
        ctx.setFillColor(self.unSelectedColor.cgColor)
        ctx.fillPath()
        
        if self.shouldShowProgressLine == true {
            ctx.beginPath()
            
            let rLinePath = CGMutablePath.init()
            rLinePath.addRoundedRect(in: CGRect.init(x: self.ballDiameter / 2, y: self.frame.size.height/2 - self.lineHeight / 2, width: self.selectedLineLength, height: self.lineHeight), cornerWidth: 0, cornerHeight: 0)
            
            var i = 0
            while i < self.pageCount {
                if Int(CGFloat(i) * distance) <= Int(self.selectedLineLength + 0.1) {
                    /// 计算出小圆的X坐标
                    let rectX = CGFloat(0.0 + CGFloat(i) * distance + CGFloat(self.ballDiameter/2))
                    
                    let circleRect:CGRect = CGRect.init(x: rectX, y: CGFloat(self.frame.size.height / 2 - self.ballDiameter / 2), width: self.ballDiameter, height: self.ballDiameter)
                    rLinePath.addEllipse(in: circleRect, transform: CGAffineTransform.identity)
                }
                i = i + 1
            }
            ctx.addPath(rLinePath)
//            ctx.setFillColor(UIColor.purple.cgColor)//调试
            ctx.setFillColor(self.selectedColor.cgColor)
            ctx.fillPath()
        }
        
    }
    
}
