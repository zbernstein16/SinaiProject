//
//  ConsentViewController.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/13/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import ResearchKit

class ConsentViewController: UIViewController {
    
    
    override func viewDidLoad() {
        
        
        
        let file = "consent.pdf" //this is the file. we will write to and read from it
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(file)
            if NSFileManager.defaultManager().fileExistsAtPath(path.path!)
            {
                print("Signature already found")
                self.performSegueWithIdentifier("toMain", sender: nil)
            }
            else
            {
                print("Signature not found")
                let taskViewController = ORKTaskViewController(task: ConsentTask, taskRunUUID: nil)
                taskViewController.delegate = self
                self.navigationController!.pushViewController(taskViewController, animated: true)
                
            }
    
        }
        

        
        
    }
    
}
extension ConsentViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        
        if reason == ORKTaskViewControllerFinishReason.Completed{
            //IF SURVEY WAS COMPLETED
            //Save document to PDF
                    let copy = ConsentDocument.copy() as! ORKConsentDocument
                    
                    let signature:ORKConsentSignatureResult! = taskViewController.result.stepResultForStepIdentifier("ConsentReviewStep")!.firstResult! as! ORKConsentSignatureResult
                    signature.applyToDocument(copy)
                    
                    copy.makePDFWithCompletionHandler() {
                        PDFData, errorOrNil in
                        if let error = errorOrNil {
                            print(error.localizedDescription)
                        }
                        else
                        {
                            
                            
                            let file = "consent.pdf" //this is the file. we will write to and read from it
                            if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                                let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(file)
                                
                                //writing
                                do {
                                    try PDFData!.writeToURL(path, options: NSDataWritingOptions.DataWritingAtomic)
                                }
                                catch { print("Falied to write signature") }
                            }
                            
                        }
                    }
                    
                    
                    //ONCE SURVEY COMPLETED, NAVIGATE TO MAIN APP
                    self.navigationController!.popViewControllerAnimated(false)
                    self.performSegueWithIdentifier("toMain", sender: nil)

        }
        else {
            //IF SURVEY NOT COMPLETED, RESTART SURVEY
            self.navigationController!.popViewControllerAnimated(false)
            let taskViewController = ORKTaskViewController(task: ConsentTask, taskRunUUID: nil)
            taskViewController.delegate = self
            self.navigationController!.pushViewController(taskViewController, animated: true)
        }
        
    }
    
}