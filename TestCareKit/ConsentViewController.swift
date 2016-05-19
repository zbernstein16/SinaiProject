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
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        appDelegate.client = MSClient(applicationURLString:"https://zachservice.azure-mobile.net/")
        appDelegate.adherenceTable = appDelegate.client!.tableWithName("Adherence")
        appDelegate.patientTable = appDelegate.client!.tableWithName("Patient")
        appDelegate.PatientMedFreqTable = appDelegate.client!.tableWithName("Patient_Med_Freq")
        appDelegate.medicationTable = appDelegate.client!.tableWithName("Medication")
        
        let file = "consent.pdf" //this is the file. we will write to and read from it
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = NSURL(fileURLWithPath: dir).URLByAppendingPathComponent(file)
            if NSFileManager.defaultManager().fileExistsAtPath(path.path!)
            {
                print("Signature already found")
                self.appDelegate.uploadJSON()
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
            
            print("Result of Date of birth")
            let dob = taskViewController.result.stepResultForStepIdentifier("dateOfBirthPage")!.firstResult! as! ORKDateQuestionResult
            let dateString = dob.dateAnswer!.monthDayYearString()
            
            
                    let copy = ConsentDocument.copy() as! ORKConsentDocument
                    let signature:ORKConsentSignatureResult! = taskViewController.result.stepResultForStepIdentifier("ConsentReviewStep")!.firstResult! as! ORKConsentSignatureResult
         
                    let firstName = signature.signature!.givenName!
                    let lastName = signature.signature!.familyName!
            
        
            let newPatient:Dictionary<String,AnyObject> = ["First_Name":firstName,"Last_Name":lastName,"Date_Of_Birth":dateString]
            appDelegate.patientTable!.insert(newPatient) { (result, error) in
                if let err = error {
                    print("ERROR ", err)
                } else if let item = result {
                    print("Inserted Patient")
                NSUserDefaults.standardUserDefaults().setInteger(item["id"] as! Int, forKey: Constants.userIdKey)
                }
            }
            
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