
本项目是Swift版本的KYAnimatedPageControl，镜像地址 https://github.com/KittenYang/KYAnimatedPageControl

可自动循环的自定义的UIPageControl (不支持手动点击滚动到目标页)。拥有两种动画样式:

 GooeyCircle (粘性小球)
  
  ![粘性小球](https://github.com/sugarAndsugar/AnimatedPageControl/blob/master/d2.gif)

RotateRect (旋转方块)

  ![旋转方块](https://github.com/sugarAndsugar/AnimatedPageControl/blob/master/d4.gif)

##Blog
https://yoon.bitcron.com/post/swift/2019-02-26

##Usage

Initialize:

```
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
```


##License This project is under MIT License. See LICENSE file for more information.
