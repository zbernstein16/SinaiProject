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
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var client:MSClient?
    var adherenceTable:MSTable?
    
    
    let serialQueue = dispatch_queue_create("com.zachbern", DISPATCH_QUEUE_SERIAL)
    let bigQue = dispatch_queue_create("com.zachbern2", DISPATCH_QUEUE_SERIAL)
    
    //MARK: Initialize
    
    required init?(coder aDecoder:NSCoder)
    {
//        //SETUP AZURE CONNECTION
//        client = MSClient(
//            applicationURLString:"https://testcarekit.azurewebsites.net"
//        )
//        activityResultsTable = client!.tableWithName("ActivityResults")
        
        
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
         //Add contact
        //connectViewController = createConnectViewController()
        
        
        
        
        self.viewControllers = [
            UINavigationController(rootViewController: careCardViewController),
            UINavigationController(rootViewController: symptomTrackerViewController),
            UINavigationController(rootViewController: insightsViewController),UINavigationController(rootViewController: docViewController)
        ]
        
        storeManager.delegate = self
    }
    //MARK: Default View Methods
    
    override func viewDidLoad() {
        //Set survey completed to true
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "surveyCompleted")
    
        
        
        self.scheduleNotification()
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
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: #selector(refresh))
        
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Care Card", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"carecard"), selectedImage: UIImage(named: "carecard-filled"))
        
        return viewController
    }
    
   func createSymptomTrackerViewController() -> OCKSymptomTrackerViewController {
        let viewController = OCKSymptomTrackerViewController(carePlanStore:storeManager.store)
        viewController.delegate = self
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: #selector(refresh))
    
    
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
         viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Insert", style: .Plain, target: self, action: #selector(insertActivity))
        // Setup the controller's title and tab bar item
        viewController.title = NSLocalizedString("Insights", comment: "")
        viewController.tabBarItem = UITabBarItem(title: viewController.title, image: UIImage(named:"insights"), selectedImage: UIImage(named: "insights-filled"))
        
        return viewController
    }
    func refresh() {
        
        print("Refresh")
        //1: Query Patient-Med-Freq for all medications this person is taking
        //2: For each medication, construct the identifier by creating string Med_id/Freq e.g ibuprofen id =1, Freq 3 -> Identifier: 1/3
        //3: Check if medication exists with that identifier
        //4: If it does not, query through Medication table, tell storeManager to run method with given type of medication and pass argument to add new activity
        
        //1
        let userId = NSUserDefaults.standardUserDefaults().integerForKey(Constants.userIdKey)
        let predicate = NSPredicate(format:"Patient_id == \(userId)", argumentArray: nil)
        self.appDelegate.PatientMedFreqTable!.readWithPredicate(predicate)
        {
            results, errorOrNil in
            if let error = errorOrNil{
                fatalError(error.localizedDescription)
            }
            else if let results = results
            {
                for item in results.items
                {
                    let PatMedFreqDict = item as! Dictionary<String,AnyObject>
                    //2
                    let identifier = String("\(PatMedFreqDict["Med_id"]!)/\(PatMedFreqDict["Freq"]!)")
                    
                    //3
                    self.storeManager.store.activityForIdentifier(identifier) {
                        success, activity, errorOrNil in
                        if let error = errorOrNil {
                            fatalError(error.localizedDescription)
                        }
                        if let _ = activity
                        {
                            //Activity already exists, do nothing
                        }
                        else
                        {
                            //Tell Storemanager to handle new activity
                            self.storeManager.handleNewMedication(PatMedFreqDict)
                        }
                        
                    }
                }
            }
            
        }
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
           
            
//            var testString = "haha"
//            switch self.checkIfActivityExistsWithIdentifier(testString) {
//            case true:
//                //Activity already exists, dont do anything
//                break;
//            case false:
//                //Actiivty doesnt exist, we need to add it
//                print("Activity doesnt exist")
//                
//            }
//            
            
            
            
            
            
            
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
            }
        }
        
        
    }
    func checkIfActivityExistsWithIdentifier(identifier:String)  {
    
        storeManager.store.activityForIdentifier(identifier) { (success, activityOrNil, errorOrNil) -> Void in
            guard success else {
                // perform real error handling here.
                fatalError("*** An error occurred \(errorOrNil?.localizedDescription) ***")
            }
            
            if let _ = activityOrNil {
                
                //Do Nothing
                
            } else {
                
                //Add activity
                
            }
        }
        
    }
    func insertActivity() {
     
        
//        let newPatMedFreq = ["Patient_id":2,"Med_id":1,"Freq":2]
//        appDelegate.PatientMedFreqTable!.insert(newPatMedFreq) { (result, error) in
//            if let err = error {
//                print("ERROR ", err)
//            } else if let item = result {
//                print("Inserted new PatMedFreq")
//
//            }
//        }
        
        
        
        
        
    }
    
}



//MARK: Extensions


extension MainViewController: CarePlanStoreManagerDelegate {
    
    /// Called when the `CarePlanStoreManager`'s insights are updated.
    
    
    //Must Eventually add ability to incorporate Research Kit charts here
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
  
//        let components = interventionEvent.date // local date time: Jun 27, 2014, 9:32 AM
//        let dateString = String(components.month) + "/" + String(components.day) + "/" + String(components.year)
//        let index = interventionEvent.occurrenceIndexOfDay
//        var eventResult:String!
//        switch interventionEvent.state.rawValue {
//        case 0 | 1:
//            eventResult = "Completed"
//        default:
//            eventResult = "Not-Completed"
//        }
       
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
        }
        
    }
    
//MARK: Background Notification executes every minute while app is open
    func scheduleNotification() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        //SET UP JSON UPDATE NOTIFICATIONS
        let notif:UILocalNotification! = UILocalNotification()

        //Set up Daily Fire Schedule
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month,NSCalendarUnit.Year], fromDate: NSDate())
        components.hour = 0
        components.minute = 0
        components.second = 0
        calendar.timeZone = NSTimeZone.systemTimeZone()
        let dateToFire = calendar.dateFromComponents(components)!
        notif.fireDate = dateToFire
        notif.timeZone = NSTimeZone.systemTimeZone()
        notif.repeatInterval = NSCalendarUnit.Minute
        notif.category = "update"
        UIApplication.sharedApplication().scheduleLocalNotification(notif)
        
        
        //Set up Reminders Three times a day
        for i in 1..<4
        {
            let notif2:UILocalNotification! = UILocalNotification()
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month,NSCalendarUnit.Year], fromDate: NSDate())
            
            switch i {
            case 1:
                components.hour = 8
            case 2:
                components.hour = 12
            case 3:
                components.hour = 20
            default:
                break
            }
            components.minute = 0
            components.second = 0
            calendar.timeZone = NSTimeZone.systemTimeZone()
            let dateToFire = calendar.dateFromComponents(components)!
            notif2.fireDate = dateToFire
            notif2.timeZone = NSTimeZone.systemTimeZone()
            notif2.repeatInterval = NSCalendarUnit.Day
            notif2.alertTitle = "Medication alert:"
            notif2.alertBody = "Don't forget to report!"
            
            UIApplication.sharedApplication().scheduleLocalNotification(notif2)
        }
        
    }
   

}