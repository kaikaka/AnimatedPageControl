//
//  KAnimatedPageControl.swift
//  KAnimatedPageControl-Demo
//
//  Created by KaiKing on 2019/2/23.
//  Copyright © 2019 K. All rights reserved.
//

import UIKit
import QuartzCore

enum IndicatorStyle {
    case GooeyCircle
    case RotateRect
}

class KAnimatedPageControl: UIView {
    
    ///page的个数
    var pageCount:Int = 5
    ///当前选中的item
    var selectedPage:Int = 1
    ///是否开启进度显示
    var shouldShowProgressLine:Bool = true
    ///pageControl线的高度
    var lineHeight:CGFloat = 2
    ///小球的直径
    var ballDiameter:CGFloat = 10
    ///未选中的颜色
    var unSelectedColor:UIColor = UIColor.init(white: 0.9, alpha: 1)
    ///选中的颜色
    var selectedColor:UIColor = UIColor.red
    ///选中的长度
    var selectedLineLength:CGFloat = 0
    ///绑定的滚动视图
    var bindScrollView:UIScrollView?
    ///是否支持手势
    var swipeEnable:Bool = false
    ///Indicator样式
    var indicatorStyle:IndicatorStyle = .GooeyCircle
    ///Indicator大小
    var indicatorSize:CGFloat = 20
    
    var pageControlLine:Line? {
        get {
            return self.line
        }
    }
    
    var indicator:Indicator!
    
    fileprivate var gooeyCircle:GooeyCircle!
    fileprivate var rotateRect:RotateRect!
    
    fileprivate var line:Line?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 当本视图的父类视图改变的时候,系统会自动的执行这个方法.newSuperview是本视图的新父类视图.newSuperview有可能是nil.
    override func willMove(toSuperview newSuperview: UIView?) {
        self.layer.addSublayer(self.getLine())
        self.layer.insertSublayer(self.getIndicator(), above: self.line)
//        self.layer.insertSublayer(self.getIndicator(), below: self.line) //用于调试
        self.line?.setNeedsDisplay()
    }
    
    func animateToIndex(_ index:Int) {
        assert(self.bindScrollView != nil, "You can not scroll without assigning bindScrollView")
        /// 计算移动的分页
        let lx = abs(((self.line?.selectedLineLength)! - CGFloat(index) * (self.line!.frame.size.width - self.line!.ballDiameter) / CGFloat(self.line!.pageCount - 1)))
        let howmanydistance = lx / ((self.line!.frame.size.width - self.line!.ballDiameter) /
            CGFloat((self.line!.pageCount - 1)))
        ///延长线的动画执行时间 就会有个线跟随球效果
        self.line?.animateSelectedLineToNewIndex(index + 1)
        self.bindScrollView?.setContentOffset(CGPoint.init(x: (self.bindScrollView?.frame.size.width)! * CGFloat(index), y: 0), animated: true)
        let value = NSNumber.init(value:Float( howmanydistance / CGFloat(self.pageCount)))
        
        self.perform(#selector(toIndicatorRestor(_:)), with: value, afterDelay: 0.33)
    }
    
    @objc func toIndicatorRestor(_ value:NSNumber ) {
        self.indicator.restoreAnimation(value)
    }
    
    func getIndicator() -> Indicator {
        if indicator == nil {
            if self.indicatorStyle == IndicatorStyle.GooeyCircle {
                indicator = self.getGooeyCircle()
            } else if self.indicatorStyle == IndicatorStyle.RotateRect {
                indicator = self.getRotateRect()
            }
            indicator.animateIndicatorWithScrollView(self.bindScrollView!, pgctl: self)
        }
        
        return indicator
    }
    
    func getLine() -> Line {
        line = Line.init()
        line?.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        line?.pageCount = self.pageCount
        line?.selectedPage = 1
        line?.shouldShowProgressLine = self.shouldShowProgressLine
        line?.unSelectedColor = self.unSelectedColor
        line?.selectedColor = self.selectedColor
        line?.bindScrollView = self.bindScrollView
        line?.ballDiameter = self.indicatorSize / 2
        line?.contentsScale = UIScreen.main.scale
        return line!
    }
    
    fileprivate func getGooeyCircle() -> Indicator {
        if gooeyCircle == nil {
            gooeyCircle = GooeyCircle.init()
            gooeyCircle.indicatorColor = self.selectedColor
            gooeyCircle.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            gooeyCircle.indicatorSize = self.indicatorSize
            gooeyCircle.contentsScale = UIScreen.main.scale
        }
        return gooeyCircle
    }
    
    fileprivate func getRotateRect() -> Indicator {
        if rotateRect == nil {
            rotateRect = RotateRect.init()
            rotateRect.indicatorColor = self.selectedColor
            rotateRect.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            rotateRect.indicatorSize = self.indicatorSize
            rotateRect.contentsScale = UIScreen.main.scale
        }
        return rotateRect
    }
}
