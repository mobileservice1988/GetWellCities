//
//  WebViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import Alamofire

class WebViewController: UIViewController, UIWebViewDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var URL: NSURL?
    var responseData: NSMutableData = NSMutableData()
    
    override func viewDidLoad() {
        request()
        super.viewDidLoad()
    }
    
    func request() {
        webView.delegate = self
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "GET"
        request.setValue("identity", forHTTPHeaderField: "Accept-Encoding")
        
        let task = session.downloadTaskWithRequest(request)
        task.resume()
        self.progressView.setProgress(0.005, animated: true)
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentageDownloaded = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        dispatch_async(dispatch_get_main_queue(),{
            self.progressView.setProgress(Float(percentageDownloaded), animated: true)
        })
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let data = NSData(contentsOfURL: location)
        dispatch_async(dispatch_get_main_queue(),{
            self.progressView.setProgress(1.0, animated: true)
            self.webView.loadData(data!, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL: self.URL!)
        })
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        progressView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
