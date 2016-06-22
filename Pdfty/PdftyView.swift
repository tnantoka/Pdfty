//
//  PdftyView.swift
//  Pdfty
//
//  Created by Tatsuya Tobioka on 6/17/16.
//  Copyright © 2016 tnantoka. All rights reserved.
//

import UIKit

class PdftyPageView: UIView {
    var page: CGPDFPage?
    
    override func drawRect(rect: CGRect) {
        guard let page = page else { return }
        
        let context = UIGraphicsGetCurrentContext()
        CGContextClearRect(context, rect)
        
        CGContextTranslateCTM(context, 0, rect.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)

        let box = CGPDFPageGetBoxRect(page, .MediaBox)

        let xScale = rect.size.width / box.size.width
        let yScale = rect.size.height / box.size.height
        let scale = min(xScale, yScale)

        let tx = (rect.size.width - box.size.width * scale) / 2
        let ty = (rect.size.height - box.size.height * scale) / 2
        CGContextTranslateCTM(context, tx, ty)

        CGContextScaleCTM(context, scale, scale)

        CGContextDrawPDFPage(context, page)
    }
}

class PdftyPageContainerView: UIScrollView, UIScrollViewDelegate {
    var pageView: UIView? {
        didSet {
            guard let pageView = pageView else { return }
            addSubview(pageView)
        }
    }
    
    override var frame: CGRect {
        didSet {
            contentSize = frame.size
            pageView?.frame = bounds
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        maximumZoomScale = 3.0
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    func didDoubleTap(sender: AnyObject) {
        if zoomScale < maximumZoomScale {
            setZoomScale(maximumZoomScale, animated: true)
        } else {
            setZoomScale(minimumZoomScale, animated: true)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return pageView
    }
}


public class PdftyView: UIView, UIScrollViewDelegate {

    let useImage = true
    
    public var page = 0 {
        didSet {
            guard page != oldValue else { return }
            let rect = CGRect(
                origin: CGPointMake(CGRectGetWidth(bounds) * CGFloat(page), 0),
                size: bounds.size
            )
            scrollView.scrollRectToVisible(rect, animated: true)
        }
    }
    public var didPage: (Int -> Void)?
    
    public var pdfty: Pdfty? {
        didSet {
            page = 0
            guard let pdfty = pdfty else { return }
            
            for containerView in containerViews {
                containerView.removeFromSuperview()
            }
            containerViews = []
            (0..<pdfty.numberOfPages).forEach { i in
                let containerView = PdftyPageContainerView(frame: CGRectZero)

                if useImage {
                    let pageView = UIImageView(frame: CGRectZero)
                    pageView.contentMode = .ScaleAspectFit
                    pageView.image = pdfty.image(atIndex: i)
                    containerView.pageView = pageView
                } else {
                    let pageView = PdftyPageView(frame: CGRectZero)
                    pageView.backgroundColor = UIColor.clearColor()
                    pageView.page = pdfty.page(atIndex: i)
                    containerView.pageView = pageView
                }
            
                containerViews.append(containerView)
                scrollView.addSubview(containerView)
            }
        }
    }
    var containerViews: [PdftyPageContainerView] = []
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRectZero)
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        self.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["scrollView": scrollView]
        let vertical = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[scrollView]|",
            options: [],
            metrics: nil,
            views: views
        )
        let horizontal = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[scrollView]|",
            options: [],
            metrics: nil,
            views: views
        )
        self.addConstraints(vertical + horizontal)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewDidDoubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewDidTap))
        tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        scrollView.addGestureRecognizer(tapRecognizer)

        return scrollView
    }()
    
    override public var backgroundColor: UIColor? {
        didSet {
            scrollView.backgroundColor = backgroundColor
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        let _ = scrollView
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let pdfty = pdfty else { return }
        let width = CGRectGetWidth(bounds)
        
        for (i, containerView) in containerViews.enumerate() {
            containerView.frame = CGRect(
                origin: CGPoint(x: CGFloat(i) * width, y: 0),
                size: bounds.size
            )
        }
        
        scrollView.contentSize = CGSizeMake(
            CGFloat(pdfty.numberOfPages) * width,
            CGRectGetHeight(bounds)
        )
    }
    
    func scrollViewDidTap(sender: UITapGestureRecognizer) {
        guard let pdfty = pdfty else { return }

        let x = sender.locationInView(self).x
        let width = CGRectGetWidth(bounds)
        let threshold: CGFloat = 0.15
        let prev = width * threshold
        let next = width - prev
        if x < prev {
            page = max(page - 1, 0)
        } else if x > next {
            page = min(page + 1, pdfty.numberOfPages - 1)
        }
    }
    
    func scrollViewDidDoubleTap(sender: AnyObject) {
        containerViews[page].didDoubleTap(sender)
    }
    
    func updatePage() {
        page = Int(floor(scrollView.contentOffset.x / CGRectGetWidth(bounds)))
        if let didPage = didPage {
            didPage(page)
        }
        for containerView in containerViews {
            containerView.setZoomScale(containerView.minimumZoomScale, animated: false)
        }

    }

    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        updatePage()
    }
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updatePage()
    }
}
