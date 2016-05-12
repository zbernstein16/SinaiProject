//
//  ViewController.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/2/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.
//

import UIKit
import CareKit
import ResearchKit
class MainViewController: UITabBarController, OCKCarePlanStoreDelegate {

    
    //MARK: Properties
    let sampleData: SampleData
    let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager

    var careCardViewController: OCKCareCardViewController!
    var symptomTrackerViewController: OCKSymptomTrackerViewController!
    var insightsViewController: OCKInsightsViewController!
    var docViewController: DocViewController!
    var chartViewController:DashboardTableViewController!
    var surveyVC: ORKTaskViewController!
    
    var client:MSClient?
    var activityResultsTable:MSTable?
    
    
    let serialQueue = dispatch_queue_create("com.zachbern", DISPATCH_QUEUE_SERIAL)
    let bigQue = dispatch_queue_create("com.zachbern2", DISPATCH_QUEUE_SERIAL)
    
    //MARK: Initialize
    
    required init?(coder aDecoder:NSCoder)
    {
        //SETUP AZURE CONNECTION
        client = MSClient(
            applicationURLString:"https://testcarekit.azurewebsites.net"
        )
        activityResultsTable = client!.tableWithName("ActivityResults")

        
        //SETUP CAREKIT AND RESEARCHKIT

        sampleData = SampleData(carePlanStore: storeManager.store)
        
        super.init(coder: aDecoder)
        
        careCardViewController = createCareCardViewController()
        symptomTrackerViewController = createSymptomTrackerViewController()
        insightsViewController = createInsightsViewController()
        
        docViewController = DocViewController()
        docViewController.title = "HTML"
        
        chartViewController = DashboardTableViewController()
        chartViewController.title = "CHART"
         //TODO: Add contact
        //connectViewController = createConnectViewController()
        
        
        
        
        self.viewControllers = [
            UINavigationController(rootViewController: careCardViewController),
            UINavigationController(rootViewController: symptomTrackerViewController),
            UINavigationController(rootViewController: insightsViewController),UINavigationController(rootViewController: docViewController),
            UINavigationController(rootViewController: chartViewController)
        ]
        
        storeManager.delegate = self
    }
    //MARK: Default View Methods
    
    override func viewDidLoad() {
       
        super.viewDidLoad()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Initialize Tab Controllers
    
    func createCareCardViewController() -> OCKCareCardViewController {
        let viewController = OCKCareCardViewController(carePlanStore:storeManager.store)
        viewController.delegate = self
        
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Care Card", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"carecard"), selectedImage: UIImage(named: "carecard-filled"))
        
        return viewController
    }
    
   func createSymptomTrackerViewController() -> OCKSymptomTrackerViewController {
        let viewController = OCKSymptomTrackerViewController(carePlanStore:storeManager.store)
        viewController.delegate = self
        
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Symptom Tracker", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"symptoms"), selectedImage: UIImage(named: "symptoms-filled"))
        
        return viewController
    }

    
    func checkValueOfEvent(event:OCKCarePlanEvent) {
        
           self.storeManager.store.activitiesWithType(event.activity.type) { (success,activites, error) in
            
        }
      
    }
    func createInsightsViewController () -> OCKInsightsViewController {
        let headerTitle = NSLocalizedString("Weekly Charts", comment: "")
        let viewController = OCKInsightsViewController(insightItems: storeManager.insights, headerTitle: headerTitle, headerSubtitle: "")
        
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Insights", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"insights"), selectedImage: UIImage(named: "insights-filled"))
        
        return viewController
    }
    }



//MARK: Extensions


extension MainViewController: CarePlanStoreManagerDelegate {
    
