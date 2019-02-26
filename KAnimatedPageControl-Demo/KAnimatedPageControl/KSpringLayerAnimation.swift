//
//  KSpringLayerAnimation.swift
//  KAnimatedPageControl-Demo
//
//  Created by KaiKing on 2019/2/25.
//  Copyright © 2019 K. All rights reserved.
//

import UIKit
import QuartzCore

/// 基础动画

class KSpringLayerAnimation: NSObject {
    
    class var sharedAnimManager: KSpringLayerAnimation {
        struct Instance {
            static let _instance:KSpringLayerAnimation = KSpringLayerAnimation()
        }
        return Instance._instance
    }
    
    //MARK: main class methods
    
    /// 线性函数
    func createBasicAnima(_ keyPath:String,duration:CFTimeInterval,fromValue:NSNumber,toValue:NSNumber) -> CAKeyframeAnimation {
        let anim = CAKeyframeAnimation.init(keyPath: keyPath)
        anim.values = self.basicAnimationValues(fromValue, toValue: toValue, duration: duration) as? [Any]
        anim.duration = duration
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        return anim
    }
    
    /// 抛到一半的二次平滑抛物函数
    func createHalfCurveAnima(_ keyPath:String,duration:CFTimeInterval,fromValue:NSNumber,toValue:NSNumber) -> CAKeyframeAnimation {
        let anim = CAKeyframeAnimation.init(keyPath: keyPath)
        anim.values = self.halfCurveAnimationValues(fromValue, toValue: toValue, duration: duration) as? [Any]
        anim.duration = duration
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        return anim
    }
    
    /// 二次平滑抛物函数
    func createCurveAnima(_ keyPath:String,duration:CFTimeInterval,fromValue:NSNumber,toValue:NSNumber) -> CAKeyframeAnimation {
        let anim = CAKeyframeAnimation.init(keyPath: keyPath)
        anim.values = self.halfCurveAnimationValues(fromValue, toValue: toValue, duration: duration) as? [Any]
        anim.duration = duration
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        return anim
    }
    /// 弹性曲线
    func createSpringAnima(_ keyPath:String,
                           duration:CFTimeInterval,
                           usingSpringWithDamping damping:CGFloat,
                           initialSpringVelocity velocity:CGFloat,
                           fromValue:NSNumber,
                           toValue:NSNumber) -> CAKeyframeAnimation {
        
        let dampingFactor:CGFloat = 10.0
        let velocityFactor = 10.0
        let values = self.springAnimationValues(fromValue, toValue: toValue, usingSpringWithDamping: damping * dampingFactor, initialSpringVelocity: velocity * CGFloat(velocityFactor), duration: duration)
        let anim = CAKeyframeAnimation.init(keyPath: keyPath)
        anim.values = values as? [Any]
        anim.duration = duration
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        return anim
    }
    
    //MARK: helper methods
    
    fileprivate func basicAnimationValues(_ fromValue:NSNumber,toValue:NSNumber,duration:CFTimeInterval) -> NSMutableArray {
        let numOfFrames = duration * 60
        let values = NSMutableArray.init(capacity: Int(numOfFrames))
        
        var i = 0
        while i < Int(numOfFrames) {
            values.add(NSNumber.init(value: 0.0))
            i = i + 1
        }
        
        let diff = toValue.floatValue - fromValue.floatValue
        for (idx,_) in values.enumerated() {
            let x = Float(idx) / Float(numOfFrames)
            let value = fromValue.floatValue + diff * x
            values[idx] = NSNumber.init(value: value)
        }
        return values
    }
    
    fileprivate func halfCurveAnimationValues(_ fromValue:NSNumber,toValue:NSNumber,duration:CFTimeInterval) -> NSMutableArray {
        let numOfFrames = duration * 60
        let values = NSMutableArray.init(capacity: Int(numOfFrames))
        
        var i = 0
        while i < Int(numOfFrames) {
            values.add(NSNumber.init(value: 0.0))
            i = i + 1
        }
        
        let diff = toValue.floatValue - fromValue.floatValue
        for (idx,_) in values.enumerated() {
            let x = Float(idx) / Float(numOfFrames)
            let value = fromValue.floatValue + diff * (-x * (x - 2))
            values[idx] = NSNumber.init(value: value)
        }
        return values
    }
    
    fileprivate func curveAnimationValues(_ fromValue:NSNumber,toValue:NSNumber,duration:CFTimeInterval) -> NSMutableArray {
        let numOfFrames = duration * 60
        let values = NSMutableArray.init(capacity: Int(numOfFrames))
        
        var i = 0
        while i < Int(numOfFrames) {
            values.add(NSNumber.init(value: 0.0))
            i = i + 1
        }
        
        let diff = toValue.floatValue - fromValue.floatValue
        for (idx,_) in values.enumerated() {
            let x = Float(idx) / Float(numOfFrames)
            let value = fromValue.floatValue + diff * (-4 * x * (x - 1))
            values[idx] = NSNumber.init(value: value)
        }
        return values
    }
    
    fileprivate func springAnimationValues(_ fromValue:NSNumber,
                                           toValue:NSNumber,
                                           usingSpringWithDamping damping:CGFloat,
                                           initialSpringVelocity velocity:CGFloat,
                                           duration:CFTimeInterval) -> NSMutableArray {
        let numOfFrames = duration * 60
        let values = NSMutableArray.init(capacity: Int(numOfFrames))
        
        var i = 0
        while i < Int(numOfFrames) {
            values.add(NSNumber.init(value: 0.0))
            i = i + 1
        }
        
        let diff = toValue.floatValue - fromValue.floatValue
        for (idx,_) in values.enumerated() {
            let x = CGFloat(idx) / CGFloat(numOfFrames)
            let value = toValue.doubleValue - Double(diff) * (pow(M_E, Double(-damping * x)) * Double(cos(velocity * x))) // y = 1-e^{-5x} * cos(30x)
            values[idx] = NSNumber.init(value: value)
        }
        return values
    }
}
