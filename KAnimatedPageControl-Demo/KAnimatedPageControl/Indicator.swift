//
//  Indicator.swift
//  KAnimatedPageControl-Demo
//
//  Created by KaiKing on 2019/2/23.
//  Copyright © 2019 K. All rights reserved.
//

import UIKit
import QuartzCore

enum ScrollDirection {
    case None
    case Left
    case Right
}

///所有Indicator的基类
class Indicator: CALayer,CAAnimationDelegate {
    ///Indicator大小 默认20
    var indicatorSize:CGFloat = 20
    ///Indicator的颜色
    var indicatorColor:UIColor = UIColor.red
    ///Indicator相对矩形的大小
    var currentRect:CGRect = CGRect.init()
    ///记录上一次的偏移量 用于计算方向
    var lastContentOffset:CGFloat = 0
    ///移动的方向
    var scrollDirection:ScrollDirection = .None
    
    func animateIndicatorWithScrollView(_ scrollView:UIScrollView,pgctl:KAnimatedPageControl) {
        
    }
    
    func restoreAnimation(_ howmanydistance:Any) {
        
    }
}
