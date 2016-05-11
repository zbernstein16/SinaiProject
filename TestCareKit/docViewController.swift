//
//  docVC.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/9/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.
//

import UIKit

class DocViewController: UIViewController {

    
    
    var webView:UIWebView?
    init() {
        print("initialize webview")
        super.init(nibName:nil, bundle:nil)
        webView = UIWebView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        self.view.addSubview(webView!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DocViewController.updateHtml(_:)), name: "loadhtml", object: nil)
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func viewWillLayoutSubviews() {

        

        dispatch_async(dispatch_get_main_queue(), {
            
            
            
            
            let file = "file.html" //Read HTML OF REPORT FROM THIS FILE
            
            
            if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(file)
                
                
                //reading
                do {
                 
                        let html = try NSString(contentsOfURL: path, encoding: NSUTF8StringEncoding)
                        self.webView!.loadHTMLString(html as String, baseURL: nil)
                    
                }
                catch {
                
                }
            }
            
        })
    
    }
    func updateHtml(notification:NSNotification)
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            
            
            
            let file = "file.html" //this is the file. we will write to and read from it
            
            
            if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(file)
                
                
                //reading
                do {
                    if let test = self.webView {
                        let html = try NSString(contentsOfURL: path, encoding: NSUTF8StringEncoding)
                        self.webView!.loadHTMLString(html as String, baseURL: nil)
                       
                    }
                }
                catch {/* error handling here */}
            }
            self.view.setNeedsLayout()

        })
        
       
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func errorPresent() {
        
    }
    
    
    
    
    
}
