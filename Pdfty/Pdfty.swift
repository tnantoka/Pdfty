//
//  Pdfty.swift
//  Pdfty
//
//  Created by Tatsuya Tobioka on 6/12/16.
//  Copyright © 2016 tnantoka. All rights reserved.
//

import CoreGraphics

public class Pdfty {
    let url: NSURL
    
    public var session = NSURLSession.sharedSession()
    public var didCache: Void -> Void = {}
    public var cachesURL = try? NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
    
    public init(url: NSURL) {
        self.url = url
    }
    
    public var cacheURL: NSURL? {
        guard let cachesURL = cachesURL else { fatalError() }
        let dirURL = cachesURL.URLByAppendingPathComponent("Pdfty")
        guard let lastPathComponent = self.url.lastPathComponent else { fatalError() }
        guard let dirPath = dirURL.path else { fatalError() }
        
        if !NSFileManager.defaultManager().fileExistsAtPath(dirPath) {
            try! NSFileManager.defaultManager().createDirectoryAtURL(dirURL, withIntermediateDirectories: false, attributes: nil)
        }

        let cacheURL = dirURL.URLByAppendingPathComponent(lastPathComponent)
        return cacheURL
    }
    
    public var cached: Bool {
        guard let cacheURL = self.cacheURL else { fatalError() }
        guard let cachePath = cacheURL.path else { fatalError() }
        let cached = NSFileManager.defaultManager().fileExistsAtPath(cachePath)
        return cached
    }
    
    lazy public var document: CGPDFDocument? = {
        guard let cacheURL = self.cacheURL else { fatalError() }
       
        if self.cached {
            return CGPDFDocumentCreateWithURL(cacheURL)
        } else {
//            if !self.url.fileURL {
                let task = self.session.dataTaskWithURL(self.url) { data, response, error in
                    guard let data = data else { return }
                    data.writeToURL(cacheURL, atomically: true)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.didCache()
                    }
                }
                task.resume()
//            }
            var document = CGPDFDocumentCreateWithURL(self.url)
            // FIXME: `CGPDFDocumentCreateWithURL` returns nil with some URL
            if document == nil {
                let data = NSData(contentsOfURL: self.url)
                document = CGPDFDocumentCreateWithProvider(CGDataProviderCreateWithCFData(data))
            }
            return document
        }
    }()

    lazy public var numberOfPages: Int = {
        return CGPDFDocumentGetNumberOfPages(self.document) ?? 0
    }()
    
    lazy public var rect: CGRect = {
        if let page = self.page(atIndex: 0) {
            return CGPDFPageGetBoxRect(page, .MediaBox)
        } else {
            return CGRectZero
        }
    }()
    
    var _pages: [CGPDFPage]?
    
    public var pages: [CGPDFPage] {
        if _pages == nil {
            _pages = (1...self.numberOfPages).flatMap { CGPDFDocumentGetPage(self.document, $0) }
        }
        return _pages!
    }

    public func page(atIndex index: Int) -> CGPDFPage? {
        guard index < numberOfPages else { return nil }
        return _pages == nil ? CGPDFDocumentGetPage(self.document, index + 1) : _pages?[index]
    }

    public func image(atIndex index: Int) -> UIImage? {
        guard let page = self.page(atIndex: index) else { return nil }
        
        let box = CGPDFPageGetBoxRect(page, .MediaBox)
        
        UIGraphicsBeginImageContextWithOptions(box.size, true, 0.0)
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(context, 0, box.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        CGContextDrawPDFPage(context, page)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func clean() {
        guard let cacheURL = self.cacheURL else { fatalError() }

        if cached {
            let _ = try? NSFileManager.defaultManager().removeItemAtURL(cacheURL)
        }
    }
}