    /// Called when the `CarePlanStoreManager`'s insights are updated.
    //TODO: Eventually add ability to incorporate Research Kit charts here
    func carePlanStoreManager(manager: CarePlanStoreManager, didUpdateInsights insights: [OCKInsightItem]) {
        // Update the insights view controller with the new insights.
        insightsViewController.items = insights
    }
}

extension MainViewController:OCKCareCardViewControllerDelegate
{
    func careCardViewController(viewController: OCKCareCardViewController, didSelectButtonWithInterventionEvent interventionEvent: OCKCarePlanEvent) {
        
        
        //This prints initial value. If initial value is 0 or 1, this means the event was just completed.
        //0:Initial 1:Not completed -> Completed
        //2 -> Just unfilled
  
        let components = interventionEvent.date // local date time: Jun 27, 2014, 9:32 AM
        let dateString = String(components.month) + "/" + String(components.day) + "/" + String(components.year)
        let index = interventionEvent.occurrenceIndexOfDay
        var eventResult:String!
        switch interventionEvent.state.rawValue {
        case 0 | 1:
            eventResult = "Completed"
        default:
            eventResult = "Not-Completed"
        }
        queryTableForResults(interventionEvent, date: dateString, valueString: eventResult, index: index)
    }

}
extension MainViewController: OCKSymptomTrackerViewControllerDelegate
{
    func symptomTrackerViewController(viewController: OCKSymptomTrackerViewController, didSelectRowWithAssessmentEvent assessmentEvent: OCKCarePlanEvent) {
        
        // Lookup the assessment the row represents.
        guard let activityType = ActivityType(rawValue: assessmentEvent.activity.identifier) else { return }
        guard let sampleAssessment = sampleData.activityWithType(activityType) as? Assessment else { return }
        
        /*
         Check if we should show a task for the selected assessment event
         based on its state.
         */
        guard assessmentEvent.state == .Initial ||
            assessmentEvent.state == .NotCompleted ||
            (assessmentEvent.state == .Completed && assessmentEvent.activity.resultResettable) else { return }
        
        // Show an `ORKTaskViewController` for the assessment's task.
        let taskViewController = ORKTaskViewController(task: sampleAssessment.task(), taskRunUUID: nil)
        taskViewController.delegate = self
        
        presentViewController(taskViewController, animated: true, completion: nil)
    }
}
extension MainViewController: ORKTaskViewControllerDelegate
{
    /// Called with then user completes a presented `ORKTaskViewController`.
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        defer {
            dismissViewControllerAnimated(true, completion: nil)
        }
        
        // Make sure the reason the task controller finished is that it was completed.
        guard reason == .Completed else { return }
        
        // Determine the event that was completed and the `SampleAssessment` it represents.
        guard let event = symptomTrackerViewController.lastSelectedAssessmentEvent,
            activityType = ActivityType(rawValue: event.activity.identifier),
            sampleAssessment = sampleData.activityWithType(activityType) as? Assessment else { return }
        
        // Build an `OCKCarePlanEventResult` that can be saved into the `OCKCarePlanStore`.
        let carePlanResult = sampleAssessment.buildResultForCarePlanEvent(event, taskResult: taskViewController.result)
        self.completeEvent(event, inStore: self.storeManager.store, withResult: carePlanResult)
    }
    
    // MARK: Convenience
    
