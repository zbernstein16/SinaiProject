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
    //MARK: Initialize
    
    required init?(coder aDecoder:NSCoder)
    {
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
        
        
        //TODO: Update this to database
        //If circle is filled, the value printed will be 1.
        //If circle is emptied, this will return a 2.
        self.checkValueOfEvent(interventionEvent)
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
        
//        //TODO: Implement Healthkit compatability
        
//        // Check assessment can be associated with a HealthKit sample.
//        if let healthSampleBuilder = sampleAssessment as? HealthSampleBuilder {
//            // Build the sample to save in the HealthKit store.
//            let sample = healthSampleBuilder.buildSampleWithTaskResult(taskViewController.result)
//            let sampleTypes: Set<HKSampleType> = [sample.sampleType]
//            
//            // Requst authorization to store the HealthKit sample.
//            let healthStore = HKHealthStore()
//            healthStore.requestAuthorizationToShareTypes(sampleTypes, readTypes: sampleTypes, completion: { success, _ in
//                // Check if authorization was granted.
//                if !success {
//                    /*
//                     Fall back to saving the simple `OCKCarePlanEventResult`
//                     in the `OCKCarePlanStore`.
//                     */
//                    self.completeEvent(event, inStore: self.storeManager.store, withResult: carePlanResult)
//                    return
//                }
//                
//                // Save the HealthKit sample in the HealthKit store.
//                healthStore.saveObject(sample, withCompletion: { success, _ in
//                    if success {
//                        /*
//                         The sample was saved to the HealthKit store. Use it
//                         to create an `OCKCarePlanEventResult` and save that
//                         to the `OCKCarePlanStore`.
//                         */
//                        let healthKitAssociatedResult = OCKCarePlanEventResult(
//                            quantitySample: sample,
//                            quantityStringFormatter: nil,
//                            displayUnit: healthSampleBuilder.unit,
//                            displayUnitStringKey: healthSampleBuilder.localizedUnitForSample(sample),
//                            userInfo: nil
//                        )
//                        
//                        self.completeEvent(event, inStore: self.storeManager.store, withResult: healthKitAssociatedResult)
//                    }
//                    else {
//                        /*
//                         Fall back to saving the simple `OCKCarePlanEventResult`
//                         in the `OCKCarePlanStore`.
//                         */
//                        self.completeEvent(event, inStore: self.storeManager.store, withResult: carePlanResult)
//                    }
//                    
//                })
//            })
//        }
//        else {
//            // Update the event with the result.
//            completeEvent(event, inStore: storeManager.store, withResult: carePlanResult)
//        }
    }
    
    // MARK: Convenience
    
    private func completeEvent(event: OCKCarePlanEvent, inStore store: OCKCarePlanStore, withResult result: OCKCarePlanEventResult) {
        store.updateEvent(event, withResult: result, state: .Completed) { success, _, error in
            
            if !success {
                print(error?.localizedDescription)
            }
        }
    }
}
