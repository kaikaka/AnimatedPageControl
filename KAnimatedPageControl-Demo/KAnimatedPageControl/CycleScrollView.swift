//
//  CycleScrollView.swift
//  qianduoduo
//
//  Created by K on 2016/11/29.
//  Copyright © 2016年 wrep. All rights reserved.
//

import UIKit

/// 轮播图
class CycleScrollView: UIView {
    
    typealias ContentViewAtIndex = (_ pageIndex: NSInteger) -> UIView
    typealias ActionBlock = (_ pageIndex: NSInteger) -> Void
    
    open lazy var imageURLArray = [String]()
    fileprivate var imageViewCopy : UIImageView?
    
    fileprivate lazy var scrollView : UIScrollView = UIScrollView()
    
    open var fetchContentViewAtIndex : ContentViewAtIndex?
    open var tapActionBlock : ActionBlock?
    open lazy var pageControl : UIPageControl = UIPageControl()
    fileprivate lazy var currentPageIndex = NSInteger()
    
    fileprivate lazy var contentViews = NSMutableArray()
    var animationTimer : Timer?
    fileprivate lazy var animationDuration = TimeInterval()
    
    fileprivate var _totalPageCount : NSInteger?
    open var totalPageCount : NSInteger? {
        set {
            _totalPageCount = newValue
            if let total = _totalPageCount {
                if total > 0 {
                    if _totalPageCount! > 1 {
                        self.scrollView.isScrollEnabled = true
                        self.startTimer()
                        if _totalPageCount == 2 {
                            self.imageViewCopy = UIImageView.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 190))
                        }
                    }
                    self.configContentViews()
                }
            }
        }
        get {
            return _totalPageCount
        }
    }
    
    var scrollViewDidScrollActionBlock:((_ scrollView: UIScrollView) -> Void)?
    
    var scrollViewDidEndDeceleratingActionBlock:((_ scrollView:UIScrollView) -> Void)?
    
    var scrollViewWillBeginDeceleratingActionBlock:((_ scrollView:UIScrollView) -> Void)?
    
    var scrollViewDidEndScrollingAnimationActiobBlock:((_ scrollView:UIScrollView) -> Void)?
    
    
    func startTimer() {
        if self.animationTimer != nil {
            self.animationTimer?.invalidate()
            self.animationTimer = nil
        }
        self.animationTimer = Timer.scheduledTimer(timeInterval: animationDuration, target: self, selector: #selector(CycleScrollView.animationTimerDidFired), userInfo:nil, repeats: true)
    }
    
    /// 初始化
    init(frame: CGRect, animationDuration: TimeInterval) {
        super.init(frame: frame)
        self.animationDuration = animationDuration
        self.autoresizesSubviews = true
        let scrollViewFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: frame.size.height)
        self.scrollView = UIScrollView.init(frame: scrollViewFrame)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.contentMode = .center
        self.scrollView.isScrollEnabled = false
        self.scrollView.contentSize = CGSize(width: 3 * scrollViewFrame.width, height: scrollViewFrame.height)
        self.scrollView.delegate = self
        self.scrollView.isPagingEnabled = true
        self.addSubview(self.scrollView)
        self.pageControl = UIPageControl.init(frame: CGRect(x: (scrollViewFrame.size.width-40)/2, y: (scrollViewFrame.size.height - 28), width: 40, height: 30))
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.init(red: 119/255, green: 48/255, blue: 44/255, alpha: 0.7)
        self.pageControl.currentPage = 0
        self.addSubview(self.pageControl)
        self.currentPageIndex = 0
    }
    
    var page:Int = 0
    
    fileprivate func configContentViews() {
        for subView in self.scrollView.subviews {
            subView.removeFromSuperview()
        }
        self.setScrollViewContentDataSource()
        var counter : CGFloat = 0
        for contentView in self.contentViews {
            
            if let view = contentView as? UIView {
                view.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(CycleScrollView.onActionTap(_:)))
                view.addGestureRecognizer(tap)
                var rightRect = view.frame
                
                rightRect.origin = CGPoint(x: UIScreen.main.bounds.width * counter, y: 0)
                counter += 1
                view.frame = rightRect
                self.scrollView.addSubview(view)
            }
           
        }
        if _totalPageCount == 1 {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        } else {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.frame.size.width, y: 0)
        }
    }
    
    fileprivate func setScrollViewContentDataSource() {
        let previousPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex - 1)
        let rearPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex + 1)
        self.contentViews.removeAllObjects()
        if let fecthViewAtIndex = self.fetchContentViewAtIndex {
            if _totalPageCount == 1 {
                self.contentViews.add(fecthViewAtIndex(0))
            } else {
                if _totalPageCount == 2 {
                    //如果当前是0的话，就copy1
                    if self.currentPageIndex == 0 {
                        self.contentViews.add(fecthViewAtIndex(previousPageIndex))
                        self.contentViews.add(fecthViewAtIndex(self.currentPageIndex))
                        if let imgvCopy = self.imageViewCopy {
//                            imgvCopy.kf.setImage(with: URL(string: self.imageURLArray[1]), placeholder: #imageLiteral(resourceName: "home_error_long"), options: nil, progressBlock: nil, completionHandler: nil)
                            imgvCopy.backgroundColor = UIColor.purple
                            self.contentViews.add(imgvCopy)
                        }
                    } else {//如果当前是1的话，就copy0
                        if let imgvCopy = self.imageViewCopy {
                            imgvCopy.backgroundColor = UIColor.brown
//                            imgvCopy.kf.setImage(with: URL(string: self.imageURLArray[0]), placeholder: #imageLiteral(resourceName: "home_error_long"), options: nil, progressBlock: nil, completionHandler: nil)
                            self.contentViews.add(imgvCopy)
                        }
                        self.contentViews.add(fecthViewAtIndex(previousPageIndex))
                        self.contentViews.add(fecthViewAtIndex(self.currentPageIndex))
                    }
                } else {
                    self.contentViews.add(fecthViewAtIndex(previousPageIndex))
                    self.contentViews.add(fecthViewAtIndex(self.currentPageIndex))
                    self.contentViews.add(fecthViewAtIndex(rearPageIndex))
                }
            }
        }
    }

    fileprivate func getValidNextPageIndexWithPageIndex(_ currentPageIndex: NSInteger) -> NSInteger {
        if currentPageIndex == -1 {
            if let total = _totalPageCount {
                return total - 1
            }
            return 0
        } else {
            if currentPageIndex == _totalPageCount {
                return 0
            } else {
                return currentPageIndex
            }
        }
    }
    
    @objc fileprivate func animationTimerDidFired() {
        let totalCount = round(self.scrollView.contentOffset.x) / UIScreen.main.bounds.width
        let newOffSet = CGPoint(x: (totalCount + 1) * UIScreen.main.bounds.width, y: self.scrollView.contentOffset.y)
        if let total = _totalPageCount {
            if self.pageControl.currentPage + 1 > (total - 1) {
                self.pageControl.currentPage = 0
            } else {
                self.pageControl.currentPage = self.pageControl.currentPage + 1
            }
            self.scrollView.setContentOffset(newOffSet, animated: true)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func onActionTap(_ tap: UITapGestureRecognizer) {
        if let action = self.tapActionBlock {
            action(self.currentPageIndex)
        }
    }
}

extension CycleScrollView : UIScrollViewDelegate {
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.animationTimer?.invalidate()
        self.animationTimer = nil
        
        if let block = self.scrollViewWillBeginDeceleratingActionBlock {
            block(scrollView)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let total = _totalPageCount {
            if total > 1 {
                self.startTimer()
            }
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let block = self.scrollViewDidEndDeceleratingActionBlock {
            block(scrollView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let block = self.scrollViewDidEndScrollingAnimationActiobBlock {
            block(scrollView)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        if contentOffsetX >= (2 * UIScreen.main.bounds.width) {
            self.currentPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex + 1)
            self.pageControl.currentPage = self.currentPageIndex
            self.configContentViews()
        }
        if contentOffsetX <= 0 {
            self.currentPageIndex = self.getValidNextPageIndexWithPageIndex(self.currentPageIndex - 1)
            self.pageControl.currentPage = self.currentPageIndex
            self.configContentViews()
        }
        if let block = self.scrollViewDidScrollActionBlock {
            block(scrollView)
        }
    }
}
