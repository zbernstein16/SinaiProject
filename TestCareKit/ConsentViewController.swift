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
        let taskViewController = ORKTaskViewController(task: ConsentTask, taskRunUUID: nil)
        taskViewController.delegate = self
        
        self.navigationController!.pushViewController(taskViewController, animated: true)
    }
    
}
extension ConsentViewController : ORKTaskViewControllerDelegate {
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        
        
        
        //Save document to PDF
        let copy = ConsentDocument.copy() as! ORKConsentDocument
        //let signature = ConsentDocument.signatures!.first!
    
       
        copy.makePDFWithCompletionHandler() {
            PFData, errorOrNil in
            if let error = errorOrNil {
                print("DIDNT MAKE PDF")
            }
            else
            {
                print("MADE PDF")
                //var docURL = (NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)).last as! NSURL
                
                //docURL = docURL?.URLByAppendingPathComponent( "myFileName.pdf")
                
                //Lastly, write your file to the disk.
                //PFData!.writeToURL(docURL!, atomically: true)
            }
        }
            
            //  (ORKConsentSignatureResult *)[[[taskViewController result] stepResultForStepIdentifier:kConsentReviewIdentifier] firstResult];
            //[signatureResult applyToDocument:documentCopy];

        //Handle results with taskViewController.result
        self.navigationController!.popViewControllerAnimated(true)
        self.performSegueWithIdentifier("toMain", sender: nil)
    }
    
}