    private func completeEvent(event: OCKCarePlanEvent, inStore store: OCKCarePlanStore, withResult result: OCKCarePlanEventResult) {
        store.updateEvent(event, withResult: result, state: .Completed) { success, _, error in
            print("EVENT RESULT: " + result.valueString)
    
            
            
           
            let components = event.date // local date time: Jun 27, 2014, 9:32 AM
            let dateString = String(components.month) + "/" + String(components.day) + "/" + String(components.year)
            let index = event.occurrenceIndexOfDay
            let eventResult = result.valueString
            
            self.queryTableForResults(event, date: dateString, valueString: eventResult, index: index)

            
        }
        
    }
    
//MARK: Azure upload methods
    func queryTableForResults(event:OCKCarePlanEvent, date:String,valueString:String,index:UInt)
    {

        var eventName:String!
        if event.activity.type == .Intervention
        {
            eventName = event.activity.identifier + event.activity.title
        }
        else
        {
            eventName = event.activity.identifier
        }
        let components = event.date // local date time: Jun 27, 2014, 9:32 AM
        let dateString = String(components.month) + "/" + String(components.day) + "/" + String(components.year)
        let index = event.occurrenceIndexOfDay
       
        
        // Create a predicate that finds if pre-existing item for this specific events exists
        let datePredicate = NSPredicate(format:"date == '\(dateString)'")
        let eventNamePredicate = NSPredicate(format:"eventName == '\(eventName)'")
        let indexPredicate = NSPredicate(format: "index == \(index)")
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate,eventNamePredicate,indexPredicate])
        
        /////////////
       
        
       dispatch_async(self.bigQue)
       {
            dispatch_suspend(self.bigQue)
            self.activityResultsTable!.readWithPredicate(predicate) { (result, error) in
                                    print("QUERY")
                                                if let err = error {
                                                    print("ERROR ", err)
                                                } else if let items = result?.items where items.count > 0 {
                                                  
                                                    
                                                    
                                                                        let oldItem = items.first!
                                                                   
                                                    
                                                                                                switch event.activity.type
                                                                                                {
                                                                                                        case OCKCarePlanActivityType.Intervention:
                                                                                                            print("Delete")
                                                                                                                self.activityResultsTable!.delete(oldItem, completion: { (result, error) -> Void in
                                                                                                                    dispatch_resume(self.bigQue)
                                                                                                                    if let err = error {
                                                                                                                    print("ERROR ", err)
                                                                                                                    } else if let _ = result {
                                                                                                                    //print("New value:" + newItem["valueString"])
                                                                                                                    }
                                                                                                                    print("B")
                                                                                                                    })
                                                                                                            
                                                                                                    
                                                                                                        case OCKCarePlanActivityType.Assessment:
                                                                                                           print("Update")
                                                                                                            var newItem = oldItem as! [NSString : AnyObject]
                                                                                                            newItem["valueString"] = valueString
                                                                                                        
                                                                                                                        self.activityResultsTable!.update(newItem as [NSObject: AnyObject], completion: { (result, error) -> Void in
                                                                                                                        
                                                                                                                            dispatch_resume(self.bigQue)
                                                                                                                            if let err = error {
                                                                                                                                print("ERROR ", err)
                                                                                                                            } else if let _ = result {
                                                                                                                                //print("New value:" + newItem["valueString"])
                                                                                                                            }
                                                                                                                        })
                                                                                                        
                                                                                                            
                                                                                                    
                                        
                                                                                                    

                                                                                                }
                                                                        
                                                    
                                                    
                                                } else {
                                                    
                                                    
                                                            //IF NO PREVIOUS ITEM FOUND, CREATE NEW ONE, ADD IT TO END OF SERIAL QUE
                                                    
                                                    
                                                                        if valueString != "Not-Completed"
                                                                        {
                                                                             self.insertNewItem(eventName, date: dateString, valueString:valueString, index: index)
                                                                        }
                                                                
                                                            
                                                    
                                                    
                                            }
                
                
        
        }
       
        
        }
    }
    
    
    
    func insertNewItem(eventName:String, date:String,valueString:String,index:UInt)
    {
        let item = ["eventName":eventName,"date":date,"valueString":valueString,"index":index]
        self.activityResultsTable!.insert(item as! [NSString : AnyObject]) {
            (insertedItem, errorOrNil) in
         
            dispatch_resume(self.bigQue)
             print("A")
            if let error = errorOrNil {
                print("Error" + error.description);
            } else {
                //let insertedItem = insertedItem as! Dictionary<String,String>
                print("Item inserted, id: " + (insertedItem!["id"]! as! String))
            }
        }

    }
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            self.serialQueue, closure)
    }

}