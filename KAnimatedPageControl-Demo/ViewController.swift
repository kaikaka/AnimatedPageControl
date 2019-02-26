//
//  ViewController.swift
//  KAnimatedPageControl-Demo
//
//  Created by KaiKing on 2019/2/23.
//  Copyright © 2019 K. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var pageControl:KAnimatedPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageControl = KAnimatedPageControl.init(frame: CGRect.init(x: 20, y: 450, width: 280, height: 50))
        self.pageControl.pageCount = 8
        self.pageControl.unSelectedColor = UIColor.init(white: 0.9, alpha: 1)
        self.pageControl.selectedColor = UIColor.red
        self.pageControl.bindScrollView = self.collectionView
        self.pageControl.shouldShowProgressLine = true
        self.pageControl.indicatorStyle = .RotateRect
        self.pageControl.indicatorSize = 20
        self.pageControl.swipeEnable = true
        self.view.addSubview(self.pageControl)
        
        
        let cycleView = CycleScrollView.init(frame: CGRect(x: 20, y: 100, width: self.view.frame.width - 40, height: 250), animationDuration: 3.0)
        cycleView.backgroundColor = UIColor.white
        /// 数据源
        let urlArray:[String] = ["1","2","3","4","5","6","7","8"]
        
        var imageViewArray:[UIImageView] = []
        for idx in urlArray.enumerated() {
            let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: cycleView.frame.width, height: 250))
            imageView.backgroundColor = idx.offset % 2 == 0 ? UIColor.purple : UIColor.brown
            imageViewArray.append(imageView)
        }
        cycleView.fetchContentViewAtIndex = {(pageIndex: NSInteger) in
            return (imageViewArray[pageIndex] as UIView)
        }
        cycleView.imageURLArray = urlArray
        cycleView.totalPageCount = imageViewArray.count
        cycleView.pageControl.numberOfPages = imageViewArray.count
        
        cycleView.scrollViewDidEndScrollingAnimationActiobBlock = { scrollView in
            self.pageControl.animateToIndex(cycleView.pageControl.currentPage)
        }
        
        self.view.addSubview(cycleView)
        
    }

    // MARK: UICollectionViewDelegate,UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pageControl.pageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "democell", for: indexPath) as? DemoCollectionViewCell {
            cell.numberLab.text = "\(indexPath.row + 1)"
            return cell
        }
        return UICollectionViewCell.init()
    }
    
    @IBAction func animateToFourPage(_ sender: UIButton) {
        self.pageControl.animateToIndex(3)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// 滚动时 指示器动画
        self.pageControl.getIndicator().animateIndicatorWithScrollView(scrollView, pgctl: self.pageControl)
        let flo = floorf(Float((scrollView.contentOffset.x - scrollView.frame.size.width/2)/scrollView.frame.size.width))+1
        self.pageControl.selectedPage = Int(flo)
        //背景线条动画
        if (scrollView.isDragging || scrollView.isDecelerating || scrollView.isTracking) {
            self.pageControl.pageControlLine?.animateSelectedLineWithScrollView(scrollView)
        }
    }
   
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControl.getIndicator().lastContentOffset = scrollView.contentOffset.x
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        self.pageControl.getIndicator().restoreAnimation(NSNumber.init(value: 1.0 / Double(self.pageControl.pageCount)))
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.pageControl.getIndicator().lastContentOffset = scrollView.contentOffset.x
    }
}

