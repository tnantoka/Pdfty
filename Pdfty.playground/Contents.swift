//: Playground - noun: a place where people can play

import Pdfty
import XCPlayground

let url = NSURL(string: "https://raw.githubusercontent.com/tnantoka/Pdfty/master/PdftyTests/example.pdf")!
let pdfty = Pdfty(url: url)
pdfty.cachesURL = try? NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
pdfty.clean()
pdfty.image(atIndex: 2)

let pdftyView = PdftyView(frame: CGRectMake(0, 0, 300, 250))
pdftyView.backgroundColor = UIColor.lightGrayColor()
pdftyView.pdfty = pdfty
pdftyView.didPage = { page in
    print(page)
}

//let delay = 1.0 * Double(NSEC_PER_SEC)
//let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//dispatch_after(time, dispatch_get_main_queue(), {
//    pdftyView.page = 2
//})

XCPlaygroundPage.currentPage.liveView = pdftyView
